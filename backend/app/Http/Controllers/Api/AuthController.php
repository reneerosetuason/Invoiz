<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Mail\EmailVerificationCode;
use App\Models\Cart;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validated = $request->validate([
            'last_name'      => ['required', 'string', 'max:100'],
            'first_name'     => ['required', 'string', 'max:100'],
            'middle_initial' => ['nullable', 'string', 'max:10'],
            'sex'            => ['required', Rule::in(['male', 'female', 'other'])],
            'email'          => ['required', 'email', 'max:150', 'unique:users,email'],
            'password'       => ['required', 'string', 'min:8', 'confirmed'],
            'phone'          => ['required', 'string', 'max:30'],
            'birthday'       => ['required', 'date', 'before:today'],
            'province'       => ['nullable', 'string', 'max:100'],
            'municipality'   => ['nullable', 'string', 'max:100'],
            'barangay'       => ['nullable', 'string', 'max:100'],
            'address_line'   => ['nullable', 'string', 'max:255'],
        ]);

        // Age auto-generated from birthday.
        $age = \Carbon\Carbon::parse($validated['birthday'])->age;

        $idImagePath = null;
        if ($request->hasFile('id_image')) {
            $idImagePath = $request->file('id_image')->store('ids', 'public');
        }

        $user = User::create([
            ...$validated,
            'age'             => $age,
            'id_image'        => $idImagePath,
            'approval_status' => 'pending',
            'role'            => 'buyer',
            'status'          => 'active',
        ]);

          // Create an empty cart so the buyer can add items right away after approval.
          Cart::create(['buyer_id' => $user->id]);

          // Send a 6-digit email verification code (valid 10 minutes).
          $this->issueCode($user);

          return response()->json([
              'message' => 'Registration submitted. We sent a 6-digit verification code to your email — enter it to verify your account.',
              'user'    => $user->only(['id', 'first_name', 'last_name', 'email', 'approval_status']),
              'verification_required' => true,
          ], 201);
      }

      /**
       * Issue (and email) a fresh 6-digit verification code.
       * Old unconsumed codes for the same email are discarded.
       */
      protected function issueCode(User $user): string
      {
          $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

          DB::table('email_verification_codes')
              ->where('email', $user->email)
              ->whereNull('consumed_at')
              ->delete();

          DB::table('email_verification_codes')->insert([
              'email'      => $user->email,
              'code'       => $code,
              'expires_at' => now()->addMinutes(10),
              'created_at' => now(),
              'updated_at' => now(),
          ]);

          try {
              Mail::to($user->email)->send(new EmailVerificationCode($user, $code));
          } catch (\Throwable $e) {
              // Never fail registration because of mail transport;
              // with MAIL_MAILER=log the code lands in storage/logs/laravel.log.
              Log::warning('Verification email failed for ' . $user->email . ': ' . $e->getMessage());
          }

          return $code;
      }

      /**
       * Verify the emailed 6-digit code: POST /verify-email {email, code}.
       */
      public function verifyEmail(Request $request)
      {
          $validated = $request->validate([
              'email' => ['required', 'email'],
              'code'  => ['required', 'string', 'size:6'],
          ]);

          $record = DB::table('email_verification_codes')
              ->where('email', $validated['email'])
              ->whereNull('consumed_at')
              ->latest('id')
              ->first();

          if (! $record) {
              return response()->json(['message' => 'No verification code found. Please request a new one.'], 422);
          }

          if (now()->greaterThan($record->expires_at)) {
              return response()->json(['message' => 'That code expired. Please request a new one.'], 422);
          }

          if ($record->attempts >= 5) {
              return response()->json(['message' => 'Too many wrong attempts. Please request a new code.'], 429);
          }

          if (! hash_equals($record->code, $validated['code'])) {
              DB::table('email_verification_codes')->where('id', $record->id)->increment('attempts');
              return response()->json(['message' => 'Wrong code. Check the 6 digits and try again.'], 422);
          }

          DB::table('email_verification_codes')->where('id', $record->id)->update([
              'consumed_at' => now(),
              'updated_at'  => now(),
          ]);

          User::where('email', $validated['email'])->update(['email_verified_at' => now()]);

          return response()->json([
              'message' => 'Email verified. Please wait for the administrator approval, which will be sent to your email.',
          ]);
      }

      /**
       * Resend a fresh code: POST /resend-code {email}. Max once per 60s.
       */
      public function resendCode(Request $request)
      {
          $validated = $request->validate(['email' => ['required', 'email']]);

          $user = User::where('email', $validated['email'])->first();
          if (! $user) {
              return response()->json(['message' => 'No account found for that email.'], 422);
          }
          if ($user->email_verified_at) {
              return response()->json(['message' => 'This email is already verified.'], 422);
          }

          $recent = DB::table('email_verification_codes')
              ->where('email', $user->email)
              ->where('created_at', '>', now()->subMinute())
              ->exists();
          if ($recent) {
              return response()->json(['message' => 'A code was just sent. Please wait a minute before requesting another.'], 429);
          }

          $this->issueCode($user);

          return response()->json(['message' => 'A new verification code was sent to your email.']);
      }

    public function login(Request $request)
    {
        $validated = $request->validate([
            'email'    => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $validated['email'])->first();

          if (! $user || ! Hash::check($validated['password'], $user->password)) {
              return response()->json(['message' => 'Invalid email or password.'], 401);
          }

          if (! $user->email_verified_at) {
              return response()->json([
                  'message' => 'Please verify your email first. Enter the 6-digit code we sent you.',
                  'verification_required' => true,
              ], 403);
          }

        if ($user->approval_status === 'pending') {
            return response()->json([
                'message' => 'Your account is still pending approval. Please wait for the administrator.',
            ], 403);
        }

        if ($user->approval_status === 'rejected') {
            return response()->json([
                'message' => 'Your registration was rejected. Please contact support.',
            ], 403);
        }

        if ($user->status !== 'active') {
            return response()->json(['message' => 'Your account is not active.'], 403);
        }

        $token = $user->createToken('invoiz-app')->plainTextToken;

        return response()->json([
            'message' => 'Login successful.',
            'token'   => $token,
            'user'    => array_merge(
                $user->only([
                    'id', 'first_name', 'last_name', 'middle_initial', 'email',
                    'sex', 'phone', 'birthday', 'age', 'role', 'approval_status',
                    'province', 'municipality', 'barangay', 'address_line', 'id_image',
                ]),
                ['seller' => $user->seller],
            ),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully.']);
    }

    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'user' => array_merge(
                $user->only([
                    'id', 'last_name', 'first_name', 'middle_initial', 'sex',
                    'email', 'phone', 'birthday', 'age', 'role', 'approval_status',
                    'province', 'municipality', 'barangay', 'address_line', 'id_image',
                ]),
                ['seller' => $user->seller],
            ),
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'last_name'      => ['sometimes', 'string', 'max:100'],
            'first_name'     => ['sometimes', 'string', 'max:100'],
            'middle_initial' => ['nullable', 'string', 'max:10'],
            'sex'            => ['sometimes', Rule::in(['male', 'female', 'other'])],
            'phone'          => ['sometimes', 'string', 'max:30'],
            'province'       => ['nullable', 'string', 'max:100'],
            'municipality'   => ['nullable', 'string', 'max:100'],
            'barangay'       => ['nullable', 'string', 'max:100'],
            'address_line'   => ['nullable', 'string', 'max:255'],
            'password'       => ['nullable', 'string', 'min:8', 'confirmed'],
        ]);

        if ($request->hasFile('id_image')) {
            if ($user->id_image) {
                Storage::disk('public')->delete($user->id_image);
            }
            $validated['id_image'] = $request->file('id_image')->store('ids', 'public');
        }

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);

        return response()->json([
            'message' => 'Profile updated successfully.',
            'user'    => $user->fresh()->only([
                'id', 'last_name', 'first_name', 'middle_initial', 'sex',
                'email', 'phone', 'birthday', 'age', 'role', 'approval_status',
                'province', 'municipality', 'barangay', 'address_line', 'id_image',
            ]),
        ]);
    }
}
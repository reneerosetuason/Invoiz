<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    protected static ?string $password;

    public function definition(): array
    {
        return [
            'last_name'       => fake()->lastName(),
            'first_name'      => fake()->firstName(),
            'sex'             => fake()->randomElement(['male', 'female']),
            'email'           => fake()->unique()->safeEmail(),
            'password'        => static::$password ??= Hash::make('password'),
            'phone'           => fake()->numerify('09########'),
            'birthday'        => fake()->date(),
            'age'             => fake()->numberBetween(18, 65),
            'approval_status' => 'approved',
            'role'            => 'buyer',
            'status'          => 'active',
            'remember_token'  => Str::random(10),
        ];
    }
}
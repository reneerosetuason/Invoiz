<?php

namespace App\Mail;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class EmailVerificationCode extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public User $user,
        public string $code,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Your Invoiz verification code: ' . $this->code,
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.verify-code',
            with: [
                'name' => $this->user->first_name,
                'code' => $this->code,
            ],
        );
    }
}

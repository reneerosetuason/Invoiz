<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family: Arial, sans-serif; background: #F7F6F2; padding: 24px;">
  <div style="max-width: 480px; margin: 0 auto; background: #ffffff; border-radius: 16px; padding: 32px; text-align: center;">
    <h2 style="color: #16697A; margin: 0 0 8px;">Welcome to Invoiz, {{ $name }}!</h2>
    <p style="color: #6E6E73; font-size: 14px;">Enter this verification code in the app to confirm your email address:</p>
    <div style="font-size: 36px; font-weight: 800; letter-spacing: 10px; color: #16697A; margin: 20px 0;">{{ $code }}</div>
    <p style="color: #6E6E73; font-size: 12px;">This code expires in 10 minutes. If you didn't register, just ignore this email.</p>
  </div>
</body>
</html>

const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API_KEY);
const fromEmail = process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev';
const appUrl = process.env.APP_URL || 'https://fe4raccoons.com';

function brandedHtml({ heading, body, ctaText, ctaUrl }) {
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;background:#FFF9F0;font-family:'Inter',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#FFF9F0;padding:40px 20px;">
    <tr><td align="center">
      <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;padding:40px;box-shadow:0 1px 3px rgba(44,44,44,0.04),0 4px 16px rgba(44,44,44,0.06);">
        <tr><td style="font-family:'DM Sans','Inter',Arial,sans-serif;font-size:22px;font-weight:700;color:#2C2C2C;padding-bottom:16px;letter-spacing:-0.02em;">
          ${heading}
        </td></tr>
        <tr><td style="font-size:15px;color:#5C584F;line-height:1.6;padding-bottom:28px;">
          ${body}
        </td></tr>
        <tr><td>
          <a href="${ctaUrl}" style="display:inline-block;background:#E8683A;color:#ffffff;font-family:'DM Sans','Inter',Arial,sans-serif;font-weight:600;font-size:15px;padding:12px 32px;border-radius:10px;text-decoration:none;">
            ${ctaText}
          </a>
        </td></tr>
        <tr><td style="padding-top:28px;font-size:13px;color:#A09C93;line-height:1.5;">
          If you didn't request this, you can safely ignore this email.
        </td></tr>
      </table>
      <p style="margin-top:24px;font-size:12px;color:#A09C93;">FE for Raccoons &mdash; fe4raccoons.com</p>
    </td></tr>
  </table>
</body>
</html>`.trim();
}

async function sendPasswordResetEmail(toEmail, rawToken) {
  try {
    await resend.emails.send({
      from: `FE for Raccoons <${fromEmail}>`,
      to: toEmail,
      subject: 'Reset your password',
      html: brandedHtml({
        heading: 'Reset Your Password',
        body: 'We received a request to reset your password. Click the button below to choose a new one. This link expires in 1 hour.',
        ctaText: 'Reset Password',
        ctaUrl: `${appUrl}/reset-password/${rawToken}`,
      }),
    });
  } catch (err) {
    console.error('[email] Failed to send password reset:', err.message);
  }
}

async function sendVerificationEmail(toEmail, rawToken) {
  try {
    await resend.emails.send({
      from: `FE for Raccoons <${fromEmail}>`,
      to: toEmail,
      subject: 'Verify your email',
      html: brandedHtml({
        heading: 'Verify Your Email',
        body: 'Thanks for signing up! Please verify your email address to get the most out of your account.',
        ctaText: 'Verify Email',
        ctaUrl: `${appUrl}/verify-email/${rawToken}`,
      }),
    });
  } catch (err) {
    console.error('[email] Failed to send verification:', err.message);
  }
}

module.exports = { sendPasswordResetEmail, sendVerificationEmail };

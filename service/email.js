const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API_KEY);
const fromEmail = process.env.RESEND_FROM_EMAIL || 'onboarding@resend.dev';
const appUrl = process.env.APP_URL || 'https://fe4raccoons.com';
const fromHeader = `FE for Raccoons <${fromEmail}>`;

const usingTestSender = fromEmail === 'onboarding@resend.dev';
if (usingTestSender) {
  // Loud, once-at-startup warning. The Resend test sender ONLY delivers to the
  // Resend account owner's own address — every other recipient is rejected, so
  // real users never get verification / reset / student-code emails. Set
  // RESEND_FROM_EMAIL to an address on a domain verified at resend.com/domains.
  console.warn(
    '[email] WARNING: RESEND_FROM_EMAIL is unset — using onboarding@resend.dev. ' +
    'This only delivers to the Resend account owner. Verify a domain and set ' +
    'RESEND_FROM_EMAIL so real users receive email.',
  );
}

// Low-level send. Returns { ok, id?, error? } — never throws — so callers can
// decide how to react (analytics never breaks a flow, but the student-code
// flow needs to know whether the code actually went out).
async function sendEmail({ to, subject, html }) {
  try {
    const r = await resend.emails.send({ from: fromHeader, to, subject, html });
    if (r.error) {
      console.error(`[email] send to ${to} rejected:`, r.error.message);
      return { ok: false, error: r.error.message };
    }
    return { ok: true, id: r.data?.id };
  } catch (err) {
    console.error(`[email] send to ${to} threw:`, err.message);
    return { ok: false, error: err.message };
  }
}

function brandedShell(inner) {
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;background:#FFF9F0;font-family:'Inter',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#FFF9F0;padding:40px 20px;">
    <tr><td align="center">
      <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;padding:40px;box-shadow:0 1px 3px rgba(44,44,44,0.04),0 4px 16px rgba(44,44,44,0.06);">
        ${inner}
      </table>
      <p style="margin-top:24px;font-size:12px;color:#A09C93;">FE for Raccoons &mdash; fe4raccoons.com</p>
    </td></tr>
  </table>
</body>
</html>`.trim();
}

function ctaEmail({ heading, body, ctaText, ctaUrl }) {
  return brandedShell(`
    <tr><td style="font-family:'DM Sans','Inter',Arial,sans-serif;font-size:22px;font-weight:700;color:#2C2C2C;padding-bottom:16px;letter-spacing:-0.02em;">${heading}</td></tr>
    <tr><td style="font-size:15px;color:#5C584F;line-height:1.6;padding-bottom:28px;">${body}</td></tr>
    <tr><td>
      <a href="${ctaUrl}" style="display:inline-block;background:#E8683A;color:#ffffff;font-family:'DM Sans','Inter',Arial,sans-serif;font-weight:600;font-size:15px;padding:12px 32px;border-radius:10px;text-decoration:none;">${ctaText}</a>
    </td></tr>
    <tr><td style="padding-top:28px;font-size:13px;color:#A09C93;line-height:1.5;">If you didn't request this, you can safely ignore this email.</td></tr>`);
}

function codeEmail({ heading, body, code }) {
  return brandedShell(`
    <tr><td style="font-family:'DM Sans','Inter',Arial,sans-serif;font-size:22px;font-weight:700;color:#2C2C2C;padding-bottom:16px;letter-spacing:-0.02em;">${heading}</td></tr>
    <tr><td style="font-size:15px;color:#5C584F;line-height:1.6;padding-bottom:24px;">${body}</td></tr>
    <tr><td align="center" style="padding-bottom:24px;">
      <div style="display:inline-block;background:#FEF0EA;border:1px solid #F6C9B6;border-radius:12px;padding:16px 28px;font-family:'JetBrains Mono','Courier New',monospace;font-size:34px;font-weight:700;letter-spacing:10px;color:#E8683A;">${code}</div>
    </td></tr>
    <tr><td style="font-size:13px;color:#A09C93;line-height:1.5;">This code expires in 15 minutes. If you didn't request it, you can ignore this email.</td></tr>`);
}

async function sendPasswordResetEmail(toEmail, rawToken) {
  return sendEmail({
    to: toEmail,
    subject: 'Reset your password',
    html: ctaEmail({
      heading: 'Reset Your Password',
      body: 'We received a request to reset your password. Click the button below to choose a new one. This link expires in 1 hour.',
      ctaText: 'Reset Password',
      ctaUrl: `${appUrl}/reset-password/${rawToken}`,
    }),
  });
}

async function sendVerificationEmail(toEmail, rawToken) {
  return sendEmail({
    to: toEmail,
    subject: 'Verify your email',
    html: ctaEmail({
      heading: 'Verify Your Email',
      body: 'Thanks for signing up! Please verify your email address to get the most out of your account.',
      ctaText: 'Verify Email',
      ctaUrl: `${appUrl}/verify-email/${rawToken}`,
    }),
  });
}

// Student-discount verification: a 6-digit code to prove the student controls
// an academic inbox before the discounted price is unlocked.
async function sendStudentCodeEmail(toEmail, code) {
  return sendEmail({
    to: toEmail,
    subject: `${code} is your FE for Raccoons student code`,
    html: codeEmail({
      heading: 'Verify Your Student Email',
      body: 'Enter this code on FE for Raccoons to unlock the student price on the Exam Simulation:',
      code,
    }),
  });
}

// Admin diagnostic: send a test email and report the raw result.
async function sendTestEmail(toEmail) {
  return sendEmail({
    to: toEmail,
    subject: 'FE for Raccoons — email delivery test',
    html: ctaEmail({
      heading: 'Email is working',
      body: 'If you can read this, transactional email delivery is configured correctly.',
      ctaText: 'Open FE for Raccoons',
      ctaUrl: appUrl,
    }),
  });
}

function getEmailConfig() {
  return { from: fromEmail, usingTestSender, appUrl };
}

module.exports = {
  sendPasswordResetEmail,
  sendVerificationEmail,
  sendStudentCodeEmail,
  sendTestEmail,
  getEmailConfig,
};

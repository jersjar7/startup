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

/* ── Branded templates ──────────────────────────────────────────────────────
   Email clients are hostile: no <style>/flexbox reliability, images blocked by
   default, custom fonts mostly unsupported. So the layout is table-based with
   inline styles, the brand wordmark is rendered as TEXT (always visible, no
   blocked image), and fonts degrade gracefully to Arial. Colors/voice follow
   the FE for Raccoons brand. */
const C = {
  ember: '#E8683A', charcoal: '#2C2C2C', cream: '#FFF9F0', card: '#FFFFFF',
  body: '#5C584F', mute: '#A09C93', line: '#F0E9DB', emberBg: '#FEF0EA', emberLine: '#F6C9B6',
};
const SANS = "'DM Sans','Helvetica Neue',Arial,sans-serif";
const BODYF = "'Inter','Helvetica Neue',Arial,sans-serif";
const MONO = "'JetBrains Mono','SFMono-Regular',Consolas,'Courier New',monospace";

function emailLayout({ preheader = '', heading, inner }) {
  return `<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="color-scheme" content="light only">
<title>${heading}</title>
</head>
<body style="margin:0;padding:0;background:${C.cream};-webkit-font-smoothing:antialiased;">
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;color:${C.cream};font-size:1px;line-height:1px;">${preheader}</div>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:${C.cream};">
    <tr><td align="center" style="padding:40px 16px;">
      <table role="presentation" width="520" cellpadding="0" cellspacing="0" style="width:520px;max-width:100%;">
        <tr><td align="center" style="padding-bottom:22px;">
          <span style="font-family:${SANS};font-weight:700;font-size:30px;letter-spacing:-1px;color:${C.charcoal};">FE<span style="color:${C.ember};">4</span></span>
          <span style="font-family:${SANS};font-weight:700;font-size:12px;letter-spacing:5px;color:${C.charcoal};margin-left:9px;">RACCOONS</span>
        </td></tr>
        <tr><td style="background:${C.card};border-radius:16px;border-top:4px solid ${C.ember};box-shadow:0 1px 3px rgba(44,44,44,0.04),0 6px 22px rgba(44,44,44,0.07);padding:40px 40px 36px;">
          <h1 style="margin:0 0 16px;font-family:${SANS};font-weight:700;font-size:23px;line-height:1.25;letter-spacing:-0.02em;color:${C.charcoal};">${heading}</h1>
          ${inner}
        </td></tr>
        <tr><td align="center" style="padding:22px 24px 0;">
          <p style="margin:0;font-family:${BODYF};font-size:12px;line-height:1.6;color:${C.mute};">
            FE for Raccoons &mdash; free FE Civil exam prep<br>
            <a href="${appUrl}" style="color:${C.mute};text-decoration:underline;">fe4raccoons.com</a>
          </p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body></html>`;
}

function para(html, extra = '') {
  return `<p style="margin:0 0 18px;font-family:${BODYF};font-size:15px;line-height:1.6;color:${C.body};${extra}">${html}</p>`;
}

function button(text, url) {
  return `<table role="presentation" cellpadding="0" cellspacing="0" style="margin:4px 0 22px;"><tr>
    <td align="center" bgcolor="${C.ember}" style="border-radius:10px;">
      <a href="${url}" target="_blank" style="display:inline-block;padding:13px 36px;font-family:${SANS};font-weight:600;font-size:15px;line-height:1;color:#ffffff;text-decoration:none;border-radius:10px;">${text}</a>
    </td></tr></table>`;
}

function fallbackLink(url) {
  return `<p style="margin:0 0 4px;font-family:${BODYF};font-size:12px;line-height:1.5;color:${C.mute};">Or paste this link into your browser:</p>
  <p style="margin:0;font-family:${MONO};font-size:12px;line-height:1.5;word-break:break-all;color:${C.ember};">${url}</p>`;
}

function noteLine(html) {
  return `<p style="margin:22px 0 0;padding-top:18px;border-top:1px solid ${C.line};font-family:${BODYF};font-size:13px;line-height:1.5;color:${C.mute};">${html}</p>`;
}

function ctaEmail({ heading, body, ctaText, ctaUrl, note }) {
  return emailLayout({
    preheader: body.replace(/<[^>]+>/g, '').slice(0, 100),
    heading,
    inner: `${para(body)}${button(ctaText, ctaUrl)}${fallbackLink(ctaUrl)}${noteLine(note || "If you didn't request this, you can safely ignore this email.")}`,
  });
}

function codeEmail({ heading, body, code }) {
  const block = `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:6px 0 18px;"><tr>
    <td align="center" style="background:${C.emberBg};border:1px solid ${C.emberLine};border-radius:12px;padding:20px 0;">
      <span style="font-family:${MONO};font-size:34px;font-weight:700;letter-spacing:12px;color:${C.ember};padding-left:12px;">${code}</span>
    </td></tr></table>`;
  return emailLayout({
    preheader: `Your verification code is ${code}`,
    heading,
    inner: `${para(body)}${block}${noteLine("This code expires in 15 minutes. If you didn't request it, you can ignore this email.")}`,
  });
}

async function sendPasswordResetEmail(toEmail, rawToken) {
  return sendEmail({
    to: toEmail,
    subject: 'Reset your FE for Raccoons password',
    html: ctaEmail({
      heading: 'Reset your password',
      body: 'We got a request to reset your password. Tap the button below to choose a new one — this link expires in 1 hour.',
      ctaText: 'Reset password',
      ctaUrl: `${appUrl}/reset-password/${rawToken}`,
    }),
  });
}

async function sendVerificationEmail(toEmail, rawToken) {
  return sendEmail({
    to: toEmail,
    subject: 'Verify your email — FE for Raccoons',
    html: ctaEmail({
      heading: 'Verify your email',
      body: "Welcome to FE for Raccoons! Confirm your email to secure your account and keep your streak, XP, and progress synced everywhere.",
      ctaText: 'Verify email',
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
      heading: 'Verify your student email',
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
      body: 'If you can read this, transactional email delivery is configured correctly and on-brand.',
      ctaText: 'Open FE for Raccoons',
      ctaUrl: appUrl,
      note: 'This is a test email sent from the admin panel.',
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

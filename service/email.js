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
async function sendEmail({ to, subject, html, headers }) {
  try {
    const payload = { from: fromHeader, to, subject, html };
    if (headers) payload.headers = headers;
    const r = await resend.emails.send(payload);
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

function emailLayout({ preheader = '', heading, inner, unsubUrl = '' }) {
  const unsub = unsubUrl
    ? `<br><a href="${unsubUrl}" style="color:${C.mute};text-decoration:underline;">Unsubscribe from these emails</a>`
    : '';
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
            <a href="${appUrl}" style="color:${C.mute};text-decoration:underline;">fe4raccoons.com</a>${unsub}
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

/* ── Lifecycle emails (welcome / weekly digest / win-back) ───────────────────
   These are engagement emails, not transactional, so they carry an unsubscribe
   link + List-Unsubscribe headers for one-click opt-out and sender reputation. */
function lifecycleHeaders(unsubUrl) {
  return {
    'List-Unsubscribe': `<${unsubUrl}>`,
    'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
  };
}

function bullets(items) {
  const rows = items.filter(Boolean).map((i) =>
    `<tr><td style="padding:3px 0;font-family:${BODYF};font-size:15px;line-height:1.5;color:${C.body};"><span style="color:${C.ember};font-weight:700;">&bull;</span>&nbsp;&nbsp;${i}</td></tr>`).join('');
  return `<table role="presentation" cellpadding="0" cellspacing="0" style="margin:0 0 22px;">${rows}</table>`;
}

// Humanize a chapter key for display ('water-resources' -> 'Water Resources').
function chapterLabel(key) {
  if (!key) return '';
  return /[-_]/.test(key)
    ? key.replace(/[-_]+/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase())
    : key;
}

// Sent the morning after a user verifies. Adaptive: if they already took the
// diagnostic, point them at their next study session instead of nagging them to
// do something they've done; otherwise, get them to the diagnostic.
async function sendWelcomeEmail(toEmail, { unsubUrl, diagnosticDone = false, focusChapter = null } = {}) {
  if (diagnosticDone) {
    const focus = chapterLabel(focusChapter);
    return sendEmail({
      to: toEmail,
      subject: 'Your study plan is ready',
      headers: lifecycleHeaders(unsubUrl),
      html: emailLayout({
        preheader: 'Nice start — here\'s your best next move.',
        heading: 'Your plan is ready.',
        unsubUrl,
        inner:
          para('Great start — your diagnostic is done, so your study plan is built around your real weak spots.') +
          (focus
            ? para(`<strong>Best place to begin: ${focus}</strong> — it\'s your lowest area right now, so it\'s where focused practice moves your score the most.`)
            : para('Jump back in and start with your lowest-mastery chapter — that\'s where focused practice moves your score the most.')) +
          button('Start studying', `${appUrl}/dashboard`) +
          para(`<span style="font-size:13px;color:${C.mute};">Everything here is free — lessons, 1,126 problems, your plan. The only paid thing is the full timed exam sim, if you ever want it.</span>`),
      }),
    });
  }
  return sendEmail({
    to: toEmail,
    subject: 'Start with the 5-minute diagnostic',
    headers: lifecycleHeaders(unsubUrl),
    html: emailLayout({
      preheader: 'Find your weak spots before you study a thing.',
      heading: "Welcome — let's pass the FE.",
      unsubUrl,
      inner:
        para('The smartest first move is the <strong>free diagnostic</strong>. About 5 minutes, and it builds your study plan around your weak spots — so you study what actually moves your score.') +
        button('Take the diagnostic', `${appUrl}/diagnostic`) +
        para(`<span style="font-size:13px;color:${C.mute};">Everything here is free — lessons, 1,126 problems, the diagnostic. The only paid thing is the full timed exam sim, if you ever want it.</span>`),
    }),
  });
}

// Sent the morning after signup if the account is still unverified — one nudge
// (with a fresh link) so a missed/spam'd first email doesn't lose the user.
async function sendVerifyReminderEmail(toEmail, rawToken) {
  return sendEmail({
    to: toEmail,
    subject: 'Finish setting up your FE for Raccoons account',
    html: ctaEmail({
      heading: 'One step left — verify your email',
      body: "You created an account but haven't verified your email yet. Confirm it to secure your account and keep your streak, XP, and progress synced everywhere.",
      ctaText: 'Verify email',
      ctaUrl: `${appUrl}/verify-email/${rawToken}`,
      note: "If you didn't create this account, you can ignore this email.",
    }),
  });
}

// Weekly recap (Sunday morning). Active users get the upbeat version; inactive
// users get a gentle restart so they don't just see a wall of zeros.
async function sendWeeklyDigestEmail(toEmail, d = {}) {
  const { active, weeklyXp = 0, streak = 0, problems = 0, masteryTo = null, focusChapter = null, unsubUrl } = d;
  let subject; let heading; let inner; let preheader;
  if (active) {
    subject = `Your week: ${weeklyXp} XP, ${streak}-day streak`;
    preheader = `${problems} problems solved this week`;
    heading = 'Your week in review';
    inner =
      bullets([
        `<strong>${weeklyXp}</strong> XP earned`,
        `<strong>${problems}</strong> problem${problems === 1 ? '' : 's'} solved`,
        `<strong>${streak}</strong>-day streak`,
        masteryTo != null ? `Overall mastery: <strong>${masteryTo}%</strong>` : null,
      ]) +
      (focusChapter ? para(`<strong>Focus next week:</strong> ${focusChapter} — your weakest area right now.`) : '') +
      button('Continue studying', `${appUrl}/dashboard`);
  } else {
    subject = 'Your FE goal is still here';
    preheader = 'A 5-minute restart';
    heading = 'Your FE goal is still here';
    inner =
      para(`No study time logged this week — that's okay. Five minutes today restarts the momentum.${focusChapter ? ` Your weakest area right now is <strong>${focusChapter}</strong>.` : ''}`) +
      button('Study 5 questions', `${appUrl}/dashboard`);
  }
  return sendEmail({ to: toEmail, subject, headers: lifecycleHeaders(unsubUrl), html: emailLayout({ preheader, heading, inner, unsubUrl }) });
}

// Exam-date countdown. Copy adapts to how close exam day is.
async function sendExamCountdownEmail(toEmail, { daysLeft, readiness = null, focusChapter = null, unsubUrl } = {}) {
  let subject; let heading; let body; let ctaText;
  if (daysLeft <= 0) {
    subject = "It's exam day — you've got this";
    heading = "Today's the day";
    body = "Trust your prep. Read each question carefully, lean on the Handbook, and keep moving — don't get stuck on any one problem. You've put in the work. Go pass the FE.";
    ctaText = null;
  } else if (daysLeft === 1) {
    subject = 'Your FE exam is tomorrow';
    heading = 'One day to go';
    body = `Keep it light today, then rest.${focusChapter ? ` If you review one thing, make it <strong>${focusChapter}</strong>.` : ''} A good night's sleep beats late cramming — you're ready.`;
    ctaText = 'Review your weak areas';
  } else {
    subject = `Your FE exam is in ${daysLeft} days`;
    heading = `${daysLeft} days to exam day`;
    const rd = readiness != null ? `You're at <strong>${readiness}% readiness</strong>. ` : '';
    body = `${rd}${focusChapter
      ? `Your biggest score lever right now is <strong>${focusChapter}</strong> — point your next few sessions there.`
      : 'Keep your streak going and drill your weakest chapters between now and exam day.'}`;
    ctaText = 'Keep studying';
  }
  return sendEmail({
    to: toEmail,
    subject,
    headers: lifecycleHeaders(unsubUrl),
    html: emailLayout({
      preheader: daysLeft <= 0 ? 'Go pass the FE.' : `${daysLeft} days to go`,
      heading,
      unsubUrl,
      inner: para(body) + (ctaText ? button(ctaText, `${appUrl}/dashboard`) : ''),
    }),
  });
}

// One-time nudge for users who've gone quiet (~7 days).
async function sendWinbackEmail(toEmail, { focusChapter = null, unsubUrl } = {}) {
  return sendEmail({
    to: toEmail,
    subject: 'Still aiming for the FE?',
    headers: lifecycleHeaders(unsubUrl),
    html: emailLayout({
      preheader: 'Your account is right where you left it.',
      heading: 'Still aiming for the FE?',
      unsubUrl,
      inner:
        para(`Your account's right where you left it. The fastest restart: 5 questions in your weakest chapter${focusChapter ? ` (<strong>${focusChapter}</strong>)` : ''}.`) +
        button('Resume studying', `${appUrl}/dashboard`),
    }),
  });
}

function getEmailConfig() {
  return { from: fromEmail, usingTestSender, appUrl };
}

module.exports = {
  sendPasswordResetEmail,
  sendVerificationEmail,
  sendVerifyReminderEmail,
  sendStudentCodeEmail,
  sendTestEmail,
  sendWelcomeEmail,
  sendWeeklyDigestEmail,
  sendWinbackEmail,
  sendExamCountdownEmail,
  getEmailConfig,
};

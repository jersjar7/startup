const express = require('express');
const { userCollection } = require('../db/connection.js');
const { isAnswered } = require('../examOutcome.js');
const {
  parseAnswer,
  outcomeUpdate,
  shouldRecord,
  validAttempt,
  resultCopy,
} = require('../examResultLink.js');

const router = express.Router();

const C = { ember: '#E8683A', charcoal: '#2C2C2C', cream: '#FFF9F0', body: '#5C584F', mute: '#A09C93' };
const appUrl = () => process.env.APP_URL || 'https://fe4raccoons.com';

/// The landing page every tokenised email link renders.
///
/// [extra] is raw HTML appended under the message, used by the exam result
/// page to offer the one optional follow-up without a second page.
function page({ ok, heading, msg, extra = '' }) {
  const url = appUrl();
  heading = heading || (ok ? "You're unsubscribed" : 'Link not found');
  msg = msg || (ok
    ? "You won't get welcome, weekly, or re-engagement emails anymore. You'll still get important account emails (verification, password reset). Changed your mind? Email support and we'll turn them back on."
    : "That unsubscribe link wasn't recognized — it may already have been used. If you keep getting emails you don't want, contact support.");
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>${heading} — FE for Raccoons</title></head>
<body style="margin:0;background:${C.cream};font-family:'Inter','Helvetica Neue',Arial,sans-serif;">
<div style="max-width:480px;margin:64px auto;padding:0 20px;text-align:center;">
  <div style="font-family:'DM Sans',Arial,sans-serif;font-weight:700;font-size:26px;letter-spacing:-1px;color:${C.charcoal};margin-bottom:28px;">FE<span style="color:${C.ember};">4</span> <span style="font-size:12px;letter-spacing:4px;">RACCOONS</span></div>
  <div style="background:#fff;border-radius:16px;border-top:4px solid ${C.ember};box-shadow:0 6px 22px rgba(44,44,44,0.07);padding:36px 32px;">
    <h1 style="font-family:'DM Sans',Arial,sans-serif;font-size:22px;color:${C.charcoal};margin:0 0 14px;">${heading}</h1>
    <p style="font-size:15px;line-height:1.6;color:${C.body};margin:0 0 24px;">${msg}</p>
    ${extra}
    <a href="${url}" style="display:inline-block;background:${C.ember};color:#fff;font-family:'DM Sans',Arial,sans-serif;font-weight:600;font-size:15px;padding:12px 28px;border-radius:10px;text-decoration:none;">Back to FE for Raccoons</a>
  </div>
</div></body></html>`;
}

// GET /api/email/unsubscribe/:token — one-click opt-out from lifecycle emails.
// (GET so email "unsubscribe" links and Gmail's List-Unsubscribe both work.)
router.get('/unsubscribe/:token', async (req, res) => {
  let ok = false;
  try {
    const r = await userCollection.updateOne(
      { unsubToken: req.params.token },
      { $set: { lifecycleOptOut: true, lifecycleOptOutAt: new Date() } },
    );
    ok = r.matchedCount > 0;
  } catch (e) {
    console.error('[email/unsubscribe] failed:', e.message);
  }
  res.status(ok ? 200 : 404).type('html').send(page({ ok }));
});

// POST — Gmail one-click List-Unsubscribe-Post sends here.
router.post('/unsubscribe/:token', async (req, res) => {
  try {
    await userCollection.updateOne(
      { unsubToken: req.params.token },
      { $set: { lifecycleOptOut: true, lifecycleOptOutAt: new Date() } },
    );
  } catch (e) {
    console.error('[email/unsubscribe] failed:', e.message);
  }
  res.status(200).end();
});

// GET /api/email/exam-result/:token?a=passed|failed|missed
//
// One tap from the email records the answer and nothing else is asked. No sign
// in, because requiring one would lose most of the replies and the whole point
// of this question is that non-response is biased: somebody who failed is less
// likely to come back and log in to say so.
//
// GET rather than POST because an email client can only produce a GET, and the
// token is a capability: unguessable, per user, and separate from the
// unsubscribe token so a leaked unsubscribe link cannot also write data.
//
// Idempotent. A second tap, or a mail client prefetching the link, cannot
// overwrite a real answer.
router.get('/exam-result/:token', async (req, res) => {
  const copyFor = (already) => resultCopy(req.query.a, { already });
  if (!parseAnswer(req.query.a)) {
    return res.status(400).type('html').send(page({ ok: false }));
  }

  let user = null;
  try {
    user = await userCollection.findOne(
      { outcomeToken: req.params.token },
      { projection: { email: 1, examOutcome: 1, examDate: 1 } },
    );
    if (shouldRecord(user, req.query.a)) {
      await userCollection.updateOne(
        { outcomeToken: req.params.token },
        { $set: outcomeUpdate(req.query.a, { examDate: user.examDate || null }) },
      );
    }
  } catch (e) {
    console.error('[email/exam-result] failed:', e.message);
  }

  if (!user) {
    return res.status(404).type('html').send(page({
      ok: false,
      heading: 'Link not found',
      msg: 'That link has expired. You can tell us from inside the app any time.',
    }));
  }

  const copy = copyFor(isAnswered(user));
  const extra = copy.offerAttempt ? attemptButtons(req.params.token) : '';
  res.status(200).type('html').send(
    page({ ok: true, heading: copy.heading, msg: copy.msg, extra }),
  );
});

function attemptButtons(token) {
  const labels = { 1: 'First', 2: 'Second', 3: 'Third or more' };
  const links = [1, 2, 3].map((n) =>
    `<a href="${appUrl()}/api/email/exam-attempt/${token}?n=${n}" style="display:inline-block;margin:0 5px 8px;padding:10px 18px;border:1.5px solid ${C.ember};border-radius:999px;color:${C.ember};font-family:'DM Sans',Arial,sans-serif;font-weight:600;font-size:14px;text-decoration:none;">${labels[n]}</a>`
  ).join('');
  return `<p style="font-size:14px;color:${C.mute};margin:4px 0 12px;">One optional extra: which attempt was it?</p>
          <div style="margin:0 0 22px;">${links}</div>`;
}

// The optional second tap. Never required, and it cannot change the result.
router.get('/exam-attempt/:token', async (req, res) => {
  const n = validAttempt(req.query.n);
  let ok = false;
  try {
    if (n !== null) {
      const r = await userCollection.updateOne(
        { outcomeToken: req.params.token, 'examOutcome.answeredAt': { $exists: true } },
        { $set: { 'examOutcome.attemptNumber': n } },
      );
      ok = r.matchedCount > 0;
    }
  } catch (e) {
    console.error('[email/exam-attempt] failed:', e.message);
  }
  res.status(ok ? 200 : 404).type('html').send(
    page({ ok, heading: ok ? 'Noted' : 'Link not found', msg: ok ? 'That is everything. Thank you.' : undefined }),
  );
});

module.exports = router;

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
const { canSeeCard, cardPayload, cardNameUpdate } = require('../passCardAccess.js');

// Apple's Smart App Banner: on an iPhone that has the app but opened this
// page in Safari anyway, one tap across (ADR 0023). Ignored everywhere else.
const APP_STORE_ID = '6800350588';

// The app opens these same links when the email is read on a phone that has
// it (ADR 0023), and asks for JSON instead of the page. Everything else about
// the request, the recording above all, is identical.
function wantsJson(req) {
  return req.query.format === 'json' || /application\/json/.test(req.get('accept') || '');
}

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
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="apple-itunes-app" content="app-id=${APP_STORE_ID}">
<title>${heading} — FE for Raccoons</title></head>
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
    if (wantsJson(req)) return res.status(400).send({ ok: false, msg: 'That link is not one of ours.' });
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
    if (wantsJson(req)) return res.status(404).send({ ok: false, msg: 'That link has expired.' });
    return res.status(404).type('html').send(page({
      ok: false,
      heading: 'Link not found',
      msg: 'That link has expired. You can tell us from inside the app any time.',
    }));
  }

  const copy = copyFor(isAnswered(user));
  if (wantsJson(req)) {
    // Re-read so the app sees what was just recorded, not the state before it.
    const now = await userCollection.findOne(
      { outcomeToken: req.params.token },
      { projection: { examOutcome: 1 } },
    ).catch(() => null);
    return res.status(200).send({
      ok: true,
      answer: req.query.a,
      already: isAnswered(user),
      heading: copy.heading,
      msg: copy.msg,
      card: canSeeCard(now || user),
      offerAttempt: Boolean(copy.offerAttempt),
    });
  }
  // A pass earns the card, and it is offered above the attempt question: the
  // reward comes before the second piece of research, not after it.
  const card = canSeeCard(user) ? cardButton(req.params.token) : '';
  const extra = card + (copy.offerAttempt ? attemptButtons(req.params.token) : '');
  res.status(200).type('html').send(
    page({ ok: true, heading: copy.heading, msg: copy.msg, extra }),
  );
});

function cardButton(token) {
  return `<p style="font-size:15px;line-height:1.6;color:${C.body};margin:0 0 16px;">You have
            something to show for it. Take the card.</p>
          <div style="margin:0 0 26px;">
            <a href="${appUrl()}/pass-card/${token}" style="display:inline-block;background:${C.ember};color:#fff;font-family:'DM Sans',Arial,sans-serif;font-weight:600;font-size:15px;padding:13px 30px;border-radius:10px;text-decoration:none;">Get my card</a>
          </div>`;
}

function attemptButtons(token) {
  const labels = { 1: 'First', 2: 'Second', 3: 'Third or more' };
  const links = [1, 2, 3].map((n) =>
    `<a href="${appUrl()}/api/email/exam-attempt/${token}?n=${n}" style="display:inline-block;margin:0 5px 8px;padding:10px 18px;border:1.5px solid ${C.ember};border-radius:999px;color:${C.ember};font-family:'DM Sans',Arial,sans-serif;font-weight:600;font-size:14px;text-decoration:none;">${labels[n]}</a>`
  ).join('');
  return `<p style="font-size:14px;color:${C.mute};margin:4px 0 12px;">One optional extra: which attempt was it?</p>
          <div style="margin:0 0 22px;">${links}</div>`;
}

// GET /api/email/pass-card/:token — what the card page needs to draw itself.
//
// No sign in, deliberately. The reward for passing has to arrive in the same
// tap as the answer or most people never see it, and this is only safe because
// the card carries nothing private: a name, a month, and the exam's own chapter
// list. See service/passCardAccess.js.
router.get('/pass-card/:token', async (req, res) => {
  let user = null;
  try {
    user = await userCollection.findOne(
      { outcomeToken: req.params.token },
      { projection: { firstName: 1, lastName: 1, cardName: 1, examOutcome: 1 } },
    );
  } catch (e) {
    console.error('[email/pass-card] lookup failed:', e.message);
    return res.status(503).send({ msg: 'Could not load your card. Try again in a moment.' });
  }
  const payload = cardPayload(user);
  // One answer for "no such token" and for "did not pass", so the endpoint
  // cannot be used to find out whether a given token belongs to a passer.
  if (!payload) return res.status(404).send({ msg: 'No card here.' });
  res.status(200).send(payload);
});

// POST /api/email/pass-card/:token/name — the name the card prints.
//
// Always saved as the card's own name (ADR 0023). The account's name is filled
// only when it is blank: a forwarded email must not let somebody else rename
// the account, and changing a name that exists stays behind a sign in.
router.post('/pass-card/:token/name', async (req, res) => {
  let user = null;
  try {
    user = await userCollection.findOne(
      { outcomeToken: req.params.token },
      { projection: { firstName: 1, lastName: 1, cardName: 1, examOutcome: 1 } },
    );
  } catch (e) {
    console.error('[email/pass-card/name] lookup failed:', e.message);
    return res.status(503).send({ msg: 'Could not save that. Try again in a moment.' });
  }
  if (!canSeeCard(user)) return res.status(404).send({ msg: 'No card here.' });
  const set = cardNameUpdate(user, req.body?.name);
  if (!set) return res.status(400).send({ msg: 'That does not look like a name.' });
  try {
    await userCollection.updateOne({ outcomeToken: req.params.token }, { $set: set });
  } catch (e) {
    console.error('[email/pass-card/name] save failed:', e.message);
    return res.status(503).send({ msg: 'Could not save that. Try again in a moment.' });
  }
  res.status(200).send(cardPayload({ ...user, ...set }));
});

// POST /api/email/pass-card/:token/pe — would they want PE prep.
//
// The one question asked of somebody who has just passed, and the only place we
// can size that market with people who have proved they are the buyer. Asked
// after the card, never before: a celebration is not a toll gate for research.
//
// Always answers 200. They have their card; a research answer that failed to
// save is our problem and there is nothing useful to tell them about it.
router.post('/pass-card/:token/pe', async (req, res) => {
  try {
    await userCollection.updateOne(
      { outcomeToken: req.params.token, 'examOutcome.passed': true },
      { $set: { peInterest: { wants: req.body?.wants === true, askedAt: new Date() } } },
    );
  } catch (e) {
    console.error('[email/pass-card/pe] failed:', e.message);
  }
  res.status(200).end();
});

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
  if (wantsJson(req)) return res.status(ok ? 200 : 404).send({ ok });
  res.status(ok ? 200 : 404).type('html').send(
    page({ ok, heading: ok ? 'Noted' : 'Link not found', msg: ok ? 'That is everything. Thank you.' : undefined }),
  );
});

// GET /api/email/waitlist-unsubscribe/:token: one tap off the PE waitlist
// emails (see ../waitlist.js). POST for Gmail's one-click header. The row and
// its source stay, so the signup still counts toward the go signal.
async function leaveWaitlist(token) {
  try {
    return await require('../database.js').leaveWaitlist(token);
  } catch (e) {
    console.error('[email/waitlist-unsubscribe] failed:', e.message);
    return false;
  }
}
router.get('/waitlist-unsubscribe/:token', async (req, res) => {
  const ok = await leaveWaitlist(req.params.token);
  res.status(ok ? 200 : 404).type('html').send(page({
    ok,
    msg: ok ? 'You will not get any more PE waitlist emails. Your FE for Raccoons account emails, if you have one, are not affected.' : undefined,
  }));
});
router.post('/waitlist-unsubscribe/:token', async (req, res) => {
  await leaveWaitlist(req.params.token);
  res.status(200).end();
});

module.exports = router;

const express = require('express');
const rateLimit = require('express-rate-limit');
const { verifyAuth, resolveAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { validateFeedback, overTheHourlyLimit } = require('../feedback.js');
const email = require('../email.js');
const { sendFeedbackAlertEmail } = email;
const contact = require('../contact.js');

const router = express.Router();

// A report from the flag on a game round (the phone). Stored, and one email
// to the owner per report. Verified accounts only, and a few per hour.
router.post('/game', verifyAuth, async (req, res) => {
  if (!req.user.emailVerified) {
    return res.status(403).send({ msg: 'Verify your email first.' });
  }
  const checked = validateFeedback(req.body);
  if (!checked.ok) return res.status(400).send({ msg: checked.msg });

  const sent = await DB.countGameFeedbackSince(req.user.email, new Date(Date.now() - 3600_000));
  if (overTheHourlyLimit(sent)) {
    return res.status(429).send({ msg: 'That is plenty for one hour. Thank you.' });
  }

  const report = { ...checked.value, gameName: typeof req.body.gameName === 'string' ? req.body.gameName.slice(0, 80) : null };
  await DB.insertGameFeedback(req.user.email, report);
  await DB.appendEvent(req.user.email, {
    kind: 'feedback', chapterId: report.chapterId, localDate: new Date().toISOString().slice(0, 10),
    data: { gameId: report.gameId, round: report.round, about: report.kind },
  }).catch(() => {});
  // The email never blocks the thank-you; a send failure is logged by email.js.
  sendFeedbackAlertEmail({ email: req.user.email, ...report }).catch(() => {});
  res.send({ ok: true });
});

// "Contact us" (../contact.js): open to anyone, signed in or not. A signed-in
// message uses the account's address; the token is read if present and
// ignored if not, so a stale one never blocks somebody asking for help.
const contactLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { msg: 'That is plenty for one hour. Thank you.' },
});

router.post('/contact', contactLimiter, async (req, res) => {
  let accountEmail = null;
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : req.cookies?.token;
    if (token) {
      const r = await resolveAuth(token, DB);
      if (r.allow) accountEmail = r.user.email;
    }
  } catch {
    // signed out it is
  }
  const checked = contact.validateContact(req.body, accountEmail);
  if (!checked.ok) return res.status(400).send({ msg: checked.msg });
  if (checked.spam) return res.send({ ok: true });

  const msg = checked.value;
  const sent = await DB.countContactSince(msg.email, new Date(Date.now() - 3600_000));
  if (contact.overTheHourlyLimit(sent)) {
    return res.status(429).send({ msg: 'That is plenty for one hour. Thank you.' });
  }
  await DB.insertContactMessage(msg);
  // The email never blocks the thank-you; a send failure is logged by email.js.
  email.sendContactAlertEmail(msg).catch(() => {});
  res.send({ ok: true });
});

module.exports = router;

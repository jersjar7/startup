const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { validateFeedback, overTheHourlyLimit } = require('../feedback.js');
const { sendFeedbackAlertEmail } = require('../email.js');

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

module.exports = router;

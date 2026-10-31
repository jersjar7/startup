const express = require('express');
const rateLimit = require('express-rate-limit');
const DB = require('../database.js');
const email = require('../email.js');
const { generateToken } = require('../crypto.js');
const { validateWaitlist } = require('../waitlist.js');

const router = express.Router();
const appUrl = () => process.env.APP_URL || 'https://fe4raccoons.com';

const limiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { msg: 'That is plenty for one hour. Thank you.' },
});

// POST /api/waitlist   { email, exam, when, place, referrer, utmSource, ... }
//
// Open to anyone. A new address gets one confirmation email; joining again
// answers the same way and sends nothing, so the form cannot be used to
// fill somebody's inbox.
router.post('/', limiter, async (req, res) => {
  const checked = validateWaitlist(req.body);
  if (!checked.ok) return res.status(400).send({ msg: checked.msg });
  if (checked.spam) return res.send({ ok: true });

  const entry = checked.value;
  // Whether they already study the FE with us: the FE users are one of the
  // channels the proposal counts on.
  try {
    entry.hasFeAccount = !!(await DB.getUser(entry.email));
  } catch {
    entry.hasFeAccount = false;
  }
  const unsubToken = generateToken();
  let isNew;
  try {
    ({ isNew } = await DB.joinWaitlist(entry, unsubToken));
  } catch (e) {
    console.error('[waitlist] join failed:', e.message);
    return res.status(500).send({ msg: 'That did not go through. Try again in a minute.' });
  }
  if (isNew) {
    // The email never blocks the answer; a send failure is logged by email.js.
    email.sendWaitlistEmail(entry.email, { unsubUrl: `${appUrl()}/api/email/waitlist-unsubscribe/${unsubToken}` }).catch(() => {});
  }
  res.send({ ok: true });
});

module.exports = router;

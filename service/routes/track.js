const express = require('express');
const { userCollection } = require('../db/connection.js');
const { logEvent } = require('../db/events.js');

const router = express.Router();

// Tracked email links: record the click (attributed to the user via their
// unsub token, which the pitch email already carries) then 302 to the real
// destination. Public + no auth — opened straight from an email client.
// Destinations are hardcoded per kind so this can never become an open redirect.
const KINDS = {
  story: { dest: '/stories/mitch', event: 'sim_pitch_click_story' },
  exam: { dest: '/exam', event: 'sim_pitch_click_exam' },
};

router.get('/:kind/:token?', async (req, res) => {
  const k = KINDS[req.params.kind];
  if (!k) return res.redirect(302, '/');
  try {
    let email = null;
    if (req.params.token) {
      const u = await userCollection.findOne({ unsubToken: req.params.token }, { projection: { email: 1 } });
      email = u ? u.email : null;
    }
    await logEvent(k.event, email, { kind: req.params.kind });
  } catch (e) {
    console.error('[track] failed:', e.message);
  }
  return res.redirect(302, k.dest);
});

module.exports = router;

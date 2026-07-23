const express = require('express');
const { logEvent } = require('../db/events.js');

const router = express.Router();

// Clean, short click-tracking redirects for the plain-text founder emails
// (fe4raccoons.com/go/exam, /go/mitch). Counts the click, then 302s to the real
// page. Aggregate (no per-user token) so the link stays clean. Destinations are
// hardcoded, so this can never become an open redirect.
const DESTS = {
  exam: { url: '/exam', event: 'sim_pitch_click_exam' },
  mitch: { url: '/stories/mitch', event: 'sim_pitch_click_story' },
};

router.get('/:dest', async (req, res) => {
  const d = DESTS[req.params.dest];
  if (!d) return res.redirect(302, '/');
  try { await logEvent(d.event, null, { via: 'go' }); } catch (e) { console.error('[go] failed:', e.message); }
  return res.redirect(302, d.url);
});

module.exports = router;

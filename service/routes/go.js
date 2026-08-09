const express = require('express');
const { logEvent } = require('../db/events.js');

const router = express.Router();

// Clean, short click-tracking redirects for the plain-text founder emails
// (fe4raccoons.com/go/exam, /go/mitch). Counts the click, then 302s to the real
// page. Aggregate (no per-user token) so the link stays clean. Destinations are
// hardcoded, so this can never become an open redirect.
// `digest` points at the PUBLIC page rather than /exam: the weekly digest goes
// to every active user, most of whom have never seen what the simulation is, and
// the public page explains it before asking for anything. Its own CTA carries
// them on to /exam.
const DESTS = {
  exam: { url: '/exam', event: 'sim_pitch_click_exam' },
  mitch: { url: '/stories/mitch', event: 'sim_pitch_click_story' },
  digest: { url: '/exam-simulation', event: 'sim_pitch_click_digest' },
};

router.get('/:dest', async (req, res) => {
  const d = DESTS[req.params.dest];
  if (!d) return res.redirect(302, '/');
  try { await logEvent(d.event, null, { via: 'go' }); } catch (e) { console.error('[go] failed:', e.message); }
  return res.redirect(302, d.url);
});

module.exports = router;

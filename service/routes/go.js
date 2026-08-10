const express = require('express');
const { logEvent } = require('../db/events.js');
const { resolveGoDest } = require('../goDests.js');

const router = express.Router();

// Clean, short click-tracking redirects. Counts the hit, then 302s to the real
// page. Used by the plain-text founder emails (fe4raccoons.com/go/exam,
// /go/mitch), the weekly digest footer (/go/digest), and the printed campus
// placements (/go/byu and friends, encoded into QR codes).
//
// Aggregate by design: no per-user token, so the link stays short enough to
// print and to scan from the back of a lecture hall.
//
// Destinations are an allowlist in ../goDests.js. An unknown code goes to the
// home page rather than anywhere the caller named, so this can never be turned
// into an open redirect.
router.get('/:dest', async (req, res) => {
  const d = resolveGoDest(req.params.dest);
  if (!d) return res.redirect(302, '/');
  try {
    await logEvent(d.event, null, { via: 'go', ...(d.meta || {}) });
  } catch (e) {
    console.error('[go] failed:', e.message);
  }
  return res.redirect(302, d.url);
});

module.exports = router;

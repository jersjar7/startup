const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { computeFunnelMetrics } = require('../metrics.js');
const { sendTestEmail, getEmailConfig } = require('../email.js');

const router = express.Router();

// Owner-only. Set ADMIN_EMAIL in service/.env to override; falls back to the
// admin account email.
const ADMIN_EMAIL = (process.env.ADMIN_EMAIL || 'admin@oqupa.com').toLowerCase();

function requireAdmin(req, res, next) {
  if ((req.user.email || '').toLowerCase() !== ADMIN_EMAIL) {
    return res.status(403).send({ msg: 'Forbidden' });
  }
  next();
}

// GET /api/admin/metrics — conversion funnel + revenue.
router.get('/metrics', verifyAuth, requireAdmin, async (req, res) => {
  const counts = await DB.getFunnelCounts();
  res.send(computeFunnelMetrics(counts));
});

// GET /api/admin/timeseries?days=30 — daily time-series + KPI snapshot.
router.get('/timeseries', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const data = await DB.getDailyAnalytics(req.query.days);
    res.send(data);
  } catch (e) {
    console.error('[admin] timeseries failed:', e.message);
    res.status(500).send({ msg: 'Failed to load analytics' });
  }
});

// GET /api/admin/recent — recent signups + purchases with MASKED emails.
router.get('/recent', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const [users, purchases, total] = await Promise.all([DB.getRecentUsers(25), DB.getRecentPurchases(10), DB.countRealUsers()]);
    res.send({ users, purchases, total });
  } catch (e) {
    console.error('[admin] recent failed:', e.message);
    res.status(500).send({ msg: 'Failed to load recent users' });
  }
});

// GET /api/admin/acquisition — how users found us (self-reported + referrers).
router.get('/acquisition', verifyAuth, requireAdmin, async (req, res) => {
  try {
    res.send(await DB.getAcquisitionBreakdown());
  } catch (e) {
    console.error('[admin] acquisition failed:', e.message);
    res.status(500).send({ msg: 'Failed to load acquisition' });
  }
});

// GET /api/admin/user-lookup?email= — full record for ONE user (support).
router.get('/user-lookup', verifyAuth, requireAdmin, async (req, res) => {
  try {
    const user = await DB.lookupUser(req.query.email);
    if (!user) return res.status(404).send({ msg: 'No user with that email' });
    res.send(user);
  } catch (e) {
    console.error('[admin] user-lookup failed:', e.message);
    res.status(500).send({ msg: 'Lookup failed' });
  }
});

// GET /api/admin/email-status — current email sender config.
router.get('/email-status', verifyAuth, requireAdmin, (req, res) => {
  res.send(getEmailConfig());
});

// POST /api/admin/email-test { to } — send a test email, report the raw result.
// Lets the owner confirm delivery from the running app after verifying a domain.
router.post('/email-test', verifyAuth, requireAdmin, async (req, res) => {
  const to = String(req.body?.to || req.user.email).trim();
  const result = await sendTestEmail(to);
  res.send({ to, ...getEmailConfig(), ...result });
});

module.exports = router;

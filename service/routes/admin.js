const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { computeFunnelMetrics } = require('../metrics.js');

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

module.exports = router;

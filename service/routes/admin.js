const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { computeFunnelMetrics } = require('../metrics.js');

const router = express.Router();

// Owner-only. Set ADMIN_EMAIL in service/.env to your account email;
// falls back to the project owner's email.
const ADMIN_EMAIL = (process.env.ADMIN_EMAIL || 'jerson01@byu.edu').toLowerCase();

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

module.exports = router;

const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');

const router = express.Router();

// Get current week ID (YYYY-Wnn)
function getWeekId() {
  const now = new Date();
  const jan1 = new Date(now.getFullYear(), 0, 1);
  const days = Math.floor((now - jan1) / 86400000);
  const week = Math.ceil((days + jan1.getDay() + 1) / 7);
  return `${now.getFullYear()}-W${String(week).padStart(2, '0')}`;
}

// Get weekly leaderboard
router.get('/', verifyAuth, async (req, res) => {
  const weekId = getWeekId();
  const entries = await DB.getLeaderboard(weekId, 30);

  // Mask emails for privacy (show first 3 chars + ***)
  const leaderboard = entries.map((entry, index) => ({
    rank: index + 1,
    name: entry.email.substring(0, 3) + '***',
    weeklyXp: entry.weeklyXp,
    isCurrentUser: entry.email === req.user.email,
  }));

  res.send({ weekId, leaderboard });
});

module.exports = router;
module.exports.getWeekId = getWeekId;

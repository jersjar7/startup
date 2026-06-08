const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { sanitizeName, displayName } = require('../profile.js');

const router = express.Router();

// Show "Maria G." when the user has set a name; otherwise mask the email so we
// never expose PII for users who haven't personalized their profile.
function leaderName(entry) {
  return sanitizeName(entry.firstName || '')
    ? displayName(entry)
    : `${String(entry.email || '').substring(0, 3)}***`;
}

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

  const leaderboard = entries.map((entry, index) => ({
    rank: index + 1,
    name: leaderName(entry),
    weeklyXp: entry.weeklyXp,
    isCurrentUser: entry.email === req.user.email,
  }));

  res.send({ weekId, leaderboard });
});

// All-time leaderboard (cumulative totalXp)
router.get('/alltime', verifyAuth, async (req, res) => {
  const entries = await DB.getAllTimeLeaderboard(30);
  const leaderboard = entries.map((entry, index) => ({
    rank: index + 1,
    name: leaderName(entry),
    totalXp: entry.totalXp,
    isCurrentUser: entry.email === req.user.email,
  }));
  res.send({ leaderboard });
});

module.exports = router;
module.exports.getWeekId = getWeekId;

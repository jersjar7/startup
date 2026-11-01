const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { sanitizeName, displayName } = require('../profile.js');
const { currentWeekId } = require('../leagues/week.js');

const router = express.Router();

// Show "Maria G." when the user has set a name; otherwise mask the email so we
// never expose PII for users who haven't personalized their profile.
function leaderName(entry) {
  return sanitizeName(entry.firstName || '')
    ? displayName(entry)
    : `${String(entry.email || '').substring(0, 3)}***`;
}

// This week's id (YYYY-Wnn): Sunday to Saturday, US Eastern (ADR 0037).
function getWeekId(now = new Date()) {
  return currentWeekId(now);
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
module.exports.leaderName = leaderName;

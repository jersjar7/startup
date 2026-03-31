const { userStatsCollection } = require('./connection');

async function getLeaderboard(weekId, limit = 30) {
  return userStatsCollection
    .find({ weekId, weeklyXp: { $gt: 0 } })
    .sort({ weeklyXp: -1 })
    .limit(limit)
    .project({ email: 1, weeklyXp: 1, _id: 0 })
    .toArray();
}

module.exports = { getLeaderboard };

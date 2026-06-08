const { userStatsCollection } = require('./connection');

async function getLeaderboard(weekId, limit = 30) {
  // Join the users collection so the route can show a real display name
  // ("Maria G.") instead of a masked email when the user has set their name.
  return userStatsCollection
    .aggregate([
      { $match: { weekId, weeklyXp: { $gt: 0 } } },
      { $sort: { weeklyXp: -1 } },
      { $limit: limit },
      { $lookup: { from: 'users', localField: 'email', foreignField: 'email', as: '_u' } },
      {
        $project: {
          _id: 0,
          email: 1,
          weeklyXp: 1,
          firstName: { $first: '$_u.firstName' },
          lastName: { $first: '$_u.lastName' },
        },
      },
    ])
    .toArray();
}

// All-time board: cumulative totalXp across the user's whole history. Always
// populated (no week filter), and rewards the long FE-prep grind.
async function getAllTimeLeaderboard(limit = 30) {
  return userStatsCollection
    .aggregate([
      { $match: { totalXp: { $gt: 0 } } },
      { $sort: { totalXp: -1 } },
      { $limit: limit },
      { $lookup: { from: 'users', localField: 'email', foreignField: 'email', as: '_u' } },
      {
        $project: {
          _id: 0,
          email: 1,
          totalXp: 1,
          firstName: { $first: '$_u.firstName' },
          lastName: { $first: '$_u.lastName' },
        },
      },
    ])
    .toArray();
}

module.exports = { getLeaderboard, getAllTimeLeaderboard };

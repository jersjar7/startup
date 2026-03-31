const { ping } = require('./db/connection');
const users = require('./db/users');
const topics = require('./db/topics');
const problems = require('./db/problems');
const stats = require('./db/stats');
const leaderboard = require('./db/leaderboard');

module.exports = {
  ping,
  ...users,
  ...topics,
  ...problems,
  ...stats,
  ...leaderboard,
};

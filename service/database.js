const { ping } = require('./db/connection');
const users = require('./db/users');
const topics = require('./db/topics');
const problems = require('./db/problems');
const stats = require('./db/stats');
const leaderboard = require('./db/leaderboard');
const diagnostic = require('./db/diagnostic');
const accountDeletion = require('./db/accountDeletion');
const purchases = require('./db/purchases');
const examAttempts = require('./db/examAttempts');

module.exports = {
  ping,
  ...users,
  ...topics,
  ...problems,
  ...stats,
  ...leaderboard,
  ...diagnostic,
  ...accountDeletion,
  ...purchases,
  ...examAttempts,
};

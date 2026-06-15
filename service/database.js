const { ping } = require('./db/connection');
const users = require('./db/users');
const topics = require('./db/topics');
const stats = require('./db/stats');
const leaderboard = require('./db/leaderboard');
const diagnostic = require('./db/diagnostic');
const accountDeletion = require('./db/accountDeletion');
const purchases = require('./db/purchases');
const examAttempts = require('./db/examAttempts');
const events = require('./db/events');
const analytics = require('./db/analytics');
const adminUsers = require('./db/adminUsers');
const syncEvents = require('./db/syncEvents');
const paperFlags = require('./db/paperFlags');

module.exports = {
  ...syncEvents,
  ...paperFlags,
  ping,
  ...users,
  ...topics,
  ...stats,
  ...leaderboard,
  ...diagnostic,
  ...accountDeletion,
  ...purchases,
  ...examAttempts,
  ...events,
  ...analytics,
  ...adminUsers,
};

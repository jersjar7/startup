const { MongoClient } = require('mongodb');

const url = `mongodb+srv://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_HOSTNAME}`;
const client = new MongoClient(url);
const db = client.db('fe4raccoons');

// Collections
const userCollection = db.collection('users');
const topicCollection = db.collection('topics');
const problemCollection = db.collection('problems');
const userStatsCollection = db.collection('userStats');
const problemHistoryCollection = db.collection('problemHistory');

// Test connection and create indexes on startup
(async function testConnection() {
  try {
    await db.command({ ping: 1 });
    console.log(`DB connected to ${process.env.DB_HOSTNAME}`);

    // Ensure indexes exist
    await topicCollection.createIndex({ topicId: 1 }, { unique: true });
    await problemCollection.createIndex({ topicId: 1, problemNumber: 1 });
    await userStatsCollection.createIndex({ email: 1 }, { unique: true });
    await problemHistoryCollection.createIndex({ email: 1, problemId: 1 }, { unique: true });
    await problemHistoryCollection.createIndex({ email: 1, nextReview: 1 });
  } catch (ex) {
    console.log(`Unable to connect to database because ${ex.message}`);
    process.exit(1);
  }
})();

// Ping for health check
async function ping() {
  await db.command({ ping: 1 });
}

// ---- User functions ----
function getUser(email) {
  return userCollection.findOne({ email: email });
}

function getUserByToken(token) {
  return userCollection.findOne({ token: token });
}

async function addUser(user) {
  await userCollection.insertOne(user);
}

async function updateUser(user) {
  await userCollection.updateOne({ email: user.email }, { $set: user });
}

// ---- Topic functions ----
async function getTopics() {
  return topicCollection.find({}).sort({ order: 1 }).toArray();
}

async function getTopicById(topicId) {
  return topicCollection.findOne({ topicId: topicId });
}

// ---- Problem functions ----
async function getProblemsForTopic(topicId, count = 5) {
  return problemCollection
    .find({ topicId: topicId })
    .sort({ problemNumber: 1 })
    .limit(count)
    .toArray();
}

// ---- User stats functions ----
async function getUserStats(email) {
  return userStatsCollection.findOne({ email: email });
}

async function updateUserStats(email, update) {
  await userStatsCollection.updateOne(
    { email: email },
    { $set: update },
    { upsert: true }
  );
  return userStatsCollection.findOne({ email: email });
}

// ---- Problem history functions (spaced repetition) ----
async function getProblemHistoryForUser(email) {
  return problemHistoryCollection.find({ email }).toArray();
}

async function upsertProblemHistory(email, problemId, topicId, isCorrect) {
  const existing = await problemHistoryCollection.findOne({ email, problemId });
  const today = new Date().toISOString().split('T')[0];

  let interval;
  let timesCorrect = existing?.timesCorrect || 0;
  let timesIncorrect = existing?.timesIncorrect || 0;

  if (isCorrect) {
    timesCorrect++;
    interval = Math.min(Math.round((existing?.interval || 1) * 2.5), 30);
  } else {
    timesIncorrect++;
    interval = 1;
  }

  const nextDate = new Date(Date.now() + interval * 86400000);
  const nextReview = nextDate.toISOString().split('T')[0];

  await problemHistoryCollection.updateOne(
    { email, problemId },
    {
      $set: {
        topicId,
        lastSeen: today,
        timesCorrect,
        timesIncorrect,
        interval,
        nextReview,
      },
    },
    { upsert: true }
  );
}

async function getProblemsForReview(email, limit = 5) {
  const today = new Date().toISOString().split('T')[0];
  return problemHistoryCollection
    .find({ email, nextReview: { $lte: today } })
    .sort({ nextReview: 1 })
    .limit(limit)
    .toArray();
}

async function getAllProblemsForTopics(topicIds) {
  return problemCollection.find({ topicId: { $in: topicIds } }).toArray();
}

// ---- Leaderboard functions ----
async function getLeaderboard(weekId, limit = 30) {
  return userStatsCollection
    .find({ weekId, weeklyXp: { $gt: 0 } })
    .sort({ weeklyXp: -1 })
    .limit(limit)
    .project({ email: 1, weeklyXp: 1, _id: 0 })
    .toArray();
}

module.exports = {
  ping,
  getUser,
  getUserByToken,
  addUser,
  updateUser,
  getTopics,
  getTopicById,
  getProblemsForTopic,
  getUserStats,
  updateUserStats,
  getProblemHistoryForUser,
  upsertProblemHistory,
  getProblemsForReview,
  getAllProblemsForTopics,
  getLeaderboard,
};

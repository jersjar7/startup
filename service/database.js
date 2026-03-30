const { MongoClient } = require('mongodb');

const url = `mongodb+srv://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_HOSTNAME}`;
const client = new MongoClient(url);
const db = client.db('fe4raccoons');

// Collections
const userCollection = db.collection('users');
const progressCollection = db.collection('progress');
const topicCollection = db.collection('topics');
const problemCollection = db.collection('problems');
const userStatsCollection = db.collection('userStats');

// Test connection and create indexes on startup
(async function testConnection() {
  try {
    await db.command({ ping: 1 });
    console.log(`DB connected to ${process.env.DB_HOSTNAME}`);

    // Ensure indexes exist
    await topicCollection.createIndex({ topicId: 1 }, { unique: true });
    await problemCollection.createIndex({ topicId: 1, problemNumber: 1 });
    await userStatsCollection.createIndex({ email: 1 }, { unique: true });
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

// ---- Progress functions (legacy, kept for backward compat) ----
async function getProgress(email) {
  const record = await progressCollection.findOne({ email: email });
  return record ? record.completed : {};
}

async function saveProgress(email, problemId, completed) {
  await progressCollection.updateOne(
    { email: email },
    { $set: { [`completed.${problemId}`]: completed } },
    { upsert: true }
  );
  const record = await progressCollection.findOne({ email: email });
  return record ? record.completed : {};
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

module.exports = {
  ping,
  getUser,
  getUserByToken,
  addUser,
  updateUser,
  getProgress,
  saveProgress,
  getTopics,
  getTopicById,
  getProblemsForTopic,
  getUserStats,
  updateUserStats,
};

const { MongoClient } = require('mongodb');
const config = require('./dbConfig.json');

const url = `mongodb+srv://${config.userName}:${config.password}@${config.hostname}`;
const client = new MongoClient(url);
const db = client.db('fe4raccoons');

const userCollection = db.collection('users');
const progressCollection = db.collection('progress');

// Test connection on startup
(async function testConnection() {
  try {
    await db.command({ ping: 1 });
    console.log(`DB connected to ${config.hostname}`);
  } catch (ex) {
    console.log(`Unable to connect to database with ${url} because ${ex.message}`);
    process.exit(1);
  }
})();

// User functions
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

// Progress functions
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

module.exports = {
  getUser,
  getUserByToken,
  addUser,
  updateUser,
  getProgress,
  saveProgress,
};

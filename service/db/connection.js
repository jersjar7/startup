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
const sessionLogCollection = db.collection('sessionLog');
const diagnosticResultsCollection = db.collection('diagnosticResults');

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
    await sessionLogCollection.createIndex({ email: 1, completedAt: -1 });
    await diagnosticResultsCollection.createIndex({ email: 1, attemptNumber: -1 });
    await userCollection.createIndex({ token: 1 }, { sparse: true });
    await userCollection.createIndex({ resetToken: 1 }, { sparse: true });
    await userCollection.createIndex({ verificationToken: 1 }, { sparse: true });
  } catch (ex) {
    console.log(`Unable to connect to database because ${ex.message}`);
    process.exit(1);
  }
})();

// Ping for health check
async function ping() {
  await db.command({ ping: 1 });
}

module.exports = {
  db,
  ping,
  userCollection,
  topicCollection,
  problemCollection,
  userStatsCollection,
  problemHistoryCollection,
  sessionLogCollection,
  diagnosticResultsCollection,
};

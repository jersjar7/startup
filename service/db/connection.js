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
const purchasesCollection = db.collection('purchases');
const examAttemptsCollection = db.collection('examAttempts');
const funnelEventsCollection = db.collection('funnelEvents');
const reviewEventsCollection = db.collection('reviewEvents');
const paperFlagsCollection = db.collection('paperFlags');
const gameFeedbackCollection = db.collection('gameFeedback');
const sessionsCollection = db.collection('sessions');
// The Daily (see ../daily.js): one stored pick per day, one result per
// account per day.
const dailyPuzzlesCollection = db.collection('dailyPuzzles');
const dailyResultsCollection = db.collection('dailyResults');
// Chapter tests (see ../chapterTests.js): one document per try.
const chapterTestAttemptsCollection = db.collection('chapterTestAttempts');
// Daily/monthly email send counters (keyed 'day:YYYY-MM-DD' / 'month:YYYY-MM'),
// so the mailer can stay under Resend's free 100/day + 3000/month caps.
const mailMetaCollection = db.collection('mailMeta');
// A tally of deletions, never a record of who. See service/deletionRecord.js.
const deletionLogCollection = db.collection('deletionLog');
// Verification emails that failed to send, to try again. Holds the intent
// only, never the email. See service/emailRetry.js.
const emailRetriesCollection = db.collection('emailRetries');
// Daily visit totals per page and channel, never a row per visitor. See
// service/visits.js.
const visitCountsCollection = db.collection('visitCounts');

// Test connection and create indexes on startup
// Unit tests import route modules that pull this in; they never touch the
// database, so do not try to reach it (and never exit the test runner).
if (!process.env.VITEST) (async function testConnection() {
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
    await purchasesCollection.createIndex({ userId: 1 });
    await purchasesCollection.createIndex({ stripeSessionId: 1 }, { unique: true });
    await examAttemptsCollection.createIndex({ userId: 1, createdAt: -1 });
    await funnelEventsCollection.createIndex({ type: 1, createdAt: -1 });
    await reviewEventsCollection.createIndex({ email: 1, eventId: 1 }, { unique: true });
    await reviewEventsCollection.createIndex({ email: 1, _id: 1 });
    await reviewEventsCollection.createIndex({ email: 1, localDate: 1, source: 1 });
    await reviewEventsCollection.createIndex({ localDate: 1, chapterId: 1 }); // a challenge's finished count
    await reviewEventsCollection.createIndex({ ts: 1 }); // the dashboard's live feed
    await paperFlagsCollection.createIndex({ email: 1, itemId: 1, localDate: 1 }, { unique: true });
    await paperFlagsCollection.createIndex({ email: 1, localDate: 1 });
    await gameFeedbackCollection.createIndex({ email: 1, createdAt: -1 });
    await gameFeedbackCollection.createIndex({ createdAt: -1 });
    // Per-device auth sessions (web + mobile concurrently). The TTL index
    // auto-removes a session 30 days after its last activity; sliding lastSeen
    // keeps an active session alive.
    await sessionsCollection.createIndex({ token: 1 }, { unique: true });
    await sessionsCollection.createIndex({ email: 1 });
    await sessionsCollection.createIndex({ lastSeen: 1 }, { expireAfterSeconds: 60 * 60 * 24 * 30 });
    await dailyPuzzlesCollection.createIndex({ number: 1 }, { unique: true });
    await dailyResultsCollection.createIndex({ number: 1, email: 1 }, { unique: true });
    await dailyResultsCollection.createIndex({ email: 1, number: -1 });
    await chapterTestAttemptsCollection.createIndex({ email: 1, chapterId: 1, startedAt: -1 });
    await visitCountsCollection.createIndex({ day: 1 });
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
  deletionLogCollection,
  emailRetriesCollection,
  visitCountsCollection,
  client,
  db,
  ping,
  userCollection,
  topicCollection,
  problemCollection,
  userStatsCollection,
  problemHistoryCollection,
  sessionLogCollection,
  diagnosticResultsCollection,
  purchasesCollection,
  examAttemptsCollection,
  funnelEventsCollection,
  reviewEventsCollection,
  paperFlagsCollection,
  gameFeedbackCollection,
  sessionsCollection,
  mailMetaCollection,
  dailyPuzzlesCollection,
  dailyResultsCollection,
  chapterTestAttemptsCollection,
};

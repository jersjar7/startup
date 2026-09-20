const { gameFeedbackCollection } = require('./connection');

// Reports from the flag on a game round (see ../feedback.js). Append-only.

async function insertGameFeedback(email, report) {
  const doc = { email, ...report, createdAt: new Date() };
  const res = await gameFeedbackCollection.insertOne(doc);
  return res.insertedId;
}

/** How many reports this account sent since `since`. */
async function countGameFeedbackSince(email, since) {
  return gameFeedbackCollection.countDocuments({ email, createdAt: { $gte: since } });
}

/** The latest reports, newest first, for the admin page. */
async function listGameFeedback(limit = 100) {
  return gameFeedbackCollection.find({}).sort({ createdAt: -1 }).limit(limit).toArray();
}

module.exports = { insertGameFeedback, countGameFeedbackSince, listGameFeedback };

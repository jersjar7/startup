const { gameFeedbackCollection } = require('./connection');

// Reports from the flag on a game round (see ../feedback.js). Append-only.

async function insertGameFeedback(email, report) {
  const doc = { email, ...report, createdAt: new Date() };
  const res = await gameFeedbackCollection.insertOne(doc);
  return res.insertedId;
}

/** How many reports this account sent since `since`. */
async function countGameFeedbackSince(email, since) {
  return gameFeedbackCollection.countDocuments({ email, kind: { $ne: 'contact' }, createdAt: { $gte: since } });
}

/** The latest reports, newest first, for the admin page. */
async function listGameFeedback(limit = 100) {
  return gameFeedbackCollection.find({}).sort({ createdAt: -1 }).limit(limit).toArray();
}

// A "Contact us" message, kept beside the round reports with kind 'contact'
// so nothing is lost if its email fails (see ../contact.js).
async function insertContactMessage(msg) {
  const doc = { kind: 'contact', ...msg, createdAt: new Date() };
  const res = await gameFeedbackCollection.insertOne(doc);
  return res.insertedId;
}

/** How many contact messages this address sent since `since`. */
async function countContactSince(email, since) {
  return gameFeedbackCollection.countDocuments({ kind: 'contact', email, createdAt: { $gte: since } });
}

module.exports = { insertGameFeedback, countGameFeedbackSince, listGameFeedback, insertContactMessage, countContactSince };

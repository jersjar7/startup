const { userStatsCollection, problemHistoryCollection, sessionLogCollection } = require('./connection');

// Reviews are WEAK-SPOTS-ONLY and graduate out (study-load policy "B", 2026-06-29).
// The old model scheduled EVERY solved problem and never let it graduate, so the
// review pile trended toward "the whole bank, recurring forever" on top of an
// already huge chapter workload. Now a review queue means "your mistakes, until
// you've shown you know them" (see upsertProblemHistory).
const GRADUATE_AFTER = 2; // corrects-in-a-row on a missed problem to leave the queue
const REVIEW_STEP_DAYS = [1, 4]; // due-in days: after the miss, then after the 1st correct
const inDays = (n) => new Date(Date.now() + n * 86400000).toISOString().split('T')[0];

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

async function getProblemHistoryForUser(email) {
  return problemHistoryCollection.find({ email }).toArray();
}

// All problemHistory rows for one chapter (topicId == chapterId), for computing
// study-driven mastery.
async function getProblemHistoryForChapter(email, topicId) {
  return problemHistoryCollection.find({ email, topicId }).toArray();
}

// Record an answer and keep the WEAK-SPOTS-ONLY review queue:
//   - MISS  -> (re)enter the queue, due again the next day.
//   - CORRECT on a previously-missed problem -> space it out; after
//     GRADUATE_AFTER corrects in a row it GRADUATES out of the queue for good.
//   - CORRECT on a problem never missed -> stays out of reviews entirely.
async function upsertProblemHistory(email, problemId, topicId, isCorrect) {
  const existing = await problemHistoryCollection.findOne({ email, problemId });
  const today = new Date().toISOString().split('T')[0];

  const timesCorrect = (existing?.timesCorrect || 0) + (isCorrect ? 1 : 0);
  const timesIncorrect = (existing?.timesIncorrect || 0) + (isCorrect ? 0 : 1);

  let reviewActive = existing?.reviewActive || false;
  let correctSinceMiss = existing?.correctSinceMiss || 0;
  let nextReview = reviewActive ? existing?.nextReview || null : null;

  if (!isCorrect) {
    reviewActive = true;
    correctSinceMiss = 0;
    nextReview = inDays(REVIEW_STEP_DAYS[0]);
  } else if (reviewActive) {
    correctSinceMiss += 1;
    if (correctSinceMiss >= GRADUATE_AFTER) {
      reviewActive = false; // graduated — out of the queue for good
      nextReview = null;
    } else {
      nextReview = inDays(REVIEW_STEP_DAYS[correctSinceMiss] || REVIEW_STEP_DAYS[REVIEW_STEP_DAYS.length - 1]);
    }
  }
  // else: correct AND never missed -> nothing scheduled.

  const fields = {
    topicId,
    lastSeen: today,
    timesCorrect,
    timesIncorrect,
    reviewActive,
    correctSinceMiss,
    // Only carry a due date while actively in the queue.
    nextReview: reviewActive && nextReview ? nextReview : null,
  };

  await problemHistoryCollection.updateOne({ email, problemId }, { $set: fields }, { upsert: true });
}

// Due review queue = active (un-graduated) weak spots whose date has come.
async function getProblemsForReview(email, limit = 5) {
  const today = new Date().toISOString().split('T')[0];
  return problemHistoryCollection
    .find({ email, reviewActive: true, nextReview: { $lte: today } })
    .sort({ nextReview: 1 })
    .limit(limit)
    .toArray();
}

async function getDueReviewCount(email) {
  const today = new Date().toISOString().split('T')[0];
  return problemHistoryCollection.countDocuments({ email, reviewActive: true, nextReview: { $lte: today } });
}

async function logSession(email, { topicId, type, answers, xpEarned, streak, durationSeconds }) {
  await sessionLogCollection.insertOne({
    email,
    topicId,
    type,
    totalProblems: answers.length,
    correct: answers.filter((a) => a.isCorrect).length,
    xpEarned,
    streak,
    // Captured so cards/minute can be calibrated empirically later (Q4); null
    // until clients send it. See service/scripts/calibrateCardsPerMinute.js.
    durationSeconds: typeof durationSeconds === 'number' ? durationSeconds : null,
    completedAt: new Date(),
  });
}

module.exports = {
  getUserStats,
  updateUserStats,
  getProblemHistoryForUser,
  getProblemHistoryForChapter,
  upsertProblemHistory,
  getProblemsForReview,
  getDueReviewCount,
  logSession,
};

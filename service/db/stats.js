const { userStatsCollection, problemHistoryCollection, sessionLogCollection } = require('./connection');
const { nextInterval } = require('../scheduling');

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

async function upsertProblemHistory(email, problemId, topicId, isCorrect) {
  const existing = await problemHistoryCollection.findOne({ email, problemId });
  const today = new Date().toISOString().split('T')[0];

  let interval;
  let timesCorrect = existing?.timesCorrect || 0;
  let timesIncorrect = existing?.timesIncorrect || 0;

  if (isCorrect) {
    timesCorrect++;
  } else {
    timesIncorrect++;
  }
  interval = nextInterval(existing?.interval, isCorrect);

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

async function getDueReviewCount(email) {
  const today = new Date().toISOString().split('T')[0];
  return problemHistoryCollection.countDocuments({ email, nextReview: { $lte: today } });
}

async function logSession(email, { topicId, type, answers, xpEarned, streak }) {
  await sessionLogCollection.insertOne({
    email,
    topicId,
    type,
    totalProblems: answers.length,
    correct: answers.filter((a) => a.isCorrect).length,
    xpEarned,
    streak,
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

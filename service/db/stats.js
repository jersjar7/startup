const { userStatsCollection, problemHistoryCollection, sessionLogCollection } = require('./connection');
const { nextInterval, nextHistoryV2 } = require('../scheduling');
const flags = require('../flags');

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

  let timesCorrect = existing?.timesCorrect || 0;
  let timesIncorrect = existing?.timesIncorrect || 0;

  if (isCorrect) {
    timesCorrect++;
  } else {
    timesIncorrect++;
  }

  // v1 (legacy binary) and v2 (shared 3-grade SM-2) computed side by side.
  // While SCHEDULER_V2 is off we SERVE v1 and only log v2 (compute-dark); when
  // flipped we serve v2 and persist its ease/reps/lapses state.
  const v1Interval = nextInterval(existing?.interval, isCorrect);
  const v1NextReview = new Date(Date.now() + v1Interval * 86400000).toISOString().split('T')[0];
  const v2 = nextHistoryV2(existing, isCorrect, Date.now());

  const useV2 = flags.schedulerV2();
  if (!useV2 && flags.darkLog()) {
    console.log(
      `[sched-dark] ${problemId} ${isCorrect ? 'ok' : 'miss'} ` +
        `v1=${v1Interval}d/${v1NextReview} v2=${v2.interval}d/${v2.nextReview}`,
    );
  }

  const fields = {
    topicId,
    lastSeen: today,
    timesCorrect,
    timesIncorrect,
    interval: useV2 ? v2.interval : v1Interval,
    nextReview: useV2 ? v2.nextReview : v1NextReview,
  };
  // Persist the SM-2 state only when serving v2 — otherwise the stored
  // ease/reps would not match the served interval. Legacy rows are seeded on
  // the fly by nextHistoryV2 at flip time, so nothing is lost by waiting.
  if (useV2) {
    fields.ease = v2.ease;
    fields.reps = v2.reps;
    fields.lapses = v2.lapses;
  }

  await problemHistoryCollection.updateOne({ email, problemId }, { $set: fields }, { upsert: true });
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

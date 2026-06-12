const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const uuid = require('uuid');
const DB = require('../database.js');
const { calculateEarnedMastery, computeStudyMastery } = require('../mastery.js');
const { calculateStreak } = require('../streak.js');
const { evaluateBadges, getBadgeDetails } = require('../badges.js');
const { getWeekId } = require('./leaderboard.js');
const { computeDailyPlan } = require('../shared/scheduler.js');
const { weightedMastery, coveragePercent } = require('../examWeights.js');
const flags = require('../flags.js');

const router = express.Router();

// Emit web-sourced review events into the shared sync log — the phone pulls
// these so it never re-drills what was just done at the desk. Never breaks
// the study flow on failure.
async function emitWebEvents(email, answers, topicIdOf, localDate) {
  try {
    const day =
      typeof localDate === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(localDate)
        ? localDate
        : new Date().toISOString().slice(0, 10);
    const events = answers.map((a) => ({
      eventId: uuid.v4(),
      itemId: a.problemId,
      chapterId: topicIdOf(a),
      grade: a.isCorrect ? 'gotIt' : 'forgot',
      source: 'web',
      deviceId: null,
      ts: Date.now(),
      localDate: day,
    }));
    await DB.insertReviewEvents(email, events);
  } catch (err) {
    console.error('[sync] web emit failed:', err.message);
  }
}


// Get due review problems as references (client resolves them against the
// question pools). The review queue is the set of problems whose spaced-
// repetition interval has elapsed — stored by id in problemHistory and
// scheduled in db/stats.js. We return only the ids + reason; the frontend
// renders them from the same content the student studied, so there is a
// single source of truth for problems.
router.get('/', verifyAuth, async (req, res) => {
  const email = req.user.email;
  const requested = Math.min(parseInt(req.query.count) || 5, 8); // legacy flat cap
  const stats = await DB.getUserStats(email);

  if (!stats || !stats.topicProgress) {
    return res.send({ problems: [], message: 'Complete a topic session first to unlock review.' });
  }

  // Require at least one studied topic before review is meaningful.
  const studiedTopicIds = Object.keys(stats.topicProgress).filter(
    (id) => stats.topicProgress[id].sessionsCompleted > 0
  );

  if (studiedTopicIds.length === 0) {
    return res.send({ problems: [], message: 'Complete a topic session first to unlock review.' });
  }

  // Exam-aware review target, computed dark. The flat cap ignored the exam
  // date entirely (a 6-months-out and a 6-days-out user both got 5). While
  // STUDY_LOAD_V2 is off we still serve the flat cap and only log the plan;
  // when flipped we surface the backlog-and-horizon-aware target instead.
  const dueCount = await DB.getDueReviewCount(email);
  const chapterMastery = stats.chapterMastery || {};
  const plan = computeDailyPlan({
    now: Date.now(),
    examDate: req.user.examDate,
    dueCount,
    currentMasteryPercent: weightedMastery(chapterMastery),
    coveragePercent: coveragePercent(chapterMastery),
  });
  const useV2 = flags.studyLoadV2();
  if (!useV2 && flags.darkLog()) {
    const p = plan.projection;
    console.log(
      `[load-dark] ${email} regime=${plan.regime} due=${dueCount} ` +
        `flat=${requested} v2Target=${plan.reviewTarget} ceiling=${plan.dynamicCeiling} ` +
        `newBudget=${plan.budgetedNewTarget}${plan.newDeferred ? '(deferred)' : ''} ` +
        `proj=${p ? `${p.currentPercent}->${p.projectedPercent}` : 'n/a'}`,
    );
  }
  const count = useV2 ? plan.reviewTarget : requested;

  // Overdue problems (nextReview <= today), soonest-due first.
  const overdue = await DB.getProblemsForReview(email, count);

  const problems = overdue.map((h) => ({
    problemId: h.problemId,
    topicId: h.topicId,
    reviewReason: 'overdue',
  }));

  res.send({ problems });
});

// Lightweight count of due review items — for the dashboard "reviews due" badge.
router.get('/count', verifyAuth, async (req, res) => {
  const count = await DB.getDueReviewCount(req.user.email);
  res.send({ count });
});

// Submit review results
router.post('/', verifyAuth, async (req, res) => {
  const { answers } = req.body;

  if (!answers || !Array.isArray(answers) || answers.length === 0 || answers.length > 20) {
    return res.status(400).send({ msg: 'answers must be an array of 1-20 items' });
  }
  for (const a of answers) {
    if (typeof a.problemId !== 'string' || typeof a.isCorrect !== 'boolean') {
      return res.status(400).send({ msg: 'Each answer must have problemId (string) and isCorrect (boolean)' });
    }
    if (a.topicId && (typeof a.topicId !== 'string' || !/^[a-z0-9-]+$/.test(a.topicId))) {
      return res.status(400).send({ msg: 'Invalid topicId in answer' });
    }
  }

  const email = req.user.email;

  // Calculate XP
  const correctCount = answers.filter((a) => a.isCorrect).length;
  const incorrectCount = answers.length - correctCount;
  const xpCorrect = correctCount * 10;
  const xpIncorrect = incorrectCount * 5;
  const xpReviewBonus = 15;
  const xpTotal = xpCorrect + xpIncorrect + xpReviewBonus;

  // Update problem history
  await Promise.all(
    answers.map((a) => DB.upsertProblemHistory(email, a.problemId, a.topicId, a.isCorrect))
  );
  await emitWebEvents(email, answers, (a) => a.topicId, req.body.localDate);

  // Update user stats (XP + streak, but not per-topic sessionsCompleted)
  const currentStats = (await DB.getUserStats(email)) || {
    email,
    totalXp: 0,
    currentStreak: 0,
    longestStreak: 0,
    lastSessionDate: null,
    topicProgress: {},
  };

  const today = new Date().toISOString().split('T')[0];
  const streakResult = calculateStreak(currentStats, today);

  // Update per-topic attempted/correct counts and sessionsCompleted
  const topicProgress = currentStats.topicProgress || {};
  const topicsInReview = new Set(answers.map((a) => a.topicId).filter(Boolean));
  for (const a of answers) {
    const tp = topicProgress[a.topicId] || {
      attempted: 0,
      correct: 0,
      sessionsCompleted: 0,
      masteryLevel: 0,
      lastStudied: null,
    };
    tp.attempted++;
    if (a.isCorrect) tp.correct++;
    tp.lastStudied = today;
    topicProgress[a.topicId] = tp;
  }
  // Increment sessionsCompleted once per topic that appeared in this review
  for (const tid of topicsInReview) {
    if (topicProgress[tid]) {
      topicProgress[tid].sessionsCompleted++;
      topicProgress[tid].masteryLevel = calculateEarnedMastery(topicProgress[tid]);
    }
  }

  // Recompute study-driven mastery for every chapter touched in this review —
  // spaced/matured recalls are where mastery climbs the most.
  const chapterMastery = { ...(currentStats.chapterMastery || {}) };
  for (const tid of topicsInReview) {
    const hist = await DB.getProblemHistoryForChapter(email, tid);
    const studyScore = computeStudyMastery(hist);
    const ex = chapterMastery[tid] || { diagnosticScore: 0 };
    chapterMastery[tid] = {
      diagnosticScore: ex.diagnosticScore || 0,
      studyScore,
      totalMastery: Math.max(ex.diagnosticScore || 0, studyScore),
    };
  }

  // Track weekly XP for leaderboard
  const weekId = getWeekId();
  const currentWeeklyXp = currentStats.weekId === weekId ? (currentStats.weeklyXp || 0) : 0;

  const updatedStats = {
    email,
    totalXp: currentStats.totalXp + xpTotal,
    weekId,
    weeklyXp: currentWeeklyXp + xpTotal,
    currentStreak: streakResult.currentStreak,
    longestStreak: streakResult.longestStreak,
    freezeUsedThisWeek: streakResult.freezeUsedThisWeek,
    lastSessionDate: today,
    topicProgress,
    chapterMastery,
    badges: currentStats.badges || [],
  };

  const newBadgeIds = evaluateBadges(updatedStats, { correct: correctCount, total: answers.length });
  if (newBadgeIds.length > 0) {
    updatedStats.badges = [...updatedStats.badges, ...newBadgeIds];
  }

  await DB.updateUserStats(email, updatedStats);

  // Log review session for audit trail
  await DB.logSession(email, {
    topicId: [...topicsInReview].join(','),
    type: 'review',
    answers,
    xpEarned: xpTotal,
    streak: streakResult.currentStreak,
    durationSeconds: req.body.durationSeconds,
  });

  res.send({
    sessionSummary: {
      totalProblems: answers.length,
      correct: correctCount,
      incorrect: incorrectCount,
      xpEarned: {
        correct: xpCorrect,
        incorrect: xpIncorrect,
        reviewBonus: xpReviewBonus,
        total: xpTotal,
      },
      streak: {
        current: streakResult.currentStreak,
        longest: streakResult.longestStreak,
      },
      newBadges: getBadgeDetails(newBadgeIds),
    },
  });
});

module.exports = router;

const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { calculateEarnedMastery } = require('../mastery.js');
const { calculateStreak } = require('../streak.js');
const { evaluateBadges, getBadgeDetails } = require('../badges.js');
const { getWeekId } = require('./leaderboard.js');

const router = express.Router();

// Get due review problems as references (client resolves them against the
// question pools). The review queue is the set of problems whose spaced-
// repetition interval has elapsed — stored by id in problemHistory and
// scheduled in db/stats.js. We return only the ids + reason; the frontend
// renders them from the same content the student studied, so there is a
// single source of truth for problems.
router.get('/', verifyAuth, async (req, res) => {
  const email = req.user.email;
  const count = Math.min(parseInt(req.query.count) || 5, 8);
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

  // Overdue problems (nextReview <= today), soonest-due first.
  const overdue = await DB.getProblemsForReview(email, count);

  const problems = overdue.map((h) => ({
    problemId: h.problemId,
    topicId: h.topicId,
    reviewReason: 'overdue',
  }));

  res.send({ problems });
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

const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { calculateEarnedMastery } = require('../mastery.js');
const { calculateStreak } = require('../streak.js');
const { evaluateBadges, getBadgeDetails } = require('../badges.js');

const router = express.Router();

// Submit a completed session
router.post('/', verifyAuth, async (req, res) => {
  const { topicId, answers } = req.body;

  if (!topicId || !answers || !Array.isArray(answers) || answers.length === 0) {
    return res.status(400).send({ msg: 'topicId and answers array are required' });
  }

  // Calculate XP
  const correctCount = answers.filter((a) => a.isCorrect).length;
  const incorrectCount = answers.length - correctCount;
  const xpCorrect = correctCount * 10;
  const xpIncorrect = incorrectCount * 5;
  const xpSessionBonus = 25;
  const xpTotal = xpCorrect + xpIncorrect + xpSessionBonus;

  // Get current user stats
  const email = req.user.email;
  const currentStats = (await DB.getUserStats(email)) || {
    email,
    totalXp: 0,
    currentStreak: 0,
    longestStreak: 0,
    lastSessionDate: null,
    topicProgress: {},
  };

  // Update streak (with freeze support)
  const today = new Date().toISOString().split('T')[0];
  const streakResult = calculateStreak(currentStats, today);

  // Update topic progress
  const topicProgress = currentStats.topicProgress || {};
  const currentTopicProgress = topicProgress[topicId] || {
    attempted: 0,
    correct: 0,
    sessionsCompleted: 0,
    masteryLevel: 0,
    lastStudied: null,
  };

  const updatedProgress = {
    attempted: currentTopicProgress.attempted + answers.length,
    correct: currentTopicProgress.correct + correctCount,
    sessionsCompleted: currentTopicProgress.sessionsCompleted + 1,
    lastStudied: today,
  };
  updatedProgress.masteryLevel = calculateEarnedMastery(updatedProgress);

  topicProgress[topicId] = updatedProgress;

  // Update per-problem history for spaced repetition
  await Promise.all(
    answers.map((a) => DB.upsertProblemHistory(email, a.problemId, topicId, a.isCorrect))
  );

  // Build updated stats for badge evaluation
  const updatedStats = {
    email,
    totalXp: currentStats.totalXp + xpTotal,
    currentStreak: streakResult.currentStreak,
    longestStreak: streakResult.longestStreak,
    freezeUsedThisWeek: streakResult.freezeUsedThisWeek,
    lastSessionDate: today,
    topicProgress,
    badges: currentStats.badges || [],
  };

  // Evaluate badges
  const newBadgeIds = evaluateBadges(updatedStats, { correct: correctCount, total: answers.length });
  if (newBadgeIds.length > 0) {
    updatedStats.badges = [...updatedStats.badges, ...newBadgeIds];
  }

  // Save to database
  await DB.updateUserStats(email, updatedStats);

  res.send({
    sessionSummary: {
      totalProblems: answers.length,
      correct: correctCount,
      incorrect: incorrectCount,
      xpEarned: {
        correct: xpCorrect,
        incorrect: xpIncorrect,
        sessionBonus: xpSessionBonus,
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

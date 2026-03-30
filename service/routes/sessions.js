const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { calculateEarnedMastery } = require('../mastery.js');

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

  // Update streak
  const today = new Date().toISOString().split('T')[0]; // "YYYY-MM-DD"
  let newStreak = currentStats.currentStreak;

  if (currentStats.lastSessionDate !== today) {
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    if (currentStats.lastSessionDate === yesterday) {
      newStreak = currentStats.currentStreak + 1;
    } else if (currentStats.lastSessionDate === null) {
      newStreak = 1;
    } else {
      newStreak = 1; // streak broken
    }
  }

  const longestStreak = Math.max(currentStats.longestStreak, newStreak);

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

  // Save to database
  await DB.updateUserStats(email, {
    email,
    totalXp: currentStats.totalXp + xpTotal,
    currentStreak: newStreak,
    longestStreak,
    lastSessionDate: today,
    topicProgress,
  });

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
        current: newStreak,
        longest: longestStreak,
      },
    },
  });
});

module.exports = router;

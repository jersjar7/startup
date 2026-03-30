const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');

const router = express.Router();

// Get review problems (overdue + unseen from studied topics)
router.get('/', verifyAuth, async (req, res) => {
  const email = req.user.email;
  const count = Math.min(parseInt(req.query.count) || 5, 8);
  const stats = await DB.getUserStats(email);

  if (!stats || !stats.topicProgress) {
    return res.send({ problems: [], message: 'Complete a topic session first to unlock review.' });
  }

  // Find topics the user has studied
  const studiedTopicIds = Object.keys(stats.topicProgress).filter(
    (id) => stats.topicProgress[id].sessionsCompleted > 0
  );

  if (studiedTopicIds.length === 0) {
    return res.send({ problems: [], message: 'Complete a topic session first to unlock review.' });
  }

  // Get overdue problems from history
  const overdue = await DB.getProblemsForReview(email, count);
  const overdueIds = new Set(overdue.map((h) => h.problemId));

  // Get the actual problem documents for overdue items
  const allProblems = await DB.getAllProblemsForTopics(studiedTopicIds);
  const problemMap = {};
  for (const p of allProblems) {
    problemMap[p._id.toString()] = p;
  }

  const reviewProblems = [];

  // Add overdue problems first
  for (const h of overdue) {
    const p = problemMap[h.problemId];
    if (p) {
      reviewProblems.push({
        problemId: p._id.toString(),
        topicId: p.topicId,
        problemNumber: p.problemNumber,
        question: p.question,
        choices: p.choices,
        correctAnswer: p.correctAnswer,
        solution: p.solution,
        difficulty: p.difficulty,
        reviewReason: 'overdue',
      });
    }
  }

  // Fill remaining slots with unseen problems from studied topics
  if (reviewProblems.length < count) {
    const history = await DB.getProblemHistoryForUser(email);
    const seenIds = new Set(history.map((h) => h.problemId));
    const unseen = allProblems.filter((p) => !seenIds.has(p._id.toString()));

    // Shuffle unseen problems
    for (let i = unseen.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [unseen[i], unseen[j]] = [unseen[j], unseen[i]];
    }

    for (const p of unseen) {
      if (reviewProblems.length >= count) break;
      if (overdueIds.has(p._id.toString())) continue;
      reviewProblems.push({
        problemId: p._id.toString(),
        topicId: p.topicId,
        problemNumber: p.problemNumber,
        question: p.question,
        choices: p.choices,
        correctAnswer: p.correctAnswer,
        solution: p.solution,
        difficulty: p.difficulty,
        reviewReason: 'unseen',
      });
    }
  }

  res.send({ problems: reviewProblems });
});

// Submit review results
router.post('/', verifyAuth, async (req, res) => {
  const { answers } = req.body;

  if (!answers || !Array.isArray(answers) || answers.length === 0) {
    return res.status(400).send({ msg: 'answers array is required' });
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
  let newStreak = currentStats.currentStreak;

  if (currentStats.lastSessionDate !== today) {
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    if (currentStats.lastSessionDate === yesterday) {
      newStreak = currentStats.currentStreak + 1;
    } else if (currentStats.lastSessionDate === null) {
      newStreak = 1;
    } else {
      newStreak = 1;
    }
  }

  const longestStreak = Math.max(currentStats.longestStreak, newStreak);

  // Update per-topic attempted/correct counts (but not sessionsCompleted)
  const topicProgress = currentStats.topicProgress || {};
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
        reviewBonus: xpReviewBonus,
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

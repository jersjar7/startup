const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { calculateStreak } = require('../streak.js');
const { evaluateBadges, getBadgeDetails } = require('../badges.js');
const { getWeekId } = require('./leaderboard.js');

const router = express.Router();

// NCEES FE Civil exam question distribution (110 total) — single backend source
// of truth in examWeights.js.
const { EXAM_DISTRIBUTION } = require('../examWeights.js');

const TOTAL_QUESTIONS = 110;
const TIME_LIMIT_SECONDS = 5 * 3600 + 20 * 60; // 5 hours 20 minutes = 19200 seconds
const XP_PER_ATTEMPT = 100;
const XP_PER_CORRECT = 2;

// Middleware: verify user has purchased exam simulation
async function requirePurchase(req, res, next) {
  const userId = req.user._id.toString();
  const purchased = await DB.hasPurchased(userId);
  if (!purchased) {
    return res.status(403).send({ msg: 'Exam Simulation purchase required' });
  }
  next();
}

// POST /api/exam/start — Generate a 110-question exam
router.post('/start', verifyAuth, requirePurchase, async (req, res) => {
  try {
    const userId = req.user._id.toString();

    // Check for an in-progress attempt
    const attempts = await DB.getExamAttempts(userId);
    const inProgress = attempts.find(a => a.status === 'in_progress');
    if (inProgress) {
      // Return existing in-progress attempt
      const full = await DB.getExamAttempt(inProgress._id.toString(), userId);
      return res.send({
        attemptId: full._id.toString(),
        questions: full.questions.map(q => ({
          id: q.id,
          chapterId: q.chapterId,
          lessonId: q.lessonId,
          statement: q.statement,
          choices: (q.choices || []).map(c => ({ id: c.id, text: c.text })),
          type: q.type,
          diagram: q.diagram || null,
        })),
        timeLimit: TIME_LIMIT_SECONDS,
        startedAt: full.startedAt,
        resumed: true,
      });
    }

    const { questions: clientQuestions } = req.body;

    if (!clientQuestions || !Array.isArray(clientQuestions) || clientQuestions.length === 0) {
      return res.status(400).send({ msg: 'Questions array is required' });
    }

    if (clientQuestions.length > TOTAL_QUESTIONS + 20) {
      return res.status(400).send({ msg: 'Too many questions' });
    }

    const attemptNumber = (await DB.getExamAttemptCount(userId)) + 1;

    const attemptId = await DB.createExamAttempt(userId, {
      attemptNumber,
      status: 'in_progress',
      questions: clientQuestions,
      timeLimit: TIME_LIMIT_SECONDS,
      startedAt: new Date(),
      totalQuestions: clientQuestions.length,
    });

    res.send({
      attemptId: attemptId.toString(),
      questions: clientQuestions.map(q => ({
        id: q.id,
        chapterId: q.chapterId,
        lessonId: q.lessonId,
        statement: q.statement,
        choices: (q.choices || []).map(c => ({ id: c.id, text: c.text })),
        type: q.type,
        diagram: q.diagram || null,
      })),
      timeLimit: TIME_LIMIT_SECONDS,
      startedAt: new Date(),
      resumed: false,
    });
  } catch (err) {
    console.error('[exam/start] Error:', err);
    res.status(500).send({ msg: 'Failed to start exam' });
  }
});

// POST /api/exam/submit — Submit completed exam
router.post('/submit', verifyAuth, requirePurchase, async (req, res) => {
  try {
  const userId = req.user._id.toString();
  const email = req.user.email;
  const { attemptId, answers, timeUsedSeconds } = req.body;

  console.log('[exam/submit] userId:', userId, 'attemptId:', attemptId);

  if (!attemptId || !answers || !Array.isArray(answers)) {
    return res.status(400).send({ msg: 'attemptId and answers array are required' });
  }

  const attempt = await DB.getExamAttempt(attemptId, userId);
  if (!attempt) {
    console.log('[exam/submit] Attempt not found. Checking all attempts for user...');
    const allAttempts = await DB.getExamAttempts(userId);
    console.log('[exam/submit] User attempts:', allAttempts.map(a => ({ id: a._id.toString(), status: a.status })));
    return res.status(404).send({ msg: 'Exam attempt not found' });
  }

  if (attempt.status === 'completed') {
    return res.status(400).send({ msg: 'This exam has already been submitted' });
  }

  // Build answer map
  const answerMap = {};
  for (const a of answers) {
    answerMap[a.questionId] = a.selectedAnswerId;
  }

  // Score each question
  const chapterScores = {};
  let totalCorrect = 0;
  let totalAttempted = 0;

  const scoredQuestions = attempt.questions.map(q => {
    const selectedId = answerMap[q.id] || null;
    const isCorrect = selectedId === q.correctAnswerId;

    if (!chapterScores[q.chapterId]) {
      chapterScores[q.chapterId] = { correct: 0, total: 0 };
    }
    chapterScores[q.chapterId].total++;

    if (selectedId) {
      totalAttempted++;
      if (isCorrect) {
        totalCorrect++;
        chapterScores[q.chapterId].correct++;
      }
    }

    return {
      ...q,
      selectedAnswerId: selectedId,
      isCorrect,
    };
  });

  // Calculate percentage per chapter
  for (const ch of Object.keys(chapterScores)) {
    const s = chapterScores[ch];
    s.percentage = s.total > 0 ? Math.round((s.correct / s.total) * 100) : 0;
  }

  const overallPercentage = attempt.totalQuestions > 0
    ? Math.round((totalCorrect / attempt.totalQuestions) * 100)
    : 0;

  // XP calculation
  const xpTotal = XP_PER_ATTEMPT + (totalCorrect * XP_PER_CORRECT);

  // Update attempt
  await DB.updateExamAttempt(attemptId, userId, {
    status: 'completed',
    completedAt: new Date(),
    timeUsedSeconds: timeUsedSeconds || 0,
    questions: scoredQuestions,
    chapterScores,
    totalCorrect,
    totalAttempted,
    overallPercentage,
    xpEarned: xpTotal,
  });

  // Update user stats
  const currentStats = (await DB.getUserStats(email)) || {
    email,
    totalXp: 0,
    currentStreak: 0,
    longestStreak: 0,
    lastSessionDate: null,
    topicProgress: {},
    badges: [],
  };

  const today = new Date().toISOString().split('T')[0];
  const streakResult = calculateStreak(currentStats, today);
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
    topicProgress: currentStats.topicProgress || {},
    badges: currentStats.badges || [],
    diagnosticCompleted: currentStats.diagnosticCompleted,
    diagnosticAttempts: currentStats.diagnosticAttempts,
    chapterMastery: currentStats.chapterMastery || {},
  };

  const newBadgeIds = evaluateBadges(updatedStats, { correct: totalCorrect, total: attempt.totalQuestions });
  if (newBadgeIds.length > 0) {
    updatedStats.badges = [...updatedStats.badges, ...newBadgeIds];
  }

  await DB.updateUserStats(email, updatedStats);

  // Log session
  await DB.logSession(email, {
    topicId: 'exam-simulation',
    type: 'exam-simulation',
    answers: scoredQuestions.map(q => ({ problemId: q.id, isCorrect: q.isCorrect })),
    xpEarned: xpTotal,
    streak: streakResult.currentStreak,
  });

  res.send({
    attemptId,
    attemptNumber: attempt.attemptNumber,
    chapterScores,
    totalCorrect,
    totalAttempted,
    totalQuestions: attempt.totalQuestions,
    overallPercentage,
    xpEarned: xpTotal,
    streak: { current: streakResult.currentStreak, longest: streakResult.longestStreak },
    newBadges: getBadgeDetails(newBadgeIds),
  });
  } catch (err) {
    console.error('[exam/submit] Error:', err);
    res.status(500).send({ msg: 'Failed to submit exam' });
  }
});

// GET /api/exam/attempts — List user's past attempts
router.get('/attempts', verifyAuth, requirePurchase, async (req, res) => {
  const userId = req.user._id.toString();
  const attempts = await DB.getExamAttempts(userId);

  res.send(attempts.map(a => ({
    attemptId: a._id.toString(),
    attemptNumber: a.attemptNumber,
    status: a.status,
    startedAt: a.startedAt,
    completedAt: a.completedAt,
    totalCorrect: a.totalCorrect,
    totalQuestions: a.totalQuestions,
    overallPercentage: a.overallPercentage,
    timeUsedSeconds: a.timeUsedSeconds,
    xpEarned: a.xpEarned,
    chapterScores: a.chapterScores,
  })));
});

// GET /api/exam/attempt/:id — Get specific attempt details
router.get('/attempt/:id', verifyAuth, requirePurchase, async (req, res) => {
  const userId = req.user._id.toString();
  const attempt = await DB.getExamAttempt(req.params.id, userId);

  if (!attempt) {
    return res.status(404).send({ msg: 'Attempt not found' });
  }

  res.send({
    attemptId: attempt._id.toString(),
    attemptNumber: attempt.attemptNumber,
    status: attempt.status,
    startedAt: attempt.startedAt,
    completedAt: attempt.completedAt,
    timeUsedSeconds: attempt.timeUsedSeconds,
    timeLimit: attempt.timeLimit,
    questions: attempt.questions,
    chapterScores: attempt.chapterScores,
    totalCorrect: attempt.totalCorrect,
    totalAttempted: attempt.totalAttempted,
    totalQuestions: attempt.totalQuestions,
    overallPercentage: attempt.overallPercentage,
    xpEarned: attempt.xpEarned,
  });
});

module.exports = router;

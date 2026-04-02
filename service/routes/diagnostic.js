const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { calculateStreak } = require('../streak.js');
const { evaluateBadges, getBadgeDetails } = require('../badges.js');
const { getWeekId } = require('./leaderboard.js');

const router = express.Router();

const CHAPTERS = [
  'mathematics', 'statistics', 'ethics', 'economics', 'statics',
  'dynamics', 'mechanics-materials', 'materials', 'fluid-mechanics',
  'surveying', 'water-resources', 'structural', 'geotechnical',
  'transportation', 'construction',
];

const QUESTIONS_PER_CHAPTER = 2;
const TOTAL_QUESTIONS = CHAPTERS.length * QUESTIONS_PER_CHAPTER; // 30
const TIME_PER_QUESTION_SEC = 174.6; // 2.91 minutes
const MASTERY_CAP = 60;
const RETAKE_THRESHOLD_MASTERY = 60;
const RETAKE_THRESHOLD_CHAPTERS = 11;

// Submit completed diagnostic exam
router.post('/submit', verifyAuth, async (req, res) => {
  const { questions, timeUsedSeconds } = req.body;
  const email = req.user.email;

  if (!questions || !Array.isArray(questions) || questions.length === 0 || questions.length > TOTAL_QUESTIONS) {
    return res.status(400).send({ msg: `questions must be an array of 1-${TOTAL_QUESTIONS} items` });
  }

  for (const q of questions) {
    if (typeof q.questionId !== 'string' || typeof q.chapterId !== 'string') {
      return res.status(400).send({ msg: 'Each question must have questionId and chapterId' });
    }
  }

  // Compute per-chapter scores
  const chapterScores = {};
  for (const ch of CHAPTERS) {
    chapterScores[ch] = { correct: 0, total: 0, masterySeeded: 0 };
  }

  let totalCorrect = 0;
  let totalAttempted = 0;

  for (const q of questions) {
    const ch = q.chapterId;
    if (!chapterScores[ch]) continue;

    chapterScores[ch].total++;
    if (q.selectedAnswerId && q.isCorrect) {
      chapterScores[ch].correct++;
      totalCorrect++;
    }
    if (q.selectedAnswerId) {
      totalAttempted++;
    }
  }

  // Calculate mastery seeded per chapter (capped at 60%)
  for (const ch of CHAPTERS) {
    const score = chapterScores[ch];
    if (score.total > 0) {
      score.masterySeeded = Math.round((score.correct / score.total) * MASTERY_CAP);
    }
  }

  // XP calculation: 10 per attempted, 5 per correct
  const xpAttempted = totalAttempted * 10;
  const xpCorrect = totalCorrect * 5;
  const xpTotal = xpAttempted + xpCorrect;

  // Get attempt number
  const attemptCount = await DB.getDiagnosticAttemptCount(email);
  const attemptNumber = attemptCount + 1;

  // Store diagnostic result
  const result = {
    attemptNumber,
    startedAt: new Date(Date.now() - (timeUsedSeconds || 0) * 1000),
    completedAt: new Date(),
    timeUsedSeconds: timeUsedSeconds || 0,
    timeLimitSeconds: Math.round(TOTAL_QUESTIONS * TIME_PER_QUESTION_SEC),
    questions,
    chapterScores,
    totalCorrect,
    totalAttempted,
    totalQuestions: questions.length,
    xpEarned: xpTotal,
  };

  await DB.saveDiagnosticResult(email, result);

  // Update user stats: XP, streak, mastery
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

  // Build chapter mastery from diagnostic
  const existingMastery = currentStats.chapterMastery || {};
  const chapterMastery = {};
  for (const ch of CHAPTERS) {
    const existing = existingMastery[ch] || { diagnosticScore: 0, studyScore: 0, totalMastery: 0 };
    const newDiagnosticScore = chapterScores[ch].masterySeeded;
    // Take the higher diagnostic score (in case of retake improvement)
    const diagnosticScore = Math.max(existing.diagnosticScore || 0, newDiagnosticScore);
    const studyScore = existing.studyScore || 0;
    chapterMastery[ch] = {
      diagnosticScore,
      studyScore,
      totalMastery: Math.min(diagnosticScore + studyScore, 100),
    };
  }

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
    diagnosticCompleted: true,
    diagnosticAttempts: attemptNumber,
    chapterMastery,
  };

  // Evaluate badges
  const newBadgeIds = evaluateBadges(updatedStats, { correct: totalCorrect, total: questions.length });
  if (newBadgeIds.length > 0) {
    updatedStats.badges = [...updatedStats.badges, ...newBadgeIds];
  }

  await DB.updateUserStats(email, updatedStats);

  // Log session for audit trail
  await DB.logSession(email, {
    topicId: 'diagnostic',
    type: 'diagnostic',
    answers: questions.map(q => ({ problemId: q.questionId, isCorrect: q.isCorrect || false })),
    xpEarned: xpTotal,
    streak: streakResult.currentStreak,
  });

  res.send({
    attemptNumber,
    chapterScores,
    totalCorrect,
    totalAttempted,
    totalQuestions: questions.length,
    xpEarned: { attempted: xpAttempted, correct: xpCorrect, total: xpTotal },
    streak: { current: streakResult.currentStreak, longest: streakResult.longestStreak },
    newBadges: getBadgeDetails(newBadgeIds),
    chapterMastery,
  });
});

// Get diagnostic history for current user
router.get('/history', verifyAuth, async (req, res) => {
  const history = await DB.getDiagnosticHistory(req.user.email);
  res.send(history.map(h => ({
    attemptNumber: h.attemptNumber,
    completedAt: h.completedAt,
    totalCorrect: h.totalCorrect,
    totalAttempted: h.totalAttempted,
    totalQuestions: h.totalQuestions,
    chapterScores: h.chapterScores,
    xpEarned: h.xpEarned,
    timeUsedSeconds: h.timeUsedSeconds,
  })));
});

// Get full results for a specific attempt (for review page)
router.get('/results/:attemptNumber', verifyAuth, async (req, res) => {
  const attemptNumber = parseInt(req.params.attemptNumber, 10);
  if (isNaN(attemptNumber) || attemptNumber < 1) {
    return res.status(400).send({ msg: 'Invalid attempt number' });
  }

  const result = await DB.getDiagnosticById(req.user.email, attemptNumber);
  if (!result) {
    return res.status(404).send({ msg: 'Diagnostic result not found' });
  }

  res.send({
    attemptNumber: result.attemptNumber,
    completedAt: result.completedAt,
    timeUsedSeconds: result.timeUsedSeconds,
    timeLimitSeconds: result.timeLimitSeconds,
    questions: result.questions,
    chapterScores: result.chapterScores,
    totalCorrect: result.totalCorrect,
    totalAttempted: result.totalAttempted,
    totalQuestions: result.totalQuestions,
    xpEarned: result.xpEarned,
  });
});

// Check if user can retake diagnostic
router.get('/can-retake', verifyAuth, async (req, res) => {
  const email = req.user.email;
  const { chapterMastery, diagnosticCompleted, diagnosticAttempts } = await DB.getChapterMastery(email);

  if (!diagnosticCompleted) {
    return res.send({ canRetake: false, reason: 'not-taken', diagnosticCompleted: false });
  }

  // Count chapters at 60%+ mastery
  let chaptersAt60 = 0;
  for (const ch of CHAPTERS) {
    const m = chapterMastery[ch];
    if (m && m.totalMastery >= RETAKE_THRESHOLD_MASTERY) {
      chaptersAt60++;
    }
  }

  const canRetake = chaptersAt60 >= RETAKE_THRESHOLD_CHAPTERS;

  res.send({
    canRetake,
    reason: canRetake ? 'eligible' : 'need-more-mastery',
    diagnosticCompleted: true,
    diagnosticAttempts,
    chaptersAt60,
    chaptersNeeded: RETAKE_THRESHOLD_CHAPTERS,
  });
});

// Get mastery data for all chapters
router.get('/mastery', verifyAuth, async (req, res) => {
  const { chapterMastery, diagnosticCompleted, diagnosticAttempts } = await DB.getChapterMastery(req.user.email);
  res.send({ chapterMastery, diagnosticCompleted, diagnosticAttempts });
});

module.exports = router;

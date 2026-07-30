const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { calculateStreak } = require('../streak.js');
const { examXp } = require('../xp.js');
const { evaluateBadges, getBadgeDetails } = require('../badges.js');
const { getWeekId } = require('./leaderboard.js');
const { isAttemptExpired } = require('../examAttempt.js');
const { scoreAttempt } = require('../examScoring.js');
const {
  sanitizeAnswers, mergeAutosave, mergeSubmission, answeredCount, elapsedSeconds,
  examDeadlineMs, isPastDeadline,
} = require('../examProgress.js');

const router = express.Router();

// NCEES FE Civil exam question distribution (110 total) — single backend source
// of truth in examWeights.js.
const { EXAM_DISTRIBUTION } = require('../examWeights.js');

const TOTAL_QUESTIONS = 110;
const TIME_LIMIT_SECONDS = 5 * 3600 + 20 * 60; // 5 hours 20 minutes = 19200 seconds
// XP values live in ../xp.js (examAttempt + examCorrect).

// Middleware: verify user has purchased exam simulation
async function requirePurchase(req, res, next) {
  const userId = req.user._id.toString();
  const purchased = await DB.hasPurchased(userId);
  if (!purchased) {
    return res.status(403).send({ msg: 'Exam Simulation purchase required' });
  }
  next();
}


// Score an attempt, persist it, and apply the stats side effects.
//
// Shared by POST /submit and by the expiry path in POST /start, so an attempt
// whose window closed without a submit is graded exactly like one the customer
// pressed submit on. Previously expiry discarded the autosaved answers entirely.
//
// answerMap is keyed by questionId. `autoSubmitted` records that the customer
// never pressed submit, so the result can be labelled honestly.
async function finalizeAttempt({ attempt, userId, email, answerMap, timeUsedSeconds, autoSubmitted = false }) {
  const attemptId = attempt._id.toString();
  const {
    scoredQuestions, chapterScores, totalCorrect, totalAttempted, overallPercentage,
  } = scoreAttempt(attempt.questions || [], answerMap, attempt.totalQuestions);

  const xpTotal = examXp(totalCorrect);

  // Trust the server's startedAt over the client's timer: the client resets its
  // startTime on every resume, so a resumed attempt under-reported badly (a
  // 46-day-old attempt claimed under two hours). Cap at the real limit so a
  // resumed session cannot report more than the exam allows.
  const wasLate = isPastDeadline(attempt, TIME_LIMIT_SECONDS);
  const serverElapsed = Math.min(elapsedSeconds(attempt.startedAt), TIME_LIMIT_SECONDS);
  const reportedTime = Math.max(Number(timeUsedSeconds) || 0, 0);

  await DB.updateExamAttempt(attemptId, userId, {
    status: 'completed',
    completedAt: new Date(),
    timeUsedSeconds: Math.min(Math.max(reportedTime, serverElapsed), TIME_LIMIT_SECONDS),
    clientReportedTimeSeconds: reportedTime,
    lateSubmission: wasLate,
    autoSubmitted,
    questions: scoredQuestions,
    chapterScores,
    totalCorrect,
    totalAttempted,
    overallPercentage,
    xpEarned: xpTotal,
  });

  const currentStats = (await DB.getUserStats(email)) || {
    email, totalXp: 0, currentStreak: 0, longestStreak: 0,
    lastSessionDate: null, topicProgress: {}, badges: [],
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
  if (newBadgeIds.length > 0) updatedStats.badges = [...updatedStats.badges, ...newBadgeIds];

  await DB.updateUserStats(email, updatedStats);

  await DB.logSession(email, {
    topicId: 'exam-simulation',
    type: 'exam-simulation',
    answers: scoredQuestions.map(q => ({ problemId: q.id, isCorrect: q.isCorrect })),
    xpEarned: xpTotal,
    streak: streakResult.currentStreak,
  });

  return {
    attemptId,
    attemptNumber: attempt.attemptNumber,
    chapterScores,
    totalCorrect,
    totalAttempted,
    totalQuestions: attempt.totalQuestions,
    overallPercentage,
    xpEarned: xpTotal,
    autoSubmitted,
    streak: { current: streakResult.currentStreak, longest: streakResult.longestStreak },
    newBadges: getBadgeDetails(newBadgeIds),
  };
}

// POST /api/exam/start — Generate a 110-question exam
router.post('/start', verifyAuth, requirePurchase, async (req, res) => {
  try {
    const userId = req.user._id.toString();

    // Check for an in-progress attempt.
    //
    // An attempt whose window has already closed must NOT be resumed. Resuming
    // one unconditionally stranded paying customers: the client computes
    // `max(0, TIME_LIMIT - elapsed)`, so a stale attempt drops the user into the
    // 110-question exam with 00:00 on the clock and a timer that never ticks.
    // Nothing reaped these, so every retry landed them back in the same dead
    // attempt. Three of the first six buyers hit it; one submitted 3 of 110
    // questions across two "completed" attempts over 40 days.
    //
    // Retire the expired attempt instead and fall through to a fresh one. The
    // grace period matches checkActiveExamSims.js so the deploy preflight and
    // this check never disagree about what counts as active.
    const attempts = await DB.getExamAttempts(userId);
    let inProgress = attempts.find(a => a.status === 'in_progress');
    if (inProgress) {
      if (isAttemptExpired(inProgress.startedAt)) {
        // The window closed without a submit. GRADE the work rather than
        // discarding it: the autosave exists precisely so this customer's hours
        // are not lost, and marking the attempt 'expired' hid it from every
        // surface in the app (Past Attempts filters on 'completed').
        const full = await DB.getExamAttempt(inProgress._id.toString(), userId);
        const saved = sanitizeAnswers(full?.savedAnswers);
        if (answeredCount(saved) > 0) {
          await finalizeAttempt({
            attempt: full,
            userId,
            email: req.user.email,
            answerMap: saved,
            // They had the full window available, whether or not they used it.
            timeUsedSeconds: TIME_LIMIT_SECONDS,
            autoSubmitted: true,
          });
          await DB.updateExamAttempt(inProgress._id.toString(), userId, { expiredAt: new Date() });
        } else {
          // Nothing was ever answered, so there is nothing to grade. Retire it
          // quietly rather than manufacturing a 0% attempt in their history.
          await DB.updateExamAttempt(inProgress._id.toString(), userId, {
            status: 'expired',
            expiredAt: new Date(),
          });
        }
        inProgress = undefined; // start a clean attempt below
      }
    }
    if (inProgress) {
      // Resume the STORED attempt, and hand back everything needed to restore
      // the session exactly: the original questions (the client must not
      // regenerate its own — doing so meant submitted questionIds did not match
      // the stored ones and were silently scored as blank), plus the saved
      // answers, position, flags and break state.
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
        // Server-issued so the client never derives its own clock. A hidden tab
        // or a sleeping laptop cannot pause a wall-clock deadline.
        deadline: examDeadlineMs(full, TIME_LIMIT_SECONDS),
        resumed: true,
        savedAnswers: sanitizeAnswers(full.savedAnswers),
        currentIndex: Number.isInteger(full.savedIndex) ? full.savedIndex : 0,
        flagged: Array.isArray(full.savedFlagged) ? full.savedFlagged : [],
        breakTaken: full.breakTaken === true,
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

    const startedAt = new Date();
    const attemptId = await DB.createExamAttempt(userId, {
      attemptNumber,
      status: 'in_progress',
      questions: clientQuestions,
      timeLimit: TIME_LIMIT_SECONDS,
      startedAt,
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
      startedAt,
      deadline: examDeadlineMs({ startedAt }, TIME_LIMIT_SECONDS),
      resumed: false,
    });
  } catch (err) {
    console.error('[exam/start] Error:', err);
    res.status(500).send({ msg: 'Failed to start exam' });
  }
});

// PATCH /api/exam/answers — autosave in-progress exam state.
//
// Called on a debounce while the user works, and on pagehide/visibilitychange.
// Everything is OPTIONAL and MERGED, never replaced: a client that has lost its
// state cannot blank out answers the server already holds. That is the failure
// this whole endpoint exists to prevent.
//
// Cheap on purpose — one small $set per flush, no scoring — because it runs
// every few seconds for up to five and a half hours.
async function saveProgress(req, res) {
  try {
    const userId = req.user._id.toString();
    const { attemptId, answers, currentIndex, flagged, breakTaken, breakStartedAt, breakEndedAt } = req.body;
    if (!attemptId) return res.status(400).send({ msg: 'attemptId is required' });

    const attempt = await DB.getExamAttempt(attemptId, userId);
    if (!attempt) return res.status(404).send({ msg: 'Exam attempt not found' });
    // Never let a late autosave reopen or mutate a finished attempt.
    if (attempt.status !== 'in_progress') {
      return res.send({ ok: true, ignored: true, status: attempt.status });
    }

    const update = { savedAt: new Date() };
    if (answers !== undefined) update.savedAnswers = mergeAutosave(attempt.savedAnswers, answers);
    if (Number.isInteger(currentIndex)) update.savedIndex = currentIndex;
    if (Array.isArray(flagged)) {
      update.savedFlagged = flagged.filter((n) => Number.isInteger(n)).slice(0, 200);
    }
    // Break is one-way: once taken it stays taken, so a refresh cannot hand out
    // a second 25-minute break.
    if (breakTaken === true) update.breakTaken = true;
    // Break timestamps extend the deadline (the break sits outside exam time, as
    // in the real NCEES appointment). Write-once so a refresh cannot buy a
    // second break or stretch the first.
    if (breakStartedAt && !attempt.breakStartedAt) update.breakStartedAt = new Date(breakStartedAt);
    if (breakEndedAt && !attempt.breakEndedAt) update.breakEndedAt = new Date(breakEndedAt);

    await DB.updateExamAttempt(attemptId, userId, update);
    res.send({ ok: true, answered: answeredCount(update.savedAnswers ?? attempt.savedAnswers) });
  } catch (err) {
    console.error('[exam/answers] Error:', err);
    res.status(500).send({ msg: 'Failed to save progress' });
  }
}

router.patch('/answers', verifyAuth, requirePurchase, saveProgress);

// POST /api/exam/answers-beacon — same save, reachable by navigator.sendBeacon.
// On pagehide a normal fetch is routinely killed mid-flight; sendBeacon is the
// only transport browsers guarantee to deliver, and it can only POST. This is
// the last-chance save when a user closes the tab mid-exam, which is exactly
// when answers used to vanish.
router.post('/answers-beacon', verifyAuth, requirePurchase, saveProgress);

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

  // Build the answer map by MERGING what the client submitted over what was
  // already autosaved. Never trust the submitted set alone: if the tab was
  // refreshed the client may hold only a fraction of the real answers.
  const submitted = {};
  for (const a of answers) {
    if (a && typeof a.questionId === 'string') submitted[a.questionId] = a.selectedAnswerId ?? null;
  }
  // Additive: a submitting client can add answers but can never erase what was
  // autosaved. See mergeSubmission for why these two paths differ.
  const answerMap = mergeSubmission(attempt.savedAnswers, submitted);

  const result = await finalizeAttempt({
    attempt, userId, email, answerMap, timeUsedSeconds, autoSubmitted: false,
  });
  res.send(result);
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
    autoSubmitted: a.autoSubmitted === true,
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

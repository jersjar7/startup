const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const uuid = require('uuid');
const DB = require('../database.js');
const { calculateEarnedMastery, computeStudyMastery, composeMastery } = require('../mastery.js');
const { XP } = require('../xp.js');
const { validAnswer, gradeAnswers, scoreAnswers } = require('../grading.js');
const { rederiveAccount } = require('../rederive.js');
const { dayFor } = require('../studyDays.js');
const { evaluateBadges, getBadgeDetails } = require('../badges.js');
const { getWeekId } = require('./leaderboard.js');

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


// Submit a completed session
router.post('/', verifyAuth, async (req, res) => {
  const { topicId, answers } = req.body;

  if (!topicId || typeof topicId !== 'string' || !/^[a-z0-9-]+$/.test(topicId)) {
    return res.status(400).send({ msg: 'Invalid topicId' });
  }
  if (!answers || !Array.isArray(answers) || answers.length === 0 || answers.length > 20) {
    return res.status(400).send({ msg: 'answers must be an array of 1-20 items' });
  }
  if (!answers.every(validAnswer)) {
    return res.status(400).send({ msg: 'Each answer must have problemId (string) and choiceId (string)' });
  }

  // Graded here, never by the browser, and a problem earns XP once a day
  // (ADR 0038). Read what was answered today BEFORE this session's answers
  // are written.
  const email = req.user.email;
  const today = dayFor(req.body); // the student's day (studyDays.js)
  const graded = gradeAnswers(answers);
  const xp = scoreAnswers(graded, await DB.getDeskAnsweredOn(email, today), XP.sessionBonus);
  const correctCount = graded.filter((a) => a.isCorrect).length;
  const incorrectCount = graded.length - correctCount;
  const xpTotal = xp.total;

  // The log is the record (ADR 0018, step 3): append the answers and the
  // session, then derive everything the surfaces read from the whole log.
  await emitWebEvents(email, graded, () => topicId, today);
  await DB.appendEvent(email, {
    kind: 'session', chapterId: topicId, localDate: today,
    data: { type: 'practice', topicId, correct: correctCount, total: answers.length, xp: xpTotal, durationSeconds: req.body.durationSeconds ?? null },
  });
  const state = await rederiveAccount(email, { sessionContext: { correct: correctCount, total: answers.length } });
  const streakResult = { currentStreak: state.daysStudied, longestStreak: state.longestStreak };
  const newBadgeIds = state.newBadgeIds;

  // Log session for audit trail
  await DB.logSession(email, {
    topicId,
    type: 'practice',
    answers: graded,
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
        correct: xp.correct,
        incorrect: xp.incorrect,
        sessionBonus: xp.bonus,
        total: xpTotal,
        repeats: xp.repeats, // answered earlier today, so no XP this time
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

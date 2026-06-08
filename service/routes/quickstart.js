const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { calculateStreak } = require('../streak.js');
const { getWeekId } = require('./leaderboard.js');

const router = express.Router();

// System-controlled chapter order: `mathematics` first (foundational, high
// weight — a fair confidence-first opener), then the remaining chapters by
// NCEES exam weight descending. The user controls HOW FAR they go; the system
// controls WHICH chapters, so blind spots can't be skipped (Dunning–Kruger).
// See docs/quickstart-diagnostic-design.md.
const SEGMENT_ORDER = [
  'mathematics',         // 13 — foundational opener
  'water-resources',     // 14
  'structural',          // 13
  'geotechnical',        // 11
  'transportation',      // 10
  'statics',             // 8
  'mechanics-materials', // 8
  'construction',        // 5
  'statistics',          // 4
  'ethics',              // 4
  'economics',           // 4
  'dynamics',            // 4
  'materials',           // 4
  'fluid-mechanics',     // 4
  'surveying',           // 4
];

const TOTAL_CHAPTERS = SEGMENT_ORDER.length; // 15

// Questions per chapter, tiered by NCEES exam weight so reliability is spent
// where it counts: weight >=10 → 5, weight 6–9 → 4, weight <=5 → 3. The heavy
// (5-question) reads are the high-weight chapters users reach first; the
// low-weight tail is lighter. Full map = 57 questions (was 75). See
// docs/quickstart-diagnostic-design.md.
const QUESTIONS_PER_CHAPTER = {
  mathematics: 5, 'water-resources': 5, structural: 5, geotechnical: 5, transportation: 5,
  statics: 4, 'mechanics-materials': 4,
  construction: 3, statistics: 3, ethics: 3, economics: 3,
  dynamics: 3, materials: 3, 'fluid-mechanics': 3, surveying: 3,
};
const MAX_SEGMENT = 5;
const countFor = (ch) => QUESTIONS_PER_CHAPTER[ch] || MAX_SEGMENT;

// A short sample is a rough read, never mastery — cap it well below 100.
const FAMILIARITY_CAP = 40;

function nextChapter(sampled) {
  const done = new Set(sampled || []);
  return SEGMENT_ORDER.find((ch) => !done.has(ch)) || null;
}

// Shape the client uses to render the X/15 map and decide the next chapter.
function buildState(stats) {
  const sampled = (stats && stats.quickstartSampled) || [];
  const chapterMastery = (stats && stats.chapterMastery) || {};
  const familiarity = {};
  for (const ch of sampled) {
    familiarity[ch] = chapterMastery[ch] ? (chapterMastery[ch].diagnosticScore || 0) : 0;
  }
  const next = nextChapter(sampled);
  return {
    sampled,
    sampledCount: sampled.length,
    totalChapters: TOTAL_CHAPTERS,
    order: SEGMENT_ORDER,
    familiarity,
    nextChapterId: next,
    nextChapterQuestions: next ? countFor(next) : 0,
    done: next === null,
  };
}

// Current quick-start progress for the signed-in user.
router.get('/state', verifyAuth, async (req, res) => {
  const stats = await DB.getUserStats(req.user.email);
  res.send(buildState(stats));
});

// Just the next chapter to sample (lightweight poll).
router.get('/next', verifyAuth, async (req, res) => {
  const stats = await DB.getUserStats(req.user.email);
  const state = buildState(stats);
  res.send({
    nextChapterId: state.nextChapterId,
    questionCount: state.nextChapterQuestions,
    done: state.done,
    sampledCount: state.sampledCount,
    totalChapters: state.totalChapters,
  });
});

// Submit one 5-question segment for a single chapter. The client grades each
// question (same trust model as the legacy diagnostic) and sends the results.
router.post('/submit-segment', verifyAuth, async (req, res) => {
  const email = req.user.email;
  const { chapterId, answers } = req.body;

  if (typeof chapterId !== 'string' || !SEGMENT_ORDER.includes(chapterId)) {
    return res.status(400).send({ msg: 'Valid chapterId is required' });
  }
  const maxForChapter = countFor(chapterId);
  if (!Array.isArray(answers) || answers.length === 0 || answers.length > maxForChapter) {
    return res.status(400).send({ msg: `answers must be an array of 1-${maxForChapter} items` });
  }
  for (const a of answers) {
    if (typeof a.questionId !== 'string') {
      return res.status(400).send({ msg: 'Each answer needs a questionId' });
    }
  }

  const total = answers.length;
  let correct = 0;
  let attempted = 0;
  for (const a of answers) {
    if (a.selectedAnswerId) attempted++;
    if (a.selectedAnswerId && a.isCorrect) correct++;
  }

  // familiarity = round(correct/total * 40), capped at 40. 5/5 → 40, never 100.
  const familiarity = Math.min(Math.round((correct / total) * FAMILIARITY_CAP), FAMILIARITY_CAP);

  // XP on the same scale as the legacy diagnostic: 10 per attempted + 5 per correct.
  const xpAttempted = attempted * 10;
  const xpCorrect = correct * 5;
  const xpTotal = xpAttempted + xpCorrect;

  const currentStats = (await DB.getUserStats(email)) || {
    email, totalXp: 0, currentStreak: 0, longestStreak: 0,
    lastSessionDate: null, topicProgress: {}, badges: [],
  };

  const today = new Date().toISOString().split('T')[0];
  const streakResult = calculateStreak(currentStats, today);
  const weekId = getWeekId();
  const currentWeeklyXp = currentStats.weekId === weekId ? (currentStats.weeklyXp || 0) : 0;

  // Merge the familiarity read into chapterMastery — never lower an existing
  // score (a re-sample or a prior study run keeps its higher value).
  const existingMastery = currentStats.chapterMastery || {};
  const prev = existingMastery[chapterId] || { diagnosticScore: 0, studyScore: 0, totalMastery: 0 };
  const diagnosticScore = Math.max(prev.diagnosticScore || 0, familiarity);
  const studyScore = prev.studyScore || 0;
  const chapterMastery = {
    ...existingMastery,
    [chapterId]: {
      diagnosticScore,
      studyScore,
      totalMastery: Math.min(diagnosticScore + studyScore, 100),
    },
  };

  // Mark the chapter sampled, keeping the canonical system order.
  const sampledSet = new Set(currentStats.quickstartSampled || []);
  sampledSet.add(chapterId);
  const quickstartSampled = SEGMENT_ORDER.filter((ch) => sampledSet.has(ch));

  // $set-merge (see db/stats.js): only these fields change; topicProgress,
  // badges, diagnosticCompleted, etc. are preserved.
  await DB.updateUserStats(email, {
    totalXp: (currentStats.totalXp || 0) + xpTotal,
    weekId,
    weeklyXp: currentWeeklyXp + xpTotal,
    currentStreak: streakResult.currentStreak,
    longestStreak: streakResult.longestStreak,
    freezeUsedThisWeek: streakResult.freezeUsedThisWeek,
    lastSessionDate: today,
    chapterMastery,
    quickstartSampled,
  });

  await DB.logSession(email, {
    topicId: chapterId,
    type: 'quickstart',
    answers: answers.map((a) => ({ problemId: a.questionId, isCorrect: a.isCorrect || false })),
    xpEarned: xpTotal,
    streak: streakResult.currentStreak,
  });

  const state = buildState({ quickstartSampled, chapterMastery });

  res.send({
    chapterId,
    correct,
    total,
    chapterFamiliarity: familiarity, // this segment's read, as a scalar
    xpEarned: { attempted: xpAttempted, correct: xpCorrect, total: xpTotal },
    streak: { current: streakResult.currentStreak, longest: streakResult.longestStreak },
    ...state, // includes `familiarity` as the full {chapterId: pct} map
  });
});

module.exports = router;

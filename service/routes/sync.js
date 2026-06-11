const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { computeStudyMastery } = require('../mastery.js');
const { calculateStreak } = require('../streak.js');

const router = express.Router();

const GRADES = new Set(['forgot', 'fuzzy', 'gotIt']);
const SOURCES = new Set(['web', 'ios', 'android']);
const MAX_BATCH = 200;
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

function validEvent(e) {
  return (
    e &&
    typeof e.eventId === 'string' && e.eventId.length >= 8 && e.eventId.length <= 64 &&
    typeof e.itemId === 'string' && e.itemId.length <= 80 &&
    typeof e.chapterId === 'string' && e.chapterId.length <= 40 &&
    GRADES.has(e.grade) &&
    SOURCES.has(e.source) &&
    typeof e.ts === 'number' &&
    typeof e.localDate === 'string' && DATE_RE.test(e.localDate)
  );
}

// Card ids derive from their parent problem (math-slq-q1:fc → math-slq-q1);
// the web's queue and mastery are keyed by the parent.
const parentId = (itemId) => itemId.split(':')[0];

/**
 * Fold freshly-inserted PHONE events into the web's view of the user — the
 * "Tuesday test": that evening the web must show the streak ticked, the due
 * queue decremented, and the work visible. Web-sourced events are skipped
 * (their effects were applied by /api/sessions / /api/review directly).
 */
async function ingestPhoneEvents(email, events) {
  const phone = events.filter((e) => e.source !== 'web');
  if (!phone.length) return;

  // 1) Same-day dedupe + schedule push: each reviewed item updates the
  //    parent problem's history, so it leaves today's web due queue.
  const touchedChapters = new Map();
  for (const e of phone) {
    await DB.upsertProblemHistory(email, parentId(e.itemId), e.chapterId, e.grade !== 'forgot');
    touchedChapters.set(e.chapterId, true);
  }

  // 2) Phone reps strengthen web mastery (one brain).
  const currentStats = (await DB.getUserStats(email)) || {};
  const chapterMastery = { ...(currentStats.chapterMastery || {}) };
  for (const ch of touchedChapters.keys()) {
    const hist = await DB.getProblemHistoryForChapter(email, ch);
    const studyScore = computeStudyMastery(hist);
    const ex = chapterMastery[ch] || { diagnosticScore: 0 };
    chapterMastery[ch] = {
      diagnosticScore: ex.diagnosticScore || 0,
      studyScore,
      totalMastery: Math.max(ex.diagnosticScore || 0, studyScore),
    };
  }

  // 3) One streak: credit the event's CLIENT-local day (offline Tuesday
  //    synced Wednesday still counts Tuesday).
  const latestDay = phone.map((e) => e.localDate).sort().pop();
  const streakResult = calculateStreak(currentStats, latestDay);

  await DB.updateUserStats(email, {
    chapterMastery,
    currentStreak: streakResult.currentStreak,
    longestStreak: streakResult.longestStreak,
    freezeUsedThisWeek: streakResult.freezeUsedThisWeek,
    lastSessionDate: latestDay,
  });
}

// Push a batch of events (idempotent by eventId — safe to retry).
router.post('/events', verifyAuth, async (req, res) => {
  const events = req.body?.events;
  if (!Array.isArray(events) || events.length === 0 || events.length > MAX_BATCH) {
    return res.status(400).send({ msg: `events must be an array of 1-${MAX_BATCH}` });
  }
  if (!events.every(validEvent)) {
    return res.status(400).send({ msg: 'malformed event in batch' });
  }
  try {
    const fresh = await DB.insertReviewEvents(req.user.email, events);
    await ingestPhoneEvents(req.user.email, fresh);
    res.send({ accepted: fresh.length, duplicates: events.length - fresh.length });
  } catch (err) {
    console.error('[sync] push failed:', err.message);
    res.status(500).send({ msg: 'sync push failed' });
  }
});

// Pull events newer than the cursor (other devices + web work).
router.get('/changes', verifyAuth, async (req, res) => {
  try {
    const out = await DB.getReviewEventsSince(req.user.email, req.query.since || null);
    res.send(out);
  } catch (err) {
    console.error('[sync] pull failed:', err.message);
    res.status(500).send({ msg: 'sync pull failed' });
  }
});

// Today's phone work, for the dashboard activity line.
router.get('/today', verifyAuth, async (req, res) => {
  const localDate =
    typeof req.query.date === 'string' && DATE_RE.test(req.query.date)
      ? req.query.date
      : new Date().toISOString().slice(0, 10);
  try {
    res.send(await DB.getPhoneActivity(req.user.email, localDate));
  } catch (err) {
    console.error('[sync] today failed:', err.message);
    res.status(500).send({ msg: 'sync today failed' });
  }
});

module.exports = router;

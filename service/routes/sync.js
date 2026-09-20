const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { computeStudyMastery, composeMastery } = require('../mastery.js');
const { clearedGames, gamesHalf, gamesIn } = require('../gamesHalf.js');
const { calculateStreak } = require('../streak.js');
const { getWeekId } = require('./leaderboard.js');
const { XP, phoneXp } = require('../xp.js');
const { evaluateBadges } = require('../badges.js');

const router = express.Router();

const GRADES = new Set(['forgot', 'fuzzy', 'gotIt']);

// Phone XP is derived from events (never synced) and capped per local day so
// couch card-grinding can't outscore desk work on the leaderboard. The values
// + cap live in ../xp.js (the single XP source of truth).
const SOURCES = new Set(['web', 'ios', 'android']);
const MAX_BATCH = 200;
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

// A "grab paper" hand-off from the phone: a paper-tier problem set aside for
// the desk. Not a graded review — a to-do item for the web Tonight card.
function validPaperFlag(f) {
  return (
    f &&
    typeof f.itemId === 'string' && f.itemId.length >= 1 && f.itemId.length <= 80 &&
    typeof f.chapterId === 'string' && f.chapterId.length <= 40 &&
    (f.source === 'ios' || f.source === 'android') &&
    typeof f.ts === 'number' &&
    typeof f.localDate === 'string' && DATE_RE.test(f.localDate) &&
    (f.statement == null || typeof f.statement === 'string')
  );
}

// The kinds the phone may push. Answers are the default (no `kind`); the
// others carry a small `data` object (ADR 0018, step 2).
const PHONE_KINDS = new Set(['answer', 'lesson-opened', 'concept-read']);

function validEvent(e) {
  if (!e || typeof e.eventId !== 'string' || e.eventId.length < 8 || e.eventId.length > 64) return false;
  const kind = e.kind === undefined ? 'answer' : e.kind;
  if (!PHONE_KINDS.has(kind)) return false;
  if (typeof e.source !== 'string' || !SOURCES.has(e.source)) return false;
  if (typeof e.ts !== 'number' || typeof e.localDate !== 'string' || !DATE_RE.test(e.localDate)) return false;
  if (typeof e.chapterId !== 'string' || e.chapterId.length > 40) return false;
  if (kind === 'answer') {
    return typeof e.itemId === 'string' && e.itemId.length <= 80 && GRADES.has(e.grade);
  }
  return e.data === undefined || (typeof e.data === 'object' && e.data !== null && JSON.stringify(e.data).length <= 2000);
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
async function ingestPhoneEvents(email, events, device) {
  const phone = events.filter((e) => e.source !== 'web');
  if (!phone.length) return;
  const answers = phone.filter((e) => (e.kind || 'answer') === 'answer');

  // 1) Same-day dedupe + schedule push: each reviewed item updates the
  //    parent problem's history, so it leaves today's web due queue.
  const touchedChapters = new Map();
  for (const e of answers) {
    await DB.upsertProblemHistory(
      email, parentId(e.itemId), e.chapterId, e.grade !== 'forgot', 'phone');
    touchedChapters.set(e.chapterId, true);
  }

  // 2) The games half: 50 times the share of the chapter's games cleared,
  //    from every phone event on the chapter (gamesHalf.js). The desk half is
  //    recomputed too, since problem history just moved; phone-only rows add
  //    nothing to it. One formula (mastery.js composeMastery).
  const currentStats = (await DB.getUserStats(email)) || {};
  const chapterMastery = { ...(currentStats.chapterMastery || {}) };
  for (const ch of touchedChapters.keys()) {
    const [hist, phoneEvents] = await Promise.all([
      DB.getProblemHistoryForChapter(email, ch),
      DB.getPhoneEventsForChapter(email, ch),
    ]);
    const cleared = clearedGames(ch, phoneEvents);
    chapterMastery[ch] = composeMastery({
      ...(chapterMastery[ch] || {}),
      studyScore: computeStudyMastery(hist),
      gamesHalf: gamesHalf(ch, cleared),
      gamesCleared: cleared.length,
      gamesTotal: Object.keys(gamesIn(ch)).length,
    });
  }

  // 3) One streak: credit the event's CLIENT-local day (offline Tuesday
  //    synced Wednesday still counts Tuesday).
  const latestDay = phone.map((e) => e.localDate).sort().pop();
  const streakResult = calculateStreak(currentStats, latestDay);

  // 4) Derived XP, capped per local day: recompute the day's capped total
  //    with and without this batch — the delta is what's newly earned.
  let xpDelta = 0;
  const byDay = new Map();
  for (const e of answers) {
    const c = byDay.get(e.localDate) || { gotIt: 0, fuzzy: 0, forgot: 0 };
    c[e.grade]++;
    byDay.set(e.localDate, c);
  }
  for (const [day, fresh] of byDay) {
    const after = await DB.getPhoneGradeCounts(email, day); // includes fresh (already inserted)
    const before = {
      gotIt: after.gotIt - fresh.gotIt,
      fuzzy: after.fuzzy - fresh.fuzzy,
      forgot: after.forgot - fresh.forgot,
    };
    xpDelta += Math.min(XP.phoneDailyCap, phoneXp(after)) - Math.min(XP.phoneDailyCap, phoneXp(before));
  }
  const weekId = getWeekId();
  const weeklyXp = (currentStats.weekId === weekId ? currentStats.weeklyXp || 0 : 0) + xpDelta;

  // Visible sync state: which device synced and when. Source comes from the
  // events; the human label comes from the client (never assume iPhone).
  const latest = phone.reduce((a, b) => (b.ts > a.ts ? b : a));

  // 5) Badges (audit F7): the phone earns them the same as the desk, and
  //    the count on the account sheet moves the moment they land.
  const forBadges = {
    ...currentStats,
    totalXp: (currentStats.totalXp || 0) + xpDelta,
    currentStreak: streakResult.currentStreak,
    longestStreak: streakResult.longestStreak,
    badges: currentStats.badges || [],
  };
  const newBadgeIds = evaluateBadges(forBadges, { correct: 0, total: 0 });
  const badges = newBadgeIds.length ? [...forBadges.badges, ...newBadgeIds] : forBadges.badges;

  await DB.updateUserStats(email, {
    chapterMastery,
    badges,
    currentStreak: streakResult.currentStreak,
    longestStreak: streakResult.longestStreak,
    freezeUsedThisWeek: streakResult.freezeUsedThisWeek,
    lastSessionDate: streakResult.lastSessionDate,
    totalXp: (currentStats.totalXp || 0) + xpDelta,
    weekId,
    weeklyXp,
    lastSyncAt: Date.now(),
    lastSyncSource: latest.source,
    lastSyncDevice: device || null,
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
  const device = typeof req.body.device === 'string' ? req.body.device.slice(0, 60) : null;
  try {
    const fresh = await DB.insertReviewEvents(req.user.email, events);
    await ingestPhoneEvents(req.user.email, fresh, device);
    res.send({ accepted: fresh.length, duplicates: events.length - fresh.length });
  } catch (err) {
    console.error('[sync] push failed:', err.message);
    res.status(500).send({ msg: 'sync push failed' });
  }
});

// Push paper hand-off flags from the phone (idempotent per item+day).
router.post('/paper-flags', verifyAuth, async (req, res) => {
  const flags = req.body?.flags;
  if (!Array.isArray(flags) || flags.length === 0 || flags.length > MAX_BATCH) {
    return res.status(400).send({ msg: `flags must be an array of 1-${MAX_BATCH}` });
  }
  if (!flags.every(validPaperFlag)) {
    return res.status(400).send({ msg: 'malformed paper flag in batch' });
  }
  try {
    const saved = await DB.upsertPaperFlags(req.user.email, flags);
    res.send({ saved });
  } catch (err) {
    console.error('[sync] paper-flags failed:', err.message);
    res.status(500).send({ msg: 'paper-flags push failed' });
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
    const [activity, paperFlags, stats] = await Promise.all([
      DB.getPhoneActivity(req.user.email, localDate),
      DB.getPaperFlagsForDay(req.user.email, localDate),
      DB.getUserStats(req.user.email),
    ]);
    const lastSync = stats && stats.lastSyncAt
      ? { at: stats.lastSyncAt, device: stats.lastSyncDevice || null, source: stats.lastSyncSource || null }
      : null;
    res.send({ ...activity, paperFlags, lastSync });
  } catch (err) {
    console.error('[sync] today failed:', err.message);
    res.status(500).send({ msg: 'sync today failed' });
  }
});

// The days this student studied, for the phone's calendar. The count is the
// same cumulative "days studied" the dashboard shows; the list is what the
// calendar can place (days before the list existed were backfilled from the
// dated records, so an old account may hold fewer days than its count).
router.get('/study-days', verifyAuth, async (req, res) => {
  try {
    const [days, stats] = await Promise.all([
      DB.getStudyDays(req.user.email),
      DB.getUserStats(req.user.email),
    ]);
    res.send({ days, count: (stats && stats.currentStreak) || 0 });
  } catch (err) {
    console.error('[sync] study-days failed:', err.message);
    res.status(500).send({ msg: 'study-days failed' });
  }
});

module.exports = router;
// Exported for tests: the mobile game client builds this exact shape, and a
// drift here fails silently in the app (the push is caught and reported as
// "did not reach your account").
module.exports.validEvent = validEvent;

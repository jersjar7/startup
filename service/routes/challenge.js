const express = require('express');
const DB = require('../database.js');
const { isExcluded } = require('../internalAccounts.js');
const { challengeOn, nextAfter, lessonsOf, finishedCount } = require('../challenges.js');

const router = express.Router();

const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;
const COUNT_TTL_MS = 5 * 60 * 1000;
const counts = new Map(); // month -> { at, value }

/** How many students finished this month's challenge, cached for a few minutes. */
async function countFor(c) {
  const hit = counts.get(c.month);
  if (hit && Date.now() - hit.at < COUNT_TTL_MS) return hit.value;
  const practice = lessonsOf(c.chapterId).flatMap((l) => l.practice);
  const rows = await DB.getChapterAnswersBetween(c.chapterId, c.start, c.end, practice);
  const byEmail = new Map();
  for (const r of rows) {
    if (isExcluded(r.email)) continue;
    if (!byEmail.has(r.email)) byEmail.set(r.email, []);
    byEmail.get(r.email).push(r);
  }
  const value = finishedCount(c, byEmail);
  counts.set(c.month, { at: Date.now(), value });
  return value;
}

// The month's challenge for anyone, signed in or not (ADR 0027): the phone,
// a guest, the public /challenge page. The student's own progress comes with
// GET /api/account/state. `date` is the caller's local day.
router.get('/current', async (req, res) => {
  const today = typeof req.query.date === 'string' && DAY_RE.test(req.query.date)
    ? req.query.date : new Date().toISOString().slice(0, 10);
  const current = challengeOn(today);
  let finished = null;
  if (current) {
    try {
      finished = await countFor(current);
    } catch (err) {
      console.error('[challenge] count failed:', err.message);
    }
  }
  res.set('Cache-Control', 'public, max-age=60');
  res.send({ current, finished, next: current ? null : nextAfter(today) });
});

module.exports = router;

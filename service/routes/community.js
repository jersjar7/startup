const express = require('express');
const { verifyAuth } = require('../middleware/auth.js');
const DB = require('../database.js');
const { isExcluded } = require('../internalAccounts.js');
const { sanitizeName, displayName } = require('../profile.js');
const { groupingKey } = require('../school.js');
const { shortSchoolName } = require('../schoolDirectory.js');
const { buildFeed } = require('../community.js');
const { challengeOn, lessonsOf } = require('../challenges.js');
const { dayNumber, isOpenDate } = require('../daily.js');

const router = express.Router();

const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;
const FEED_TTL_MS = 60 * 1000;
const SCHOOL_TTL_MS = 5 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
const WEEK_MS = 7 * DAY_MS;
// A school line only once a school has this many students studying, the
// same rule the Daily's school board uses.
const SCHOOL_MIN = 5;

const feeds = new Map(); // `${date}|${internal}` -> { at, value }
let schools = null; // { at, byEmail: Map(email -> school) }

// A student who has not set a name is "A student" here, never part of their
// email: the feed is about company, not about who.
function feedName(user) {
  return user && sanitizeName(user.firstName || '') ? displayName(user) : 'A student';
}

async function feedFor(today, internalViewer) {
  const key = `${today}|${internalViewer}`;
  const hit = feeds.get(key);
  if (hit && Date.now() - hit.at < FEED_TTL_MS) return hit.value;

  const now = Date.now();
  // Our own accounts never show to students; they do see each other, so the
  // team can test the feed (the Daily's rule, owner 2026-10-16).
  const shown = (email) => internalViewer || !isExcluded(email);
  const current = challengeOn(today);
  const [answers, challengeRows, dailies, studied] = await Promise.all([
    DB.getAnswersSince(now - DAY_MS),
    current
      ? DB.getChapterAnswersBetween(current.chapterId, current.start, current.end, lessonsOf(current.chapterId).flatMap((l) => l.practice))
      : [],
    isOpenDate(today) ? DB.listDailyFinishers(dayNumber(today)).catch(() => []) : [],
    DB.emailsStudiedOn(today),
  ]);

  const eventsByEmail = new Map();
  for (const r of challengeRows) {
    if (!shown(r.email)) continue;
    if (!eventsByEmail.has(r.email)) eventsByEmail.set(r.email, []);
    eventsByEmail.get(r.email).push(r);
  }
  const rows = buildFeed({
    answers: answers.filter((e) => shown(e.email)),
    challenge: current ? { entry: current, eventsByEmail } : null,
    dailies: dailies.filter((d) => shown(d.email)),
    now,
    limit: 10, // a few spare, since the viewer's own row is taken out
  });
  const users = await DB.getUsersByEmails(rows.map((r) => r.email));
  const byEmail = new Map(users.map((u) => [u.email, u]));
  const value = {
    rows: rows.map((r) => ({ ...r, name: feedName(byEmail.get(r.email)) })),
    studiedToday: studied.filter(shown).length,
  };
  feeds.set(key, { at: Date.now(), value });
  return value;
}

/** How many students from the viewer's school studied in the last week. */
async function schoolLine(viewer) {
  const key = groupingKey(viewer.school);
  if (!key) return null;
  if (!schools || Date.now() - schools.at > SCHOOL_TTL_MS) {
    const emails = (await DB.emailsActiveSince(Date.now() - WEEK_MS)).filter((e) => !isExcluded(e));
    const users = await DB.getUsersByEmails(emails);
    schools = { at: Date.now(), byEmail: new Map(users.map((u) => [u.email, u.school])) };
  }
  let count = 0;
  for (const school of schools.byEmail.values()) if (groupingKey(school) === key) count += 1;
  if (count < SCHOOL_MIN) return null;
  return { name: shortSchoolName(viewer.school.name) || viewer.school.name, count };
}

// What other students are doing (docs/dashboard.md): one row each, the
// people working right now first, with today's count and the viewer's
// school. `date` is the viewer's local day.
router.get('/now', verifyAuth, async (req, res) => {
  const today = typeof req.query.date === 'string' && DAY_RE.test(req.query.date)
    ? req.query.date : new Date().toISOString().slice(0, 10);
  try {
    const internalViewer = isExcluded(req.user.email);
    const [feed, school] = await Promise.all([feedFor(today, internalViewer), schoolLine(req.user).catch(() => null)]);
    res.send({
      rows: feed.rows.filter((r) => r.email !== req.user.email).slice(0, 6).map(({ email, ...rest }) => rest),
      studiedToday: feed.studiedToday,
      school,
      now: Date.now(),
    });
  } catch (err) {
    console.error('[community] feed failed:', err.message);
    res.status(500).send({ msg: 'The feed is not available right now.' });
  }
});

// For tests: forget the cached feed and schools.
router.resetCache = () => { feeds.clear(); schools = null; };

module.exports = router;

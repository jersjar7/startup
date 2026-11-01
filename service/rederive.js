// Step 3 of ADR 0018: the one place derived state is written.
//
// A writer appends its events to the log and calls rederiveAccount. This
// reads the whole log back, runs the deriver, and writes what it says into
// the caches the surfaces read (userStats, problemHistory). No route
// computes a figure of its own any more; the nightly re-derive
// (scripts/rederiveAll.js) runs the same function over every account.
//
// What is kept from the stored record rather than derived: badges already
// earned (never revoked), the longest streak ever shown, the phone's last
// sync fields, and everything that is not progress (email verification,
// purchases, the acquisition survey).

const DB = require('./database.js');
const { deriveAccount } = require('./derive.js');
const { evaluateBadges } = require('./badges.js');

// The week's id for a YYYY-MM-DD day, and today's day, both by the Eastern
// calendar the leagues run on (ADR 0037). getWeekId() uses the same reckoning.
const { weekIdFor, dayIn } = require('./leagues/week.js');

async function allEvents(email) {
  const out = [];
  let cursor = null;
  for (;;) {
    const page = await DB.getReviewEventsSince(email, cursor, 5000);
    out.push(...page.events);
    if (page.events.length < 5000 || !page.cursor || page.cursor === cursor) break;
    cursor = page.cursor;
  }
  return out;
}

/**
 * Re-derives one account from its log and writes the result.
 * @param {string} email
 * @param {object} [opts]
 * @param {object} [opts.sessionContext]  {correct, total} of the session just finished, for the perfect-session badge
 * @param {object} [opts.extra]  fields to set alongside (the phone's lastSync*)
 */
async function rederiveAccount(email, { sessionContext = null, extra = {} } = {}) {
  const [events, existing] = await Promise.all([allEvents(email), DB.getUserStats(email)]);
  const prior = existing || {};
  const d = deriveAccount({ events });

  const thisWeek = weekIdFor(dayIn(new Date()));
  let weeklyXp = 0;
  for (const [day, xp] of Object.entries(d.xpByDay)) if (weekIdFor(day) === thisWeek) weeklyXp += xp;

  const longestStreak = Math.max(prior.longestStreak || 0, d.daysStudied);
  const forBadges = {
    totalXp: d.totalXp, longestStreak, topicProgress: d.topicProgress, chapterMastery: d.chapterMastery, badges: prior.badges || [],
  };
  const newBadgeIds = evaluateBadges(forBadges, sessionContext);
  const badges = newBadgeIds.length ? [...(prior.badges || []), ...newBadgeIds] : (prior.badges || []);

  const stats = {
    email,
    chapterMastery: d.chapterMastery,
    studyDays: d.studyDays,
    currentStreak: d.daysStudied,
    longestStreak,
    lastSessionDate: d.lastSessionDate,
    totalXp: d.totalXp,
    weekId: thisWeek,
    weeklyXp,
    topicProgress: d.topicProgress,
    badges,
    diagnosticCompleted: !!(prior.diagnosticCompleted || d.sessions.diagnostic > 0),
    diagnosticAttempts: Math.max(prior.diagnosticAttempts || 0, d.sessions.diagnostic),
    ...extra,
  };
  await DB.replaceUserStats(email, stats);
  await DB.replaceProblemHistory(email, d.history);
  // The first XP of the week puts the student in a league group. Placement
  // never touches a tier and never throws, so this can neither undo a week's
  // result nor cost anyone their progress (ADR 0037).
  await require('./leagues/league.js').placeIfEarning(email, weeklyXp);

  return { ...d, weeklyXp, longestStreak, badges, newBadgeIds, stats };
}

module.exports = { rederiveAccount, weekIdFor, allEvents };

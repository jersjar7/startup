// Weekly leagues (ADR 0037, docs/leagues-spec.md).
//
// A student joins a group of their tier the first time they earn XP in a
// week, so every row on a board is someone studying that week. When the week
// ends, each group is ranked: the top move up a tier, the bottom move down,
// everyone else stays. A week with no XP changes nothing.

const DB = require('../database.js');
const { deriveAccount } = require('../derive.js');
const { isExcluded } = require('../internalAccounts.js');
const { LEAGUE, STARTING_TIER, stepTier } = require('./config.js');
const { weekIdFor, currentWeekId } = require('./week.js');

/**
 * Ranks a group: most XP first. Equal XP goes to whoever got there first
 * (their last XP of the week came earlier), then to whoever joined first.
 * rows: [{ email, xp, lastAt, joinIndex }]
 */
function rankGroup(rows) {
  const at = (r) => (Number.isFinite(r.lastAt) ? r.lastAt : Infinity);
  return [...rows]
    .sort((a, b) => (b.xp - a.xp) || (at(a) - at(b)) || (a.joinIndex - b.joinIndex))
    .map((r, i) => ({ ...r, place: i + 1 }));
}

/**
 * What a ranked group means for each member's tier. A group under the
 * minimum size has no move-down zone, so a thin group never sends anyone
 * down; the top tier has nowhere up and the bottom nowhere down.
 */
function resultsFor(tier, ranked, weekId, cfg = LEAGUE) {
  const size = ranked.length;
  const demotes = size >= cfg.minGroupForDemotion;
  return ranked.map((r) => {
    let moved = 'stayed';
    if (r.place <= cfg.promote && stepTier(tier, 1) !== tier) moved = 'up';
    else if (demotes && r.place > size - cfg.demote && stepTier(tier, -1) !== tier) moved = 'down';
    const newTier = moved === 'up' ? stepTier(tier, 1) : moved === 'down' ? stepTier(tier, -1) : tier;
    return { email: r.email, weekId, tier, place: r.place, size, xp: r.xp, moved, newTier };
  });
}

/**
 * Puts a student into this week's league if they have earned XP and are not
 * in one yet. Never throws: a league problem must never cost anyone their
 * progress, so the caller only ever sees a logged error.
 */
async function placeIfEarning(email, weeklyXp, now = new Date()) {
  if (!(weeklyXp > 0) || isExcluded(email)) return null;
  const weekId = currentWeekId(now);
  try {
    const standing = await DB.claimLeaguePlacement(email, weekId, STARTING_TIER);
    if (!standing) return null; // already placed this week
    try {
      const tier = standing.tier || STARTING_TIER;
      const group = await DB.addToLeagueGroup(email, weekId, tier, LEAGUE.groupSize);
      await DB.setLeagueGroupForStanding(email, weekId, group._id);
      return group;
    } catch (e) {
      await DB.releaseLeaguePlacement(email, weekId); // try again on their next XP
      throw e;
    }
  } catch (e) {
    console.error(`[leagues] could not place ${email}: ${e.message}`);
    return null;
  }
}

/**
 * A student's XP in one week, from the log, and when they last earned any.
 * Read from the log rather than the weekly cache, because by the time a week
 * closes the cache already holds the new week.
 */
async function weekXpFromLog(email, weekId, events) {
  const d = deriveAccount({ events });
  let xp = 0;
  for (const [day, v] of Object.entries(d.xpByDay)) if (weekIdFor(day) === weekId) xp += v;
  let lastAt = null;
  for (const e of events) {
    if (e && /^\d{4}-\d{2}-\d{2}$/.test(e.localDate || '') && weekIdFor(e.localDate) === weekId && Number.isFinite(e.ts)) {
      lastAt = lastAt == null ? e.ts : Math.max(lastAt, e.ts);
    }
  }
  return { xp, lastAt };
}

/**
 * Closes every group of a week that ended before this one: ranks it, moves
 * each member's tier, and records the result. Safe to run twice: a student
 * already moved for that week is skipped, and a closed group is not reopened.
 * Returns a summary for the log.
 */
async function closeEndedWeeks(now = new Date(), { loadEvents } = {}) {
  const { allEvents } = require('../rederive.js');
  const events = loadEvents || allEvents;
  const groups = await DB.listOpenLeagueGroupsBefore(currentWeekId(now));
  const summary = { groups: 0, students: 0, up: 0, down: 0 };
  for (const g of groups) {
    const rows = [];
    for (let i = 0; i < g.members.length; i++) {
      const email = g.members[i];
      const { xp, lastAt } = await weekXpFromLog(email, g.weekId, await events(email));
      rows.push({ email, xp, lastAt, joinIndex: i });
    }
    const results = resultsFor(g.tier, rankGroup(rows), g.weekId);
    for (const r of results) {
      if (await DB.applyLeagueResult(r.email, r)) {
        summary.students++;
        if (r.moved === 'up') summary.up++;
        if (r.moved === 'down') summary.down++;
      }
    }
    if (await DB.closeLeagueGroup(g._id, results)) summary.groups++;
  }
  return summary;
}

module.exports = { rankGroup, resultsFor, placeIfEarning, weekXpFromLog, closeEndedWeeks };

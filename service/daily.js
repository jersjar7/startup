// The Daily: three whole games from three chapters, the same for every
// student that day, played once (owner's call, 2026-10-15).
//
// Why the server picks and the phone does not: every phone could work the
// three out from the date alone, but a phone on an older version knows fewer
// games, so on the day after an update two students would be comparing
// scores on different puzzles. The server picks once, stores the pick, and
// every phone plays what it was handed.
//
// The picks are drawn from the games the phone already has, played whole.
// A single round out of its game makes no sense ("Same setup, different
// triangle"), and the concept sheet a game opens with is what turns a guess
// into something learned.
//
// The Daily is practice like any game. Its rounds reach the event log through
// the game itself, and none of it touches mastery (ADR 0020).
//
// Everything in this file is pure. routes/daily.js does the storage.

const catalog = require('./gameCatalog.json'); // {chapterId: {gameId: rounds}}
const { EXAM_DISTRIBUTION } = require('./examWeights.js');

/**
 * Daily No. 1. Every later day is one more. The number is an internal key for
 * matching results and tracking the cycle; students only ever see the date
 * (ADR 0022).
 */
const DAILY_EPOCH = '2026-10-15';

/** Three chapters a day. */
const GAMES_PER_DAY = 3;

/** A school's own board opens once this many of its students play one day. */
const SCHOOL_BOARD_MIN = 5;

/** How many names the results show above your own row. */
const TOP_COUNT = 2;

const DAY_MS = 86400000;
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

function utcDay(date) {
  if (typeof date !== 'string' || !DATE_RE.test(date)) return null;
  const t = Date.parse(`${date}T00:00:00Z`);
  if (Number.isNaN(t)) return null;
  // Rejects 2026-02-31, which Date.parse quietly rolls into March.
  if (new Date(t).toISOString().slice(0, 10) !== date) return null;
  return t;
}

/** 'YYYY-MM-DD' -> its Daily number, or null before the first Daily. */
function dayNumber(date) {
  const t = utcDay(date);
  if (t === null) return null;
  const n = Math.round((t - utcDay(DAILY_EPOCH)) / DAY_MS) + 1;
  return n >= 1 ? n : null;
}

/** The date a Daily number belongs to. */
function dateOfNumber(n) {
  return new Date(utcDay(DAILY_EPOCH) + (n - 1) * DAY_MS).toISOString().slice(0, 10);
}

/**
 * Whether a phone may ask for this date's Daily. The phone sends its own
 * calendar date, because a new Daily opens at the student's midnight, not
 * ours. Every local date on Earth is within a day of the UTC date, so
 * anything further out is somebody trying to see tomorrow's games early.
 */
function isOpenDate(date, now = Date.now()) {
  const t = utcDay(date);
  if (t === null || dayNumber(date) === null) return false;
  const today = utcDay(new Date(now).toISOString().slice(0, 10));
  return Math.abs(t - today) <= DAY_MS;
}

/** A small seeded generator (mulberry32), so a day's pick is repeatable. */
function seeded(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/**
 * The games already used in the current cycle, from the stored Dailies in
 * order. A Daily that opened a new cycle starts the set again.
 */
function usedThisCycle(puzzles) {
  const used = new Set();
  for (const p of [...puzzles].sort((a, b) => a.number - b.number)) {
    if (p.newCycle) used.clear();
    for (const g of p.games) used.add(g.gameId);
  }
  return used;
}

/**
 * One day's three games.
 *
 * No game comes up twice until every game has come up once: a cycle runs
 * through all of them, then starts again. Chapters are drawn by how much of
 * the exam they are, scaled by how much of the chapter is still unplayed this
 * cycle, so the heavy chapters come up more often without running dry long
 * before the light ones.
 *
 * Returns {games, newCycle}. newCycle is true when too few chapters had
 * anything left and the cycle started again with this Daily.
 */
function pickGames({ number, used = new Set(), games = catalog, weights = EXAM_DISTRIBUTION }) {
  const random = seeded(number * 2654435761);
  const chapters = Object.keys(games).sort();
  const left = (u) => Object.fromEntries(
    chapters.map((c) => [c, Object.keys(games[c]).sort().filter((g) => !u.has(g))]),
  );

  let remaining = left(used);
  let newCycle = false;
  if (chapters.filter((c) => remaining[c].length > 0).length < GAMES_PER_DAY) {
    remaining = left(new Set());
    newCycle = true;
  }

  const picked = [];
  const pool = chapters.filter((c) => remaining[c].length > 0);
  for (let i = 0; i < GAMES_PER_DAY && pool.length > 0; i++) {
    const weightOf = (c) => (weights[c] || 1) * (remaining[c].length / Object.keys(games[c]).length);
    const sum = pool.reduce((s, c) => s + weightOf(c), 0);
    let roll = random() * sum;
    let at = 0;
    while (at < pool.length - 1 && roll >= weightOf(pool[at])) {
      roll -= weightOf(pool[at]);
      at++;
    }
    const chapterId = pool.splice(at, 1)[0];
    const options = remaining[chapterId];
    const gameId = options[Math.floor(random() * options.length)];
    picked.push({ chapterId, gameId, rounds: games[chapterId][gameId] });
  }
  return { games: picked, newCycle };
}

/**
 * Checks a finished Daily against the puzzle it claims to be.
 *
 * `rounds` is one list per game, one boolean per round: right on the first
 * try or not. The score is how many were. `ms` is the time on the clock,
 * which only breaks ties.
 */
function validateResult(body, puzzle) {
  const rounds = body && body.rounds;
  if (!Array.isArray(rounds) || rounds.length !== puzzle.games.length) {
    return { ok: false, msg: 'That does not match today\'s Daily.' };
  }
  for (let i = 0; i < rounds.length; i++) {
    const r = rounds[i];
    if (!Array.isArray(r) || r.length !== puzzle.games[i].rounds || !r.every((x) => typeof x === 'boolean')) {
      return { ok: false, msg: 'That does not match today\'s Daily.' };
    }
  }
  const ms = Number(body.ms);
  if (!Number.isFinite(ms) || ms <= 0) return { ok: false, msg: 'Missing the time.' };
  const total = rounds.reduce((s, r) => s + r.length, 0);
  const score = rounds.reduce((s, r) => s + r.filter(Boolean).length, 0);
  // Never fewer than a second a round, never more than six hours.
  const clamped = Math.round(Math.min(Math.max(ms, total * 1000), 6 * 3600 * 1000));
  return { ok: true, value: { rounds, score, total, ms: clamped } };
}

/** Best first: the higher score, then the faster time, then whoever was first in. */
function ranked(results) {
  return [...results].sort((a, b) => b.score - a.score
    || a.ms - b.ms
    || new Date(a.createdAt) - new Date(b.createdAt));
}

/** One board: who played, how the scores spread, the top names and you. */
function board(results, email) {
  const order = ranked(results);
  const distribution = {};
  for (const r of order) distribution[r.score] = (distribution[r.score] || 0) + 1;
  const at = order.findIndex((r) => r.email === email);
  const mine = at >= 0 ? order[at] : null;
  const below = mine ? order.filter((r) => r.score < mine.score || (r.score === mine.score && r.ms > mine.ms)).length : 0;
  return {
    players: order.length,
    distribution,
    top: order.slice(0, TOP_COUNT).map((r, i) => ({ rank: i + 1, name: r.name, score: r.score, ms: r.ms, isYou: r.email === email })),
    me: mine ? {
      rank: at + 1,
      score: mine.score,
      total: mine.total,
      ms: mine.ms,
      // Share of the OTHER players you finished ahead of. Alone, nobody.
      beat: order.length > 1 ? Math.round((100 * below) / (order.length - 1)) : null,
    } : null,
  };
}

/**
 * Everything the results screen shows. `results` are the day's stored rows,
 * with internal accounts already removed except your own.
 */
function summarize(results, { email, schoolKey, schoolName }) {
  const everyone = board(results, email);
  let school = null;
  if (schoolKey) {
    const mates = results.filter((r) => r.schoolKey === schoolKey);
    const open = mates.length >= SCHOOL_BOARD_MIN;
    school = {
      name: schoolName,
      players: mates.length,
      needs: SCHOOL_BOARD_MIN,
      open,
      // Below the line the board would be three people and a name you know,
      // so it stays shut rather than half empty.
      board: open ? board(mates, email) : null,
    };
  }
  return { ...everyone, school };
}

/**
 * The streak, from the Daily numbers this account has played. It is alive
 * when it reaches today, or yesterday while today is still open.
 */
function streakOf(numbers, today) {
  const played = new Set(numbers);
  let best = 0;
  let run = 0;
  for (const n of [...played].sort((a, b) => a - b)) {
    run = played.has(n - 1) ? run + 1 : 1;
    best = Math.max(best, run);
  }
  let end = played.has(today) ? today : today - 1;
  let current = 0;
  while (played.has(end)) {
    current++;
    end--;
  }
  return { current, best, playedToday: played.has(today) };
}

module.exports = {
  DAILY_EPOCH,
  GAMES_PER_DAY,
  SCHOOL_BOARD_MIN,
  dayNumber,
  dateOfNumber,
  isOpenDate,
  usedThisCycle,
  pickGames,
  validateResult,
  ranked,
  summarize,
  streakOf,
};

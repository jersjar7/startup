import { describe, it, expect } from 'vitest';
const catalog = require('./gameCatalog.json');
const {
  DAILY_EPOCH, dayNumber, dateOfNumber, isOpenDate, usedThisCycle, pickGames,
  validateResult, summarize, streakOf, SCHOOL_BOARD_MIN,
} = require('./daily.js');

const allGames = Object.values(catalog).reduce((n, c) => n + Object.keys(c).length, 0);

/** Runs the picker the way the route does, day after day from No. 1. */
function simulate(days) {
  const puzzles = [];
  for (let n = 1; n <= days; n++) {
    const { games, newCycle } = pickGames({ number: n, used: usedThisCycle(puzzles) });
    puzzles.push({ number: n, games, newCycle });
  }
  return puzzles;
}

describe('the Daily calendar', () => {
  it('numbers days from the first Daily', () => {
    expect(dayNumber(DAILY_EPOCH)).toBe(1);
    expect(dayNumber('2026-10-17')).toBe(2);
    expect(dayNumber('2026-10-15')).toBeNull();
    expect(dateOfNumber(1)).toBe(DAILY_EPOCH);
    expect(dateOfNumber(dayNumber('2027-03-14'))).toBe('2027-03-14');
  });

  it('is not fooled by a daylight saving change or a date that does not exist', () => {
    expect(dayNumber('2026-11-02') - dayNumber('2026-11-01')).toBe(1);
    expect(dayNumber('2027-02-31')).toBeNull();
    expect(dayNumber('soon')).toBeNull();
  });

  it('opens a date within a day of UTC, so every time zone gets its own midnight', () => {
    const now = Date.parse('2026-10-20T12:00:00Z');
    expect(isOpenDate('2026-10-19', now)).toBe(true);
    expect(isOpenDate('2026-10-20', now)).toBe(true);
    expect(isOpenDate('2026-10-21', now)).toBe(true);
    expect(isOpenDate('2026-10-22', now)).toBe(false);
    expect(isOpenDate('2026-10-18', now)).toBe(false);
  });
});

describe('picking the three games', () => {
  it('gives three games from three different chapters, the same every time', () => {
    const a = pickGames({ number: 7 });
    const b = pickGames({ number: 7 });
    expect(a).toEqual(b);
    expect(a.games).toHaveLength(3);
    expect(new Set(a.games.map((g) => g.chapterId)).size).toBe(3);
    for (const g of a.games) expect(catalog[g.chapterId][g.gameId]).toBe(g.rounds);
  });

  it('changes from one day to the next', () => {
    expect(pickGames({ number: 8 }).games).not.toEqual(pickGames({ number: 9 }).games);
  });

  it('plays no game twice until every game has come up once', () => {
    const puzzles = simulate(200);
    const firstCycleEnd = puzzles.findIndex((p, i) => i > 0 && p.newCycle);
    expect(firstCycleEnd).toBeGreaterThan(0);
    const firstCycle = puzzles.slice(0, firstCycleEnd).flatMap((p) => p.games.map((g) => g.gameId));
    expect(new Set(firstCycle).size).toBe(firstCycle.length);
    // A cycle ends only when fewer than three chapters have anything left,
    // so it covers nearly everything.
    expect(firstCycle.length).toBeGreaterThan(allGames * 0.9);
  });

  it('brings the heavy chapters up more often than the light ones', () => {
    const counts = {};
    for (const p of simulate(60)) for (const g of p.games) counts[g.chapterId] = (counts[g.chapterId] || 0) + 1;
    expect(counts.structural || 0).toBeGreaterThan(counts.statistics || 0);
  });
});

describe('a finished Daily', () => {
  const puzzle = { games: [{ rounds: 2 }, { rounds: 3 }, { rounds: 1 }] };

  it('scores the rounds right on the first try', () => {
    const r = validateResult({ rounds: [[true, false], [true, true, true], [false]], ms: 90000 }, puzzle);
    expect(r).toEqual({ ok: true, value: { rounds: [[true, false], [true, true, true], [false]], score: 4, total: 6, ms: 90000 } });
  });

  it('refuses rounds that do not match the puzzle', () => {
    expect(validateResult({ rounds: [[true], [true, true, true], [false]], ms: 1 }, puzzle).ok).toBe(false);
    expect(validateResult({ rounds: [[true, 'yes'], [true, true, true], [false]], ms: 1 }, puzzle).ok).toBe(false);
    expect(validateResult({ rounds: [[true, true]], ms: 1 }, puzzle).ok).toBe(false);
    expect(validateResult({ rounds: [[true, false], [true, true, true], [false]] }, puzzle).ok).toBe(false);
  });

  it('allows no less than a second a round on the clock', () => {
    expect(validateResult({ rounds: [[true, true], [true, true, true], [true]], ms: 5 }, puzzle).value.ms).toBe(6000);
  });
});

describe('how everyone did', () => {
  const row = (email, score, ms, schoolKey = null) => ({ email, name: email, score, total: 18, ms, schoolKey, createdAt: 0 });
  const rows = [row('a', 18, 120000), row('b', 18, 100000), row('me', 16, 161000, 'byu'), row('c', 15, 90000), row('d', 12, 200000)];

  it('ranks by score, then time, and says who you beat', () => {
    const s = summarize(rows, { email: 'me' });
    expect(s.players).toBe(5);
    expect(s.top.map((t) => t.name)).toEqual(['b', 'a']);
    expect(s.me).toMatchObject({ rank: 3, score: 16, beat: 50 });
    expect(s.distribution).toEqual({ 18: 2, 16: 1, 15: 1, 12: 1 });
  });

  it('keeps a school board shut until enough of its students play', () => {
    const closed = summarize(rows, { email: 'me', schoolKey: 'byu', schoolName: 'BYU' });
    expect(closed.school).toMatchObject({ name: 'BYU', players: 1, needs: SCHOOL_BOARD_MIN, open: false, board: null });

    const mates = Array.from({ length: SCHOOL_BOARD_MIN - 1 }, (_, i) => row(`s${i}`, 10 + i, 100000, 'byu'));
    const open = summarize([...rows, ...mates], { email: 'me', schoolKey: 'byu', schoolName: 'BYU' });
    expect(open.school.open).toBe(true);
    expect(open.school.board.me.rank).toBe(1);
  });

  it('beats nobody when you are the only player', () => {
    expect(summarize([row('me', 9, 1000)], { email: 'me' }).me.beat).toBeNull();
  });
});

describe('the streak', () => {
  it('counts the run that reaches today', () => {
    expect(streakOf([1, 2, 4, 5, 6], 6)).toEqual({ current: 3, best: 3, playedToday: true });
  });

  it('stays alive through today until today is over', () => {
    expect(streakOf([3, 4, 5], 6)).toEqual({ current: 3, best: 3, playedToday: false });
  });

  it('is gone after a missed day, and remembers the best', () => {
    expect(streakOf([1, 2, 3, 4], 7)).toEqual({ current: 0, best: 4, playedToday: false });
    expect(streakOf([], 7)).toEqual({ current: 0, best: 0, playedToday: false });
  });
});

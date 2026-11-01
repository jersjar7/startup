import { describe, it, expect, beforeEach, vi } from 'vitest';
const DB = require('./database.js');
const { rankGroup, resultsFor, placeIfEarning, closeEndedWeeks } = require('./leagues/league.js');
const { LEAGUE } = require('./leagues/config.js');

// Weekly leagues (ADR 0037) against an in-memory store with the same rules
// as db/leagues.js. Nothing touches a database.

const NOW = new Date('2026-11-04T17:00:00Z'); // Wednesday of 2026-W45
const NEXT_SUNDAY = new Date('2026-11-08T09:00:00Z'); // 2026-W46

let standings;
let groups;

function store() {
  standings = new Map();
  groups = [];
  let id = 0;
  Object.assign(DB, {
    claimLeaguePlacement: async (email, weekId, startingTier) => {
      const s = standings.get(email);
      if (s && s.placingWeek === weekId) return null;
      const next = s || { email, tier: startingTier, hidden: false, history: [] };
      next.placingWeek = weekId;
      standings.set(email, next);
      return { ...next };
    },
    releaseLeaguePlacement: async (email, weekId) => {
      const s = standings.get(email);
      if (s && s.placingWeek === weekId) delete s.placingWeek;
    },
    addToLeagueGroup: async (email, weekId, tier, size) => {
      const open = groups.filter((g) => g.weekId === weekId && g.tier === tier && !g.closedAt && g.members.length < size)
        .sort((a, b) => b.groupNo - a.groupNo)[0];
      if (open) { open.members.push(email); return open; }
      const last = groups.filter((g) => g.weekId === weekId && g.tier === tier).sort((a, b) => b.groupNo - a.groupNo)[0];
      const g = { _id: ++id, weekId, tier, groupNo: (last?.groupNo || 0) + 1, members: [email], closedAt: null };
      groups.push(g);
      return g;
    },
    setLeagueGroupForStanding: async (email, weekId, groupId) => Object.assign(standings.get(email), { weekId, groupId }),
    listOpenLeagueGroupsBefore: async (weekId) => groups.filter((g) => g.weekId < weekId && !g.closedAt),
    applyLeagueResult: async (email, entry) => {
      const s = standings.get(email);
      if (s.history.some((h) => h.weekId === entry.weekId)) return false;
      s.history.push(entry);
      s.tier = entry.newTier;
      s.lastResult = { ...entry, seen: false };
      return true;
    },
    closeLeagueGroup: async (groupId, results) => {
      const g = groups.find((x) => x._id === groupId);
      if (g.closedAt) return false;
      g.closedAt = new Date();
      g.results = results;
      return true;
    },
  });
}

beforeEach(() => {
  store();
  vi.spyOn(console, 'error').mockImplementation(() => {});
});

const emails = (n, prefix = 's') => Array.from({ length: n }, (_, i) => `${prefix}${i + 1}@school.edu`);

describe('ranking a group', () => {
  it('puts the most XP first', () => {
    const r = rankGroup([{ email: 'a', xp: 10, joinIndex: 0 }, { email: 'b', xp: 30, joinIndex: 1 }]);
    expect(r.map((x) => [x.email, x.place])).toEqual([['b', 1], ['a', 2]]);
  });

  it('gives a tie to whoever got there first', () => {
    const r = rankGroup([{ email: 'late', xp: 50, lastAt: 200, joinIndex: 0 }, { email: 'early', xp: 50, lastAt: 100, joinIndex: 1 }]);
    expect(r[0].email).toBe('early');
  });

  it('falls back to who joined first when there is no time', () => {
    const r = rankGroup([{ email: 'second', xp: 50, joinIndex: 1 }, { email: 'first', xp: 50, joinIndex: 0 }]);
    expect(r[0].email).toBe('first');
  });
});

describe('what a week means for each tier', () => {
  const ranked = (n) => emails(n).map((email, i) => ({ email, xp: 1000 - i, place: i + 1 }));

  it('moves the top five up and the bottom three down', () => {
    const r = resultsFor('silver', ranked(15), '2026-W45');
    expect(r.filter((x) => x.moved === 'up').map((x) => x.place)).toEqual([1, 2, 3, 4, 5]);
    expect(r.filter((x) => x.moved === 'down').map((x) => x.place)).toEqual([13, 14, 15]);
    expect(r[0].newTier).toBe('gold');
    expect(r[14].newTier).toBe('bronze');
    expect(r[7]).toMatchObject({ moved: 'stayed', newTier: 'silver' });
  });

  it('never sends anyone down from a group under eight', () => {
    const r = resultsFor('silver', ranked(LEAGUE.minGroupForDemotion - 1), '2026-W45');
    expect(r.some((x) => x.moved === 'down')).toBe(false);
  });

  it('has nowhere up from Platinum and nowhere down from Copper', () => {
    expect(resultsFor('platinum', ranked(15), 'w').some((x) => x.moved === 'up')).toBe(false);
    expect(resultsFor('copper', ranked(15), 'w').some((x) => x.moved === 'down')).toBe(false);
  });

  it('a small group moves up only its top third', () => {
    expect(resultsFor('copper', ranked(3), 'w').filter((x) => x.moved === 'up').map((x) => x.place)).toEqual([1]);
    expect(resultsFor('copper', ranked(7), 'w').filter((x) => x.moved === 'up')).toHaveLength(2);
    expect(resultsFor('copper', ranked(8), 'w').filter((x) => x.moved === 'up')).toHaveLength(LEAGUE.promote);
  });

  it('a group of one or two moves nobody up', () => {
    expect(resultsFor('copper', ranked(1), 'w').some((x) => x.moved === 'up')).toBe(false);
    expect(resultsFor('copper', ranked(2), 'w').some((x) => x.moved === 'up')).toBe(false);
  });
});

describe('joining a league', () => {
  it('only once XP is earned', async () => {
    expect(await placeIfEarning('a@school.edu', 0, NOW)).toBeNull();
    expect(groups).toHaveLength(0);
  });

  it('puts a new student in Copper', async () => {
    await placeIfEarning('a@school.edu', 20, NOW);
    expect(groups[0]).toMatchObject({ weekId: '2026-W45', tier: 'copper', groupNo: 1, members: ['a@school.edu'] });
    expect(standings.get('a@school.edu')).toMatchObject({ tier: 'copper', weekId: '2026-W45' });
  });

  it('places a student once a week, however often they earn XP', async () => {
    await placeIfEarning('a@school.edu', 20, NOW);
    await placeIfEarning('a@school.edu', 40, NOW);
    expect(groups[0].members).toEqual(['a@school.edu']);
  });

  it('opens a second group when the first is full', async () => {
    for (const e of emails(LEAGUE.groupSize + 1)) await placeIfEarning(e, 10, NOW);
    expect(groups.map((g) => g.members.length)).toEqual([LEAGUE.groupSize, 1]);
    expect(groups[1].groupNo).toBe(2);
  });

  it('joins their own tier', async () => {
    standings.set('pro@school.edu', { email: 'pro@school.edu', tier: 'gold', history: [] });
    await placeIfEarning('pro@school.edu', 10, NOW);
    expect(groups[0].tier).toBe('gold');
  });

  it('never places internal or test accounts', async () => {
    await placeIfEarning('admin+test1@oqupa.com', 500, NOW);
    expect(groups).toHaveLength(0);
  });

  it('gives the claim back when placing fails, so the next XP tries again', async () => {
    const real = DB.addToLeagueGroup;
    DB.addToLeagueGroup = async () => { throw new Error('down'); };
    expect(await placeIfEarning('a@school.edu', 10, NOW)).toBeNull();
    DB.addToLeagueGroup = real;
    await placeIfEarning('a@school.edu', 10, NOW);
    expect(groups[0].members).toEqual(['a@school.edu']);
  });
});

describe('closing the week', () => {
  // A log with one practice session worth `xp` on a day of 2026-W45.
  const logFor = (xp, ts = 1) => [{ kind: 'session', source: 'web', localDate: '2026-11-04', ts, data: { xp } }];

  async function fill(n, tier = 'silver') {
    const list = emails(n);
    for (const e of list) {
      standings.set(e, { email: e, tier, history: [] });
      await placeIfEarning(e, 10, NOW);
    }
    return list;
  }

  it('waits until the week is over', async () => {
    await fill(3);
    const s = await closeEndedWeeks(NOW, { loadEvents: async () => [] });
    expect(s.groups).toBe(0);
  });

  it('ranks by the week\'s XP from the log and moves tiers', async () => {
    const list = await fill(15);
    const xpOf = Object.fromEntries(list.map((e, i) => [e, 100 * (i + 1)])); // s15 earned most
    const s = await closeEndedWeeks(NEXT_SUNDAY, { loadEvents: async (e) => logFor(xpOf[e]) });
    expect(s).toMatchObject({ groups: 1, students: 15, up: 5, down: 3 });
    expect(standings.get('s15@school.edu')).toMatchObject({ tier: 'gold' });
    expect(standings.get('s15@school.edu').lastResult).toMatchObject({ place: 1, moved: 'up', seen: false });
    expect(standings.get('s1@school.edu')).toMatchObject({ tier: 'bronze' });
    expect(standings.get('s8@school.edu')).toMatchObject({ tier: 'silver' });
  });

  it('running twice changes nothing the second time', async () => {
    await fill(10);
    const load = async () => logFor(0);
    await closeEndedWeeks(NEXT_SUNDAY, { loadEvents: load });
    const tiers = [...standings.values()].map((s) => s.tier);
    const again = await closeEndedWeeks(NEXT_SUNDAY, { loadEvents: load });
    expect(again).toMatchObject({ groups: 0, students: 0 });
    expect([...standings.values()].map((s) => s.tier)).toEqual(tiers);
    expect(standings.get('s1@school.edu').history).toHaveLength(1);
  });

  it('a student moved before a crash is not moved again on the rerun', async () => {
    await fill(10);
    const load = async () => logFor(0);
    const realClose = DB.closeLeagueGroup;
    DB.closeLeagueGroup = async () => { throw new Error('crash'); };
    await expect(closeEndedWeeks(NEXT_SUNDAY, { loadEvents: load })).rejects.toThrow('crash');
    DB.closeLeagueGroup = realClose;
    const tierAfterFirst = standings.get('s1@school.edu').tier;
    await closeEndedWeeks(NEXT_SUNDAY, { loadEvents: load });
    expect(standings.get('s1@school.edu').tier).toBe(tierAfterFirst);
    expect(standings.get('s1@school.edu').history).toHaveLength(1);
  });
});

describe('the admin line', () => {
  const { summarizeWeeks } = require('./leagues/league.js');
  it('counts groups and students per tier, and last week\'s moves', () => {
    const s = summarizeWeeks(
      [{ tier: 'copper', members: ['a', 'b'] }, { tier: 'copper', members: ['c'] }, { tier: 'gold', members: ['d'] }],
      [{ tier: 'silver', closedAt: new Date(), results: [{ moved: 'up' }, { moved: 'down' }, { moved: 'stayed' }] }],
    );
    expect(s.thisWeek).toMatchObject({ placed: 4, groups: 3 });
    expect(s.thisWeek.tiers.copper).toMatchObject({ groups: 2, students: 3 });
    expect(s.lastWeek).toMatchObject({ closed: 1 });
    expect(s.lastWeek.moves.silver).toEqual({ up: 1, down: 1, stayed: 1 });
    expect(JSON.stringify(s)).not.toMatch(/"a"|"b"/);
  });
});

describe('who moved since yesterday', () => {
  const { moveSince, snapshotPlaces } = require('./leagues/league.js');
  const snap = { day: '2026-11-03', places: { a: 3, b: 1, c: 2 } };

  it('compares the place now with the day\'s snapshot', () => {
    expect(moveSince(snap, 'a', 1)).toBe('up');
    expect(moveSince(snap, 'b', 2)).toBe('down');
    expect(moveSince(snap, 'c', 2)).toBeNull();
  });

  it('calls anyone not in it new, and everyone in a group without one', () => {
    expect(moveSince(snap, 'd', 4)).toBe('new');
    expect(moveSince(undefined, 'a', 1)).toBe('new');
  });

  it('records each group\'s places once a day, ranked like the board', async () => {
    const writes = [];
    DB.listLeagueGroupsToSnapshot = async (weekId, day) => {
      expect(weekId).toBe('2026-W45');
      expect(day).toBe('2026-11-04');
      return [{ _id: 'g1', members: ['a', 'b', 'c'] }];
    };
    DB.getLeagueMemberInfo = async (members) => members.map((email, i) => ({ email, weeklyXp: [50, 300, 120][i] }));
    DB.setLeagueGroupSnapshot = async (id, day, places) => { writes.push({ id, day, places }); return true; };
    expect(await snapshotPlaces(NOW)).toBe(1);
    expect(writes).toEqual([{ id: 'g1', day: '2026-11-04', places: { b: 1, c: 2, a: 3 } }]);
  });
});

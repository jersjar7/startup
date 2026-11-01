import { describe, it, expect, beforeEach, vi } from 'vitest';
const express = require('express');
const request = require('supertest');
const DB = require('./database.js');
const { currentWeekId } = require('./leagues/week.js');

// GET /api/league and its two writes, against an in-memory store. This is
// the contract the website and the phone app both read (ADR 0037).

let standings;
let group;
const WEEK = currentWeekId();

beforeEach(() => {
  vi.spyOn(console, 'error').mockImplementation(() => {});
  group = { _id: 'g1', weekId: WEEK, tier: 'silver', members: ['me@x.com', 'ana@x.com', 'shy@x.com', 'top@x.com'],
    snapshot: { day: '2026-11-01', places: { 'top@x.com': 1, 'me@x.com': 2, 'shy@x.com': 3 } } };
  standings = {
    'me@x.com': { email: 'me@x.com', tier: 'silver', weekId: WEEK, groupId: 'g1', hidden: false },
    'ana@x.com': { email: 'ana@x.com', tier: 'silver', weekId: WEEK, groupId: 'g1' },
    'shy@x.com': { email: 'shy@x.com', tier: 'silver', weekId: WEEK, groupId: 'g1', hidden: true },
    'top@x.com': { email: 'top@x.com', tier: 'silver', weekId: WEEK, groupId: 'g1' },
  };
  const info = {
    'me@x.com': { email: 'me@x.com', firstName: 'Maria', lastName: 'Gomez', weeklyXp: 300, days: 4 },
    'ana@x.com': { email: 'ana@x.com', weeklyXp: 120 },
    'shy@x.com': { email: 'shy@x.com', firstName: 'Sam', lastName: 'Lee', weeklyXp: 500 },
    'top@x.com': { email: 'top@x.com', firstName: 'Tom', weeklyXp: 900 },
  };
  Object.assign(DB, {
    getSessionByToken: async (token) => ({ email: token, lastSeen: new Date() }),
    getUser: async (e) => ({ email: e }),
    touchSession: async () => {},
    getLeagueStanding: async (e) => standings[e] || null,
    getLeagueGroup: async (id) => (id === 'g1' ? group : null),
    getLeagueMemberInfo: async (emails) => emails.map((e) => info[e]),
    getLeagueStandings: async (emails) => emails.map((e) => standings[e]).filter(Boolean),
    markLeagueResultSeen: async (e) => { if (standings[e]?.lastResult) standings[e].lastResult.seen = true; },
    setLeagueHidden: async (e, hidden) => { standings[e] = { ...(standings[e] || { email: e, tier: 'copper' }), hidden }; },
  });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(require('cookie-parser')());
  a.use('/api/league', require('./routes/league.js'));
  return a;
}
const as = (e) => ({ Authorization: `Bearer ${e}` });

describe('GET /api/league', () => {
  it('shows the group ranked by this week\'s XP, with me marked', async () => {
    const r = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(r.status).toBe(200);
    expect(r.body).toMatchObject({ tier: 'silver', tierName: 'Silver', weekId: WEEK, joined: true });
    expect(r.body.rows.map((x) => [x.place, x.name, x.xp, x.isMe])).toEqual([
      [1, 'Tom', 900, false],
      [2, 'A student', 500, false],
      [3, 'Maria G.', 300, true],
      [4, 'ana***', 120, false],
    ]);
  });

  it('says who moved since the day\'s snapshot, and how many days each studied', async () => {
    const r = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(r.body.rows.map((x) => [x.name, x.move, x.days])).toEqual([
      ['Tom', null, 0],
      ['A student', 'up', 0],
      ['Maria G.', 'down', 4],
      ['ana***', 'new', 0],
    ]);
  });

  it('never shows anyone\'s email, only the masked start', async () => {
    const r = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(JSON.stringify(r.body)).not.toContain('@x.com');
  });

  it('a hidden student still sees their own name', async () => {
    const r = await request(app()).get('/api/league').set(as('shy@x.com'));
    expect(r.body.rows.find((x) => x.isMe).name).toBe('Sam L.');
  });

  it('a small group moves up its top third and sends nobody down', async () => {
    const r = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(r.body.zones).toEqual({ promote: 1, demote: 0 });
  });

  it('names the leagues above and below, and none past either end', async () => {
    const r = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(r.body).toMatchObject({ nextTier: 'gold', nextTierName: 'Gold', prevTier: 'bronze', prevTierName: 'Bronze' });
    const fresh = await request(app()).get('/api/league').set(as('new@x.com'));
    expect(fresh.body).toMatchObject({ nextTierName: 'Bronze', prevTier: null, prevTierName: null });
  });

  it('says when the week ends', async () => {
    const r = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(new Date(r.body.weekEndsAt).getTime()).toBeGreaterThan(Date.now());
  });

  it('before the first XP of the week: their tier, no rows', async () => {
    standings['me@x.com'] = { email: 'me@x.com', tier: 'gold', weekId: '2020-W01', groupId: 'old' };
    const r = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(r.body).toMatchObject({ tier: 'gold', tierName: 'Gold', joined: false, rows: [] });
  });

  it('a brand new student is in Copper', async () => {
    const r = await request(app()).get('/api/league').set(as('new@x.com'));
    expect(r.body).toMatchObject({ tier: 'copper', joined: false, lastResult: null });
  });

  it('shows last week\'s result until it has been seen', async () => {
    standings['me@x.com'].lastResult = { weekId: '2026-W44', tier: 'bronze', place: 2, size: 15, xp: 1180, moved: 'up', newTier: 'silver', seen: false };
    const first = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(first.body.lastResult).toMatchObject({ place: 2, xp: 1180, moved: 'up', tierName: 'Bronze', newTierName: 'Silver' });
    await request(app()).post('/api/league/seen').set(as('me@x.com'));
    const again = await request(app()).get('/api/league').set(as('me@x.com'));
    expect(again.body.lastResult).toBeNull();
  });

  it('is not found while leagues are switched off', async () => {
    process.env.LEAGUES_DISABLED = '1';
    const r = await request(app()).get('/api/league').set(as('me@x.com'));
    delete process.env.LEAGUES_DISABLED;
    expect(r.status).toBe(404);
  });

  it('needs a signed-in student', async () => {
    const r = await request(app()).get('/api/league');
    expect(r.status).toBe(401);
  });
});

describe('POST /api/league/hidden', () => {
  it('saves the switch', async () => {
    const r = await request(app()).post('/api/league/hidden').set(as('me@x.com')).send({ hidden: true });
    expect(r.body).toEqual({ ok: true, hidden: true });
    expect(standings['me@x.com'].hidden).toBe(true);
  });

  it('refuses anything but true or false', async () => {
    const r = await request(app()).post('/api/league/hidden').set(as('me@x.com')).send({ hidden: 'yes' });
    expect(r.status).toBe(400);
  });
});

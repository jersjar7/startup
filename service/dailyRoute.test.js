import { describe, it, expect, beforeEach } from 'vitest';
const express = require('express');
const request = require('supertest');
const DB = require('./database.js');
const { dayNumber } = require('./daily.js');

// The Daily's routes against an in-memory store, so the contract the phone
// relies on (mobile/lib/features/daily/) is pinned without a database.

const users = {
  'me@byu.edu': { email: 'me@byu.edu', firstName: 'Ana', lastName: 'Ruiz', school: { name: 'Brigham Young University', key: 'brigham young', domain: 'byu.edu' } },
  'b@x.com': { email: 'b@x.com', firstName: 'Ben', lastName: 'Ko' },
};
let puzzles;
let results;

beforeEach(() => {
  puzzles = [];
  results = [];
  Object.assign(DB, {
    getSessionByToken: async (token) => (users[token] ? { email: token, lastSeen: new Date() } : null),
    getUser: async (email) => users[email] || null,
    touchSession: async () => {},
    getDailyPuzzle: async (n) => puzzles.find((p) => p.number === n) || null,
    listDailyPuzzles: async () => [...puzzles].sort((a, b) => a.number - b.number),
    insertDailyPuzzle: async (p) => {
      if (!puzzles.some((q) => q.number === p.number)) puzzles.push(p);
      return puzzles.find((q) => q.number === p.number);
    },
    getDailyResult: async (n, email) => results.find((r) => r.number === n && r.email === email) || null,
    insertDailyResult: async (row) => {
      if (!results.some((r) => r.number === row.number && r.email === row.email)) results.push({ ...row, createdAt: new Date() });
      return results.find((r) => r.number === row.number && r.email === row.email);
    },
    listDailyResults: async (n) => results.filter((r) => r.number === n),
    listDailyNumbers: async (email) => results.filter((r) => r.email === email).map((r) => r.number),
  });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(require('cookie-parser')());
  a.use('/api/daily', require('./routes/daily.js'));
  return a;
}

const today = new Date().toISOString().slice(0, 10);
const as = (email) => ({ Authorization: `Bearer ${email}` });
const allRight = (games) => games.map((g) => Array(g.rounds).fill(true));

describe('the Daily routes', () => {
  it('hands every phone the same three games for a date', async () => {
    const a = await request(app()).get(`/api/daily?date=${today}`).set(as('me@byu.edu'));
    const b = await request(app()).get(`/api/daily?date=${today}`).set(as('b@x.com'));
    expect(a.status).toBe(200);
    expect(a.body.number).toBe(dayNumber(today));
    expect(a.body.games).toHaveLength(3);
    expect(b.body.games).toEqual(a.body.games);
    expect(a.body.mine).toBeNull();
    expect(a.body.streak).toEqual({ current: 0, best: 0, playedToday: false });
  });

  it('shows a guest today\'s games with no account, and nothing about anybody', async () => {
    let accountReads = 0;
    const getUser = DB.getUser;
    DB.getUser = async (e) => { accountReads++; return getUser(e); };
    const guest = await request(app()).get(`/api/daily/preview?date=${today}`);
    expect(guest.status).toBe(200);
    expect(accountReads).toBe(0);
    expect(Object.keys(guest.body).sort()).toEqual(['date', 'games', 'number', 'total']);
    const signedIn = await request(app()).get(`/api/daily?date=${today}`).set(as('me@byu.edu'));
    expect(guest.body.games).toEqual(signedIn.body.games);
    expect(guest.body.total).toBe(signedIn.body.total);
    expect((await request(app()).get('/api/daily/preview?date=2099-01-01')).status).toBe(400);
  });

  it('still asks for an account to play, or to see who played', async () => {
    const { body: d } = await request(app()).get(`/api/daily/preview?date=${today}`);
    const sent = await request(app()).post(`/api/daily/${d.number}/result`)
      .send({ date: today, rounds: allRight(d.games), ms: 1000 });
    expect(sent.status).toBe(401);
    expect(results).toHaveLength(0);
    expect((await request(app()).get(`/api/daily/${d.number}/results`)).status).toBe(401);
    expect((await request(app()).get(`/api/daily?date=${today}`)).status).toBe(401);
  });

  it('will not show a day that is not open yet', async () => {
    const res = await request(app()).get('/api/daily?date=2099-01-01').set(as('me@byu.edu'));
    expect(res.status).toBe(400);
  });

  it('keeps the first try and answers with the results', async () => {
    const { body: d } = await request(app()).get(`/api/daily?date=${today}`).set(as('me@byu.edu'));
    const rounds = allRight(d.games);
    rounds[1][0] = false;
    const first = await request(app()).post(`/api/daily/${d.number}/result`).set(as('me@byu.edu'))
      .send({ date: today, rounds, ms: 150000 });
    expect(first.status).toBe(200);
    expect(first.body.mine.score).toBe(d.total - 1);
    expect(first.body.streak).toMatchObject({ current: 1, playedToday: true });
    expect(first.body.results).toMatchObject({ players: 1, me: { rank: 1 } });
    expect(first.body.results.school).toMatchObject({ name: 'BYU', open: false });

    const again = await request(app()).post(`/api/daily/${d.number}/result`).set(as('me@byu.edu'))
      .send({ date: today, rounds: allRight(d.games), ms: 60000 });
    expect(again.body.mine.score).toBe(d.total - 1);

    await request(app()).post(`/api/daily/${d.number}/result`).set(as('b@x.com'))
      .send({ date: today, rounds: allRight(d.games), ms: 200000 });
    const board = await request(app()).get(`/api/daily/${d.number}/results`).set(as('me@byu.edu'));
    expect(board.body.top.map((t) => t.name)).toEqual(['Ben K.', 'Ana R.']);
    expect(board.body.me).toMatchObject({ rank: 2, beat: 0 });
  });

  it('refuses a result for the wrong day or the wrong shape', async () => {
    const { body: d } = await request(app()).get(`/api/daily?date=${today}`).set(as('me@byu.edu'));
    const wrongDay = await request(app()).post(`/api/daily/${d.number + 5}/result`).set(as('me@byu.edu'))
      .send({ date: today, rounds: allRight(d.games), ms: 1000 });
    expect(wrongDay.status).toBe(400);
    const wrongShape = await request(app()).post(`/api/daily/${d.number}/result`).set(as('me@byu.edu'))
      .send({ date: today, rounds: [[true]], ms: 1000 });
    expect(wrongShape.status).toBe(400);
  });

  it('needs a signed-in account', async () => {
    const res = await request(app()).get(`/api/daily?date=${today}`);
    expect(res.status).toBe(401);
  });
});

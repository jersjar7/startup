import { describe, it, expect, beforeEach } from 'vitest';
const express = require('express');
const request = require('supertest');
const DB = require('./database.js');
const { lessonsOf } = require('./challenges.js');

// The challenge routes against an in-memory log: the public read the phone,
// guests and the /challenge page use, and the fields GET /api/account/state
// gains (ADR 0027).

const users = { 'me@x.com': { email: 'me@x.com' } };
let log; // rows with email

const deskAll = (email, localDate) => lessonsOf('statics').flatMap((l) =>
  l.practice.map((id) => ({ email, itemId: id, chapterId: 'statics', grade: 'gotIt', source: 'web', localDate, kind: 'answer' })));

beforeEach(() => {
  log = [];
  Object.assign(DB, {
    getSessionByToken: async (token) => (users[token] ? { email: token, lastSeen: new Date() } : null),
    getUser: async (email) => users[email] || null,
    touchSession: async () => {},
    getUserStats: async () => null,
    getReviewEventsSince: async (email) => ({ events: log.filter((r) => r.email === email), cursor: null }),
    getChapterAnswersBetween: async (chapterId, start, end) =>
      log.filter((r) => r.localDate >= start && r.localDate <= end && r.grade !== 'forgot'),
  });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(require('cookie-parser')());
  a.use('/api/challenge', require('./routes/challenge.js'));
  a.use('/api/account', require('./routes/account.js'));
  return a;
}

describe('GET /api/challenge/current', () => {
  it('before December names the next challenge and no current one', async () => {
    const res = await request(app()).get('/api/challenge/current?date=2026-11-20');
    expect(res.status).toBe(200);
    expect(res.body.current).toBeNull();
    expect(res.body.next).toMatchObject({ month: '2026-12', chapterId: 'statics', start: '2026-12-01' });
  });

  it('in December, without signing in, gives the lessons and who finished', async () => {
    log.push(...deskAll('a@y.com', '2026-12-04'));
    const res = await request(app()).get('/api/challenge/current?date=2026-12-05');
    expect(res.body.current.lessons).toHaveLength(7);
    expect(res.body.finished).toMatchObject({ finished: 1, atDesk: 1 });
    expect(res.body.next).toBeNull();
  });
});

describe('GET /api/account/state', () => {
  it('carries the month\'s progress and the finished coins', async () => {
    log.push(...deskAll('me@x.com', '2026-12-04'));
    const res = await request(app()).get('/api/account/state?date=2026-12-05').set('Authorization', 'Bearer me@x.com');
    expect(res.status).toBe(200);
    expect(res.body.challenge).toMatchObject({ month: '2026-12', cleared: 7, total: 7, finished: true, finishedAtDesk: true });
    expect(res.body.challenges).toEqual([{ month: '2026-12', chapterId: 'statics', name: 'Statics Challenge', atDesk: true }]);
  });

  it('has no challenge in a month without one', async () => {
    const res = await request(app()).get('/api/account/state?date=2026-11-05').set('Authorization', 'Bearer me@x.com');
    expect(res.body.challenge).toBeNull();
    expect(res.body.challenges).toEqual([]);
  });
});

import { describe, it, expect, beforeEach } from 'vitest';
const express = require('express');
const request = require('supertest');
const DB = require('./database.js');

// GET /api/community/now against an in-memory log (docs/dashboard.md).

const school = { name: 'Brigham Young University', domain: 'byu.edu' };
let users;
let answers;

beforeEach(() => {
  require('./routes/community.js').resetCache();
  users = {
    'me@byu.edu': { email: 'me@byu.edu', firstName: 'Ana', school },
    'maria@x.com': { email: 'maria@x.com', firstName: 'Maria', lastName: 'Garcia' },
    'noname@x.com': { email: 'noname@x.com' },
    'admin@oqupa.com': { email: 'admin@oqupa.com', firstName: 'Owner' },
  };
  answers = [];
  Object.assign(DB, {
    getSessionByToken: async (token) => (users[token] ? { email: token, lastSeen: new Date() } : null),
    getUser: async (email) => users[email] || null,
    touchSession: async () => {},
    getAnswersSince: async (since) => answers.filter((a) => a.ts >= since),
    getChapterAnswersBetween: async () => [],
    listDailyFinishers: async () => [],
    emailsStudiedOn: async () => [...new Set(answers.map((a) => a.email))],
    emailsActiveSince: async () => Object.keys(users),
    getUsersByEmails: async (emails) => emails.map((e) => users[e]).filter(Boolean),
  });
});

function app() {
  const a = express();
  a.use(require('cookie-parser')());
  a.use('/api/community', require('./routes/community.js'));
  return a;
}

const answer = (email, itemId, minsAgo) => ({ email, itemId, chapterId: 'statics', source: 'web', kind: 'answer', grade: 'gotIt', ts: Date.now() - minsAgo * 60000 });

describe('GET /api/community/now', () => {
  it('needs an account', async () => {
    const res = await request(app()).get('/api/community/now?date=2026-12-19');
    expect(res.status).toBe(401);
  });

  it('shows the others by name, never the viewer, never an email, never our accounts', async () => {
    answers.push(answer('maria@x.com', 'stat-fri-q1', 2), answer('noname@x.com', 'stat-tjs-q1', 50),
      answer('me@byu.edu', 'stat-fri-q2', 1), answer('admin@oqupa.com', 'stat-fri-q3', 1));
    const res = await request(app()).get('/api/community/now?date=2026-12-19').set('Authorization', 'Bearer me@byu.edu');
    expect(res.status).toBe(200);
    expect(res.body.rows.map((r) => [r.name, r.kind])).toEqual([['Maria G.', 'working'], ['A student', 'practiced']]);
    expect(JSON.stringify(res.body)).not.toMatch(/@/);
    expect(res.body.studiedToday).toBe(3);
  });

  it('gives a school line only once five from the school studied this week', async () => {
    const res1 = await request(app()).get('/api/community/now?date=2026-12-19').set('Authorization', 'Bearer me@byu.edu');
    expect(res1.body.school).toBeNull();
    for (let i = 0; i < 4; i++) users[`s${i}@byu.edu`] = { email: `s${i}@byu.edu`, school };
    require('./routes/community.js').resetCache();
    const res2 = await request(app()).get('/api/community/now?date=2026-12-20').set('Authorization', 'Bearer me@byu.edu');
    expect(res2.body.school).toEqual({ name: 'BYU', count: 5 });
  });
});

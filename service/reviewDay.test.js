import { describe, it, expect, beforeEach } from 'vitest';
const express = require('express');
const request = require('supertest');
const DB = require('./database.js');

// Review is due by the student's own day, the day the deriver schedules
// nextReview by, not the server's UTC day. In the evening in the Americas
// UTC is already tomorrow, so a miss at 8pm came due the same night.

const users = { 'me@x.com': { email: 'me@x.com' } };
let rows;

beforeEach(() => {
  // Missed on Monday evening, so due Tuesday.
  rows = [{ email: 'me@x.com', problemId: 'stat-fri-q1', topicId: 'statics', reviewActive: true, nextReview: '2026-12-15' }];
  const due = (today) => rows.filter((r) => r.reviewActive && r.nextReview <= today);
  Object.assign(DB, {
    getSessionByToken: async (token) => (users[token] ? { email: token, lastSeen: new Date() } : null),
    getUser: async (email) => users[email] || null,
    touchSession: async () => {},
    getUserStats: async () => ({ topicProgress: { statics: { sessionsCompleted: 1 } }, chapterMastery: {} }),
    getDueReviewCount: async (email, today) => due(today).length,
    getProblemsForReview: async (email, limit, today) => due(today).slice(0, limit),
  });
});

function app() {
  const a = express();
  a.use(require('cookie-parser')());
  a.use('/api/review', require('./routes/review.js'));
  return a;
}

const get = (path) => request(app()).get(path).set('Authorization', 'Bearer me@x.com');

describe('the review day', () => {
  it('is not due yet on the evening it was missed, by the student\'s day', async () => {
    expect((await get('/api/review/count?date=2026-12-14')).body.count).toBe(0);
    expect((await get('/api/review?count=5&date=2026-12-14')).body.problems).toEqual([]);
  });

  it('is due on the student\'s next day', async () => {
    expect((await get('/api/review/count?date=2026-12-15')).body.count).toBe(1);
    expect((await get('/api/review?count=5&date=2026-12-15')).body.problems).toEqual([
      { problemId: 'stat-fri-q1', topicId: 'statics', reviewReason: 'overdue' },
    ]);
  });

  it('ignores a date that is not a day', async () => {
    const res = await get('/api/review/count?date=tomorrow');
    expect(res.status).toBe(200);
    expect(typeof res.body.count).toBe('number');
  });
});

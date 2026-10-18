import { describe, it, expect, beforeEach } from 'vitest';
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const express = require('express');
const cookieParser = require('cookie-parser');
const request = require('supertest');
const { ObjectId } = require('mongodb');
const DB = require('./database.js');

// Two submits of one exam in flight together (a double tap, a retry on a weak
// connection) both read the attempt as in progress. Before the completion
// became a one-time claim, both went on to award the exam's XP and log a
// session. Against an in-memory store.

// The route takes rederiveAccount at load, so stand it in first.
const rederive = require('./rederive.js');
let rederived;
rederive.rederiveAccount = async () => { rederived += 1; return { daysStudied: 1, longestStreak: 1, newBadgeIds: [] }; };

const attemptId = new ObjectId();
let attempt;
let events;
let sessions;

beforeEach(() => {
  rederived = 0;
  events = [];
  sessions = [];
  attempt = {
    _id: attemptId,
    userId: 'u1',
    attemptNumber: 1,
    status: 'in_progress',
    startedAt: new Date(Date.now() - 60 * 60 * 1000),
    totalQuestions: 2,
    questions: [
      { id: 'q1', chapterId: 'ethics', choices: [{ id: 'a' }, { id: 'b' }], correctAnswerId: 'a' },
      { id: 'q2', chapterId: 'ethics', choices: [{ id: 'a' }, { id: 'b' }], correctAnswerId: 'b' },
    ],
    savedAnswers: {},
  };
  Object.assign(DB, {
    getSessionByToken: async (t) => (t === 'good' ? { email: 'me@x.com', lastSeen: new Date() } : null),
    getUser: async () => ({ _id: { toString: () => 'u1' }, email: 'me@x.com' }),
    touchSession: async () => {},
    hasPurchased: async () => true,
    // A copy, as a database returns; yields first so the two requests overlap.
    getExamAttempt: async () => { await new Promise((r) => setImmediate(r)); return structuredClone(attempt); },
    getExamAttempts: async () => [attempt],
    claimExamCompletion: async (_id, _u, update) => {
      if (attempt.status === 'completed') return false;
      Object.assign(attempt, update);
      return true;
    },
    updateExamAttempt: async (_id, _u, update) => { Object.assign(attempt, update); },
    insertReviewEvents: async (_e, list) => { events.push(...list); },
    appendEvent: async (_e, ev) => { events.push(ev); },
    logSession: async (_e, s) => { sessions.push(s); },
  });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(cookieParser());
  a.use('/api/exam', require('./routes/exam.js'));
  return a;
}

const submit = (server) => request(server).post('/api/exam/submit')
  .set('Authorization', 'Bearer good')
  .send({
    attemptId: attemptId.toString(),
    answers: [{ questionId: 'q1', selectedAnswerId: 'a' }, { questionId: 'q2', selectedAnswerId: 'a' }],
    timeUsedSeconds: 100,
  });

describe('POST /api/exam/submit, twice at once', () => {
  it('grades and rewards the exam once, and both get the same score', async () => {
    const server = app();
    const [one, two] = await Promise.all([submit(server), submit(server)]);
    expect(one.status).toBe(200);
    expect(two.status).toBe(200);
    expect(one.body.totalCorrect).toBe(1);
    expect(two.body.totalCorrect).toBe(1);
    expect(sessions).toHaveLength(1);
    expect(events.filter((e) => e.kind === 'exam')).toHaveLength(1);
    expect(rederived).toBe(1);
  });

  it('a submit after the exam is graded lands on the same result, not an error', async () => {
    const server = app();
    await submit(server);
    const again = await submit(server);
    expect(again.status).toBe(200);
    expect(again.body).toMatchObject({ totalCorrect: 1, alreadySubmitted: true });
    expect(sessions).toHaveLength(1);
  });
});

import { describe, it, expect, beforeEach } from 'vitest';
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const express = require('express');
const cookieParser = require('cookie-parser');
const request = require('supertest');
const { ObjectId } = require('mongodb');
const DB = require('./database.js');
const { mergeAutosaveStamped, mergeSubmission } = require('./examProgress.js');

// Two tabs on one exam (docs/EXAM-SIMULATION.md, open issue 2). Every save
// sends the tab's whole sheet, and a tab saves the moment it is switched away
// from, so an older tab used to undo newer answers just by being left.

describe('mergeAutosaveStamped', () => {
  it('keeps the newest choice per question, wherever it was made', () => {
    const { answers, times } = mergeAutosaveStamped(
      { q1: 'a', q2: 'b' }, { q1: 200, q2: 100 },
      { q1: 'c', q2: 'd' }, { q1: 150, q2: 300 },
      1000,
    );
    expect(answers).toEqual({ q1: 'a', q2: 'd' });
    expect(times).toEqual({ q1: 200, q2: 300 });
  });

  it('a page from before stamps still saves where nothing stamped is stored', () => {
    const { answers } = mergeAutosaveStamped({ q1: 'a' }, {}, { q1: 'b', q2: 'c' }, undefined, 1000);
    expect(answers).toEqual({ q1: 'b', q2: 'c' });
    const kept = mergeAutosaveStamped({ q1: 'a' }, { q1: 500 }, { q1: 'b' }, undefined, 1000);
    expect(kept.answers).toEqual({ q1: 'a' });
  });

  it('a clock running ahead cannot lock an answer', () => {
    const first = mergeAutosaveStamped({}, {}, { q1: 'a' }, { q1: 9e15 }, 1000);
    expect(first.times.q1).toBe(1000);
    const later = mergeAutosaveStamped(first.answers, first.times, { q1: 'b' }, { q1: 1000 }, 2000);
    expect(later.answers.q1).toBe('b');
  });

  it('a newer clear still clears', () => {
    const { answers } = mergeAutosaveStamped({ q1: 'a' }, { q1: 100 }, { q1: null }, { q1: 200 }, 1000);
    expect(answers.q1).toBeNull();
  });
});

describe('mergeSubmission with stamps', () => {
  it('a stale tab\'s submit cannot swap a newer answer back', () => {
    expect(mergeSubmission({ q1: 'new' }, { q1: 'old' }, { q1: 500 }, { q1: 100 }, 1000)).toEqual({ q1: 'new' });
    expect(mergeSubmission({ q1: 'old' }, { q1: 'new' }, { q1: 100 }, { q1: 500 }, 1000)).toEqual({ q1: 'new' });
  });

  it('still only adds, and without stamps is the old rule', () => {
    expect(mergeSubmission({ q1: 'a' }, { q1: null, q2: 'b' }, { q1: 100 }, {}, 1000)).toEqual({ q1: 'a', q2: 'b' });
    expect(mergeSubmission({ q1: 'a' }, { q1: 'b' })).toEqual({ q1: 'b' });
  });
});

// The save route itself, against an in-memory attempt.
const attemptId = new ObjectId();
let attempt;
beforeEach(() => {
  attempt = {
    _id: attemptId, userId: 'u1', status: 'in_progress', startedAt: new Date(), totalQuestions: 3,
    questions: [], savedAnswers: {},
  };
  Object.assign(DB, {
    getSessionByToken: async (t) => (t === 'good' ? { email: 'me@x.com', lastSeen: new Date() } : null),
    getUser: async () => ({ _id: { toString: () => 'u1' }, email: 'me@x.com' }),
    touchSession: async () => {},
    hasPurchased: async () => true,
    getExamAttempt: async () => structuredClone(attempt),
    updateExamAttempt: async (_id, _u, update) => { Object.assign(attempt, update); },
  });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(cookieParser());
  a.use('/api/exam', require('./routes/exam.js'));
  return a;
}
const save = (server, body) => request(server).patch('/api/exam/answers')
  .set('Authorization', 'Bearer good').send({ attemptId: attemptId.toString(), ...body });

describe('PATCH /api/exam/answers from two tabs', () => {
  it('the tab left behind cannot undo the other tab\'s answers, flags or place', async () => {
    const server = app();
    const t0 = Date.now() - 60_000;
    // Tab A answers q1 and q2, flags question 2, moves to question 3.
    await save(server, {
      answers: { q1: 'a', q2: 'b' }, answerTimes: { q1: t0 + 10, q2: t0 + 20 },
      flagged: [2], flaggedAt: t0 + 20, currentIndex: 2, indexAt: t0 + 20,
    });
    // Tab B, opened earlier, still holds the first answer it saw for q1 and
    // nothing else, and saves when the student switches away from it.
    await save(server, {
      answers: { q1: 'x' }, answerTimes: { q1: t0 + 1 },
      flagged: [], flaggedAt: t0 + 1, currentIndex: 0, indexAt: t0 + 1,
    });
    expect(attempt.savedAnswers).toEqual({ q1: 'a', q2: 'b' });
    expect(attempt.savedFlagged).toEqual([2]);
    expect(attempt.savedIndex).toBe(2);

    // A genuinely newer change in tab B does land.
    await save(server, { answers: { q1: 'x' }, answerTimes: { q1: t0 + 30 } });
    expect(attempt.savedAnswers.q1).toBe('x');
  });
});

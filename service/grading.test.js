import { describe, it, expect, beforeEach, vi } from 'vitest';
const express = require('express');
const request = require('supertest');
const DB = require('./database.js');
const { validAnswer, gradeAnswers, scoreAnswers } = require('./grading.js');

// Desk answers are graded by the server and a problem earns XP once a day
// (ADR 0038).

const content = {
  problemsById: {
    p1: { correctAnswerId: 'b' },
    p2: { correctAnswerId: 'a' },
    p3: { correctAnswerId: 'c' },
  },
};

describe('grading', () => {
  it('decides right and wrong from the bank, not the browser', () => {
    const g = gradeAnswers([
      { problemId: 'p1', choiceId: 'b', isCorrect: false },
      { problemId: 'p2', choiceId: 'c', isCorrect: true },
    ], content);
    expect(g.map((a) => [a.isCorrect, a.graded, a.known])).toEqual([[true, true, true], [false, true, true]]);
  });

  it('marks a problem it does not hold as wrong and unknown', () => {
    const [a] = gradeAnswers([{ problemId: 'made-up', choiceId: 'a' }], content);
    expect(a).toMatchObject({ isCorrect: false, known: false });
  });

  it('keeps an old build\'s right or wrong, ungraded', () => {
    const [a] = gradeAnswers([{ problemId: 'p1', isCorrect: true }], content);
    expect(a).toMatchObject({ isCorrect: true, graded: false, known: true });
  });

  it('accepts a choice or, from an old build, right or wrong', () => {
    expect(validAnswer({ problemId: 'p1', choiceId: 'a' })).toBe(true);
    expect(validAnswer({ problemId: 'p1', isCorrect: false })).toBe(true);
    expect(validAnswer({ problemId: 'p1' })).toBe(false);
    expect(validAnswer({ problemId: 'p1', choiceId: 3 })).toBe(false);
    expect(validAnswer({ choiceId: 'a' })).toBe(false);
  });
});

describe('XP for a session', () => {
  const g = (rows) => gradeAnswers(rows, content);

  it('pays 10 right and 5 wrong, plus the bonus', () => {
    const xp = scoreAnswers(g([{ problemId: 'p1', choiceId: 'b' }, { problemId: 'p2', choiceId: 'b' }]), new Set(), 25);
    expect(xp).toEqual({ correct: 10, incorrect: 5, bonus: 25, total: 40, repeats: 0 });
  });

  it('pays nothing for a problem already answered today', () => {
    const xp = scoreAnswers(g([{ problemId: 'p1', choiceId: 'b' }, { problemId: 'p2', choiceId: 'a' }]), new Set(['p1']), 25);
    expect(xp).toMatchObject({ correct: 10, total: 35, repeats: 1 });
  });

  it('counts a problem asked twice in one session once', () => {
    const xp = scoreAnswers(g([{ problemId: 'p1', choiceId: 'b' }, { problemId: 'p1', choiceId: 'b' }]), new Set(), 15);
    expect(xp).toMatchObject({ correct: 10, total: 25, repeats: 1 });
  });

  it('pays no finishing bonus for a session made only of repeats', () => {
    const xp = scoreAnswers(g([{ problemId: 'p1', choiceId: 'b' }, { problemId: 'p2', choiceId: 'a' }]), new Set(['p1', 'p2']), 25);
    expect(xp).toEqual({ correct: 0, incorrect: 0, bonus: 0, total: 0, repeats: 2 });
  });

  it('pays an old build\'s "right" only the attempt XP', () => {
    const xp = scoreAnswers(g([{ problemId: 'p1', isCorrect: true }]), new Set(), 0);
    expect(xp.total).toBe(5);
  });

  it('pays nothing for a problem the server does not hold', () => {
    const xp = scoreAnswers(g([{ problemId: 'nope', choiceId: 'a' }]), new Set(), 0);
    expect(xp.total).toBe(0);
  });
});

describe('POST /api/sessions', () => {
  let written;
  beforeEach(() => {
    vi.spyOn(console, 'error').mockImplementation(() => {});
    written = [];
    Object.assign(DB, {
      getSessionByToken: async (token) => ({ email: token, lastSeen: new Date() }),
      getUser: async (e) => ({ email: e }),
      touchSession: async () => {},
      getDeskAnsweredOn: async () => new Set(['math-slq-q2']),
      insertReviewEvents: async (e, ev) => { written.push(...ev); return ev; },
      appendEvent: async (e, ev) => { written.push(ev); },
      logSession: async () => {},
    });
  });

  function app() {
    // The route takes rederiveAccount when it is first required, so stub it first.
    require('./rederive.js').rederiveAccount = async () => ({ daysStudied: 1, longestStreak: 1, newBadgeIds: [] });
    const a = express();
    a.use(express.json());
    a.use(require('cookie-parser')());
    a.use('/api/sessions', require('./routes/sessions.js'));
    return a;
  }

  it('grades on the server and skips today\'s repeats', async () => {
    const real = require('./content.json').problemsById;
    const right = real['math-slq-q1'].correctAnswerId;
    const r = await request(app()).post('/api/sessions').set('Authorization', 'Bearer me@x.com').send({
      topicId: 'mathematics',
      localDate: '2026-11-02',
      answers: [
        { problemId: 'math-slq-q1', choiceId: right, isCorrect: false },
        { problemId: 'math-slq-q2', choiceId: real['math-slq-q2'].correctAnswerId },
        { problemId: 'math-slq-q3', choiceId: 'zz', isCorrect: true },
      ],
    });
    expect(r.status).toBe(200);
    expect(r.body.sessionSummary).toMatchObject({ correct: 2, incorrect: 1 });
    expect(r.body.sessionSummary.xpEarned).toEqual({ correct: 10, incorrect: 5, sessionBonus: 25, total: 40, repeats: 1 });
    const answers = written.filter((e) => e.grade);
    expect(answers.map((e) => e.grade)).toEqual(['gotIt', 'gotIt', 'forgot']);
    expect(written.find((e) => e.kind === 'session').data.xp).toBe(40);
  });

  it('refuses an answer with neither a choice nor right or wrong', async () => {
    const r = await request(app()).post('/api/sessions').set('Authorization', 'Bearer me@x.com')
      .send({ topicId: 'mathematics', answers: [{ problemId: 'math-slq-q1' }] });
    expect(r.status).toBe(400);
  });
});

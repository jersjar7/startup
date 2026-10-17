import { describe, it, expect, beforeEach, vi } from 'vitest';
// The email module builds its client on load; a dummy key keeps it quiet, and
// nothing is ever sent (the one send is stubbed below).
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const express = require('express');
const request = require('supertest');
const DB = require('./database.js');
const { userCollection } = require('./db/connection.js');
const email = require('./email.js');

// The routes behind ADR 0023: what we call a student, the name on their pass
// card, and the results links the app opens. Against an in-memory store, so
// the contract both clients rely on is pinned without a database.

let users;
const passedOutcome = { answeredAt: new Date('2026-11-29'), sat: true, passed: true };

beforeEach(() => {
  users = {
    'named@x.com': { email: 'named@x.com', firstName: 'Sammy', outcomeToken: 'tok-named', examOutcome: passedOutcome },
    'blank@x.com': { email: 'blank@x.com', outcomeToken: 'tok-blank', examOutcome: passedOutcome },
    'failed@x.com': { email: 'failed@x.com', firstName: 'Fay', outcomeToken: 'tok-failed', examOutcome: { answeredAt: new Date(), sat: true, passed: false } },
    'open@x.com': { email: 'open@x.com', outcomeToken: 'tok-open', examDate: '2026-11-20' },
  };
  const byToken = (q) => Object.values(users).find((u) => u.outcomeToken === q.outcomeToken) || null;
  const apply = (u, set) => {
    for (const [k, v] of Object.entries(set)) {
      if (!k.includes('.')) { u[k] = v; continue; }
      const [a, b] = k.split('.');
      u[a] = { ...(u[a] || {}), [b]: v };
    }
  };
  Object.assign(userCollection, {
    // A copy, as a real database returns: a snapshot, not the live record.
    findOne: async (q) => {
      const u = byToken(q);
      return u ? JSON.parse(JSON.stringify(u)) : null;
    },
    updateOne: async (q, op) => {
      const u = byToken(q);
      if (!u) return { matchedCount: 0 };
      apply(u, op.$set || {});
      return { matchedCount: 1 };
    },
  });
  Object.assign(DB, {
    getSessionByToken: async (token) => (users[token] ? { email: token, lastSeen: new Date() } : null),
    getUser: async (e) => users[e] || null,
    touchSession: async () => {},
    setUserFields: async (e, set) => apply(users[e], set),
    addUser: async (u) => { users[u.email] = u; },
    createSession: async () => 'session-token',
    getUserStats: async () => null,
    countProblemsAnswered: async () => 0,
  });
  vi.spyOn(email, 'sendVerificationEmail').mockResolvedValue({ ok: true });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(require('cookie-parser')());
  a.use('/api/email', require('./routes/email.js'));
  a.use('/api/auth', require('./routes/auth.js'));
  return a;
}
const as = (e) => ({ Authorization: `Bearer ${e}` });

describe('what we call a student', () => {
  it('takes a first name when the account is made', async () => {
    const r = await request(app()).post('/api/auth/create')
      .send({ email: 'new@x.com', password: 'Abcdefg1', firstName: '  Sam ' });
    expect(r.status).toBe(200);
    expect(users['new@x.com'].firstName).toBe('Sam');
  });

  it('makes the account without one, too', async () => {
    const r = await request(app()).post('/api/auth/create')
      .send({ email: 'none@x.com', password: 'Abcdefg1' });
    expect(r.status).toBe(200);
    expect(users['none@x.com'].firstName).toBeUndefined();
  });

  it('drops a name that is only junk', async () => {
    await request(app()).post('/api/auth/create')
      .send({ email: 'junk@x.com', password: 'Abcdefg1', firstName: '!!! 123' });
    expect(users['junk@x.com'].firstName).toBeUndefined();
  });
});

describe('the name on the pass card, from the email link', () => {
  it('fills the question with the account\'s name', async () => {
    const r = await request(app()).get('/api/email/pass-card/tok-named');
    expect(r.status).toBe(200);
    expect(r.body.suggestedName).toBe('Sammy');
  });

  it('saves the card\'s own name and leaves the account\'s alone', async () => {
    const r = await request(app()).post('/api/email/pass-card/tok-named/name').send({ name: 'Samantha Reyes' });
    expect(r.status).toBe(200);
    expect(r.body.cardName).toBe('Samantha Reyes');
    expect(users['named@x.com'].cardName).toBe('Samantha Reyes');
    expect(users['named@x.com'].firstName).toBe('Sammy');
    // And it comes back filled in next time.
    const again = await request(app()).get('/api/email/pass-card/tok-named');
    expect(again.body.suggestedName).toBe('Samantha Reyes');
  });

  it('fills a blank account name', async () => {
    await request(app()).post('/api/email/pass-card/tok-blank/name').send({ name: 'Ana Ruiz' });
    expect(users['blank@x.com']).toMatchObject({ cardName: 'Ana Ruiz', firstName: 'Ana', lastName: 'Ruiz' });
  });

  it('has no card for somebody who did not pass', async () => {
    expect((await request(app()).get('/api/email/pass-card/tok-failed')).status).toBe(404);
    expect((await request(app()).post('/api/email/pass-card/tok-failed/name').send({ name: 'X Y' })).status).toBe(404);
    expect(users['failed@x.com'].cardName).toBeUndefined();
  });
});

describe('the name on the pass card, signed in', () => {
  it('is on the account, ready to draw', async () => {
    const r = await request(app()).get('/api/auth/me').set(as('named@x.com'));
    expect(r.body.passCard.suggestedName).toBe('Sammy');
    const none = await request(app()).get('/api/auth/me').set(as('failed@x.com'));
    expect(none.body.passCard).toBeNull();
  });

  it('saves the card\'s own name', async () => {
    const r = await request(app()).post('/api/auth/card-name').set(as('named@x.com')).send({ name: 'Samantha Reyes' });
    expect(r.status).toBe(200);
    expect(users['named@x.com'].cardName).toBe('Samantha Reyes');
    expect(users['named@x.com'].firstName).toBe('Sammy');
  });

  it('refuses without a pass', async () => {
    const r = await request(app()).post('/api/auth/card-name').set(as('failed@x.com')).send({ name: 'Fay Lu' });
    expect(r.status).toBe(404);
  });
});

describe('the results links, opened by the app', () => {
  it('records the answer and says so in JSON', async () => {
    const r = await request(app()).get('/api/email/exam-result/tok-open?a=passed&format=json');
    expect(r.status).toBe(200);
    expect(r.type).toMatch(/json/);
    expect(r.body).toMatchObject({ ok: true, answer: 'passed', already: false, card: true });
    expect(users['open@x.com'].examOutcome.passed).toBe(true);
  });

  it('cannot change an answer already given', async () => {
    const r = await request(app()).get('/api/email/exam-result/tok-failed?a=passed')
      .set('Accept', 'application/json');
    expect(r.body.already).toBe(true);
    expect(r.body.card).toBe(false);
    expect(users['failed@x.com'].examOutcome.passed).toBe(false);
  });

  it('answers an unknown link the same way for everyone', async () => {
    const r = await request(app()).get('/api/email/exam-result/nope?a=passed&format=json');
    expect(r.status).toBe(404);
    expect(r.body.ok).toBe(false);
  });

  it('still serves the page to a browser', async () => {
    const r = await request(app()).get('/api/email/exam-result/tok-open?a=passed');
    expect(r.type).toMatch(/html/);
  });

  it('records the attempt in JSON too', async () => {
    const r = await request(app()).get('/api/email/exam-attempt/tok-named?n=1&format=json');
    expect(r.body).toEqual({ ok: true });
    expect(users['named@x.com'].examOutcome.attemptNumber).toBe(1);
  });
});

// The school step comes before the account exists, on both sign-ups, so the
// directory's suggestions must answer without a sign-in (owner, 2026-10-16:
// the app's sign-up had none for nine days because this was signed-in only).
describe('school suggestions', () => {
  it('answer before there is an account', async () => {
    const r = await request(app()).get('/api/auth/schools?q=brigham');
    expect(r.status).toBe(200);
    expect(r.body.schools).toContain('Brigham Young University');
  });

  it('say nothing for one letter, rather than half the directory', async () => {
    const r = await request(app()).get('/api/auth/schools?q=b');
    expect(r.body.schools).toEqual([]);
  });

  it('carry nothing but institution names', async () => {
    const r = await request(app()).get('/api/auth/schools?q=university');
    expect(JSON.stringify(r.body)).not.toContain('@');
    expect(r.body.schools.every((s) => typeof s === 'string')).toBe(true);
  });

  it('are limited, so the open endpoint cannot be hammered', async () => {
    const a = app();
    let limited = false;
    for (let i = 0; i < 130 && !limited; i++) {
      const r = await request(a).get('/api/auth/schools?q=state');
      limited = r.status === 429;
    }
    expect(limited).toBe(true);
  });
});

// "I have already graduated" is an answer, not a blank: repeat takers are a
// third of the FE Civil population (owner, 2026-10-16: the app showed
// "Not set" after it was tapped, and both clients saved a plain null).
describe('already graduated', () => {
  it('is kept at sign-up, apart from somebody who skipped the year', async () => {
    await request(app()).post('/api/auth/create').send({
      email: 'grad@x.com', password: 'Abcdefg1', school: 'Brigham Young University', graduated: true,
    });
    await request(app()).post('/api/auth/create').send({
      email: 'skip@x.com', password: 'Abcdefg1', school: 'Brigham Young University',
    });
    expect(users['grad@x.com'].school).toMatchObject({ graduated: true, graduationYear: null });
    expect(users['skip@x.com'].school).toMatchObject({ graduated: false, graduationYear: null });
  });

  it('keeps the year they graduated, and never a year still to come', async () => {
    const now = new Date().getUTCFullYear();
    await request(app()).post('/api/auth/create').send({
      email: 'past@x.com', password: 'Abcdefg1', school: 'BYU', graduated: true,
      graduationYear: 2019, graduationTerm: 'spring',
    });
    await request(app()).post('/api/auth/create').send({
      email: 'future@x.com', password: 'Abcdefg1', school: 'BYU', graduated: true, graduationYear: now + 1,
    });
    // The year, with no term: years later the term only costs a tap.
    expect(users['past@x.com'].school).toMatchObject({ graduated: true, graduationYear: 2019, graduationTerm: null });
    expect(users['future@x.com'].school).toMatchObject({ graduated: true, graduationYear: null });
  });

  it('saves the year they graduated from the account, too', async () => {
    users['named@x.com'].school = { name: 'BYU' };
    await request(app()).post('/api/auth/school').set(as('named@x.com'))
      .send({ name: 'BYU', graduated: true, graduationYear: 2019 });
    expect(users['named@x.com'].school).toMatchObject({ graduated: true, graduationYear: 2019 });
    const me = await request(app()).get('/api/auth/me').set(as('named@x.com'));
    expect(me.body.school).toMatchObject({ graduated: true, graduationYear: 2019 });
  });

  it('is saved from the account and shown back', async () => {
    users['named@x.com'].school = { name: 'BYU' };
    await request(app()).post('/api/auth/school').set(as('named@x.com'))
      .send({ name: 'BYU', graduated: true });
    expect(users['named@x.com'].school.graduated).toBe(true);
    const me = await request(app()).get('/api/auth/me').set(as('named@x.com'));
    expect(me.body.school.graduated).toBe(true);
  });

  it('is not forgotten by a client that only edits the name', async () => {
    users['named@x.com'].school = { name: 'BYU', graduated: true };
    await request(app()).post('/api/auth/school').set(as('named@x.com')).send({ name: 'BYU Idaho' });
    expect(users['named@x.com'].school.graduated).toBe(true);
  });

  it('gives way when a graduation year is picked', async () => {
    users['named@x.com'].school = { name: 'BYU', graduated: true };
    await request(app()).post('/api/auth/school').set(as('named@x.com'))
      .send({ name: 'BYU', graduationYear: 2027 });
    expect(users['named@x.com'].school.graduated).toBe(false);
  });
});

describe('the last day studied', () => {
  it('reaches the phone, for its reminders and its greeting', async () => {
    DB.getUserStats = async () => ({ lastSessionDate: '2026-10-15', currentStreak: 4 });
    const r = await request(app()).get('/api/auth/me').set(as('named@x.com'));
    expect(r.body.lastSessionDate).toBe('2026-10-15');
  });

  it('carries the days in a row ending on it, apart from the total', async () => {
    DB.getUserStats = async () => ({
      lastSessionDate: '2026-10-15',
      currentStreak: 6, // the cumulative count, despite its name
      studyDays: ['2026-10-01', '2026-10-05', '2026-10-09', '2026-10-13', '2026-10-14', '2026-10-15'],
    });
    const r = await request(app()).get('/api/auth/me').set(as('named@x.com'));
    expect(r.body.currentStreak).toBe(6);
    expect(r.body.runToLastDay).toBe(3);
  });

  it('is null for somebody who has not studied', async () => {
    const r = await request(app()).get('/api/auth/me').set(as('named@x.com'));
    expect(r.body.lastSessionDate).toBeNull();
  });
});

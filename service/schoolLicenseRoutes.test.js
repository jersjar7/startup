import { describe, it, expect, beforeEach } from 'vitest';
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
process.env.STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY || 'sk_test_dummy_never_called';
const express = require('express');
const cookieParser = require('cookie-parser');
const request = require('supertest');
const { ObjectId } = require('mongodb');
const DB = require('./database.js');
const { hashToken } = require('./crypto.js');

// School site licences (ADR 0040) through the real routes, against an
// in-memory store: the exam gate, the checkout status the pages read, the
// student code that unlocks it, and the owner-only admin endpoints.

// The exam route takes rederiveAccount at load, so stand it in first.
const rederive = require('./rederive.js');
rederive.rederiveAccount = async () => ({ daysStudied: 1, longestStreak: 1, newBadgeIds: [] });

const ADMIN = 'admin@oqupa.com';
const DAY = 24 * 60 * 60 * 1000;

let users; // email -> user
let licenses;
let claims;
let attempts;
let purchases;

function addUser(email, fields = {}) {
  const u = { _id: new ObjectId(), email, emailVerified: true, ...fields };
  users[email] = u;
  return u;
}

function addLicense(over = {}) {
  const l = {
    _id: new ObjectId(),
    schoolName: 'Brigham Young University',
    domains: ['byu.edu'],
    startsAt: new Date(Date.now() - 30 * DAY),
    endsAt: new Date(Date.now() + 300 * DAY),
    seatCap: 500,
    seatsUsed: 0,
    contactName: 'Dr. Ames',
    contactEmail: 'ames@byu.edu',
    notes: 'PO 123',
    createdAt: new Date(),
    ...over,
  };
  licenses.push(l);
  return l;
}

beforeEach(() => {
  users = {};
  licenses = [];
  claims = [];
  attempts = [];
  purchases = [];
  Object.assign(DB, {
    // Auth: the bearer token IS the email in these tests.
    getSessionByToken: async (t) => (users[t] ? { email: t, lastSeen: new Date() } : null),
    getUser: async (email) => (users[email] ? { ...users[email] } : null),
    touchSession: async () => {},
    setUserFields: async (email, f) => { Object.assign(users[email], f); },
    unsetUserFields: async (email, keys) => { for (const k of keys) delete users[email][k]; },
    logEvent: async () => {},

    hasPurchased: async (userId) => purchases.some((p) => p.userId === userId && p.status === 'completed'),
    recordPurchase: async () => { throw new Error('a licence must never record a purchase'); },

    findLicensesForDomains: async (domains) => licenses
      .filter((l) => l.domains.some((d) => domains.includes(d)))
      .map((l) => ({ ...l })),
    getClaimsForUser: async (userId) => claims.filter((c) => c.userId === userId),
    // Same shape as the real one: claim row first (unique), then a counter
    // that only moves under the cap; yields so concurrent claims interleave.
    claimSeat: async (license, userId, domain) => {
      const id = String(license._id);
      if (claims.some((c) => String(c.licenseId) === id && c.userId === userId)) return true;
      claims.push({ licenseId: license._id, userId, domain });
      await new Promise((r) => setImmediate(r));
      const l = licenses.find((x) => String(x._id) === id);
      if ((l.seatsUsed || 0) < l.seatCap) { l.seatsUsed = (l.seatsUsed || 0) + 1; return true; }
      claims = claims.filter((c) => !(String(c.licenseId) === id && c.userId === userId));
      return false;
    },

    listSchoolLicenses: async () => licenses.map((l) => ({ ...l })),
    getSchoolLicense: async (id) => licenses.find((l) => String(l._id) === String(id)) || null,
    createSchoolLicense: async (fields) => addLicense({ ...fields, seatsUsed: 0 }),
    updateSchoolLicense: async (id, fields) => {
      const l = licenses.find((x) => String(x._id) === String(id));
      Object.assign(l, fields);
      return { ...l };
    },

    getExamAttempts: async (userId) => attempts.filter((a) => a.userId === userId)
      .map(({ questions, ...a }) => a), // eslint-disable-line no-unused-vars
    getExamAttempt: async (id, userId) => {
      const a = attempts.find((x) => x._id.toString() === id && x.userId === userId);
      return a ? { ...a, savedAnswers: { ...(a.savedAnswers || {}) } } : null;
    },
    getExamAttemptCount: async (userId) => attempts.filter((a) => a.userId === userId).length,
    getExamQuestionIdsSeen: async () => [],
    createExamAttempt: async (userId, a) => {
      const _id = new ObjectId();
      attempts.push({ _id, userId, ...structuredClone(a) });
      return _id;
    },
    updateExamAttempt: async (id, _u, update) => { Object.assign(attempts.find((a) => a._id.toString() === id), update); },
    claimExamCompletion: async (id, _u, update) => {
      const a = attempts.find((x) => x._id.toString() === id);
      if (a.status === 'completed') return false;
      Object.assign(a, update);
      return true;
    },
    insertReviewEvents: async () => {},
    appendEvent: async () => {},
    logSession: async () => {},
  });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(cookieParser());
  a.use('/api/exam', require('./routes/exam.js'));
  a.use('/api/checkout', require('./routes/checkout.js'));
  a.use('/api/admin', require('./routes/admin.js'));
  return a;
}

const as = (email) => ({ Authorization: `Bearer ${email}` });
const start = (server, email) => request(server).post('/api/exam/start').set(as(email)).send({});
const status = (server, email) => request(server).get('/api/checkout/status').set(as(email));
const codeVerifiedAt = (school) => ({ studentVerified: true, verifiedStudentEmail: school });

describe('the exam gate, through a school licence', () => {
  it('lets a code-verified student in, takes one seat, and never records a sale', async () => {
    const lic = addLicense();
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    const server = app();

    const res = await start(server, u.email);
    expect(res.status).toBe(200);
    expect(res.body.questions).toHaveLength(110);
    expect(lic.seatsUsed).toBe(1);
    expect(claims).toHaveLength(1);
    expect(attempts[0]).toMatchObject({ accessVia: 'school' });
    expect(String(attempts[0].schoolLicenseId)).toBe(String(lic._id));
    expect(purchases).toHaveLength(0);

    // Coming back resumes and does not take a second seat.
    const again = await start(server, u.email);
    expect(again.body.resumed).toBe(true);
    expect(lic.seatsUsed).toBe(1);
  });

  it('lets a student whose verified account address is on the domain in', async () => {
    addLicense();
    const u = addUser('sam@byu.edu', { emailVerified: true });
    expect((await start(app(), u.email)).status).toBe(200);
  });

  it('turns away an unverified student, takes no seat, and says why', async () => {
    const lic = addLicense();
    const u = addUser('sam@byu.edu', { emailVerified: false });
    const res = await start(app(), u.email);
    expect(res.status).toBe(403);
    expect(res.body.reason).toBe('unverified');
    expect(lic.seatsUsed).toBe(0);
  });

  it('turns away a verified student at a school with no licence', async () => {
    addLicense();
    const u = addUser('lee@gmail.com', codeVerifiedAt('lee@utah.edu'));
    const res = await start(app(), u.email);
    expect(res.status).toBe(403);
    expect(res.body.reason).toBe('none');
  });

  it('turns away a lookalike domain', async () => {
    addLicense();
    const u = addUser('x@byu.edu.evil.com', { emailVerified: true });
    expect((await start(app(), u.email)).status).toBe(403);
  });

  it('when the seats are gone, a new student is told to ask their department', async () => {
    const lic = addLicense({ seatCap: 2, seatsUsed: 2 });
    const u = addUser('late@gmail.com', codeVerifiedAt('late@byu.edu'));
    const res = await start(app(), u.email);
    expect(res.status).toBe(403);
    expect(res.body.reason).toBe('seats_full');
    expect(res.body.msg).toMatch(/department/i);
    expect(lic.seatsUsed).toBe(2);
  });

  it('two students racing for the last seat: exactly one gets it', async () => {
    const lic = addLicense({ seatCap: 1 });
    const a = addUser('a@gmail.com', codeVerifiedAt('a@byu.edu'));
    const b = addUser('b@gmail.com', codeVerifiedAt('b@byu.edu'));
    const server = app();
    const [ra, rb] = await Promise.all([start(server, a.email), start(server, b.email)]);
    expect([ra.status, rb.status].sort()).toEqual([200, 403]);
    expect(lic.seatsUsed).toBe(1);
    expect(claims).toHaveLength(1);
  });

  it('an expired licence lets nobody start', async () => {
    addLicense({ endsAt: new Date(Date.now() - DAY) });
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    expect((await start(app(), u.email)).status).toBe(403);
  });

  it('a licence ending mid-exam does not end the exam, but no new one starts', async () => {
    const lic = addLicense();
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    const server = app();
    const first = await start(server, u.email);
    const attemptId = first.body.attemptId;
    const q = first.body.questions[0];

    lic.endedAt = new Date(); // the owner ends it

    // Resume still works and still renders the stored questions.
    const resumed = await start(server, u.email);
    expect(resumed.status).toBe(200);
    expect(resumed.body.attemptId).toBe(attemptId);

    const save = await request(server).patch('/api/exam/answers').set(as(u.email))
      .send({ attemptId, answers: { [q.id]: q.choices[0].id } });
    expect(save.status).toBe(200);

    // Another attempt id is not part of the grace.
    const other = await request(server).patch('/api/exam/answers').set(as(u.email))
      .send({ attemptId: new ObjectId().toString(), answers: {} });
    expect(other.status).toBe(403);

    const sub = await request(server).post('/api/exam/submit').set(as(u.email))
      .send({ attemptId, answers: [], timeUsedSeconds: 60 });
    expect(sub.status).toBe(200);
    // Submit only adds: the autosaved answer was kept.
    expect(sub.body.totalAttempted).toBe(1);

    const next = await start(server, u.email);
    expect(next.status).toBe(403);
  });

  it('the status tells a student whose licence ended that their exam is still open', async () => {
    const lic = addLicense();
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    const server = app();
    await start(server, u.email);
    lic.endedAt = new Date();
    const res = await status(server, u.email);
    expect(res.body).toMatchObject({ purchased: false, unfinishedSchoolExam: true });
  });

  it('an attempt that ran out of time after the licence ended is graded, not dropped', async () => {
    addLicense({ endedAt: new Date() });
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    const questions = Array.from({ length: 20 }, (_, i) => ({
      id: `q${i}`, chapterId: 'ethics', choices: [{ id: 'a' }, { id: 'b' }], correctAnswerId: 'a',
    }));
    const _id = new ObjectId();
    attempts.push({
      _id, userId: u._id.toString(), attemptNumber: 1, status: 'in_progress', accessVia: 'school',
      startedAt: new Date(Date.now() - 7 * 60 * 60 * 1000), totalQuestions: 20, questions,
      savedAnswers: Object.fromEntries(questions.map((q) => [q.id, 'a'])),
    });
    const res = await start(app(), u.email);
    expect(res.status).toBe(403);
    expect(attempts[0].status).toBe('completed');
    expect(attempts[0].autoSubmitted).toBe(true);
    expect(attempts[0].totalCorrect).toBe(20);
  });

  it('a refunded buyer mid-exam keeps today\'s behaviour: no grace', async () => {
    const u = addUser('buyer@gmail.com');
    purchases.push({ userId: u._id.toString(), status: 'completed' });
    const server = app();
    const first = await start(server, u.email);
    expect(attempts[0].accessVia).toBe('purchase');
    purchases[0].status = 'refunded';
    const save = await request(server).patch('/api/exam/answers').set(as(u.email))
      .send({ attemptId: first.body.attemptId, answers: {} });
    expect(save.status).toBe(403);
  });

  it('a refunded buyer at a licensed school gets in through the school', async () => {
    addLicense();
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    purchases.push({ userId: u._id.toString(), status: 'refunded' });
    const res = await start(app(), u.email);
    expect(res.status).toBe(200);
    expect(attempts[0].accessVia).toBe('school');
  });

  it('a buyer at a licensed school uses their purchase and leaves the seat', async () => {
    const lic = addLicense();
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    purchases.push({ userId: u._id.toString(), status: 'completed' });
    await start(app(), u.email);
    expect(attempts[0].accessVia).toBe('purchase');
    expect(lic.seatsUsed).toBe(0);
  });

  it('listing past attempts never takes a seat', async () => {
    const lic = addLicense();
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    const res = await request(app()).get('/api/exam/attempts').set(as(u.email));
    expect(res.status).toBe(200);
    expect(lic.seatsUsed).toBe(0);
  });
});

describe('GET /api/checkout/status', () => {
  it('a covered student reads as having it, through their school, without taking a seat', async () => {
    const lic = addLicense();
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    const res = await status(app(), u.email);
    expect(res.body).toMatchObject({ purchased: true, access: 'school', school: { name: 'Brigham Young University' } });
    expect(JSON.stringify(res.body)).not.toMatch(/Ames|PO 123/);
    expect(lic.seatsUsed).toBe(0);
  });

  it('an unverified student at a licensed school is told their school covers them', async () => {
    addLicense();
    const u = addUser('sam@byu.edu', { emailVerified: false });
    const res = await status(app(), u.email);
    expect(res.body).toMatchObject({ purchased: false, schoolReason: 'unverified', school: { domains: ['byu.edu'] } });
  });

  it('the school on their profile is enough to point them at verification', async () => {
    addLicense();
    const u = addUser('sam@gmail.com', { school: { name: 'Brigham Young University' } });
    const res = await status(app(), u.email);
    expect(res.body).toMatchObject({ purchased: false, schoolReason: 'unverified' });
  });

  it('a full licence says so', async () => {
    addLicense({ seatCap: 1, seatsUsed: 1 });
    const u = addUser('late@gmail.com', codeVerifiedAt('late@byu.edu'));
    const res = await status(app(), u.email);
    expect(res.body).toMatchObject({ purchased: false, schoolReason: 'seats_full' });
  });

  it('a student at an unlicensed school sees the ordinary page', async () => {
    addLicense();
    const u = addUser('lee@gmail.com', codeVerifiedAt('lee@utah.edu'));
    const res = await status(app(), u.email);
    expect(res.body).toEqual({ purchased: false, access: null });
  });
});

describe('the student code unlocks the licence', () => {
  it('confirming a code for a licensed domain answers schoolAccess', async () => {
    addLicense();
    const u = addUser('jane@gmail.com', {
      studentCode: hashToken('123456'), studentCodeEmail: 'jane@byu.edu',
      studentCodeExpiry: new Date(Date.now() + 60000), studentCodeAttempts: 0,
    });
    const res = await request(app()).post('/api/checkout/student/confirm').set(as(u.email)).send({ code: '123456' });
    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({ verified: true, schoolAccess: true, school: { name: 'Brigham Young University' } });
    expect(users[u.email].verifiedStudentEmail).toBe('jane@byu.edu');
  });

  it('a wrong code unlocks nothing', async () => {
    addLicense();
    const u = addUser('jane@gmail.com', {
      studentCode: hashToken('123456'), studentCodeEmail: 'jane@byu.edu',
      studentCodeExpiry: new Date(Date.now() + 60000), studentCodeAttempts: 0,
    });
    const res = await request(app()).post('/api/checkout/student/confirm').set(as(u.email)).send({ code: '000000' });
    expect(res.status).toBe(400);
    expect((await start(app(), u.email)).status).toBe(403);
  });

  it('checkout refuses to charge a student their school covers', async () => {
    addLicense();
    const u = addUser('jane@gmail.com', codeVerifiedAt('jane@byu.edu'));
    const res = await request(app()).post('/api/checkout/create-session').set(as(u.email)).send({});
    expect(res.status).toBe(400);
    expect(res.body.msg).toMatch(/school/i);
  });
});

describe('admin: school licences', () => {
  const valid = {
    schoolName: 'Brigham Young University', domains: 'byu.edu, Student.BYU.edu',
    startsAt: '2026-08-01', endsAt: '2027-08-01', seatCap: 500,
    contactName: 'Dr. Ames', contactEmail: 'ames@byu.edu', notes: 'PO 123',
  };

  it('is owner-only, every endpoint', async () => {
    addUser('jane@byu.edu');
    const lic = addLicense();
    const server = app();
    const calls = [
      request(server).get('/api/admin/school-licenses'),
      request(server).post('/api/admin/school-licenses').send(valid),
      request(server).patch(`/api/admin/school-licenses/${lic._id}`).send({ seatCap: 1 }),
      request(server).post(`/api/admin/school-licenses/${lic._id}/end`),
      request(server).post(`/api/admin/school-licenses/${lic._id}/reopen`),
    ];
    for (const c of calls) expect((await c.set(as('jane@byu.edu'))).status).toBe(403);
    expect(lic.seatCap).toBe(500);
    expect(lic.endedAt).toBeUndefined();
  });

  it('needs a session at all', async () => {
    const res = await request(app()).get('/api/admin/school-licenses');
    expect(res.status).toBe(401);
  });

  it('creates a licence with clean domains and dates', async () => {
    addUser(ADMIN);
    const res = await request(app()).post('/api/admin/school-licenses').set(as(ADMIN)).send(valid);
    expect(res.status).toBe(201);
    expect(res.body).toMatchObject({
      schoolName: 'Brigham Young University', domains: ['byu.edu', 'student.byu.edu'],
      seatCap: 500, seatsUsed: 0, seatsLeft: 500, state: 'active',
    });
    expect(new Date(res.body.startsAt).toISOString()).toBe('2026-08-01T00:00:00.000Z');
  });

  it('refuses bad input', async () => {
    addUser(ADMIN);
    const server = app();
    const bad = [
      { ...valid, schoolName: '' },
      { ...valid, domains: 'gmail.com' },
      { ...valid, domains: 'byu.edu.evil.com' },
      { ...valid, domains: '' },
      { ...valid, endsAt: '2026-07-01' },
      { ...valid, seatCap: 0 },
      { ...valid, seatCap: 2.5 },
      { ...valid, contactEmail: 'not-an-email' },
    ];
    for (const body of bad) {
      const res = await request(server).post('/api/admin/school-licenses').set(as(ADMIN)).send(body);
      expect(res.status, JSON.stringify(body)).toBe(400);
    }
    expect(licenses).toHaveLength(0);
  });

  it('lists licences with seats used, without anything a student reads', async () => {
    addUser(ADMIN);
    addLicense({ seatsUsed: 12, seatCap: 40 });
    const res = await request(app()).get('/api/admin/school-licenses').set(as(ADMIN));
    expect(res.body.licenses[0]).toMatchObject({ seatsUsed: 12, seatsLeft: 28, state: 'active', contactName: 'Dr. Ames' });
  });

  it('edits, ends and reopens', async () => {
    addUser(ADMIN);
    const lic = addLicense();
    const server = app();
    const edit = await request(server).patch(`/api/admin/school-licenses/${lic._id}`).set(as(ADMIN)).send({ seatCap: 600, notes: 'renewed' });
    expect(edit.body).toMatchObject({ seatCap: 600, notes: 'renewed', schoolName: 'Brigham Young University' });

    const badEdit = await request(server).patch(`/api/admin/school-licenses/${lic._id}`).set(as(ADMIN))
      .send({ endsAt: new Date(lic.startsAt.getTime() - DAY).toISOString() });
    expect(badEdit.status).toBe(400);

    const end = await request(server).post(`/api/admin/school-licenses/${lic._id}/end`).set(as(ADMIN));
    expect(end.body.state).toBe('ended');
    const reopen = await request(server).post(`/api/admin/school-licenses/${lic._id}/reopen`).set(as(ADMIN));
    expect(reopen.body.state).toBe('active');
  });

  it('404s an unknown licence', async () => {
    addUser(ADMIN);
    const res = await request(app()).post(`/api/admin/school-licenses/${new ObjectId()}/end`).set(as(ADMIN));
    expect(res.status).toBe(404);
  });
});

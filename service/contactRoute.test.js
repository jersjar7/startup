import { describe, it, expect, beforeEach, vi } from 'vitest';
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const express = require('express');
const cookieParser = require('cookie-parser');
const request = require('supertest');
const DB = require('./database.js');
const email = require('./email.js');

// POST /api/feedback/contact: "Contact us" from the website and the app,
// against an in-memory store. Nothing is ever sent.

let stored;
let mailed;

beforeEach(() => {
  stored = [];
  mailed = [];
  const users = { 'me@byu.edu': { email: 'me@byu.edu' } };
  Object.assign(DB, {
    getSessionByToken: async (t) => (t === 'good' ? { email: 'me@byu.edu', lastSeen: new Date() } : null),
    getUser: async (e) => users[e] || null,
    touchSession: async () => {},
    deleteSession: async () => {},
    insertContactMessage: async (m) => { stored.push(m); },
    countContactSince: async (e) => stored.filter((m) => m.email === e).length,
  });
  vi.spyOn(email, 'sendContactAlertEmail').mockImplementation(async (m) => { mailed.push(m); return { ok: true }; });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(cookieParser());
  a.use('/api/feedback', require('./routes/feedback.js'));
  return a;
}

describe('POST /api/feedback/contact', () => {
  it('a signed-in message from the app goes out from the account address', async () => {
    const r = await request(app()).post('/api/feedback/contact')
      .set('Authorization', 'Bearer good')
      .send({ message: 'Love the app', source: 'app', build: '1144' });
    expect(r.status).toBe(200);
    expect(stored[0]).toMatchObject({ email: 'me@byu.edu', source: 'app', signedIn: true });
    expect(mailed[0]).toMatchObject({ email: 'me@byu.edu', message: 'Love the app' });
  });

  it('a signed-out visitor must give an address', async () => {
    const r = await request(app()).post('/api/feedback/contact').send({ message: 'Hello' });
    expect(r.status).toBe(400);
    expect(r.body.msg).toMatch(/email address/);
    const ok = await request(app()).post('/api/feedback/contact').send({ message: 'Hello', email: 'sam@school.edu' });
    expect(ok.status).toBe(200);
    expect(mailed[0]).toMatchObject({ email: 'sam@school.edu', signedIn: false, source: 'web' });
  });

  it('a stale sign-in never blocks a message', async () => {
    const r = await request(app()).post('/api/feedback/contact')
      .set('Authorization', 'Bearer expired')
      .send({ message: 'I cannot sign in', email: 'stuck@x.com' });
    expect(r.status).toBe(200);
    expect(stored[0]).toMatchObject({ email: 'stuck@x.com', signedIn: false });
  });

  it('a bot filling the hidden field is thanked and nothing is kept', async () => {
    const r = await request(app()).post('/api/feedback/contact')
      .send({ message: 'cheap pills', email: 'bot@x.com', website: 'http://spam' });
    expect(r.status).toBe(200);
    expect(stored).toEqual([]);
    expect(mailed).toEqual([]);
  });

  it('stops at five an hour from one address', async () => {
    for (let i = 0; i < 5; i++) {
      await request(app()).post('/api/feedback/contact').send({ message: `m${i}`, email: 'a@b.co' });
    }
    const r = await request(app()).post('/api/feedback/contact').send({ message: 'm6', email: 'a@b.co' });
    expect(r.status).toBe(429);
    expect(stored.length).toBe(5);
  });
});

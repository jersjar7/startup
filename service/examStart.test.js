import { describe, it, expect, beforeEach } from 'vitest';
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const express = require('express');
const cookieParser = require('cookie-parser');
const request = require('supertest');
const { ObjectId } = require('mongodb');
const DB = require('./database.js');
const content = require('./content.json');

// The server picks a new exam's questions and sends them without the answer
// key. Against an in-memory store.

let attempts;

beforeEach(() => {
  attempts = [];
  Object.assign(DB, {
    getSessionByToken: async (t) => (t === 'good' ? { email: 'me@x.com', lastSeen: new Date() } : null),
    getUser: async () => ({ _id: { toString: () => 'u1' }, email: 'me@x.com' }),
    touchSession: async () => {},
    hasPurchased: async () => true,
    getExamAttempts: async () => attempts.map(({ questions, ...a }) => a), // eslint-disable-line no-unused-vars
    getExamAttempt: async (id) => structuredClone(attempts.find((a) => a._id.toString() === id)),
    getExamAttemptCount: async () => attempts.length,
    getExamQuestionIdsSeen: async () => attempts.flatMap((a) => a.questions.map((q) => q.id)),
    createExamAttempt: async (userId, a) => {
      const _id = new ObjectId();
      attempts.push({ _id, userId, ...structuredClone(a) });
      return _id;
    },
    updateExamAttempt: async (id, _u, update) => {
      Object.assign(attempts.find((a) => a._id.toString() === id), update);
    },
  });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(cookieParser());
  a.use('/api/exam', require('./routes/exam.js'));
  return a;
}

const start = (server, body = {}) => request(server).post('/api/exam/start')
  .set('Authorization', 'Bearer good')
  .send(body);

describe('POST /api/exam/start', () => {
  it('picks 110 questions and sends none of their answers', async () => {
    const res = await start(app());
    expect(res.status).toBe(200);
    expect(res.body.questions).toHaveLength(110);
    expect(JSON.stringify(res.body)).not.toContain('correctAnswerId');

    // The stored attempt grades against the server's own key.
    const stored = attempts[0].questions;
    expect(stored.map((q) => q.id)).toEqual(res.body.questions.map((q) => q.id));
    for (const q of stored) expect(q.correctAnswerId).toBe(content.problemsById[q.id].correctAnswerId);
  });

  it('gives a second exam questions the first did not have', async () => {
    const server = app();
    const first = await start(server);
    attempts[0].status = 'completed';
    const second = await start(server);
    expect(second.body.resumed).toBe(false);
    const before = new Set(first.body.questions.map((q) => q.id));
    expect(second.body.questions.filter((q) => before.has(q.id))).toEqual([]);
  });

  it('turns away a page that still posts its own questions, before any attempt exists', async () => {
    const res = await start(app(), { questions: [{ id: 'x', correctAnswerId: 'a' }] });
    expect(res.status).toBe(409);
    expect(res.body.msg).toMatch(/reload/i);
    expect(attempts).toHaveLength(0);
  });

  it('resumes the stored exam, whatever a page posts', async () => {
    const server = app();
    const first = await start(server);
    const again = await start(server, { questions: [{ id: 'x' }] });
    expect(again.status).toBe(200);
    expect(again.body.resumed).toBe(true);
    expect(again.body.questions.map((q) => q.id)).toEqual(first.body.questions.map((q) => q.id));
    expect(JSON.stringify(again.body)).not.toContain('correctAnswerId');
  });
});

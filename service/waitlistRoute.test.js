import { describe, it, expect, beforeEach, vi } from 'vitest';
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const express = require('express');
const request = require('supertest');
const DB = require('./database.js');
const email = require('./email.js');

// POST /api/waitlist against an in-memory store. Nothing is ever sent.

let rows;
let mailed;

beforeEach(() => {
  rows = [];
  mailed = [];
  Object.assign(DB, {
    getUser: async (e) => (e === 'fe@student.edu' ? { email: e } : null),
    joinWaitlist: async (entry, unsubToken) => {
      const found = rows.find((r) => r.email === entry.email && r.exam === entry.exam);
      if (found) {
        if (entry.when) found.when = entry.when;
        return { isNew: false };
      }
      rows.push({ ...entry, unsubToken });
      return { isNew: true };
    },
  });
  vi.spyOn(email, 'sendWaitlistEmail').mockImplementation(async (to, o) => { mailed.push({ to, ...o }); return { ok: true }; });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use('/api/waitlist', require('./routes/waitlist.js'));
  return a;
}

describe('POST /api/waitlist', () => {
  it('stores a new signup with its source and sends one confirmation', async () => {
    const r = await request(app()).post('/api/waitlist')
      .send({ email: 'Pat@Firm.com', when: '2027-04-to-12', place: 'top', utmSource: 'linkedin' });
    expect(r.status).toBe(200);
    expect(rows[0]).toMatchObject({ email: 'pat@firm.com', when: '2027-04-to-12', channel: 'utm: linkedin', hasFeAccount: false });
    expect(mailed).toHaveLength(1);
    expect(mailed[0].unsubUrl).toContain(`/api/email/waitlist-unsubscribe/${rows[0].unsubToken}`);
  });

  it('joining again answers the same and sends nothing', async () => {
    await request(app()).post('/api/waitlist').send({ email: 'pat@firm.com' });
    const again = await request(app()).post('/api/waitlist').send({ email: 'pat@firm.com', when: '2028-plus' });
    expect(again.status).toBe(200);
    expect(rows).toHaveLength(1);
    expect(rows[0].when).toBe('2028-plus');
    expect(mailed).toHaveLength(1);
  });

  it('marks an address that already has an FE account', async () => {
    await request(app()).post('/api/waitlist').send({ email: 'fe@student.edu' });
    expect(rows[0].hasFeAccount).toBe(true);
  });

  it('turns away a bad address and quietly drops a bot', async () => {
    const bad = await request(app()).post('/api/waitlist').send({ email: 'nope' });
    expect(bad.status).toBe(400);
    expect(bad.body.msg).toMatch(/email address/);
    const bot = await request(app()).post('/api/waitlist').send({ email: 'a@b.co', website: 'x' });
    expect(bot.status).toBe(200);
    expect(rows).toHaveLength(0);
    expect(mailed).toHaveLength(0);
  });
});

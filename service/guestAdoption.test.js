import { describe, it, expect, beforeEach } from 'vitest';
const fs = require('fs');
const path = require('path');
const express = require('express');
const cookieParser = require('cookie-parser');
const request = require('supertest');
const DB = require('./database.js');

// A guest's rounds arriving at their new account (docs/adr/0026-guest-mode.md).
//
// The body below is exactly what the app sent at sign-up in its own
// end-to-end test (mobile/test/guest_journey_test.dart writes it), pushed
// here through the real sync and account routes and the real deriver, with
// only the database in memory. If the app changes what it sends, its test
// rewrites the file and this one has to pass against it.

const fixture = JSON.parse(fs.readFileSync(
  path.join(__dirname, '..', 'mobile/test/fixtures/guest-adoption-events.json'), 'utf8',
));

const EMAIL = 'new@school.edu';
let events;
let stats;

beforeEach(() => {
  events = [];
  stats = null;
  Object.assign(DB, {
    getSessionByToken: async (t) => (t === 'good' ? { email: EMAIL, lastSeen: new Date() } : null),
    getUser: async () => ({ _id: { toString: () => 'u1' }, email: EMAIL }),
    touchSession: async () => {},
    insertReviewEvents: async (email, batch) => {
      const fresh = [];
      for (const e of batch) {
        if (events.some((x) => x.email === email && x.eventId === e.eventId)) continue;
        const row = { email, kind: 'answer', ...e, _id: String(events.length).padStart(24, '0') };
        events.push(row);
        fresh.push(row);
      }
      return fresh;
    },
    getReviewEventsSince: async (email, since) => {
      const rows = events.filter((e) => e.email === email && (!since || e._id > since));
      return { events: rows, cursor: rows.length ? rows[rows.length - 1]._id : since };
    },
    getUserStats: async () => stats,
    replaceUserStats: async (_e, s) => { stats = s; },
    replaceProblemHistory: async () => {},
  });
});

function app() {
  const a = express();
  a.use(express.json());
  a.use(cookieParser());
  a.use('/api/sync', require('./routes/sync.js'));
  a.use('/api/account', require('./routes/account.js'));
  return a;
}
const push = (server, body) => request(server).post('/api/sync/events').set('Authorization', 'Bearer good').send(body);

describe('a guest\'s rounds, adopted by their new account', () => {
  it('are accepted as the app sends them', async () => {
    const res = await push(app(), fixture);
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ accepted: fixture.events.length, duplicates: 0 });
  });

  it('show on the account as the rounds the guest cleared', async () => {
    const server = app();
    await push(server, fixture);
    const { body } = await request(server).get('/api/account/state').set('Authorization', 'Bearer good');
    const cleared = fixture.events.filter((e) => e.grade === 'gotIt').map((e) => Number(e.itemId.split(':')[2]));
    expect(body.phone.games['which-property'].rounds).toEqual(cleared);
    expect(body.events).toBe(fixture.events.length);
  });

  it('are kept once when a retry sends them again', async () => {
    const server = app();
    await push(server, fixture);
    const again = await push(server, fixture);
    expect(again.body).toEqual({ accepted: 0, duplicates: fixture.events.length });
    expect(events).toHaveLength(fixture.events.length);
  });

  it('are refused without an account, so a guest can never write here', async () => {
    const res = await request(app()).post('/api/sync/events').send(fixture);
    expect(res.status).toBe(401);
    expect(events).toHaveLength(0);
  });

  it('take the same batch size the app splits into', async () => {
    const server = fs.readFileSync(path.join(__dirname, 'routes/sync.js'), 'utf8');
    const phone = fs.readFileSync(path.join(__dirname, '..', 'mobile/lib/features/games/game_sync.dart'), 'utf8');
    const serverMax = Number(server.match(/const MAX_BATCH = (\d+);/)[1]);
    const appMax = Number(phone.match(/static const maxBatch = (\d+);/)[1]);
    expect(appMax).toBe(serverMax);
    const over = { ...fixture, events: Array.from({ length: serverMax + 1 }, (_, i) => ({ ...fixture.events[0], eventId: `guest-over-${i}` })) };
    expect((await push(app(), over)).status).toBe(400);
  });
});

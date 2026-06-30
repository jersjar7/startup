import { describe, it, expect } from 'vitest';

const {
  resolveAuth,
  SESSION_MAX_AGE_MS,
  LEGACY_MAX_AGE_MS,
  TOUCH_AFTER_MS,
} = require('./middleware/auth.js');

// A tiny in-memory db facade matching the functions resolveAuth uses.
function fakeDb({ session = null, sessionUser = null, legacyUser = null } = {}) {
  return {
    getSessionByToken: async () => session,
    getUser: async () => sessionUser,
    getUserByToken: async () => legacyUser,
  };
}

const NOW = 1_700_000_000_000;

describe('resolveAuth (per-device sessions + legacy fallback)', () => {
  it('rejects when no token is present', async () => {
    const r = await resolveAuth(undefined, fakeDb(), NOW);
    expect(r.allow).toBe(false);
    expect(r.msg).toBe('Unauthorized');
  });

  it('allows a valid session and returns its user', async () => {
    const r = await resolveAuth('t1', fakeDb({
      session: { email: 'a@b.com', lastSeen: new Date(NOW) },
      sessionUser: { email: 'a@b.com' },
    }), NOW);
    expect(r.allow).toBe(true);
    expect(r.user.email).toBe('a@b.com');
    expect(r.touch).toBeFalsy(); // fresh, no slide needed
  });

  it('expires and asks to delete a session past the max age', async () => {
    const r = await resolveAuth('t2', fakeDb({
      session: { email: 'a@b.com', lastSeen: new Date(NOW - SESSION_MAX_AGE_MS - 1000) },
    }), NOW);
    expect(r.allow).toBe(false);
    expect(r.msg).toBe('Session expired');
    expect(r.clearCookie).toBe(true);
    expect(r.deleteSession).toBe('t2');
  });

  it('flags a slide (touch) for an old-but-valid session', async () => {
    const r = await resolveAuth('t3', fakeDb({
      session: { email: 'a@b.com', lastSeen: new Date(NOW - TOUCH_AFTER_MS - 1000) },
      sessionUser: { email: 'a@b.com' },
    }), NOW);
    expect(r.allow).toBe(true);
    expect(r.touch).toBe('t3');
  });

  it('rejects when the session points at a missing user', async () => {
    const r = await resolveAuth('t4', fakeDb({
      session: { email: 'gone@b.com', lastSeen: new Date(NOW) },
      sessionUser: null,
    }), NOW);
    expect(r.allow).toBe(false);
    expect(r.deleteSession).toBe('t4');
  });

  it('falls back to a valid legacy user token when there is no session', async () => {
    const r = await resolveAuth('legacy', fakeDb({
      legacyUser: { email: 'legacy@b.com', tokenCreatedAt: new Date(NOW) },
    }), NOW);
    expect(r.allow).toBe(true);
    expect(r.user.email).toBe('legacy@b.com');
  });

  it('expires a legacy token past 7 days', async () => {
    const r = await resolveAuth('legacy', fakeDb({
      legacyUser: { email: 'legacy@b.com', tokenCreatedAt: new Date(NOW - LEGACY_MAX_AGE_MS - 1000) },
    }), NOW);
    expect(r.allow).toBe(false);
    expect(r.clearCookie).toBe(true);
  });

  it('rejects an unknown token (neither session nor legacy)', async () => {
    const r = await resolveAuth('ghost', fakeDb(), NOW);
    expect(r.allow).toBe(false);
    expect(r.msg).toBe('Unauthorized');
  });
});

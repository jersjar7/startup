import { describe, it, expect } from 'vitest';
import {
  DIGEST_ACTIVE_DAYS,
  digestActiveSince,
  inDigestAudience,
  audienceNote,
} from './digestAudience.js';

// The digest was consuming the whole daily send budget on the free Resend tier,
// which is why the exam outcome question had almost no room to send. What is
// guarded here is that narrowing the audience never silently drops the two
// things that must keep working: an opt-out is still honoured, and somebody who
// is studying still gets their digest.

const active = new Set(['studying@a.com', 'keen@b.com']);
const verified = (email, extra = {}) => ({ email, emailVerified: true, ...extra });

describe('who still gets a digest', () => {
  it('somebody who has studied inside the window', () => {
    expect(inDigestAudience(verified('studying@a.com'), active)).toBe(true);
  });

  it('nobody who has not', () => {
    // 94 of 394 had never completed a single session and were getting a weekly
    // summary of nothing.
    expect(inDigestAudience(verified('dormant@c.com'), active)).toBe(false);
  });

  it('nobody who opted out, however active they are', () => {
    // The budget cut must never become a way to resurrect an unsubscribe.
    expect(inDigestAudience(verified('studying@a.com', { lifecycleOptOut: true }), active))
      .toBe(false);
  });

  it('nobody unverified, however active they are', () => {
    expect(inDigestAudience({ email: 'studying@a.com', emailVerified: false }, active))
      .toBe(false);
  });

  it('nobody without an address to send to', () => {
    expect(inDigestAudience({ emailVerified: true }, active)).toBe(false);
    expect(inDigestAudience(null, active)).toBe(false);
  });
});

describe('the active set', () => {
  it('takes a plain array as well as a Set, so the caller can pass a distinct()', () => {
    expect(inDigestAudience(verified('studying@a.com'), ['studying@a.com'])).toBe(true);
  });

  it('treats a missing set as nobody active rather than everybody', () => {
    // Failing open here would restore the exact behaviour this replaces, and
    // would do it silently on the day a query errored.
    expect(inDigestAudience(verified('studying@a.com'), null)).toBe(false);
    expect(inDigestAudience(verified('studying@a.com'), undefined)).toBe(false);
  });
});

describe('the window', () => {
  it('is 45 days, the owner\'s call', () => {
    expect(DIGEST_ACTIVE_DAYS).toBe(45);
  });

  it('counts back from the moment given, not from now', () => {
    const now = new Date('2026-10-06T12:00:00Z');
    expect(digestActiveSince(now).toISOString()).toBe('2026-08-22T12:00:00.000Z');
  });

  it('can be widened if the send budget stops being the constraint', () => {
    const now = new Date('2026-10-06T12:00:00Z');
    expect(digestActiveSince(now, 90).toISOString()).toBe('2026-07-08T12:00:00.000Z');
  });
});

describe('what the log says', () => {
  it('reports the audience and what the cut frees, per day', () => {
    // Measured on production the day this shipped: 190 of 394.
    const note = audienceNote(394, 190);
    expect(note).toContain('190/394');
    expect(note).toContain('27.1/day');
    expect(note).toContain('29.1/day freed');
  });
});

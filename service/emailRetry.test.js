import { describe, it, expect } from 'vitest';
import {
  MAX_ATTEMPTS,
  shouldRetry,
  nextAttemptAt,
  retryEntry,
  isDue,
} from './emailRetry.js';

// 2026-10-07: 34 sends were refused with "API key is invalid", 22 distinct
// people. Not a quota problem. The rejections sit between "RESEND_FROM_EMAIL
// is unset" warnings and missing public/index.html errors, which is the
// service running with no environment: the few seconds during a deploy when
// the app is up but broken. The send was fired and forgotten at sign-up, so
// every failure was logged and dropped.

const now = new Date('2026-10-08T00:00:00Z');

describe('what is worth another go', () => {
  it('retries the failure that caused this to exist', () => {
    // An invalid API key is a config problem that fixes itself when the deploy
    // finishes. It is also indistinguishable from any other transient fault.
    expect(shouldRetry('API key is invalid')).toBe(true);
  });

  it('retries anything it does not recognise', () => {
    // Losing a sign-up costs far more than one extra attempt.
    expect(shouldRetry('socket hang up')).toBe(true);
    expect(shouldRetry('503 Service Unavailable')).toBe(true);
    expect(shouldRetry('')).toBe(true);
    expect(shouldRetry(null)).toBe(true);
  });

  it('gives up where the address itself is the problem', () => {
    // Mailing a bad address repeatedly costs sender reputation and changes
    // nothing for the person.
    for (const msg of [
      'Invalid recipient',
      'invalid to field',
      'Recipient not found',
      'address is on the suppression list',
      'blocked by the receiving server',
    ]) {
      expect(shouldRetry(msg), `"${msg}" should not be retried`).toBe(false);
    }
  });
});

describe('when to try again', () => {
  it('tries again within a minute, because a deploy window is seconds', () => {
    expect(nextAttemptAt(0, now).toISOString()).toBe('2026-10-08T00:01:00.000Z');
  });

  it('backs off after that rather than hammering', () => {
    expect(nextAttemptAt(1, now).toISOString()).toBe('2026-10-08T00:10:00.000Z');
    expect(nextAttemptAt(2, now).toISOString()).toBe('2026-10-08T00:45:00.000Z');
    expect(nextAttemptAt(3, now).toISOString()).toBe('2026-10-08T02:00:00.000Z');
  });

  it('stops after four, so a bad address is not mailed forever', () => {
    expect(nextAttemptAt(MAX_ATTEMPTS, now)).toBeNull();
    expect(nextAttemptAt(99, now)).toBeNull();
  });
});

describe('the queued row', () => {
  it('carries the intent, never the email', () => {
    // A verification link cannot be stored and resent: only the hash of the
    // token is kept, by design. A retry mints a fresh one. So nothing
    // sensitive sits in the queue, and this asserts it.
    const row = retryEntry({ email: 'a@b.com', error: 'API key is invalid', now });
    expect(Object.keys(row).sort())
      .toEqual(['attempts', 'email', 'kind', 'lastError', 'nextAt', 'updatedAt']);
    expect(JSON.stringify(row)).not.toMatch(/token|html|<a |href/i);
  });

  it('counts the attempt it is queued for', () => {
    expect(retryEntry({ email: 'a@b.com', error: 'x', now }).attempts).toBe(1);
    expect(retryEntry({ email: 'a@b.com', error: 'x', attempts: 2, now }).attempts).toBe(3);
  });

  it('queues nothing once the attempts are spent', () => {
    expect(retryEntry({ email: 'a@b.com', error: 'x', attempts: MAX_ATTEMPTS, now })).toBeNull();
  });

  it('queues nothing for an address that will never work', () => {
    expect(retryEntry({ email: 'a@b.com', error: 'Invalid recipient', now })).toBeNull();
  });

  it('queues nothing without an address', () => {
    expect(retryEntry({ email: '', error: 'x', now })).toBeNull();
    expect(retryEntry({ email: null, error: 'x', now })).toBeNull();
  });

  it('keeps the error short, because it is only a breadcrumb', () => {
    const row = retryEntry({ email: 'a@b.com', error: 'z'.repeat(5000), now });
    expect(row.lastError.length).toBeLessThanOrEqual(200);
  });
});

describe('picking up what is due', () => {
  it('is due once the time has passed', () => {
    expect(isDue({ nextAt: new Date('2026-10-07T23:59:00Z') }, now)).toBe(true);
    expect(isDue({ nextAt: now }, now)).toBe(true);
  });

  it('is not due early', () => {
    expect(isDue({ nextAt: new Date('2026-10-08T00:01:00Z') }, now)).toBe(false);
  });

  it('is not due with nothing scheduled', () => {
    expect(isDue({}, now)).toBe(false);
    expect(isDue(null, now)).toBe(false);
  });
});

import { describe, it, expect } from 'vitest';
const {
  isAttemptExpired, TIME_LIMIT_SECONDS, EXPIRY_GRACE_SECONDS,
} = require('./examAttempt.js');

const NOW = new Date('2026-07-30T12:00:00Z');
const minutesAgo = (m) => new Date(NOW.getTime() - m * 60000).toISOString();

// These tests exist because getting this wrong in either direction is costly:
// too strict and you kill someone's live paid exam mid-session; too loose and
// they are stranded in a dead attempt with a 00:00 clock, which is exactly what
// happened to three of the first six paying customers.
describe('isAttemptExpired', () => {
  it('is false for an attempt that just started', () => {
    expect(isAttemptExpired(minutesAgo(1), NOW)).toBe(false);
  });

  it('is false mid-exam, four hours in', () => {
    expect(isAttemptExpired(minutesAgo(240), NOW)).toBe(false);
  });

  it('is false just inside the time limit', () => {
    expect(isAttemptExpired(minutesAgo(319), NOW)).toBe(false);
  });

  it('is false during the grace period after the limit', () => {
    // Someone submitting right at the buzzer must not have it pulled away.
    expect(isAttemptExpired(minutesAgo(330), NOW)).toBe(false);
    expect(isAttemptExpired(minutesAgo(349), NOW)).toBe(false);
  });

  it('is true once limit + grace has passed', () => {
    expect(isAttemptExpired(minutesAgo(351), NOW)).toBe(true);
  });

  it('is true for the real stranded attempts that caused this', () => {
    expect(isAttemptExpired('2026-07-18T17:02:05Z', NOW)).toBe(true); // 11 days
    expect(isAttemptExpired('2026-06-14T05:01:17Z', NOW)).toBe(true); // 46 days
  });

  it('matches the deploy preflight window exactly', () => {
    // checkActiveExamSims.js blocks deploys for attempts started within
    // limit + grace. If these drift, a deploy either lands on a user the app
    // still considers active, or is blocked by attempts already expired.
    expect((TIME_LIMIT_SECONDS + EXPIRY_GRACE_SECONDS) / 60).toBe(350); // 5h50m
  });

  it('leaves an attempt alone when startedAt is missing or unparseable', () => {
    expect(isAttemptExpired(null, NOW)).toBe(false);
    expect(isAttemptExpired(undefined, NOW)).toBe(false);
    expect(isAttemptExpired('not-a-date', NOW)).toBe(false);
  });

  it('accepts a Date as well as a string', () => {
    expect(isAttemptExpired(new Date(minutesAgo(400)), NOW)).toBe(true);
  });
});

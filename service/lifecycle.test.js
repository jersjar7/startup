import { describe, it, expect } from 'vitest';
const {
  etDate, etHour, etWeekday, isWelcomeDue, daysSince, digestIsActive,
} = require('./lifecycle');

const TZ = 'America/New_York';

describe('timezone helpers', () => {
  it('etDate/etHour reflect the target timezone', () => {
    // 2026-06-02T05:30:00Z = 01:30 EDT on 2026-06-02
    const d = new Date('2026-06-02T05:30:00Z');
    expect(etDate(d, TZ)).toBe('2026-06-02');
    expect(etHour(d, TZ)).toBe(1);
  });

  it('etDate rolls back across midnight in ET', () => {
    // 2026-06-02T03:00:00Z = 23:00 EDT on 2026-06-01
    const d = new Date('2026-06-02T03:00:00Z');
    expect(etDate(d, TZ)).toBe('2026-06-01');
    expect(etHour(d, TZ)).toBe(23);
  });

  it('etWeekday returns the short day name', () => {
    expect(etWeekday(new Date('2026-06-07T13:00:00Z'), TZ)).toBe('Sun');
  });
});

describe('isWelcomeDue (morning after verification)', () => {
  it('is false the same calendar day as verification', () => {
    const verified = new Date('2026-06-02T14:00:00Z'); // 10am ET Jun 2
    const now = new Date('2026-06-02T16:00:00Z'); // noon ET Jun 2
    expect(isWelcomeDue(verified, now, TZ)).toBe(false);
  });

  it('is true the next morning', () => {
    const verified = new Date('2026-06-02T14:00:00Z'); // Jun 2 ET
    const now = new Date('2026-06-03T12:00:00Z'); // 8am ET Jun 3
    expect(isWelcomeDue(verified, now, TZ)).toBe(true);
  });

  it('handles late-night verification correctly (verified 11pm ET → due next morning)', () => {
    const verified = new Date('2026-06-03T03:00:00Z'); // 11pm ET Jun 2
    const now = new Date('2026-06-03T12:00:00Z'); // 8am ET Jun 3
    expect(isWelcomeDue(verified, now, TZ)).toBe(true);
  });

  it('is false with no verification timestamp', () => {
    expect(isWelcomeDue(null, new Date(), TZ)).toBe(false);
  });
});

describe('daysSince', () => {
  it('floors whole days between instants', () => {
    const now = new Date('2026-06-10T00:00:00Z');
    expect(daysSince(new Date('2026-06-03T00:00:00Z'), now)).toBe(7);
    expect(daysSince(new Date('2026-06-09T12:00:00Z'), now)).toBe(0);
  });
  it('treats a missing date as infinitely inactive', () => {
    expect(daysSince(null, new Date())).toBe(Infinity);
  });
});

describe('digestIsActive', () => {
  it('is active with any XP or problems this week', () => {
    expect(digestIsActive({ weeklyXp: 10, problemsThisWeek: 0 })).toBe(true);
    expect(digestIsActive({ weeklyXp: 0, problemsThisWeek: 4 })).toBe(true);
  });
  it('is inactive with a blank week', () => {
    expect(digestIsActive({ weeklyXp: 0, problemsThisWeek: 0 })).toBe(false);
    expect(digestIsActive({})).toBe(false);
  });
});

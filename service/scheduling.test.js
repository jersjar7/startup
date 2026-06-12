import { describe, it, expect } from 'vitest';
const { nextInterval, nextHistoryV2, MAX_INTERVAL_DAYS } = require('./scheduling');

describe('nextInterval (SM-2 scheduling)', () => {
  it('resets to 1 day on an incorrect answer regardless of prior interval', () => {
    expect(nextInterval(1, false)).toBe(1);
    expect(nextInterval(20, false)).toBe(1);
    expect(nextInterval(30, false)).toBe(1);
  });

  it('treats a missing/zero prior interval as 1 on a first correct answer', () => {
    expect(nextInterval(undefined, true)).toBe(3); // round(1 * 2.5)
    expect(nextInterval(0, true)).toBe(3);
  });

  it('grows by the ease factor on consecutive correct answers', () => {
    expect(nextInterval(3, true)).toBe(8);   // round(7.5)
    expect(nextInterval(8, true)).toBe(20);  // round(20)
  });

  it('caps the interval at the maximum', () => {
    expect(nextInterval(20, true)).toBe(MAX_INTERVAL_DAYS); // round(50) -> cap 30
    expect(nextInterval(30, true)).toBe(MAX_INTERVAL_DAYS);
  });

  it('never returns more than the cap', () => {
    for (let i = 1; i <= 40; i++) {
      expect(nextInterval(i, true)).toBeLessThanOrEqual(MAX_INTERVAL_DAYS);
    }
  });
});

describe('nextHistoryV2 (shared 3-grade SM-2 web adapter)', () => {
  // Fixed clock so nextReview is deterministic. Noon UTC keeps the +10min
  // relearn step on the same UTC calendar day.
  const NOW = Date.parse('2026-06-12T12:00:00Z');
  const DAY = 86400000;
  const dateOf = (ms) => new Date(ms).toISOString().split('T')[0];

  it('a fresh correct answer schedules 1 day out with seeded SM-2 state', () => {
    expect(nextHistoryV2(null, true, NOW)).toEqual({
      interval: 1,
      ease: 2.5,
      reps: 1,
      lapses: 0,
      nextReview: dateOf(NOW + 1 * DAY),
    });
  });

  it('seeds a legacy interval-only row so a mature item keeps growing (not reset to 1)', () => {
    // interval 8, no ease/reps -> seeded reps 3 -> correct -> round(8*2.5)=20
    expect(nextHistoryV2({ interval: 8, timesIncorrect: 1 }, true, NOW)).toEqual({
      interval: 20,
      ease: 2.5,
      reps: 4,
      lapses: 1,
      nextReview: dateOf(NOW + 20 * DAY),
    });
  });

  it('a miss resets the interval and resurfaces the item the same day (relearn)', () => {
    const r = nextHistoryV2({ interval: 20, ease: 2.5, reps: 4, lapses: 1 }, false, NOW);
    expect(r.interval).toBe(0);
    expect(r.reps).toBe(0);
    expect(r.lapses).toBe(2);
    expect(r.ease).toBe(2.3);
    expect(r.nextReview).toBe(dateOf(NOW)); // due again today
  });
});

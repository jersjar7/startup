import { describe, it, expect } from 'vitest';
const { nextInterval, MAX_INTERVAL_DAYS } = require('./scheduling');

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

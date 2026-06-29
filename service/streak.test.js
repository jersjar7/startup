import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
const { calculateStreak } = require('./streak.js');

// "Days studied" — cumulative count of distinct study days; never resets.
describe('calculateStreak (cumulative days studied)', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns 1 for the first-ever session', () => {
    vi.setSystemTime(new Date('2025-03-15'));
    const result = calculateStreak(
      { currentStreak: 0, longestStreak: 0, lastSessionDate: null, freezeUsedThisWeek: null },
      '2025-03-15'
    );
    expect(result.currentStreak).toBe(1);
    expect(result.longestStreak).toBe(1);
  });

  it('does not change the count when already studied today', () => {
    vi.setSystemTime(new Date('2025-03-15'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 10, lastSessionDate: '2025-03-15', freezeUsedThisWeek: null },
      '2025-03-15'
    );
    expect(result.currentStreak).toBe(5);
    expect(result.longestStreak).toBe(10);
  });

  it('adds 1 on a consecutive day', () => {
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 3, longestStreak: 5, lastSessionDate: '2025-03-15', freezeUsedThisWeek: null },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(4);
    expect(result.longestStreak).toBe(5);
  });

  it('still adds 1 after a one-day gap (never resets)', () => {
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 5, lastSessionDate: '2025-03-14', freezeUsedThisWeek: null },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(6);
  });

  it('still adds 1 after a multi-day gap (a gap never erases your effort)', () => {
    vi.setSystemTime(new Date('2025-03-25'));
    const result = calculateStreak(
      { currentStreak: 12, longestStreak: 12, lastSessionDate: '2025-03-13', freezeUsedThisWeek: null },
      '2025-03-25'
    );
    expect(result.currentStreak).toBe(13);
    expect(result.longestStreak).toBe(13);
  });

  it('adds 1 after a months-long gap', () => {
    vi.setSystemTime(new Date('2025-06-01'));
    const result = calculateStreak(
      { currentStreak: 20, longestStreak: 20, lastSessionDate: '2025-03-01', freezeUsedThisWeek: null },
      '2025-06-01'
    );
    expect(result.currentStreak).toBe(21);
  });

  it('updates longest when the count exceeds it', () => {
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 5, lastSessionDate: '2025-03-15', freezeUsedThisWeek: null },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(6);
    expect(result.longestStreak).toBe(6);
  });

  it('passes freezeUsedThisWeek through unchanged (freeze is retired)', () => {
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 10, lastSessionDate: '2025-03-14', freezeUsedThisWeek: '2025-03-13' },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(6);
    expect(result.freezeUsedThisWeek).toBe('2025-03-13');
  });

  it('handles a missing longestStreak gracefully', () => {
    vi.setSystemTime(new Date('2025-03-15'));
    const result = calculateStreak(
      { currentStreak: 3, lastSessionDate: '2025-03-14' },
      '2025-03-15'
    );
    expect(result.currentStreak).toBe(4);
    expect(result.longestStreak).toBe(4);
  });
});

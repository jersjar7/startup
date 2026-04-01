import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
const { calculateStreak } = require('./streak.js');

describe('calculateStreak', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns streak 1 for first-ever session', () => {
    vi.setSystemTime(new Date('2025-03-15'));
    const result = calculateStreak(
      { currentStreak: 0, longestStreak: 0, lastSessionDate: null, freezeUsedThisWeek: null },
      '2025-03-15'
    );
    expect(result.currentStreak).toBe(1);
    expect(result.longestStreak).toBe(1);
  });

  it('does not change streak when already studied today', () => {
    vi.setSystemTime(new Date('2025-03-15'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 10, lastSessionDate: '2025-03-15', freezeUsedThisWeek: null },
      '2025-03-15'
    );
    expect(result.currentStreak).toBe(5);
    expect(result.longestStreak).toBe(10);
  });

  it('increments streak on consecutive day', () => {
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 3, longestStreak: 5, lastSessionDate: '2025-03-15', freezeUsedThisWeek: null },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(4);
    expect(result.longestStreak).toBe(5);
  });

  it('updates longest streak when current exceeds it', () => {
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 5, lastSessionDate: '2025-03-15', freezeUsedThisWeek: null },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(6);
    expect(result.longestStreak).toBe(6);
  });

  it('resets streak when more than one day missed and no freeze', () => {
    vi.setSystemTime(new Date('2025-03-18'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 10, lastSessionDate: '2025-03-15', freezeUsedThisWeek: null },
      '2025-03-18'
    );
    expect(result.currentStreak).toBe(1);
    expect(result.longestStreak).toBe(10);
  });

  it('uses freeze when exactly one day missed and freeze is available', () => {
    // Last session: March 14, today: March 16 (missed March 15)
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 5, lastSessionDate: '2025-03-14', freezeUsedThisWeek: null },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(6);
    expect(result.freezeUsedThisWeek).toBe('2025-03-16');
  });

  it('does not use freeze when already used this week', () => {
    // Last session: March 14, today: March 16, freeze already used March 13 (same week)
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 10, lastSessionDate: '2025-03-14', freezeUsedThisWeek: '2025-03-13' },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(1);
  });

  it('allows freeze when last freeze was in a different week', () => {
    // Last freeze: March 9 (prior week), today: March 16
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 3, longestStreak: 5, lastSessionDate: '2025-03-14', freezeUsedThisWeek: '2025-03-09' },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(4);
    expect(result.freezeUsedThisWeek).toBe('2025-03-16');
  });

  it('resets streak when two or more days missed even with freeze', () => {
    // Last session: March 13, today: March 16 (missed 2 days)
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 5, longestStreak: 10, lastSessionDate: '2025-03-13', freezeUsedThisWeek: null },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(1);
  });

  it('does not use freeze when streak is 0', () => {
    vi.setSystemTime(new Date('2025-03-16'));
    const result = calculateStreak(
      { currentStreak: 0, longestStreak: 0, lastSessionDate: '2025-03-14', freezeUsedThisWeek: null },
      '2025-03-16'
    );
    expect(result.currentStreak).toBe(1);
  });

  it('handles missing longestStreak gracefully', () => {
    vi.setSystemTime(new Date('2025-03-15'));
    const result = calculateStreak(
      { currentStreak: 3, lastSessionDate: '2025-03-14' },
      '2025-03-15'
    );
    expect(result.currentStreak).toBe(4);
    expect(result.longestStreak).toBe(4);
  });
});

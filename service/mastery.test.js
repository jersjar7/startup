import { describe, it, expect, vi, afterEach } from 'vitest';
const { calculateEarnedMastery, applyDecay, isDecaying, masteryName, computeStudyMastery, problemRetention } = require('./mastery.js');

describe('calculateEarnedMastery', () => {
  it('returns 0 when no sessions completed', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 0, attempted: 0, correct: 0 })).toBe(0);
  });

  it('returns 1 for first session with low accuracy', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 1, attempted: 10, correct: 3 })).toBe(1);
  });

  it('returns 2 when accuracy >= 50%', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 1, attempted: 10, correct: 5 })).toBe(2);
  });

  it('returns 2 when accuracy is 74% with 3+ sessions', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 3, attempted: 100, correct: 74 })).toBe(2);
  });

  it('returns 3 when accuracy >= 75% and 3+ sessions', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 3, attempted: 100, correct: 75 })).toBe(3);
  });

  it('returns 3 with high accuracy and many sessions', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 10, attempted: 50, correct: 45 })).toBe(3);
  });

  it('returns 1 when 2 sessions but accuracy < 50%', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 2, attempted: 10, correct: 4 })).toBe(1);
  });

  it('handles edge case of 0 attempted with sessions', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 1, attempted: 0, correct: 0 })).toBe(1);
  });

  it('handles defaults for missing fields', () => {
    expect(calculateEarnedMastery({})).toBe(0);
  });

  it('returns 2 at exactly 50% accuracy boundary', () => {
    expect(calculateEarnedMastery({ sessionsCompleted: 1, attempted: 2, correct: 1 })).toBe(2);
  });
});

describe('applyDecay', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns earned mastery when no lastStudied', () => {
    expect(applyDecay(3, null)).toBe(3);
  });

  it('returns 0 for earned mastery of 0', () => {
    expect(applyDecay(0, '2025-01-01')).toBe(0);
  });

  it('returns earned mastery when studied recently (< 14 days)', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-03-15'));
    expect(applyDecay(3, '2025-03-05')).toBe(3);
  });

  it('decays by 1 level when 14-29 days idle', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-03-29'));
    expect(applyDecay(3, '2025-03-15')).toBe(2);
  });

  it('decays by 2 levels when 30+ days idle', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-04-15'));
    expect(applyDecay(3, '2025-03-15')).toBe(1);
  });

  it('never goes below 0', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-04-15'));
    expect(applyDecay(1, '2025-03-15')).toBe(0);
  });

  it('decays level 2 by 2 to 0 after 30 days', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-04-15'));
    expect(applyDecay(2, '2025-03-15')).toBe(0);
  });
});

describe('isDecaying', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns false when recently studied', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-03-15'));
    expect(isDecaying(3, '2025-03-10')).toBe(false);
  });

  it('returns true when idle for 14+ days', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-03-29'));
    expect(isDecaying(3, '2025-03-15')).toBe(true);
  });

  it('returns false for mastery 0', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-04-15'));
    expect(isDecaying(0, '2025-03-15')).toBe(false);
  });
});

describe('masteryName', () => {
  it('returns correct names for all levels', () => {
    expect(masteryName(0)).toBe('Not Started');
    expect(masteryName(1)).toBe('Introduced');
    expect(masteryName(2)).toBe('Practicing');
    expect(masteryName(3)).toBe('Familiar');
    expect(masteryName(4)).toBe('Proficient');
    expect(masteryName(5)).toBe('Mastered');
  });

  it('returns Not Started for out-of-range level', () => {
    expect(masteryName(99)).toBe('Not Started');
  });
});

describe('computeStudyMastery (retrieval + spacing curve, τ=25)', () => {
  const learned = (n) => Array.from({ length: n }, () => ({ timesCorrect: 1, timesIncorrect: 0, interval: 1 }));   // crammed today
  const matured = (n) => Array.from({ length: n }, () => ({ timesCorrect: 3, timesIncorrect: 0, interval: 21 }));  // recalled across weeks

  it('gives 0 for no history', () => {
    expect(computeStudyMastery([])).toBe(0);
  });

  it('matches the worked example: cram 20 → 27%', () => {
    expect(computeStudyMastery(learned(20))).toBe(27);
  });

  it('rewards spacing: same 20, matured → 55% (≈ double the cram)', () => {
    expect(computeStudyMastery(matured(20))).toBe(55);
  });

  it('saturates with diminishing returns', () => {
    expect(computeStudyMastery(matured(40))).toBe(80);
    expect(computeStudyMastery(matured(55))).toBe(89);
  });

  it('a problem never answered correctly contributes nothing', () => {
    expect(problemRetention({ timesCorrect: 0, timesIncorrect: 5, interval: 0 })).toBe(0);
  });

  it('lowers credit for lapses (accuracy gate)', () => {
    const half = problemRetention({ timesCorrect: 1, timesIncorrect: 1, interval: 21 }); // 1.0 * 0.5
    const clean = problemRetention({ timesCorrect: 1, timesIncorrect: 0, interval: 21 }); // 1.0 * 1.0
    expect(half).toBeCloseTo(0.5);
    expect(clean).toBe(1);
  });
});

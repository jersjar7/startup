import { describe, it, expect, vi, afterEach } from 'vitest';
const { calculateEarnedMastery, applyDecay, isDecaying, masteryName, computeStudyMastery, composeMastery, nextMaturity, problemsInChapter, holdsProblem } = require('./mastery.js');

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

describe('computeStudyMastery: the desk half is coverage', () => {
  const held = (n, topicId = 'mathematics') => Array.from({ length: n }, () => ({ topicId, timesCorrect: 1, timesIncorrect: 0, deskAttempts: 1 }));
  const phone = (n, topicId = 'mathematics') => Array.from({ length: n }, () => ({ topicId, timesCorrect: 3, timesIncorrect: 0, deskAttempts: 0 }));
  const legacy = (n, topicId = 'mathematics') => Array.from({ length: n }, () => ({ topicId, timesCorrect: 1, timesIncorrect: 0 }));

  it("knows the chapters' sizes from the content build", () => {
    expect(problemsInChapter('mathematics')).toBe(135);
    expect(problemsInChapter('economics')).toBe(50);
    expect(problemsInChapter('nowhere')).toBe(0);
  });

  it("is the share of the chapter's problems held, and 100 when every one is", () => {
    expect(computeStudyMastery([], 'mathematics')).toBe(0);
    expect(computeStudyMastery(held(27), 'mathematics')).toBe(20);
    expect(computeStudyMastery(held(135), 'mathematics')).toBe(100);
    expect(computeStudyMastery(held(50, 'economics'), 'economics')).toBe(100);
  });

  it('a problem counts once answered right, and not while open in the queue since a miss', () => {
    expect(holdsProblem({ timesCorrect: 1, timesIncorrect: 0, deskAttempts: 1 })).toBe(true);
    expect(holdsProblem({ timesCorrect: 0, timesIncorrect: 2, deskAttempts: 2 })).toBe(false);
    expect(holdsProblem({ timesCorrect: 1, timesIncorrect: 1, deskAttempts: 2, reviewActive: true, correctSinceMiss: 0 })).toBe(false);
    expect(holdsProblem({ timesCorrect: 2, timesIncorrect: 1, deskAttempts: 3, reviewActive: true, correctSinceMiss: 1 })).toBe(true);
  });

  it('phone-only rows add nothing to the desk half; legacy rows count as desk', () => {
    expect(computeStudyMastery(phone(50), 'mathematics')).toBe(0);
    expect(computeStudyMastery([...phone(50), ...held(27)], 'mathematics')).toBe(20);
    expect(computeStudyMastery(legacy(27), 'mathematics')).toBe(20);
  });

  it("reads the chapter from the rows when not told, and ignores other chapters' rows", () => {
    expect(computeStudyMastery(held(27))).toBe(20);
    expect(computeStudyMastery([...held(27), ...held(10, 'statics')], 'mathematics')).toBe(20);
  });
});

describe('composeMastery: one number, two halves', () => {
  it('takes the higher of the diagnostic and the study curve as the desk half', () => {
    expect(composeMastery({ diagnosticScore: 40, studyScore: 30 }).deskScore).toBe(40);
    expect(composeMastery({ diagnosticScore: 40, studyScore: 55 }).deskScore).toBe(55);
  });

  it('adds the games half and stops at 100', () => {
    expect(composeMastery({ studyScore: 30, gamesHalf: 20 }).totalMastery).toBe(50);
    expect(composeMastery({ studyScore: 90, gamesHalf: 50 }).totalMastery).toBe(100);
    expect(composeMastery({ gamesHalf: 50 }).totalMastery).toBe(50);
    expect(composeMastery({}).totalMastery).toBe(0);
  });

  it('never lets the games half pass 50', () => {
    expect(composeMastery({ gamesHalf: 80 }).gamesHalf).toBe(50);
  });

  it('carries the counts through for the surfaces to show', () => {
    const m = composeMastery({ studyScore: 10, gamesHalf: 15, gamesCleared: 3, gamesTotal: 10 });
    expect(m).toEqual({ diagnosticScore: 0, studyScore: 10, deskScore: 10, gamesHalf: 15, gamesCleared: 3, gamesTotal: 10, totalMastery: 25 });
  });
});

describe('nextMaturity: a right desk answer after a gap grows the interval', () => {
  it('starts at zero on the first right answer and remembers the day', () => {
    expect(nextMaturity({}, { isCorrect: true, today: '2026-09-01' })).toEqual({ interval: 0, lastCorrectAt: '2026-09-01' });
  });

  it('grows to the gap since the last right answer, and never shrinks on a right answer', () => {
    const a = nextMaturity({ interval: 0, lastCorrectAt: '2026-09-01' }, { isCorrect: true, today: '2026-09-09' });
    expect(a).toEqual({ interval: 8, lastCorrectAt: '2026-09-09' });
    const b = nextMaturity(a, { isCorrect: true, today: '2026-09-12' });
    expect(b.interval).toBe(8);
    const c = nextMaturity(b, { isCorrect: true, today: '2026-10-05' });
    expect(c.interval).toBe(23);
  });

  it('a wrong answer resets the interval', () => {
    expect(nextMaturity({ interval: 23, lastCorrectAt: '2026-10-05' }, { isCorrect: false, today: '2026-10-06' })).toEqual({ interval: 0, lastCorrectAt: '2026-10-05' });
  });

  it('phone rounds do not mature a problem', () => {
    expect(nextMaturity({ interval: 8, lastCorrectAt: '2026-09-09' }, { isCorrect: true, today: '2026-10-09', source: 'phone' })).toEqual({ interval: 8, lastCorrectAt: '2026-09-09' });
  });

});

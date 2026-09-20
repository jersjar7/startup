import { describe, it, expect } from 'vitest';
import { deriveAccount, foldAnswer, addDays } from './derive.js';

const ev = (itemId, { grade = 'gotIt', source = 'ios', day = '2026-09-19', ts = 1, chapterId = 'mathematics' } = {}) =>
  ({ itemId, grade, source, localDate: day, ts, chapterId });

describe('foldAnswer: the review-queue rules, from the student\'s day', () => {
  it('a miss enters the queue due tomorrow; two rights in a row graduate it', () => {
    const a = foldAnswer(null, { isCorrect: false, day: '2026-09-01', source: 'desk' });
    expect(a.reviewActive).toBe(true);
    expect(a.nextReview).toBe('2026-09-02');
    const b = foldAnswer(a, { isCorrect: true, day: '2026-09-02', source: 'desk' });
    expect(b.reviewActive).toBe(true);
    expect(b.nextReview).toBe('2026-09-06');
    const c = foldAnswer(b, { isCorrect: true, day: '2026-09-06', source: 'desk' });
    expect(c.reviewActive).toBe(false);
    expect(c.nextReview).toBeNull();
    expect(c.timesCorrect).toBe(2);
    expect(c.deskAttempts).toBe(3);
  });

  it('a right answer never missed stays out of the queue', () => {
    const a = foldAnswer(null, { isCorrect: true, day: '2026-09-01', source: 'desk' });
    expect(a.reviewActive).toBe(false);
    expect(a.interval).toBe(0);
    expect(a.lastCorrectAt).toBe('2026-09-01');
  });

  it('phone answers count but do not mature or add desk attempts', () => {
    const a = foldAnswer(null, { isCorrect: true, day: '2026-09-01', source: 'phone' });
    expect(a.deskAttempts).toBe(0);
    expect(a.lastCorrectAt).toBeNull();
  });

  it('addDays crosses months', () => {
    expect(addDays('2026-09-30', 4)).toBe('2026-10-04');
  });
});

describe('deriveAccount: an account from its log', () => {
  it('is empty from an empty log', () => {
    expect(deriveAccount({ events: [] })).toEqual({
      history: {}, chapterMastery: {}, studyDays: [], daysStudied: 0, lastSessionDate: null, phoneXp: 0, problemsAnswered: 0,
    });
  });

  it('derives both halves, the days, and capped phone XP from a mixed log', () => {
    const events = [
      // one game cleared on the phone: 8 rounds on one problem
      ...Array.from({ length: 8 }, (_, r) => ev(`math-slq-q2:perpendicular-flip:${r + 1}`, { ts: r })),
      // five desk problems the next day, one of them missed
      ...['q10', 'q11', 'q12', 'q13'].map((q, i) => ev(`math-${q}`, { source: 'web', day: '2026-09-20', ts: 100 + i })),
      ev('math-q14', { source: 'web', grade: 'forgot', day: '2026-09-20', ts: 200 }),
    ];
    const s = deriveAccount({ events });
    expect(s.studyDays).toEqual(['2026-09-19', '2026-09-20']);
    expect(s.lastSessionDate).toBe('2026-09-20');
    expect(s.problemsAnswered).toBe(6);
    expect(s.phoneXp).toBe(40);
    const m = s.chapterMastery.mathematics;
    expect(m.gamesCleared).toBe(1);
    expect(m.gamesHalf).toBe(1);
    // four right desk problems at the lowest maturity: 100*(1-e^(-1.6/25)) = 6
    expect(m.studyScore).toBe(6);
    expect(m.totalMastery).toBe(7);
    expect(s.history['math-q14'].reviewActive).toBe(true);
    expect(s.history['math-slq-q2'].deskAttempts).toBe(0);
  });

  it('takes the diagnostic score it cannot derive yet as an input', () => {
    const s = deriveAccount({ events: [], diagnosticScores: { statics: 40 } });
    expect(s.chapterMastery.statics.totalMastery).toBe(40);
  });

  it('orders by the student\'s day, not by arrival', () => {
    const events = [
      ev('math-q1', { source: 'web', day: '2026-09-20', ts: 5 }),                 // arrived first
      ev('math-q1', { source: 'web', grade: 'forgot', day: '2026-09-19', ts: 9 }), // happened first
    ];
    const s = deriveAccount({ events });
    // the miss came first, then the right answer: in the queue, one right since the miss
    expect(s.history['math-q1'].correctSinceMiss).toBe(1);
    expect(s.history['math-q1'].reviewActive).toBe(true);
  });
});

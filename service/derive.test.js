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
      history: {}, chapterMastery: {}, studyDays: [], daysStudied: 0, lastSessionDate: null, phoneXp: 0, webXp: 0, totalXp: 0,
      sessions: { practice: 0, review: 0, diagnostic: 0, quickstart: 0, exam: 0 }, examDate: null, xpByDay: {}, topicProgress: {}, games: {}, problemsAnswered: 0,
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
    expect(s.games['perpendicular-flip']).toEqual({ rounds: [1, 2, 3, 4, 5, 6, 7, 8], firstTry: 8 });
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

  it('reads the other kinds: sessions carry XP, the diagnostic and quick start the floor, a snapshot the past', () => {
    const events = [
      { kind: 'snapshot', itemId: 'math-q1', chapterId: 'mathematics', source: 'web', localDate: '2026-06-01', ts: 1,
        data: { timesCorrect: 2, timesIncorrect: 1, deskAttempts: 3, reviewActive: true, correctSinceMiss: 1, nextReview: '2026-06-05' } },
      { kind: 'session', chapterId: 'mathematics', source: 'web', localDate: '2026-06-01', ts: 2, data: { type: 'practice', xp: 75, correct: 5, total: 5 } },
      { kind: 'quickstart', chapterId: 'statics', source: 'web', localDate: '2026-06-02', ts: 3, data: { familiarity: 24, xp: 35 } },
      { kind: 'diagnostic', chapterId: null, source: 'web', localDate: '2026-06-03', ts: 4, data: { chapterScores: { statics: 30, dynamics: 12 }, xp: 450 } },
      { kind: 'exam', chapterId: null, source: 'web', localDate: '2026-06-04', ts: 5, data: { xp: 180 } },
      { kind: 'profile', chapterId: null, source: 'web', localDate: '2026-06-04', ts: 6, data: { examDate: '2026-11-28' } },
      ev('math-q1', { source: 'web', day: '2026-06-05', ts: 7 }), // graduates the snapshot's queue entry
    ];
    const s = deriveAccount({ events });
    expect(s.webXp).toBe(740);
    expect(s.totalXp).toBe(740);
    expect(s.sessions).toEqual({ practice: 1, review: 0, diagnostic: 1, quickstart: 1, exam: 1 });
    expect(s.chapterMastery.statics.diagnosticScore).toBe(30);
    expect(s.chapterMastery.dynamics.totalMastery).toBe(12);
    expect(s.examDate).toBe('2026-11-28');
    expect(s.xpByDay).toEqual({ '2026-06-01': 75, '2026-06-02': 35, '2026-06-03': 450, '2026-06-04': 180 });
    expect(s.topicProgress.mathematics).toEqual({ attempted: 5, correct: 5, sessionsCompleted: 1, masteryLevel: 2, lastStudied: '2026-06-01' });
    expect(s.studyDays).toEqual(['2026-06-01', '2026-06-02', '2026-06-03', '2026-06-04', '2026-06-05']);
    const row = s.history['math-q1'];
    expect(row.timesCorrect).toBe(3);
    expect(row.reviewActive).toBe(false);
    expect(row.deskAttempts).toBe(4);
  });
});

import { describe, it, expect } from 'vitest';
const { scoreAttempt, isAnswerCorrect } = require('./examScoring.js');

const q = (id, chapterId, correctAnswerId) => ({ id, chapterId, correctAnswerId });

describe('isAnswerCorrect', () => {
  it('is true only for a real matching selection', () => {
    expect(isAnswerCorrect('a', 'a')).toBe(true);
    expect(isAnswerCorrect('a', 'b')).toBe(false);
  });

  it('never calls an unanswered question correct', () => {
    // The old inline comparison returned true when BOTH sides were nullish, so
    // the results screen told customers they got questions right that they had
    // never answered.
    expect(isAnswerCorrect(null, null)).toBe(false);
    expect(isAnswerCorrect(undefined, undefined)).toBe(false);
    expect(isAnswerCorrect(null, 'a')).toBe(false);
    expect(isAnswerCorrect('a', null)).toBe(false);
  });
});

describe('scoreAttempt', () => {
  const questions = [
    q('q1', 'statics', 'a'),
    q('q2', 'statics', 'b'),
    q('q3', 'materials', 'c'),
    q('q4', 'materials', 'd'),
  ];

  it('scores correct, attempted and overall percentage', () => {
    const r = scoreAttempt(questions, { q1: 'a', q2: 'x', q3: 'c' }, 4);
    expect(r.totalCorrect).toBe(2);
    expect(r.totalAttempted).toBe(3);
    expect(r.overallPercentage).toBe(50); // 2 of 4, not 2 of 3
  });

  it('counts unanswered questions in the chapter total', () => {
    // An unanswered question is a wrong answer on the real exam; excluding it
    // would flatter the chapter breakdown.
    const r = scoreAttempt(questions, { q3: 'c' }, 4);
    expect(r.chapterScores.statics).toEqual({ correct: 0, total: 2, percentage: 0 });
    expect(r.chapterScores.materials).toEqual({ correct: 1, total: 2, percentage: 50 });
  });

  it('marks unanswered questions isCorrect: false', () => {
    const r = scoreAttempt(questions, {}, 4);
    expect(r.scoredQuestions.every((x) => x.isCorrect === false)).toBe(true);
    expect(r.totalCorrect).toBe(0);
    expect(r.overallPercentage).toBe(0);
  });

  it('uses the full exam as the denominator, so skipping cannot inflate a score', () => {
    // Answer 2 of 110 correctly: that is 2%, never 100%.
    const many = Array.from({ length: 110 }, (_, i) => q(`q${i}`, 'statics', 'a'));
    const r = scoreAttempt(many, { q0: 'a', q1: 'a' }, 110);
    expect(r.totalCorrect).toBe(2);
    expect(r.overallPercentage).toBe(2);
  });

  it('falls back to the question count when totalQuestions is missing', () => {
    const r = scoreAttempt(questions, { q1: 'a' }, null);
    expect(r.overallPercentage).toBe(25);
  });

  it('preserves the selection on each scored question', () => {
    const r = scoreAttempt(questions, { q2: 'b' }, 4);
    const q2 = r.scoredQuestions.find((x) => x.id === 'q2');
    expect(q2.selectedAnswerId).toBe('b');
    expect(q2.isCorrect).toBe(true);
  });

  it('handles an empty attempt without throwing', () => {
    const r = scoreAttempt([], {}, 0);
    expect(r).toMatchObject({ totalCorrect: 0, totalAttempted: 0, overallPercentage: 0 });
  });

  it('grades an abandoned attempt from its autosaved answers', () => {
    // The expiry path scores exactly this way. A customer who answered 60 of 110
    // and never pressed submit must get a real 60-question grade, not nothing.
    const many = Array.from({ length: 110 }, (_, i) => q(`q${i}`, 'statics', 'a'));
    const saved = {};
    for (let i = 0; i < 60; i += 1) saved[`q${i}`] = 'a';
    const r = scoreAttempt(many, saved, 110);
    expect(r.totalAttempted).toBe(60);
    expect(r.totalCorrect).toBe(60);
    expect(r.overallPercentage).toBe(55);
  });
});

import { describe, it, expect } from 'vitest';
import { daysLeft, progressLine, daysLine, finishedLine, nextLesson, finishLine } from './challengeText';

const lessons = (marks) => marks.map((cleared, i) => ({ id: `l${i}`, name: `L${i}`, cleared }));
const p = (marks) => {
  const l = lessons(marks);
  const cleared = l.filter((x) => x.cleared).length;
  return { lessons: l, cleared, total: l.length, finished: cleared === l.length, finishedAtDesk: l.every((x) => x.cleared === 'desk') };
};

describe('challenge words', () => {
  it('counts days left including today', () => {
    expect(daysLeft('2026-12-01', '2026-12-31')).toBe(31);
    expect(daysLeft('2026-12-31', '2026-12-31')).toBe(1);
    expect(daysLeft('2027-01-01', '2026-12-31')).toBe(0);
    expect(daysLine(1)).toBe('Last day');
    expect(daysLine(12)).toBe('12 days left');
  });

  it('says how many lessons, and how many at the desk only when it differs', () => {
    expect(progressLine(p(['desk', 'phone', null]))).toBe('2 of 3 lessons, 1 at the desk');
    expect(progressLine(p(['desk', 'desk', null]))).toBe('2 of 3 lessons');
    expect(progressLine(p(['phone', null, null]))).toBe('1 of 3 lessons');
  });

  it('counts finishers in plain words', () => {
    expect(finishedLine({ finished: 0 })).toBe('Nobody has finished yet');
    expect(finishedLine({ finished: 1 })).toBe('1 student finished');
    expect(finishedLine({ finished: 14 })).toBe('14 students finished');
  });

  it('points at the next lesson, then at the desk', () => {
    expect(nextLesson(p(['desk', null, 'phone'])).id).toBe('l1');
    expect(nextLesson(p(['desk', 'phone', 'phone'])).id).toBe('l1');
    expect(nextLesson(p(['desk', 'desk']))).toBeNull();
  });

  it('names the finish, and the gold rim only for the desk', () => {
    expect(finishLine(p(['desk', null]))).toBe('');
    expect(finishLine(p(['desk', 'phone']))).toBe('Finished. Clear the rest at the desk for the gold rim.');
    expect(finishLine(p(['desk', 'desk']))).toBe('Finished at the desk.');
  });
});

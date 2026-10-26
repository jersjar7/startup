import { describe, it, expect } from 'vitest';
import { roadStops, weekEnd, timeAgo, feedLine, initials, boardRows, passLine, nextBadge } from './road';

const keys = (stops) => stops.map((s) => s.key);
const challenge = { finishedAtDesk: false };

describe('roadStops', () => {
  it('runs from today to exam day in date order', () => {
    const stops = roadStops({ today: '2026-12-17', examDate: '2027-02-10', challenge, challengeEnd: '2026-12-31' });
    expect(keys(stops)).toEqual(['today', 'week', 'challenge', 'sim', 'exam']);
    expect(stops.map((s) => s.when)).toEqual(['Today', 'Saturday · week ends', 'Dec 31 · challenge ends', 'Jan 20 · three weeks out', 'Feb 10']);
  });

  it('puts the simulation now once the exam is inside three weeks', () => {
    const stops = roadStops({ today: '2027-01-25', examDate: '2027-02-10' });
    expect(stops.find((s) => s.key === 'sim').when).toBe('Now · 16 days out');
  });

  it('drops the simulation in the last two days, unless it is already bought', () => {
    expect(keys(roadStops({ today: '2027-02-09', examDate: '2027-02-10' }))).not.toContain('sim');
    expect(keys(roadStops({ today: '2027-02-09', examDate: '2027-02-10', simOwned: true }))).toContain('sim');
  });

  it('leaves out a challenge that ends after the exam, and one finished at the desk', () => {
    expect(keys(roadStops({ today: '2026-12-02', examDate: '2026-12-20', challenge, challengeEnd: '2026-12-31' }))).not.toContain('challenge');
    expect(keys(roadStops({ today: '2026-12-02', examDate: '2027-02-10', challenge: { finishedAtDesk: true }, challengeEnd: '2026-12-31' }))).not.toContain('challenge');
  });

  it('without an exam date keeps the simulation and an undated exam day at the end', () => {
    const stops = roadStops({ today: '2026-12-19' });
    expect(keys(stops)).toEqual(['today', 'week', 'sim', 'exam']);
    expect(stops.slice(-2).map((s) => s.when)).toEqual(['Before exam day', 'Exam day']);
  });

  it('treats a past exam date as no date', () => {
    expect(roadStops({ today: '2026-12-19', examDate: '2026-10-01' }).at(-1).date).toBeNull();
  });
});

describe('weekEnd', () => {
  it('is the Saturday of the week, which starts on Sunday', () => {
    expect(weekEnd('2026-12-13')).toBe('2026-12-19'); // a Sunday
    expect(weekEnd('2026-12-19')).toBe('2026-12-19'); // the Saturday itself
    expect(roadStops({ today: '2026-12-19' })[1].when).toBe('Tonight · week ends');
  });
});

describe('the feed words', () => {
  it('says what each kind of row did', () => {
    expect(feedLine({ kind: 'working', device: 'desk', lesson: 'Friction' })).toBe('is working through Friction');
    expect(feedLine({ kind: 'working', device: 'desk', lesson: null }, 'Statics')).toBe('is practicing Statics');
    expect(feedLine({ kind: 'working', device: 'phone', lesson: 'Friction' })).toBe('is playing Friction in the app');
    expect(feedLine({ kind: 'practiced', device: 'desk', lesson: 'Friction', count: 9 })).toBe('practiced Friction, 9 problems');
    expect(feedLine({ kind: 'practiced', device: 'phone', lesson: 'Friction', count: 1 })).toBe('played 1 round of Friction');
    expect(feedLine({ kind: 'challenge' }, 'Statics')).toBe('finished the Statics challenge');
    expect(feedLine({ kind: 'daily' })).toBe("finished today's Daily");
  });

  it('counts time in minutes, then hours', () => {
    expect(timeAgo(1000, 1000 + 60000)).toBe('now');
    expect(timeAgo(0, 18 * 60000)).toBe('18 min');
    expect(timeAgo(0, 130 * 60000)).toBe('2 hr');
  });

  it('makes two letters from a name', () => {
    expect(initials('Maria G.')).toBe('MG');
    expect(initials('A student')).toBe('AS');
    expect(initials('Kevin')).toBe('K');
  });
});

describe('the boards', () => {
  const board = Array.from({ length: 20 }, (_, i) => ({ rank: i + 1, name: `P${i + 1}`, weeklyXp: 1000 - i * 40, isCurrentUser: i === 14 }));

  it('shows the top, then the viewer between their neighbours', () => {
    const rows = boardRows(board, 8);
    expect(rows.map((r) => (r.gap ? '...' : r.rank))).toEqual([1, 2, 3, 4, 5, '...', 14, 15, 16]);
  });

  it('shows just the top when the viewer is in it', () => {
    const top = board.map((e, i) => ({ ...e, isCurrentUser: i === 2 }));
    expect(boardRows(top, 8)).toHaveLength(8);
  });

  it('says how far to the next name', () => {
    expect(passLine(board, 'weeklyXp')).toBe('41 XP to pass P14.');
    expect(passLine([{ name: 'Devon R.', weeklyXp: 210 }, { name: 'Ana R.', weeklyXp: 180, isCurrentUser: true }], 'weeklyXp')).toBe('31 XP to pass Devon R.');
    expect(passLine(board.map((e, i) => ({ ...e, isCurrentUser: i === 0 })), 'weeklyXp')).toBe('You lead this week.');
    expect(passLine([], 'weeklyXp')).toBe('');
  });
});

describe('nextBadge', () => {
  it('picks the unearned badge closest to done', () => {
    const earned = new Set(['xp-100', 'streak-3', 'streak-7']);
    expect(nextBadge(earned, { totalXp: 420, streak: 9 })).toEqual({ id: 'xp-500', have: 420, need: 500, unit: 'XP' });
  });

  it('is null when nothing measurable is left', () => {
    expect(nextBadge(new Set(['xp-100', 'xp-500', 'xp-1000', 'streak-3', 'streak-7', 'streak-30']))).toBeNull();
  });
});

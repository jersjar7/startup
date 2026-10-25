import { describe, it, expect } from 'vitest';
const catalog = require('./gameCatalog.json');
const lessonGames = require('./lessonGames.json');
const { deriveAccount } = require('./derive.js');
const {
  calendar, monthBounds, lessonsOf, challengeOn, nextAfter, progress, finishedChallenges, finishedCount,
} = require('./challenges.js');

const DEC = challengeOn('2026-12-10');
const statics = lessonsOf('statics');

/** Every round of every game on a lesson's node, right, on the phone. */
function phoneClear(lessonId, localDate) {
  return lessonGames.statics[lessonId].flatMap((g) =>
    Array.from({ length: catalog.statics[g] }, (_, i) => ({
      itemId: `stat-x:${g}:${i + 1}`, chapterId: 'statics', grade: 'gotIt', source: 'ios', localDate,
    })));
}

/** Every practice problem of a lesson, right, at the desk. */
function deskClear(lessonId, localDate) {
  return statics.find((l) => l.id === lessonId).practice.map((id) => ({
    itemId: id, chapterId: 'statics', grade: 'gotIt', source: 'web', localDate,
  }));
}

describe('the calendar', () => {
  it('opens with Statics in December 2026', () => {
    expect(calendar[0]).toMatchObject({ month: '2026-12', chapterId: 'statics' });
    expect(DEC.lessons).toHaveLength(7);
    expect(DEC.line).toBe('Clear every Statics lesson before December ends.');
  });

  it('has one challenge per month, each lesson clearable both ways', () => {
    const months = calendar.map((c) => c.month);
    expect(new Set(months).size).toBe(months.length);
    for (const c of calendar) {
      const lessons = lessonsOf(c.chapterId);
      expect(lessons.length).toBeGreaterThan(0);
      for (const l of lessons) {
        expect(l.practice.length).toBeGreaterThan(0);
        expect(l.games.length).toBeGreaterThan(0);
      }
    }
  });

  it('fits Apple\'s 30-character event name', () => {
    for (const c of calendar) expect(challengeOn(`${c.month}-01`).storeName.length).toBeLessThanOrEqual(30);
    expect(DEC.storeName).toBe('December Statics Challenge');
  });

  it('knows month ends and what comes next', () => {
    expect(monthBounds('2027-02')).toEqual({ start: '2027-02-01', end: '2027-02-28' });
    expect(challengeOn('2026-11-30')).toBeNull();
    expect(nextAfter('2026-10-25').month).toBe('2026-12');
  });
});

describe('progress', () => {
  it('counts a lesson cleared either way, desk first when both', () => {
    const events = [
      ...phoneClear('friction', '2026-12-03'),
      ...deskClear('friction', '2026-12-04'),
      ...phoneClear('force-systems-resultants', '2026-12-05'),
      ...deskClear('frames-machines', '2026-12-06'),
    ];
    const p = progress(DEC, events);
    const by = Object.fromEntries(p.lessons.map((l) => [l.id, l.cleared]));
    expect(by).toMatchObject({ friction: 'desk', 'force-systems-resultants': 'phone', 'frames-machines': 'desk' });
    expect(p.cleared).toBe(3);
    expect(p.finished).toBe(false);
  });

  it('ignores work from before the 1st and counts the last local day', () => {
    const p = progress(DEC, [...phoneClear('friction', '2026-11-30'), ...deskClear('frames-machines', '2026-12-31')]);
    expect(p.lessons.find((l) => l.id === 'friction').cleared).toBeNull();
    expect(p.lessons.find((l) => l.id === 'frames-machines').cleared).toBe('desk');
  });

  it('needs every round of every game, and a miss then a retry still clears', () => {
    const events = phoneClear('friction', '2026-12-03');
    const p1 = progress(DEC, events.slice(1));
    expect(p1.lessons.find((l) => l.id === 'friction').cleared).toBeNull();
    const retried = [{ ...events[0], grade: 'forgot' }, ...events];
    expect(progress(DEC, retried).lessons.find((l) => l.id === 'friction').cleared).toBe('phone');
  });

  it('needs every practice problem right at the desk', () => {
    const desk = deskClear('friction', '2026-12-03');
    desk[0] = { ...desk[0], grade: 'forgot' };
    expect(progress(DEC, desk).lessons.find((l) => l.id === 'friction').cleared).toBeNull();
  });

  it('finishes on all seven, and gives the gold rim only to all seven at the desk', () => {
    const phone = statics.flatMap((l) => phoneClear(l.id, '2026-12-08'));
    const desk = statics.flatMap((l) => deskClear(l.id, '2026-12-09'));
    expect(progress(DEC, phone)).toMatchObject({ finished: true, finishedAtDesk: false });
    expect(progress(DEC, desk)).toMatchObject({ finished: true, finishedAtDesk: true });
    const mixed = [...phone, ...desk.filter((e) => !e.itemId.startsWith('stat-fri'))];
    expect(progress(DEC, mixed)).toMatchObject({ finished: true, finishedAtDesk: false });
  });

  it('lists finished challenges as coins and counts finishers', () => {
    const desk = statics.flatMap((l) => deskClear(l.id, '2026-12-09'));
    expect(finishedChallenges(desk)).toEqual([{ month: '2026-12', chapterId: 'statics', name: 'Statics Challenge', atDesk: true }]);
    const byEmail = new Map([['a', desk], ['b', phoneClear('friction', '2026-12-02')]]);
    expect(finishedCount(DEC, byEmail)).toEqual({ finished: 1, atDesk: 1, taking: 2 });
  });

  it('never moves mastery', () => {
    const phone = statics.flatMap((l) => phoneClear(l.id, '2026-12-08'));
    expect(progress(DEC, phone).finished).toBe(true);
    expect(deriveAccount({ events: phone }).chapterMastery.statics.totalMastery).toBe(0);
  });
});

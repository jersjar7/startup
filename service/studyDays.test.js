import { describe, it, expect } from 'vitest';
import { studyDayUpdate, collectStudyDays, dayFor } from './studyDays.js';

describe('studyDayUpdate', () => {
  it('adds the day to the set whenever a stats write moves lastSessionDate', () => {
    const u = studyDayUpdate({ currentStreak: 4, lastSessionDate: '2026-09-19' });
    expect(u).toEqual({
      $set: { currentStreak: 4, lastSessionDate: '2026-09-19' },
      $addToSet: { studyDays: '2026-09-19' },
    });
  });

  it('leaves a write without a day alone', () => {
    expect(studyDayUpdate({ totalXp: 10 })).toEqual({ $set: { totalXp: 10 } });
    expect(studyDayUpdate({ lastSessionDate: null })).toEqual({ $set: { lastSessionDate: null } });
    expect(studyDayUpdate({ lastSessionDate: 'yesterday' })).toEqual({ $set: { lastSessionDate: 'yesterday' } });
  });
});

describe('collectStudyDays', () => {
  it('unions every dated record into sorted distinct days', () => {
    const days = collectStudyDays({
      existing: ['2026-09-01'],
      sessions: [{ completedAt: new Date('2026-08-03T23:10:00Z') }, { completedAt: new Date('2026-08-03T01:00:00Z') }],
      events: [{ localDate: '2026-08-05' }, { localDate: '2026-08-05' }, { localDate: 'bad' }],
      diagnostics: [{ completedAt: '2026-07-30T12:00:00Z' }],
      attempts: [{ createdAt: new Date('2026-09-02T08:00:00Z') }],
    });
    expect(days).toEqual(['2026-07-30', '2026-08-03', '2026-08-05', '2026-09-01', '2026-09-02']);
  });

  it('is empty for a user with nothing on record', () => {
    expect(collectStudyDays({})).toEqual([]);
  });
});

describe('dayFor', () => {
  it("takes the student's day when the client sent one, else the server's UTC day", () => {
    expect(dayFor({ localDate: '2026-09-19' })).toBe('2026-09-19');
    expect(dayFor({ localDate: 'yesterday' })).toBe(new Date().toISOString().slice(0, 10));
    expect(dayFor({})).toBe(new Date().toISOString().slice(0, 10));
    expect(dayFor(undefined)).toBe(new Date().toISOString().slice(0, 10));
  });
});

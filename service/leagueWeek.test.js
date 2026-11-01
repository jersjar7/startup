import { describe, it, expect } from 'vitest';
const week = require('./leagues/week.js');
const { getWeekId } = require('./routes/leaderboard.js');
const { weekIdFor } = require('./rederive.js');

// The league week: Sunday to Saturday, US Eastern for everyone (ADR 0037).
// The board's getWeekId() and the re-derive's weekIdFor() must always name the
// same week, or a student's weekly XP lands in a week nobody reads.

describe('the week id', () => {
  it('keeps the ids the board has always used, away from New Year', () => {
    expect(weekIdFor('2026-10-31')).toBe('2026-W44'); // Saturday
    expect(weekIdFor('2026-11-01')).toBe('2026-W45'); // Sunday
    expect(weekIdFor('2026-06-15')).toBe('2026-W25');
  });

  it('gives every day of one week the same id', () => {
    const ids = week.daysOfWeek('2026-11-04').map(weekIdFor);
    expect(new Set(ids).size).toBe(1);
    expect(ids[0]).toBe('2026-W45');
  });

  it('never splits the week that crosses New Year', () => {
    // Sunday 2026-12-27 to Saturday 2027-01-02 is one week.
    for (const d of ['2026-12-27', '2026-12-31', '2027-01-01', '2027-01-02']) {
      expect(weekIdFor(d)).toBe('2026-W53');
    }
    expect(weekIdFor('2027-01-03')).toBe('2027-W02');
  });

  it('sorts in order as text, so older weeks compare lower', () => {
    expect(weekIdFor('2026-12-27') < weekIdFor('2027-01-03')).toBe(true);
    expect(weekIdFor('2026-02-01') < weekIdFor('2026-11-01')).toBe(true);
  });
});

describe('the board and the re-derive agree', () => {
  const cases = [
    ['Saturday 23:30 Eastern is still the old week', '2026-11-08T04:30:00Z', '2026-W45'],
    ['Sunday 00:30 Eastern is the new week', '2026-11-08T05:30:00Z', '2026-W46'],
    ['Saturday 23:30 Eastern in summer time', '2026-07-12T03:30:00Z', '2026-W28'],
    ['Sunday 00:30 Eastern in summer time', '2026-07-12T04:30:00Z', '2026-W29'],
    ['a Sunday morning UTC that is still Saturday night Eastern', '2026-11-01T02:00:00Z', '2026-W44'],
  ];
  for (const [label, iso, id] of cases) {
    it(label, () => {
      const now = new Date(iso);
      expect(getWeekId(now)).toBe(id);
      expect(weekIdFor(week.dayIn(now))).toBe(id);
    });
  }
});

describe('when the week ends', () => {
  it('is the next Sunday at midnight Eastern', () => {
    expect(week.weekEndsAt(new Date('2026-11-04T15:00:00Z')).toISOString()).toBe('2026-11-08T05:00:00.000Z');
  });

  it('follows summer time', () => {
    expect(week.weekEndsAt(new Date('2026-07-08T15:00:00Z')).toISOString()).toBe('2026-07-12T04:00:00.000Z');
  });

  it('names the week before', () => {
    expect(week.previousWeekId(new Date('2026-11-08T08:00:00Z'))).toBe('2026-W45');
  });
});

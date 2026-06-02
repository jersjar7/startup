import { describe, it, expect } from 'vitest';
const { dateAxis, seriesFor, cumulative } = require('./analytics');

describe('dateAxis', () => {
  it('builds a continuous chronological axis ending on the given day', () => {
    const axis = dateAxis('2026-06-01', 5);
    expect(axis).toEqual(['2026-05-28', '2026-05-29', '2026-05-30', '2026-05-31', '2026-06-01']);
  });

  it('crosses month boundaries correctly', () => {
    const axis = dateAxis('2026-03-02', 4);
    expect(axis).toEqual(['2026-02-27', '2026-02-28', '2026-03-01', '2026-03-02']);
  });

  it('spans a daylight-saving change without dropping or duplicating a day', () => {
    // US DST began 2026-03-08; a window across it must stay 1 day apart.
    const axis = dateAxis('2026-03-10', 5);
    expect(axis).toEqual(['2026-03-06', '2026-03-07', '2026-03-08', '2026-03-09', '2026-03-10']);
  });
});

describe('seriesFor', () => {
  const axis = ['2026-05-30', '2026-05-31', '2026-06-01'];

  it('zero-fills days with no data', () => {
    const rows = [{ day: '2026-05-31', count: 4 }];
    expect(seriesFor(rows, axis, 'count')).toEqual([0, 4, 0]);
  });

  it('maps the requested key and coerces to numbers', () => {
    const rows = [{ day: '2026-05-30', cents: 2900 }, { day: '2026-06-01', cents: '4900' }];
    expect(seriesFor(rows, axis, 'cents')).toEqual([2900, 0, 4900]);
  });
});

describe('cumulative', () => {
  it('produces a running total offset by a baseline', () => {
    expect(cumulative([1, 2, 3], 10)).toEqual([11, 13, 16]);
  });

  it('ends at the true total when baseline = total - window sum', () => {
    const daily = [2, 0, 5];
    const total = 100;
    const baseline = total - daily.reduce((a, b) => a + b, 0);
    const series = cumulative(daily, baseline);
    expect(series[series.length - 1]).toBe(total);
  });
});

import { describe, it, expect } from 'vitest';
import {
  resolveWindow,
  isAllTime,
  MIN_WINDOW,
  MAX_WINDOW,
  DEFAULT_WINDOW,
} from './analyticsWindow.js';

// The rule worth guarding: "all time" must keep meaning all time. A fixed
// ceiling would silently start truncating it once the platform is old enough,
// and the page would go on looking correct while hiding the earliest months.

const LAUNCH = '2026-06-03T00:00:00Z'; // the first real account
const now = (iso) => new Date(iso).getTime();

describe('naming the all-time range', () => {
  it('recognises it however it is cased', () => {
    expect(isAllTime('all')).toBe(true);
    expect(isAllTime('ALL')).toBe(true);
    expect(isAllTime('All')).toBe(true);
  });

  it('does not mistake a number for it', () => {
    expect(isAllTime(30)).toBe(false);
    expect(isAllTime('30')).toBe(false);
    expect(isAllTime(null)).toBe(false);
  });
});

describe('fixed ranges', () => {
  it('passes a normal range straight through', () => {
    expect(resolveWindow(7)).toBe(7);
    expect(resolveWindow(30)).toBe(30);
    expect(resolveWindow(90)).toBe(90);
    expect(resolveWindow('90')).toBe(90);
  });

  it('falls back to the default rather than failing', () => {
    expect(resolveWindow(undefined)).toBe(DEFAULT_WINDOW);
    expect(resolveWindow('')).toBe(DEFAULT_WINDOW);
    expect(resolveWindow('tuesday')).toBe(DEFAULT_WINDOW);
  });

  it('refuses a window that would ask for a million buckets', () => {
    expect(resolveWindow(999999)).toBe(MAX_WINDOW);
    expect(resolveWindow(-5)).toBe(MIN_WINDOW);
    expect(resolveWindow(0)).toBe(DEFAULT_WINDOW); // zero is "unset", not "none"
  });
});

describe('all time', () => {
  it('reaches back to the first account, with the launch day complete', () => {
    // 3 June to 6 October is 125.3 elapsed days and 126 calendar buckets,
    // counting the launch day itself.
    expect(resolveWindow('all', {
      firstAccountAt: LAUNCH,
      now: now('2026-10-06T07:00:00Z'),
    })).toBe(126);
  });

  it('is not capped at a year, which is the whole point', () => {
    // The window this replaced clamped at 365. From a June launch that would
    // have started quietly dropping the earliest months in the second summer,
    // with the page still looking perfectly correct.
    const at = (iso) => resolveWindow('all', { firstAccountAt: LAUNCH, now: now(iso) });

    expect(at('2027-06-03T00:00:00Z')).toBe(365); // exactly a year
    expect(at('2027-09-01T00:00:00Z')).toBeGreaterThan(365);
    expect(at('2028-06-03T00:00:00Z')).toBeGreaterThan(730);
    expect(at('2029-06-03T00:00:00Z')).toBeGreaterThan(at('2028-06-03T00:00:00Z'));
  });

  it('survives having no accounts at all', () => {
    expect(resolveWindow('all', { firstAccountAt: null })).toBe(MIN_WINDOW);
    expect(resolveWindow('all', {})).toBe(MIN_WINDOW);
  });

  it('survives a corrupt date rather than producing a nonsense axis', () => {
    expect(resolveWindow('all', { firstAccountAt: 'not a date' })).toBe(MIN_WINDOW);
  });

  it('never asks for less than the minimum, even on launch day', () => {
    expect(resolveWindow('all', {
      firstAccountAt: LAUNCH,
      now: now('2026-06-03T06:00:00Z'),
    })).toBe(MIN_WINDOW);
  });

  it('is still bounded, so a bad createdAt cannot hang the page', () => {
    expect(resolveWindow('all', {
      firstAccountAt: '1970-01-01T00:00:00Z',
      now: now('2026-10-06T00:00:00Z'),
    })).toBe(MAX_WINDOW);
  });
});

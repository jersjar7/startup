import { describe, it, expect } from 'vitest';
import { formatDuration } from './formatDuration';

describe('formatDuration', () => {
  it('renders hours and minutes', () => {
    expect(formatDuration(17520)).toBe('4h 52m');
  });

  it('drops the hour part under an hour', () => {
    expect(formatDuration(2820)).toBe('47m');
  });

  it('renders the full exam limit as 5h 20m', () => {
    // Must match TIME_LIMIT_SECONDS in service/examAttempt.js, which is what
    // the results screen prints as the denominator.
    expect(formatDuration(19200)).toBe('5h 20m');
  });

  it('handles zero', () => {
    expect(formatDuration(0)).toBe('0m');
  });

  it('rounds to the nearest minute rather than truncating', () => {
    expect(formatDuration(119)).toBe('2m');
  });

  it('carries a rounded 60th minute into the hour', () => {
    // 3599s rounds to 60 minutes, which must read "1h 0m", never "0h 60m".
    expect(formatDuration(3599)).toBe('1h 0m');
  });

  // Attempts completed before time was tracked, and any bad payload, must
  // return null so the caller can hide the stat instead of printing "NaNh".
  it.each([undefined, null, NaN, Infinity, -1, 'abc'])('returns null for %s', (bad) => {
    expect(formatDuration(bad)).toBeNull();
  });
});

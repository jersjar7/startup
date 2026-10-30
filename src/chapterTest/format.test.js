import { describe, it, expect } from 'vitest';
import { formatClock, formatDuration } from './format';

describe('chapter test clock', () => {
  it('shows m:ss under an hour and h:mm:ss above', () => {
    expect(formatClock(45 * 60)).toBe('45:00');
    expect(formatClock(65)).toBe('1:05');
    expect(formatClock(3725)).toBe('1:02:05');
    expect(formatClock(-3)).toBe('0:00');
  });
  it('says time taken in words', () => {
    expect(formatDuration(20)).toBe('under a minute');
    expect(formatDuration(36 * 60)).toBe('36 min');
    expect(formatDuration(65 * 60)).toBe('1 h 5 min');
  });
});

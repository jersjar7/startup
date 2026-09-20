import { describe, it, expect } from 'vitest';
import { validateFeedback, overTheHourlyLimit, MAX_TEXT, PER_HOUR } from './feedback.js';

describe('validateFeedback', () => {
  const good = { kind: 'explanation', kindLabel: 'The explanation', text: ' The sign rule was not clear. ', gameId: 'set-it-up', chapterId: 'mathematics', round: 3, build: '850' };

  it('cleans a good report', () => {
    expect(validateFeedback(good)).toEqual({
      ok: true,
      value: { kind: 'explanation', kindLabel: 'The explanation', text: 'The sign rule was not clear.', gameId: 'set-it-up', chapterId: 'mathematics', round: 3, build: '850' },
    });
  });

  it('knows every part of a round, and falls back to the id as the label', () => {
    for (const kind of ['question', 'drawing', 'howto', 'concept', 'answer', 'explanation']) {
      expect(validateFeedback({ ...good, kind, kindLabel: '' }).value.kindLabel).toBe(kind);
    }
  });

  it('refuses an unknown kind, an empty line, and a wall of text', () => {
    expect(validateFeedback({ ...good, kind: 'rant' }).ok).toBe(false);
    expect(validateFeedback({ ...good, text: '   ' }).ok).toBe(false);
    expect(validateFeedback({ ...good, text: 'x'.repeat(MAX_TEXT + 1) }).ok).toBe(false);
    expect(validateFeedback({ ...good, gameId: '' }).ok).toBe(false);
    expect(validateFeedback(null).ok).toBe(false);
  });

  it('drops a round it cannot trust rather than failing the report', () => {
    expect(validateFeedback({ ...good, round: 'three' }).value.round).toBeNull();
    expect(validateFeedback({ ...good, round: -1 }).value.round).toBeNull();
  });

  it('caps reports per hour', () => {
    expect(overTheHourlyLimit(PER_HOUR - 1)).toBe(false);
    expect(overTheHourlyLimit(PER_HOUR)).toBe(true);
  });
});

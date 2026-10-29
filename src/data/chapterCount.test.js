import { describe, it, expect } from 'vitest';
import { getChapterProblemCount, getProblemPoolSize } from './problemPool';
import { CHAPTERS } from './chapters';

describe('getChapterProblemCount', () => {
  it('splits the whole bank across the 15 chapters', () => {
    const counts = CHAPTERS.map((c) => getChapterProblemCount(c.id));
    expect(counts.every((n) => n > 0)).toBe(true);
    expect(counts.reduce((a, b) => a + b, 0)).toBe(getProblemPoolSize());
  });
});

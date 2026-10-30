import { describe, it, expect } from 'vitest';
import { pageTitle, titleName, TITLE_MAX } from './pageTitle';
import { allTopics } from '../public/content';

describe('page titles', () => {
  it('keeps the brand only when it fits', () => {
    expect(pageTitle('Short')).toBe('Short | FE for Raccoons');
    expect(pageTitle('x'.repeat(60))).toBe('x'.repeat(60));
  });

  it('fits every chapter title under the limit, even with a 4-digit count', () => {
    for (const t of allTopics()) {
      expect(pageTitle(`FE Civil ${titleName(t)} Practice Problems (9999 Free)`).length, t.id).toBeLessThanOrEqual(TITLE_MAX);
      expect(pageTitle(`FE Civil ${titleName(t)} Practice Problems with Solutions`).length, t.id).toBeLessThanOrEqual(TITLE_MAX);
    }
  });
});

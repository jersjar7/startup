import { describe, it, expect } from 'vitest';
import { HANDBOOK_EDITION, handbookRef } from './handbook.js';

describe('handbookRef', () => {
  it('names the edition before the page', () => {
    expect(handbookRef('p. 182')).toBe(`Handbook ${HANDBOOK_EDITION}, p. 182`);
  });

  it('reads a bare page number as a page', () => {
    expect(handbookRef('36')).toBe(`Handbook ${HANDBOOK_EDITION}, p. 36`);
  });

  it('keeps ranges and section notes as written', () => {
    expect(handbookRef('pp. 4-5, Model Rules §240.15', 'FE Reference Handbook'))
      .toBe(`FE Reference Handbook ${HANDBOOK_EDITION}, pp. 4-5, Model Rules §240.15`);
  });
});

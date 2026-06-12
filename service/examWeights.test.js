import { describe, it, expect } from 'vitest';
const {
  EXAM_DISTRIBUTION,
  TOTAL_WEIGHT,
  weightedMastery,
  coveragePercent,
} = require('./examWeights');

describe('examWeights', () => {
  it('the NCEES distribution sums to 110', () => {
    expect(TOTAL_WEIGHT).toBe(110);
  });

  it('weightedMastery is 0 for an empty map and 100 when every chapter is mastered', () => {
    expect(weightedMastery({})).toBe(0);
    const all = {};
    for (const id of Object.keys(EXAM_DISTRIBUTION)) all[id] = { totalMastery: 100 };
    expect(weightedMastery(all)).toBe(100);
  });

  it('weightedMastery is coverage-anchored: untouched chapters drag it down', () => {
    // Master only structural (weight 13 of 110) -> ~12.
    expect(weightedMastery({ structural: { totalMastery: 100 } })).toBe(Math.round((100 * 13) / 110));
  });

  it('weightedMastery weights by exam share, not chapter count', () => {
    // water-resources (14) mastered beats construction (5) mastered.
    expect(weightedMastery({ 'water-resources': { totalMastery: 100 } })).toBeGreaterThan(
      weightedMastery({ construction: { totalMastery: 100 } }),
    );
  });

  it('coveragePercent counts only chapters past the threshold, weighted', () => {
    expect(coveragePercent({})).toBe(0);
    // A bare diagnostic blip (below threshold) is not "covered".
    expect(coveragePercent({ structural: { totalMastery: 10 } })).toBe(0);
    // structural at/above threshold -> 13/110.
    expect(coveragePercent({ structural: { totalMastery: 20 } })).toBe(Math.round((100 * 13) / 110));
  });
});

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
    // Master only structural (weight 11 of 110) -> ~10.
    expect(weightedMastery({ structural: { totalMastery: 100 } })).toBe(Math.round((100 * 11) / 110));
  });

  it('weightedMastery weights by exam share, not chapter count', () => {
    // water-resources (11) mastered beats materials (6) mastered.
    expect(weightedMastery({ 'water-resources': { totalMastery: 100 } })).toBeGreaterThan(
      weightedMastery({ materials: { totalMastery: 100 } }),
    );
  });

  it('matches the current NCEES spec, not the retired 2014 one', () => {
    // research/civil/fe-civil-cbt-spec.pdf, effective July 2020, midpoints
    // scaled to 110. The 2014 numbers gave maths 17 and construction 5, which
    // is what this guards against coming back.
    expect(EXAM_DISTRIBUTION.mathematics + EXAM_DISTRIBUTION.statistics).toBe(9);
    expect(EXAM_DISTRIBUTION.construction).toBe(9);
    expect(EXAM_DISTRIBUTION.surveying).toBe(6);
    expect(EXAM_DISTRIBUTION['fluid-mechanics']).toBe(6);
    expect(EXAM_DISTRIBUTION['water-resources']).toBe(11);
  });

  it('the three copies of the distribution agree', () => {
    // The same map lives in the backend, the exam bank and the phone, kept in
    // sync by hand. They diverging is the silent failure: the dashboard and
    // the phone would show different mastery for the same account.
    const fs = require('node:fs');
    const parse = (src, open) => {
      const i = src.indexOf(open);
      const body = src.slice(i, src.indexOf('};', i));
      const out = {};
      for (const m of body.matchAll(/['"]?([a-z-]+)['"]?\s*:\s*(\d+)/g)) out[m[1]] = Number(m[2]);
      return out;
    };
    const bank = parse(
      fs.readFileSync('src/data/exam-bank/index.js', 'utf8'),
      'const EXAM_DISTRIBUTION = {',
    );
    const phone = parse(
      fs.readFileSync('mobile/lib/features/profile/mastery_model.dart', 'utf8'),
      'const examWeights = <String, int>{',
    );
    expect(bank).toEqual(EXAM_DISTRIBUTION);
    expect(phone).toEqual(EXAM_DISTRIBUTION);
  });

  it('coveragePercent counts only chapters past the threshold, weighted', () => {
    expect(coveragePercent({})).toBe(0);
    // A bare diagnostic blip (below threshold) is not "covered".
    expect(coveragePercent({ structural: { totalMastery: 10 } })).toBe(0);
    // structural at/above threshold -> 11/110.
    expect(coveragePercent({ structural: { totalMastery: 20 } })).toBe(Math.round((100 * 11) / 110));
  });
});

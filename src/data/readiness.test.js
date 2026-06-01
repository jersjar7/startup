import { describe, it, expect } from 'vitest';
import { computeReadiness, computeFocusAreas, readinessLabel } from './readiness';

describe('computeReadiness', () => {
  it('is 0 with no mastery data', () => {
    expect(computeReadiness({})).toBe(0);
  });

  it('is 100 when every chapter is fully mastered', () => {
    const all = {};
    const ids = ['mathematics', 'statistics', 'ethics', 'economics', 'statics', 'dynamics',
      'mechanics-materials', 'materials', 'fluid-mechanics', 'surveying', 'water-resources',
      'structural', 'geotechnical', 'transportation', 'construction'];
    ids.forEach((id) => { all[id] = 100; });
    expect(computeReadiness(all)).toBe(100);
  });

  it('weights by exam question count (statics weight 8 of 110)', () => {
    expect(computeReadiness({ statics: 100 })).toBe(Math.round((100 * 8) / 110)); // 7
  });

  it('ignores unknown chapter ids', () => {
    expect(computeReadiness({ 'not-a-chapter': 100 })).toBe(0);
  });
});

describe('computeFocusAreas', () => {
  it('returns the 3 highest-leverage chapters, weakest-first by score', () => {
    const focus = computeFocusAreas({});
    expect(focus).toHaveLength(3);
    // all at 0% mastery -> ranked purely by exam weight; transportation (12) is highest
    expect(focus[0].ch.id).toBe('transportation');
    expect(focus[0].focusScore).toBe(100 * 12);
  });

  it('excludes chapters at or above the mastered threshold', () => {
    const mastery = { transportation: 95 };
    const focus = computeFocusAreas(mastery);
    expect(focus.find((f) => f.ch.id === 'transportation')).toBeUndefined();
  });

  it('honors the exclude option', () => {
    const focus = computeFocusAreas({}, { exclude: ['transportation'] });
    expect(focus.find((f) => f.ch.id === 'transportation')).toBeUndefined();
  });

  it('respects the limit option', () => {
    expect(computeFocusAreas({}, { limit: 1 })).toHaveLength(1);
  });
});

describe('readinessLabel', () => {
  it('maps percentages to tiers', () => {
    expect(readinessLabel(10)).toBe('Just getting started');
    expect(readinessLabel(40)).toBe('Building momentum');
    expect(readinessLabel(70)).toBe('On track to pass');
    expect(readinessLabel(85)).toBe('Exam ready');
  });
});

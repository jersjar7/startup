import { describe, it, expect } from 'vitest';
import { getProblemById, getProblemPoolSize } from './problemPool';

describe('problemPool resolver (review single source of truth)', () => {
  it('indexes the full pool', () => {
    expect(getProblemPoolSize()).toBeGreaterThan(900);
  });

  it('resolves a lesson-practice id', () => {
    const p = getProblemById('stat-fri-q1');
    expect(p).toBeTruthy();
    expect(p.statement).toBeTruthy();
    expect(p.choices).toHaveLength(4);
    expect(p.choices.some((c) => c.id === p.correctAnswerId)).toBe(true);
  });

  it('resolves an exam-bank id', () => {
    const p = getProblemById('stat-fsr-ex1');
    expect(p).toBeTruthy();
    expect(p.correctAnswerId).toBeTruthy();
  });

  it('resolves a chapter-practice id', () => {
    const p = getProblemById('stat-fri-cp1');
    expect(p).toBeTruthy();
    expect(p.chapterId).toBe('statics');
  });

  it('returns null for an unknown / removed id', () => {
    expect(getProblemById('does-not-exist-zzz')).toBeNull();
  });

  // Guards the Diagnostic Review screen: every diagnostic question (exam-bank
  // ids) must resolve to a full problem, or the review renders empty cards.
  it('resolves every diagnostic question id', async () => {
    const DIAGNOSTIC_IDS = (await import('./exam-bank/diagnostic-ids')).default;
    expect(DIAGNOSTIC_IDS.length).toBeGreaterThan(0);
    for (const id of DIAGNOSTIC_IDS) {
      const p = getProblemById(id);
      expect(p, `diagnostic id ${id} should resolve`).toBeTruthy();
      expect(p.statement).toBeTruthy();
    }
  });
});

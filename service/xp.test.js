import { describe, it, expect } from 'vitest';
const { XP, sessionXp, reviewXp, diagnosticXp, examXp, phoneXp } = require('./xp');

describe('xp table', () => {
  it('practice session = correct*10 + incorrect*5 + 25 bonus', () => {
    expect(sessionXp(5, 0)).toBe(75);
    expect(sessionXp(3, 2)).toBe(65);
    expect(sessionXp(0, 0)).toBe(XP.sessionBonus);
  });

  it('review session uses the 15 review bonus', () => {
    expect(reviewXp(5, 0)).toBe(65);
    expect(reviewXp(0, 0)).toBe(XP.reviewBonus);
  });

  it('diagnostic = attempted*10 + correct*5', () => {
    expect(diagnosticXp(5, 3)).toBe(65);
  });

  it('exam = 100 attempt + correct*2', () => {
    expect(examXp(0)).toBe(100);
    expect(examXp(80)).toBe(260);
  });

  it('phone weights gotIt > fuzzy > forgot and ignores unknowns', () => {
    expect(phoneXp({ gotIt: 4, fuzzy: 2, forgot: 1 })).toBe(28);
    expect(phoneXp({})).toBe(0);
    expect(XP.phone.gotIt).toBeGreaterThan(XP.phone.fuzzy);
    expect(XP.phone.fuzzy).toBeGreaterThan(XP.phone.forgot);
  });

  it('a phone card is worth less than a desk problem, and the day is capped', () => {
    expect(XP.phone.gotIt).toBeLessThan(XP.problemCorrect);
    expect(XP.phoneDailyCap).toBe(60);
  });
});

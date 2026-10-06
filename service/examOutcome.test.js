import { describe, it, expect } from 'vitest';
import { ASK_AFTER_DAYS, dueDate, shouldAsk, isAnswered, parseOutcome } from './examOutcome.js';

// These two records are the only ones that can ever prove the product works,
// so the rules worth guarding are: ask exactly once, never ask someone with no
// exam date, and never store a result that would poison a pass rate.

describe('when the question comes due', () => {
  it('lands nine days after the exam, when results are out but the day is fresh', () => {
    expect(ASK_AFTER_DAYS).toBe(9);
    expect(dueDate('2026-04-10')).toBe('2026-04-19');
  });

  it('crosses a month and a year boundary correctly', () => {
    expect(dueDate('2026-01-25')).toBe('2026-02-03');
    expect(dueDate('2026-12-28')).toBe('2027-01-06');
  });

  it('has no due date without a usable exam date', () => {
    expect(dueDate(null)).toBeNull();
    expect(dueDate('')).toBeNull();
    expect(dueDate('not a date')).toBeNull();
  });
});

describe('who gets asked', () => {
  const user = (over = {}) => ({ examDate: '2026-04-10', ...over });

  it('is asked on the due day and every day after, until answered', () => {
    expect(shouldAsk(user(), '2026-04-19')).toBe(true);
    expect(shouldAsk(user(), '2026-05-01')).toBe(true);
  });

  it('is not asked before the day the result exists', () => {
    expect(shouldAsk(user(), '2026-04-18')).toBe(false);
    expect(shouldAsk(user(), '2026-04-10')).toBe(false);
  });

  it('is never asked without an exam date, which is most of the base', () => {
    expect(shouldAsk({ examDate: null }, '2026-05-01')).toBe(false);
    expect(shouldAsk({}, '2026-05-01')).toBe(false);
    expect(shouldAsk(null, '2026-05-01')).toBe(false);
  });

  it('is never asked twice', () => {
    expect(shouldAsk(user({ examOutcome: { askedAt: new Date() } }), '2026-05-01')).toBe(false);
    expect(shouldAsk(user({ examOutcome: { answeredAt: new Date() } }), '2026-05-01')).toBe(false);
    expect(shouldAsk(user({ examOutcome: { declinedAt: new Date() } }), '2026-05-01')).toBe(false);
  });
});

describe('answered', () => {
  it('counts an answer and a refusal the same', () => {
    expect(isAnswered({ examOutcome: { answeredAt: new Date() } })).toBe(true);
    expect(isAnswered({ examOutcome: { declinedAt: new Date() } })).toBe(true);
  });

  it('does not count merely having been asked', () => {
    expect(isAnswered({ examOutcome: { askedAt: new Date() } })).toBe(false);
    expect(isAnswered({})).toBe(false);
    expect(isAnswered(null)).toBe(false);
  });
});

describe('what an answer may say', () => {
  it('takes a pass with an attempt number', () => {
    expect(parseOutcome({ sat: true, passed: true, attemptNumber: 1 }))
      .toEqual({ sat: true, passed: true, attemptNumber: 1 });
  });

  it('takes a fail, which is the more valuable record of the two', () => {
    expect(parseOutcome({ sat: true, passed: false, attemptNumber: 2 }))
      .toEqual({ sat: true, passed: false, attemptNumber: 2 });
  });

  it('records somebody who did not sit it as having no result at all', () => {
    // Storing passed:false against a no-show would make every pass rate
    // computed from this field wrong, in the direction that flatters nobody.
    expect(parseOutcome({ sat: false })).toEqual({ sat: false, passed: null, attemptNumber: null });
    expect(parseOutcome({ sat: false, passed: false })).toEqual({ sat: false, passed: null, attemptNumber: null });
  });

  it('takes a refusal to answer', () => {
    expect(parseOutcome({ declined: true })).toEqual({ declined: true });
  });

  it('allows a missing attempt number, since people forget', () => {
    expect(parseOutcome({ sat: true, passed: true }).attemptNumber).toBeNull();
    expect(parseOutcome({ sat: true, passed: true, attemptNumber: '' }).attemptNumber).toBeNull();
  });

  it('rejects a body that says nothing usable', () => {
    expect(parseOutcome({})).toBeNull();
    expect(parseOutcome(null)).toBeNull();
    expect(parseOutcome('yes')).toBeNull();
    expect(parseOutcome({ sat: 'yes' })).toBeNull();
    expect(parseOutcome({ sat: true })).toBeNull(); // sat but no result
  });

  it('rejects an impossible attempt number', () => {
    expect(parseOutcome({ sat: true, passed: true, attemptNumber: 0 })).toBeNull();
    expect(parseOutcome({ sat: true, passed: true, attemptNumber: -1 })).toBeNull();
    expect(parseOutcome({ sat: true, passed: true, attemptNumber: 99 })).toBeNull();
    expect(parseOutcome({ sat: true, passed: true, attemptNumber: 1.5 })).toBeNull();
  });
});

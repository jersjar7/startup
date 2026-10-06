import { describe, it, expect } from 'vitest';
import {
  parseAnswer,
  outcomeUpdate,
  shouldRecord,
  validAttempt,
  resultCopy,
} from './examResultLink.js';

// The email's buttons used to point at /exam-result, a route that existed
// nowhere. Every tap would have landed on the catch-all and recorded nothing,
// and the only reason it never bit anyone was that the email was held behind a
// flag. This file is the guard against that returning.
//
// The rules: one tap records the answer with no sign in, a second tap or a
// mail client's prefetch cannot overwrite a real answer, a bad token or a bad
// answer writes nothing, and somebody who did not sit the exam is never
// recorded as having failed.

describe('reading the answer', () => {
  it('knows the three the email offers, however they are cased', () => {
    expect(parseAnswer('passed')).toEqual({ sat: true, passed: true });
    expect(parseAnswer('FAILED')).toEqual({ sat: true, passed: false });
    expect(parseAnswer('Missed')).toEqual({ sat: false, passed: null });
  });

  it('refuses anything else, so a mangled link writes nothing', () => {
    expect(parseAnswer('maybe')).toBeNull();
    expect(parseAnswer('')).toBeNull();
    expect(parseAnswer(null)).toBeNull();
    expect(parseAnswer('true')).toBeNull();
  });
});

describe('what gets written', () => {
  const now = new Date('2026-04-19T10:00:00Z');

  it('records a pass in the same shape the app writes', () => {
    const u = outcomeUpdate('passed', { examDate: '2026-04-10', now });
    expect(u['examOutcome.sat']).toBe(true);
    expect(u['examOutcome.passed']).toBe(true);
    expect(u['examOutcome.examDateAtAnswer']).toBe('2026-04-10');
    expect(u['examOutcome.answeredAt']).toBe(now);
    expect(u['examOutcome.via']).toBe('email');
  });

  it('records a fail, which is the answer the whole design protects', () => {
    const u = outcomeUpdate('failed', { now });
    expect(u['examOutcome.sat']).toBe(true);
    expect(u['examOutcome.passed']).toBe(false);
  });

  it('records a no-show as having no result at all', () => {
    // passed:false against somebody who never sat it would make every pass
    // rate computed from this field wrong.
    const u = outcomeUpdate('missed', { now });
    expect(u['examOutcome.sat']).toBe(false);
    expect(u['examOutcome.passed']).toBeNull();
  });

  it('always clears the attempt number, so a re-answer inherits nothing', () => {
    expect(outcomeUpdate('passed', { now })['examOutcome.attemptNumber']).toBeNull();
  });

  it('writes nothing at all for an answer it does not recognise', () => {
    expect(outcomeUpdate('maybe', { now })).toBeNull();
  });
});

describe('whether to write', () => {
  it('writes for a real user giving a real answer', () => {
    expect(shouldRecord({ email: 'a@b.com' }, 'passed')).toBe(true);
  });

  it('writes nothing for a token nobody holds', () => {
    expect(shouldRecord(null, 'passed')).toBe(false);
    expect(shouldRecord(undefined, 'passed')).toBe(false);
  });

  it('cannot overwrite a real answer, so a prefetch or a second tap is safe', () => {
    // Mail clients follow links to build previews. A second visit must never
    // silently change what somebody said.
    const answered = { examOutcome: { answeredAt: new Date(), passed: true } };
    expect(shouldRecord(answered, 'failed')).toBe(false);
    const declined = { examOutcome: { declinedAt: new Date() } };
    expect(shouldRecord(declined, 'passed')).toBe(false);
  });

  it('writes nothing for a mangled answer even with a good token', () => {
    expect(shouldRecord({ email: 'a@b.com' }, 'maybe')).toBe(false);
  });
});

describe('what the page says back', () => {
  it('congratulates only a pass', () => {
    expect(resultCopy('passed').heading).toBe('Congratulations');
    expect(resultCopy('failed').heading).not.toContain('Congratulations');
    expect(resultCopy('missed').heading).not.toContain('Congratulations');
  });

  it('thanks somebody who failed without dwelling on it', () => {
    const c = resultCopy('failed');
    expect(c.heading).toBe('Thank you for telling us');
    expect(c.msg).toContain('helps the people sitting it after you');
  });

  it('offers the attempt number only to somebody who actually sat it', () => {
    expect(resultCopy('passed').offerAttempt).toBe(true);
    expect(resultCopy('failed').offerAttempt).toBe(true);
    expect(resultCopy('missed').offerAttempt).toBe(false);
  });

  it('says so plainly when the answer was already in, and asks for nothing', () => {
    const c = resultCopy('passed', { already: true });
    expect(c.heading).toBe('Already noted');
    expect(c.offerAttempt).toBe(false);
  });
});

describe('the optional attempt number', () => {
  it('takes a plausible number', () => {
    expect(validAttempt('1')).toBe(1);
    expect(validAttempt(2)).toBe(2);
    expect(validAttempt('3')).toBe(3);
  });

  it('refuses an impossible one rather than storing it', () => {
    for (const n of ['0', '-1', '99', 'two', '', null, undefined, '1.5']) {
      expect(validAttempt(n)).toBeNull();
    }
  });
});

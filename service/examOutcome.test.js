import { describe, it, expect } from 'vitest';
import {
  ASK_AFTER_DAYS,
  ASK_DAYS,
  dueDate,
  askDue,
  shouldAsk,
  asksSent,
  isAnswered,
  parseOutcome,
} from './examOutcome.js';

// These two records are the only ones that can ever prove the product works,
// so the rules worth guarding are: ask up to four times and then never again,
// never ask someone with no exam date, stop the instant they answer or refuse,
// and never store a result that would poison a pass rate.

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

  it('stops the moment they answer, or refuse to', () => {
    expect(shouldAsk(user({ examOutcome: { answeredAt: new Date() } }), '2026-05-01')).toBe(false);
    expect(shouldAsk(user({ examOutcome: { declinedAt: new Date() } }), '2026-05-01')).toBe(false);
  });

  it('asks again when they say nothing, which is the point of the sequence', () => {
    // One ask already out, and the second is due. See the follow-up group
    // below for why silence is not treated as an answer.
    expect(shouldAsk(user({ examOutcome: { askedAt: new Date() } }), '2026-05-01')).toBe(true);
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
  // Every answer also records which surface it came from, so a reply rate can
  // be read per surface rather than guessed at. Absent means the app.
  it('takes a pass with an attempt number', () => {
    expect(parseOutcome({ sat: true, passed: true, attemptNumber: 1 }))
      .toEqual({ sat: true, passed: true, attemptNumber: 1, via: 'app' });
  });

  it('takes a fail, which is the more valuable record of the two', () => {
    expect(parseOutcome({ sat: true, passed: false, attemptNumber: 2, via: 'email' }))
      .toEqual({ sat: true, passed: false, attemptNumber: 2, via: 'email' });
  });

  it('records somebody who did not sit it as having no result at all', () => {
    // Storing passed:false against a no-show would make every pass rate
    // computed from this field wrong, in the direction that flatters nobody.
    expect(parseOutcome({ sat: false }))
      .toEqual({ sat: false, passed: null, attemptNumber: null, via: 'app' });
    expect(parseOutcome({ sat: false, passed: false, via: 'notification' }))
      .toEqual({ sat: false, passed: null, attemptNumber: null, via: 'notification' });
  });

  it('takes a refusal to answer', () => {
    expect(parseOutcome({ declined: true })).toEqual({ declined: true });
  });

  it('keeps putting the card away separate from refusing', () => {
    // One dismissal used to end the question forever on the phone while the
    // email went on asking four times. "Not now" and "never" are different.
    expect(parseOutcome({ snoozed: true })).toEqual({ snoozed: true });
    expect(parseOutcome({ snoozed: true }).declined).toBeUndefined();
    expect(parseOutcome({ declined: true }).snoozed).toBeUndefined();
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

describe('the follow-up sequence', () => {
  const after = (days) => {
    const d = new Date('2026-04-10T00:00:00Z');
    d.setUTCDate(d.getUTCDate() + days);
    return d.toISOString().slice(0, 10);
  };
  const user = (sent = 0) => ({
    examDate: '2026-04-10',
    examOutcome: sent ? { asks: Array.from({ length: sent }, () => new Date()) } : undefined,
  });

  it('is four touches and no more', () => {
    // The sequence exists to correct response BIAS, not to chase volume:
    // somebody who failed is less likely to say so, and a pass rate built
    // from mostly passers is inflated and worse than no data at all.
    expect(ASK_DAYS).toEqual([9, 16, 30, 60]);
    expect(ASK_DAYS[0]).toBe(ASK_AFTER_DAYS);
  });

  it('widens the gaps, so it reads as persistence rather than nagging', () => {
    const gaps = ASK_DAYS.slice(1).map((d, i) => d - ASK_DAYS[i]);
    expect(gaps).toEqual([7, 14, 30]);
    for (let i = 1; i < gaps.length; i++) {
      expect(gaps[i]).toBeGreaterThan(gaps[i - 1]);
    }
  });

  it('walks through all four in order', () => {
    expect(askDue(user(0), after(8))).toBe(0);
    expect(askDue(user(0), after(9))).toBe(1);
    expect(askDue(user(1), after(15))).toBe(0);
    expect(askDue(user(1), after(16))).toBe(2);
    expect(askDue(user(2), after(29))).toBe(0);
    expect(askDue(user(2), after(30))).toBe(3);
    expect(askDue(user(3), after(59))).toBe(0);
    expect(askDue(user(3), after(60))).toBe(4);
  });

  it('goes silent forever after the fourth, however long they wait', () => {
    expect(askDue(user(4), after(61))).toBe(0);
    expect(askDue(user(4), after(400))).toBe(0);
    expect(askDue(user(9), after(400))).toBe(0);
  });

  it('stops the moment they answer, at any point in the sequence', () => {
    for (let sent = 0; sent < 4; sent += 1) {
      const answered = { ...user(sent), examOutcome: { ...(user(sent).examOutcome || {}), answeredAt: new Date() } };
      const declined = { ...user(sent), examOutcome: { ...(user(sent).examOutcome || {}), declinedAt: new Date() } };
      expect(askDue(answered, after(400))).toBe(0);
      expect(askDue(declined, after(400))).toBe(0);
    }
  });

  it('counts an account asked by the first version as having had one', () => {
    // The first release stamped a single askedAt. Those people must pick up
    // at the second ask, not start the whole sequence again.
    expect(asksSent({ examOutcome: { askedAt: new Date() } })).toBe(1);
    expect(askDue({ examDate: '2026-04-10', examOutcome: { askedAt: new Date() } }, after(16))).toBe(2);
    expect(askDue({ examDate: '2026-04-10', examOutcome: { askedAt: new Date() } }, after(10))).toBe(0);
  });

  it('counts nothing for an account never asked', () => {
    expect(asksSent(null)).toBe(0);
    expect(asksSent({})).toBe(0);
    expect(asksSent({ examOutcome: {} })).toBe(0);
  });

  it('still never asks anyone without an exam date', () => {
    expect(askDue({ examDate: null }, after(400))).toBe(0);
    expect(shouldAsk({ examDate: null }, after(400))).toBe(false);
  });
});

import { describe, it, expect } from 'vitest';
const {
  sanitizeAnswers, mergeAnswers, answeredCount, elapsedSeconds,
} = require('./examProgress.js');

describe('mergeAnswers', () => {
  // THE critical property. A client that lost its state must not be able to
  // wipe answers the server already holds — that is the bug being fixed.
  it('never drops stored answers that the incoming set omits', () => {
    const stored = { q1: 'a', q2: 'b', q3: 'c' };
    expect(mergeAnswers(stored, { q2: 'x' })).toEqual({ q1: 'a', q2: 'x', q3: 'c' });
  });

  it('an empty incoming set changes nothing', () => {
    const stored = { q1: 'a', q2: 'b' };
    expect(mergeAnswers(stored, {})).toEqual(stored);
    expect(mergeAnswers(stored, null)).toEqual(stored);
    expect(mergeAnswers(stored, undefined)).toEqual(stored);
  });

  it('is idempotent, so a retried save is harmless', () => {
    const once = mergeAnswers({ q1: 'a' }, { q2: 'b' });
    expect(mergeAnswers(once, { q2: 'b' })).toEqual(once);
  });

  it('lets a later write win per question', () => {
    expect(mergeAnswers({ q1: 'a' }, { q1: 'z' })).toEqual({ q1: 'z' });
  });

  it('honours an explicit null as "user cleared this answer"', () => {
    expect(mergeAnswers({ q1: 'a', q2: 'b' }, { q1: null })).toEqual({ q1: null, q2: 'b' });
  });

  it('works from an empty stored state', () => {
    expect(mergeAnswers(null, { q1: 'a' })).toEqual({ q1: 'a' });
    expect(mergeAnswers(undefined, undefined)).toEqual({});
  });
});

describe('sanitizeAnswers', () => {
  it('drops non-string choice ids and oversized keys', () => {
    expect(sanitizeAnswers({ q1: 5, q2: {}, q3: [], q4: 'ok' })).toEqual({ q4: 'ok' });
    expect(sanitizeAnswers({ ['x'.repeat(200)]: 'a' })).toEqual({});
    expect(sanitizeAnswers({ q1: 'y'.repeat(200) })).toEqual({});
  });

  it('ignores empty keys and empty values but keeps null', () => {
    expect(sanitizeAnswers({ '': 'a', q1: '', q2: null })).toEqual({ q2: null });
  });

  it('never throws on junk input', () => {
    expect(sanitizeAnswers(null)).toEqual({});
    expect(sanitizeAnswers('nope')).toEqual({});
    expect(sanitizeAnswers(42)).toEqual({});
  });
});

describe('answeredCount', () => {
  it('counts only real selections', () => {
    expect(answeredCount({ q1: 'a', q2: null, q3: 'c' })).toBe(2);
    expect(answeredCount({})).toBe(0);
    expect(answeredCount(null)).toBe(0);
  });
});

describe('elapsedSeconds', () => {
  it('measures from the server startedAt, not a client clock', () => {
    const started = '2026-07-30T10:00:00Z';
    expect(elapsedSeconds(started, new Date('2026-07-30T12:00:00Z'))).toBe(7200);
  });

  it('reports the true span for a long-abandoned attempt', () => {
    // The old client reset startTime on resume, so a 46-day-old attempt
    // reported ~2 hours used.
    const days = elapsedSeconds('2026-06-14T05:00:00Z', new Date('2026-07-30T05:00:00Z')) / 86400;
    expect(Math.round(days)).toBe(46);
  });

  it('is 0 for missing or unparseable input, never negative', () => {
    expect(elapsedSeconds(null)).toBe(0);
    expect(elapsedSeconds('nope')).toBe(0);
    expect(elapsedSeconds('2026-07-30T12:00:00Z', new Date('2026-07-30T10:00:00Z'))).toBe(0);
  });
});

import { describe, it, expect } from 'vitest';
const {
  sanitizeAnswers, mergeAutosave, mergeSubmission, answeredCount, elapsedSeconds,
  examDeadlineMs, isPastDeadline,
} = require('./examProgress.js');

describe('mergeAutosave', () => {
  // THE critical property. A client that lost its state must not be able to
  // wipe answers the server already holds — that is the bug being fixed.
  it('never drops stored answers that the incoming set omits', () => {
    const stored = { q1: 'a', q2: 'b', q3: 'c' };
    expect(mergeAutosave(stored, { q2: 'x' })).toEqual({ q1: 'a', q2: 'x', q3: 'c' });
  });

  it('an empty incoming set changes nothing', () => {
    const stored = { q1: 'a', q2: 'b' };
    expect(mergeAutosave(stored, {})).toEqual(stored);
    expect(mergeAutosave(stored, null)).toEqual(stored);
    expect(mergeAutosave(stored, undefined)).toEqual(stored);
  });

  it('is idempotent, so a retried save is harmless', () => {
    const once = mergeAutosave({ q1: 'a' }, { q2: 'b' });
    expect(mergeAutosave(once, { q2: 'b' })).toEqual(once);
  });

  it('lets a later write win per question', () => {
    expect(mergeAutosave({ q1: 'a' }, { q1: 'z' })).toEqual({ q1: 'z' });
  });

  it('honours an explicit null as "user cleared this answer"', () => {
    // Correct for AUTOSAVE only: there the client is reporting live state.
    expect(mergeAutosave({ q1: 'a', q2: 'b' }, { q1: null })).toEqual({ q1: null, q2: 'b' });
  });

  it('works from an empty stored state', () => {
    expect(mergeAutosave(null, { q1: 'a' })).toEqual({ q1: 'a' });
    expect(mergeAutosave(undefined, undefined)).toEqual({});
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

// mergeSubmission is the fix for the critical defect the audit found: the client
// sends an explicit null for every question it does not hold, and honouring
// those at submit deleted the autosaved answers and scored the customer ~0%.
// Submit must only ever ADD.
describe('mergeSubmission', () => {
  it('CANNOT clear a stored answer with a null — the critical property', () => {
    expect(mergeSubmission({ q1: 'a', q2: 'b' }, { q1: null, q2: null }))
      .toEqual({ q1: 'a', q2: 'b' });
  });

  it('survives the exact failure: a blank auto-submit over a full autosave', () => {
    // The timed auto-submit used to fire with a stale, empty answer set. Even in
    // that worst case the customer's saved work must be scored.
    const saved = {};
    for (let i = 1; i <= 110; i += 1) saved[`q${i}`] = 'choice-a';
    const blankSubmit = {};
    for (let i = 1; i <= 110; i += 1) blankSubmit[`q${i}`] = null;
    const result = mergeSubmission(saved, blankSubmit);
    expect(Object.values(result).filter(Boolean)).toHaveLength(110);
  });

  it('adds answers the server had not seen yet', () => {
    expect(mergeSubmission({ q1: 'a' }, { q2: 'b' })).toEqual({ q1: 'a', q2: 'b' });
  });

  it('lets a real selection overwrite a different stored one', () => {
    expect(mergeSubmission({ q1: 'a' }, { q1: 'z' })).toEqual({ q1: 'z' });
  });

  it('a partial submit keeps everything it did not mention', () => {
    expect(mergeSubmission({ q1: 'a', q2: 'b', q3: 'c' }, { q2: 'x' }))
      .toEqual({ q1: 'a', q2: 'x', q3: 'c' });
  });

  it('an empty or junk submission is a no-op, never destructive', () => {
    const stored = { q1: 'a', q2: 'b' };
    expect(mergeSubmission(stored, {})).toEqual(stored);
    expect(mergeSubmission(stored, null)).toEqual(stored);
    expect(mergeSubmission(stored, 'nonsense')).toEqual(stored);
  });
});

// The clock is the product for a timed exam. The old countdown was a bare
// setInterval decrement that never re-derived from wall clock, so hiding the tab
// or sleeping the laptop stopped it and handed out unlimited extra time.
describe('examDeadlineMs', () => {
  const L = 5 * 3600 + 20 * 60; // 5h20m
  const START = '2026-07-30T10:00:00Z';
  const iso = (ms) => new Date(ms).toISOString();

  it('is startedAt plus the limit when no break was taken', () => {
    expect(iso(examDeadlineMs({ startedAt: START }, L))).toBe('2026-07-30T15:20:00.000Z');
  });

  it('extends by a completed break, because the break sits outside exam time', () => {
    const d = examDeadlineMs({
      startedAt: START,
      breakStartedAt: '2026-07-30T12:00:00Z',
      breakEndedAt: '2026-07-30T12:25:00Z',
    }, L);
    expect(iso(d)).toBe('2026-07-30T15:45:00.000Z');
  });

  it('extends as an in-progress break runs', () => {
    const d = examDeadlineMs(
      { startedAt: START, breakStartedAt: '2026-07-30T12:00:00Z' },
      L,
      new Date('2026-07-30T12:10:00Z'),
    );
    expect(iso(d)).toBe('2026-07-30T15:30:00.000Z');
  });

  it('caps the credit at one full break, so a long absence is not free time', () => {
    const d = examDeadlineMs({
      startedAt: START,
      breakStartedAt: '2026-07-30T12:00:00Z',
      breakEndedAt: '2026-08-30T12:00:00Z', // a month later
    }, L);
    expect(iso(d)).toBe('2026-07-30T15:45:00.000Z'); // +25m only
  });

  it('never credits negative time from reversed timestamps', () => {
    const d = examDeadlineMs({
      startedAt: START,
      breakStartedAt: '2026-07-30T12:25:00Z',
      breakEndedAt: '2026-07-30T12:00:00Z',
    }, L);
    expect(iso(d)).toBe('2026-07-30T15:20:00.000Z');
  });

  it('is NaN for an unparseable start, so callers can fall back', () => {
    expect(Number.isNaN(examDeadlineMs({ startedAt: 'nope' }, L))).toBe(true);
  });
});

describe('isPastDeadline', () => {
  const L = 5 * 3600 + 20 * 60;
  const START = '2026-07-30T10:00:00Z';

  it('is false inside the window and true after it', () => {
    expect(isPastDeadline({ startedAt: START }, L, new Date('2026-07-30T15:19:00Z'))).toBe(false);
    expect(isPastDeadline({ startedAt: START }, L, new Date('2026-07-30T15:21:00Z'))).toBe(true);
  });

  it('accounts for the break before declaring a submit late', () => {
    const withBreak = {
      startedAt: START,
      breakStartedAt: '2026-07-30T12:00:00Z',
      breakEndedAt: '2026-07-30T12:25:00Z',
    };
    expect(isPastDeadline(withBreak, L, new Date('2026-07-30T15:30:00Z'))).toBe(false);
  });

  it('does not flag a submit late when the start time is unusable', () => {
    expect(isPastDeadline({ startedAt: null }, L)).toBe(false);
  });
});

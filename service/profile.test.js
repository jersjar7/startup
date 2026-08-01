import { describe, it, expect } from 'vitest';
const { sanitizeName, displayName, normalizeExamDate, daysUntilExam, examTimingFromMetadata, examDateBounds } = require('./profile');

describe('sanitizeName', () => {
  it('keeps letters, spaces, hyphens, apostrophes and trims/collapses', () => {
    expect(sanitizeName("  María   José  ")).toBe('María José');
    expect(sanitizeName("O'Brien-Smith")).toBe("O'Brien-Smith");
  });
  it('strips digits, symbols, and angle brackets (XSS safety)', () => {
    expect(sanitizeName('Bob123 <script>')).toBe('Bob script');
    expect(sanitizeName('a@b.com')).toBe('abcom');
  });
  it('caps length and handles non-strings', () => {
    expect(sanitizeName('a'.repeat(80)).length).toBe(40);
    expect(sanitizeName(null)).toBe('');
  });
});

describe('displayName (never leaks the full email)', () => {
  it('first + last initial', () => {
    expect(displayName({ firstName: 'Maria', lastName: 'Gomez' })).toBe('Maria G.');
  });
  it('first name only when no last name', () => {
    expect(displayName({ firstName: 'Maria' })).toBe('Maria');
  });
  it('falls back to the email local part, not the full email', () => {
    expect(displayName({ email: 'maria@university.edu' })).toBe('maria');
    expect(displayName({ email: 'maria@university.edu' })).not.toContain('@');
  });
  it('handles missing everything', () => {
    expect(displayName({})).toBe('A student');
  });
});

describe('normalizeExamDate', () => {
  it('accepts a valid YYYY-MM-DD', () => {
    expect(normalizeExamDate('2026-10-15')).toBe('2026-10-15');
  });
  it('treats null/empty as a clear', () => {
    expect(normalizeExamDate(null)).toBeNull();
    expect(normalizeExamDate('')).toBeNull();
  });
  it('rejects bad formats and impossible dates', () => {
    expect(normalizeExamDate('10/15/2026')).toBeUndefined();
    expect(normalizeExamDate('2026-02-31')).toBeUndefined();
    expect(normalizeExamDate('1999-01-01')).toBeUndefined();
    expect(normalizeExamDate(12345)).toBeUndefined();
  });
});

describe('daysUntilExam', () => {
  it('counts whole days ahead', () => {
    const now = new Date('2026-06-01T12:00:00Z');
    expect(daysUntilExam('2026-06-24', now)).toBe(23);
  });
  it('is null with no date', () => {
    expect(daysUntilExam(null)).toBeNull();
  });
});

// Stripe stores metadata as STRINGS only, so the round-trip through
// checkout -> metadata -> purchase record is where this silently breaks.
describe('examTimingFromMetadata', () => {
  it('parses the string Stripe hands back into a number', () => {
    expect(examTimingFromMetadata({ daysUntilExam: '23', examDateAtPurchase: '2026-06-24' }))
      .toEqual({ daysUntilExam: 23, examDateAtPurchase: '2026-06-24' });
  });

  it('keeps 0 distinct from "no date on file" (exam day itself)', () => {
    expect(examTimingFromMetadata({ daysUntilExam: '0' }).daysUntilExam).toBe(0);
  });

  it('keeps negative days — a retaker with a stale past date is real signal', () => {
    expect(examTimingFromMetadata({ daysUntilExam: '-12' }).daysUntilExam).toBe(-12);
  });

  it('returns nulls when the keys were never set', () => {
    expect(examTimingFromMetadata({ tier: 'student' }))
      .toEqual({ daysUntilExam: null, examDateAtPurchase: null });
    expect(examTimingFromMetadata({})).toEqual({ daysUntilExam: null, examDateAtPurchase: null });
    expect(examTimingFromMetadata()).toEqual({ daysUntilExam: null, examDateAtPurchase: null });
  });

  it('does not turn an empty string into 0', () => {
    // Number('') is 0, which would fabricate "bought on exam day".
    expect(examTimingFromMetadata({ daysUntilExam: '' }).daysUntilExam).toBeNull();
  });

  it('returns null rather than NaN for garbage', () => {
    expect(examTimingFromMetadata({ daysUntilExam: 'soon' }).daysUntilExam).toBeNull();
  });
});

// Exam-date bounds. Two users had entered 2028 dates, which produced a 739-day
// outlier and made purchase-timing data unusable. The window is relative to now
// so it keeps working without anyone bumping a constant.
describe('normalizeExamDate bounds', () => {
  const shift = (years, days = 0) => {
    const d = new Date();
    d.setUTCFullYear(d.getUTCFullYear() + years);
    d.setUTCDate(d.getUTCDate() + days);
    return d.toISOString().slice(0, 10);
  };

  it('rejects the 2028-style typo that poisoned the data', () => {
    expect(normalizeExamDate('2028-06-15')).toBeUndefined();
  });

  it('accepts a date inside the next twelve months', () => {
    expect(normalizeExamDate(shift(0, 30))).toBe(shift(0, 30));
    expect(normalizeExamDate(shift(0, 300))).toBe(shift(0, 300));
  });

  it('rejects beyond twelve months out', () => {
    expect(normalizeExamDate(shift(1, 5))).toBeUndefined();
    expect(normalizeExamDate(shift(3))).toBeUndefined();
  });

  it('still accepts a recently sat exam, so real input is not discarded', () => {
    expect(normalizeExamDate(shift(0, -30))).toBe(shift(0, -30));
  });

  it('rejects an implausibly old date', () => {
    expect(normalizeExamDate(shift(-3))).toBeUndefined();
  });

  it('keeps clearing the date working', () => {
    expect(normalizeExamDate(null)).toBeNull();
    expect(normalizeExamDate('')).toBeNull();
  });

  it('still rejects bad formats and rolled-over dates', () => {
    expect(normalizeExamDate('06/15/2026')).toBeUndefined();
    expect(normalizeExamDate('not-a-date')).toBeUndefined();
    expect(normalizeExamDate(12345)).toBeUndefined();
  });
});

describe('examDateBounds', () => {
  it('returns a one-year window either side, for the date input min/max', () => {
    const b = examDateBounds(new Date('2026-07-31T00:00:00Z'));
    expect(b).toEqual({ min: '2025-07-31', max: '2027-07-31' });
  });

  it('agrees with what normalizeExamDate accepts', () => {
    // If these drift, the UI silently offers dates the server rejects.
    const b = examDateBounds();
    expect(normalizeExamDate(b.max)).toBe(b.max);
    expect(normalizeExamDate(b.min)).toBe(b.min);
  });
});

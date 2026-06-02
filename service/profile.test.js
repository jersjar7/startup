import { describe, it, expect } from 'vitest';
const { sanitizeName, displayName, normalizeExamDate, daysUntilExam } = require('./profile');

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

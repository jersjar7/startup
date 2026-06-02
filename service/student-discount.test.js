import { describe, it, expect } from 'vitest';
const { qualifiesForStudent, priceCentsForUser, STUDENT_CENTS, STANDARD_CENTS } = require('./pricing');
const { generateNumericCode } = require('./crypto');

describe('qualifiesForStudent (anti-fraud gate)', () => {
  it('rejects a user who merely has a .edu account email that is NOT verified', () => {
    expect(qualifiesForStudent({ email: 'fake@university.edu', emailVerified: false })).toBe(false);
  });

  it('rejects a standard email even if verified', () => {
    expect(qualifiesForStudent({ email: 'me@gmail.com', emailVerified: true })).toBe(false);
  });

  it('accepts a verified academic ACCOUNT email', () => {
    expect(qualifiesForStudent({ email: 'me@university.edu', emailVerified: true })).toBe(true);
  });

  it('accepts a user who verified a separate .edu via emailed code', () => {
    expect(qualifiesForStudent({ email: 'me@gmail.com', studentVerified: true })).toBe(true);
  });

  it('does NOT accept an unverified studentVerified-falsey user', () => {
    expect(qualifiesForStudent({ email: 'me@gmail.com', studentVerified: false })).toBe(false);
  });

  it('handles null/undefined safely', () => {
    expect(qualifiesForStudent(null)).toBe(false);
    expect(qualifiesForStudent(undefined)).toBe(false);
  });

  it('prices: verified student pays student cents, everyone else standard', () => {
    expect(priceCentsForUser({ email: 'me@gmail.com', studentVerified: true })).toBe(STUDENT_CENTS);
    expect(priceCentsForUser({ email: 'me@gmail.com' })).toBe(STANDARD_CENTS);
  });
});

describe('generateNumericCode', () => {
  it('produces a 6-digit numeric string by default', () => {
    for (let i = 0; i < 200; i++) {
      const c = generateNumericCode();
      expect(c).toMatch(/^\d{6}$/);
    }
  });

  it('respects a custom length', () => {
    expect(generateNumericCode(4)).toMatch(/^\d{4}$/);
    expect(generateNumericCode(8)).toMatch(/^\d{8}$/);
  });

  it('is not constant across calls', () => {
    const set = new Set(Array.from({ length: 50 }, () => generateNumericCode()));
    expect(set.size).toBeGreaterThan(1);
  });
});

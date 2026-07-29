import { describe, it, expect } from 'vitest';
const { isAcquisitionResolved } = require('./acquisition.js');

// This function is the server-side guard against asking the same person "how
// did you find us?" twice. Every branch matters.
describe('isAcquisitionResolved', () => {
  it('is false for a user with no acquisition object at all', () => {
    expect(isAcquisitionResolved({ email: 'a@b.com' })).toBe(false);
  });

  it('is false when acquisition holds only passive utm/referrer capture', () => {
    // The common case: they arrived on a tagged link but never answered the
    // survey. Passive capture must NOT suppress the question.
    expect(isAcquisitionResolved({
      acquisition: { utmSource: 'tiktok', utmMedium: 'social', referrer: 'https://google.com/' },
    })).toBe(false);
  });

  it('is true once they answered', () => {
    expect(isAcquisitionResolved({ acquisition: { source: 'tiktok' } })).toBe(true);
  });

  it('is true once they dismissed, even with no source', () => {
    expect(isAcquisitionResolved({ acquisition: { dismissedAt: new Date() } })).toBe(true);
  });

  it('is true when they answered AND dismissed', () => {
    expect(isAcquisitionResolved({ acquisition: { source: 'reddit', dismissedAt: new Date() } })).toBe(true);
  });

  it('is false for an empty string source (never counts as answered)', () => {
    expect(isAcquisitionResolved({ acquisition: { source: '' } })).toBe(false);
  });

  it('does not throw on null/undefined users', () => {
    expect(isAcquisitionResolved(null)).toBe(false);
    expect(isAcquisitionResolved(undefined)).toBe(false);
    expect(isAcquisitionResolved({ acquisition: null })).toBe(false);
  });
});

import { describe, it, expect } from 'vitest';
import { shouldPitchSimInDigest } from './digestPitch.js';

describe('shouldPitchSimInDigest', () => {
  it('pitches to an active non-buyer', () => {
    expect(shouldPitchSimInDigest({ active: true, hasPurchased: false })).toBe(true);
  });

  // The expensive mistake: selling a customer the thing they already own.
  it('never pitches to somebody who already bought it', () => {
    expect(shouldPitchSimInDigest({ active: true, hasPurchased: true })).toBe(false);
  });

  // The inactive digest exists to restart a lapsed user with five minutes of
  // study. Appending a $49 offer to "you logged nothing this week" works
  // against that.
  it('stays out of the inactive digest', () => {
    expect(shouldPitchSimInDigest({ active: false, hasPurchased: false })).toBe(false);
    expect(shouldPitchSimInDigest({ active: false, hasPurchased: true })).toBe(false);
  });

  // The caller sets hasPurchased to true when the lookup throws, so a database
  // hiccup silently drops the footer rather than pitching to a customer.
  it('defaults to not pitching when told nothing', () => {
    expect(shouldPitchSimInDigest()).toBe(false);
    expect(shouldPitchSimInDigest({})).toBe(false);
  });

  it('treats a missing active flag as inactive rather than truthy', () => {
    expect(shouldPitchSimInDigest({ hasPurchased: false })).toBe(false);
    expect(shouldPitchSimInDigest({ active: undefined, hasPurchased: false })).toBe(false);
  });
});

import { describe, it, expect } from 'vitest';
import { shouldAskSource, ACQ_BACKFILL_CUTOFF } from './acquisitionGate';

const BEFORE = '2026-07-15T10:00:00Z'; // legacy account
const AFTER = '2026-08-01T10:00:00Z'; // asked at registration

// The dashboard ask is a ONE-TIME backfill. These tests exist because the
// failure mode (asking somebody the same question twice) is invisible in code
// review but obvious and annoying to a user.
describe('shouldAskSource', () => {
  it('asks a legacy account that has not resolved', () => {
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: BEFORE })).toBe(true);
  });

  it('never asks an account created after the cutoff — it was asked at signup', () => {
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: AFTER })).toBe(false);
  });

  it('never asks once resolved, legacy or not', () => {
    expect(shouldAskSource({ acquisitionResolved: true, createdAt: BEFORE })).toBe(false);
    expect(shouldAskSource({ acquisitionResolved: true, createdAt: AFTER })).toBe(false);
  });

  it('does not ask while /me is still loading or failed', () => {
    // acquisitionResolved defaults to `true` in the component and is only ever
    // set to false by a successful /me. Anything that is not an explicit false
    // must stay silent rather than risk a duplicate ask.
    expect(shouldAskSource({ acquisitionResolved: undefined, createdAt: BEFORE })).toBe(false);
    expect(shouldAskSource({ acquisitionResolved: null, createdAt: BEFORE })).toBe(false);
    expect(shouldAskSource({})).toBe(false);
    expect(shouldAskSource()).toBe(false);
  });

  it('does not ask when createdAt is missing or unparseable', () => {
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: null })).toBe(false);
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: '' })).toBe(false);
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: 'not-a-date' })).toBe(false);
  });

  it('treats the cutoff instant itself as post-cutoff (exclusive)', () => {
    const at = new Date(ACQ_BACKFILL_CUTOFF).toISOString();
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: at })).toBe(false);
    const justBefore = new Date(ACQ_BACKFILL_CUTOFF - 1).toISOString();
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: justBefore })).toBe(true);
  });

  it('accepts a Date object for createdAt, not just a string', () => {
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: new Date(BEFORE).toISOString() })).toBe(true);
  });
});

import { describe, it, expect } from 'vitest';
import { shouldAskSource } from './acquisitionGate';

// The rule: ask until resolved, never after. These tests exist because the
// failure mode (asking somebody the same question twice) is invisible in code
// review but obvious and annoying to a user.
describe('shouldAskSource', () => {
  it('asks a user who has not answered or dismissed', () => {
    expect(shouldAskSource({ acquisitionResolved: false })).toBe(true);
  });

  it('never asks once resolved', () => {
    expect(shouldAskSource({ acquisitionResolved: true })).toBe(false);
  });

  it('stays silent while /me is loading, missing, or failed', () => {
    // The component seeds this as `true` and only a successful /me can set it
    // to false, so anything that is not an explicit false must not ask.
    expect(shouldAskSource({ acquisitionResolved: undefined })).toBe(false);
    expect(shouldAskSource({ acquisitionResolved: null })).toBe(false);
    expect(shouldAskSource({})).toBe(false);
    expect(shouldAskSource()).toBe(false);
  });

  it('does not treat falsy-but-not-false values as unresolved', () => {
    // Guards against a truthiness refactor reintroducing duplicate asks.
    expect(shouldAskSource({ acquisitionResolved: 0 })).toBe(false);
    expect(shouldAskSource({ acquisitionResolved: '' })).toBe(false);
    expect(shouldAskSource({ acquisitionResolved: NaN })).toBe(false);
  });

  it('ignores createdAt entirely — there is no date cutoff any more', () => {
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: '2020-01-01T00:00:00Z' })).toBe(true);
    expect(shouldAskSource({ acquisitionResolved: false, createdAt: '2099-01-01T00:00:00Z' })).toBe(true);
  });
});

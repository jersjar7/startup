import { describe, it, expect } from 'vitest';
import { shouldAskSchool } from './schoolGate';
import { shouldAskSource } from './acquisitionGate';

// The rule: ask until resolved, never after, and never at the same time as the
// attribution question. Both failure modes (asking twice, or stacking two
// modals on a brand new account) are invisible in code review and immediately
// obvious to a user.
describe('shouldAskSchool', () => {
  it('asks a user who has not answered or skipped, once attribution is settled', () => {
    expect(shouldAskSchool({ acquisitionResolved: true, schoolResolved: false })).toBe(true);
  });

  it('never asks once resolved', () => {
    expect(shouldAskSchool({ acquisitionResolved: true, schoolResolved: true })).toBe(false);
  });

  it('stays silent while /me is loading, missing, or failed', () => {
    // The callers seed this as `true` and only a successful /me can set it to
    // false, so anything that is not an explicit false must not ask.
    expect(shouldAskSchool({ acquisitionResolved: true, schoolResolved: undefined })).toBe(false);
    expect(shouldAskSchool({ acquisitionResolved: true, schoolResolved: null })).toBe(false);
    expect(shouldAskSchool({ acquisitionResolved: true })).toBe(false);
    expect(shouldAskSchool({})).toBe(false);
    expect(shouldAskSchool()).toBe(false);
  });

  it('does not treat falsy-but-not-false values as unresolved', () => {
    // Guards against a truthiness refactor reintroducing duplicate asks.
    expect(shouldAskSchool({ acquisitionResolved: true, schoolResolved: 0 })).toBe(false);
    expect(shouldAskSchool({ acquisitionResolved: true, schoolResolved: '' })).toBe(false);
    expect(shouldAskSchool({ acquisitionResolved: true, schoolResolved: NaN })).toBe(false);
  });

  it('stands down while the attribution question is still outstanding', () => {
    expect(shouldAskSchool({ acquisitionResolved: false, schoolResolved: false })).toBe(false);
    expect(shouldAskSchool({ acquisitionResolved: false, schoolResolved: true })).toBe(false);
  });

  it('never lets both prompts show at once, for any combination of flags', () => {
    // The invariant stated as the invariant, rather than as two example cases.
    const values = [true, false, undefined, null, 0, ''];
    for (const acquisitionResolved of values) {
      for (const schoolResolved of values) {
        const both = shouldAskSource({ acquisitionResolved })
          && shouldAskSchool({ acquisitionResolved, schoolResolved });
        expect(both).toBe(false);
      }
    }
  });

  it('asks the school question on the render after attribution resolves', () => {
    // What the dashboard actually does: one flag flips, the other does not.
    const unresolved = { acquisitionResolved: false, schoolResolved: false };
    expect(shouldAskSource(unresolved)).toBe(true);
    expect(shouldAskSchool(unresolved)).toBe(false);

    const answered = { ...unresolved, acquisitionResolved: true };
    expect(shouldAskSource(answered)).toBe(false);
    expect(shouldAskSchool(answered)).toBe(true);
  });
});

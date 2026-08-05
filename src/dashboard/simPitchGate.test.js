import { describe, it, expect } from 'vitest';
import {
  shouldShowSimPitch, usesCountdownCopy, daysUntil, MIN_DAYS, PROBLEMS_THRESHOLD,
} from './simPitchGate';

// This predicate decides the reach of the only paid product. The old gate saw
// 15 of 270 users while converting 60% of them, so both directions are costly:
// too tight and the offer is invisible, too loose and it is pitched to people
// nowhere near ready for a 5h20m exam.
describe('shouldShowSimPitch', () => {
  it('shows to someone with an exam date comfortably ahead', () => {
    expect(shouldShowSimPitch({ daysLeft: 20, problemsAnswered: 0 })).toBe(true);
  });

  it('NO LONGER excludes someone planning far ahead', () => {
    // The old 30-day ceiling dropped 35 users purely for booking early.
    expect(shouldShowSimPitch({ daysLeft: 45, problemsAnswered: 0 })).toBe(true);
    expect(shouldShowSimPitch({ daysLeft: 200, problemsAnswered: 0 })).toBe(true);
  });

  it('does not pitch a five-hour exam to someone sitting it tomorrow', () => {
    expect(shouldShowSimPitch({ daysLeft: 1, problemsAnswered: 0 })).toBe(false);
    expect(shouldShowSimPitch({ daysLeft: 0, problemsAnswered: 0 })).toBe(false);
    expect(shouldShowSimPitch({ daysLeft: -5, problemsAnswered: 0 })).toBe(false);
  });

  it('reaches an engaged studier with no exam date at all', () => {
    // The whole point of widening: these users were previously invisible.
    expect(shouldShowSimPitch({ daysLeft: null, problemsAnswered: 25 })).toBe(true);
    expect(shouldShowSimPitch({ daysLeft: null, problemsAnswered: 300 })).toBe(true);
  });

  it('stays quiet for a newcomer who has barely started', () => {
    expect(shouldShowSimPitch({ daysLeft: null, problemsAnswered: 0 })).toBe(false);
    expect(shouldShowSimPitch({ daysLeft: null, problemsAnswered: 24 })).toBe(false);
  });

  it('rescues a user whose exam date has gone stale but who is still working', () => {
    // Date in the past, so no countdown — but 60 problems is real effort.
    expect(shouldShowSimPitch({ daysLeft: -30, problemsAnswered: 60 })).toBe(true);
  });

  it('is safe with missing or junk input', () => {
    expect(shouldShowSimPitch()).toBe(false);
    expect(shouldShowSimPitch({})).toBe(false);
    expect(shouldShowSimPitch({ daysLeft: undefined, problemsAnswered: undefined })).toBe(false);
  });

  it('pins the threshold constants the analysis was based on', () => {
    expect(MIN_DAYS).toBe(2);
    expect(PROBLEMS_THRESHOLD).toBe(25);
  });
});

describe('usesCountdownCopy', () => {
  it('is true only when a real countdown exists', () => {
    expect(usesCountdownCopy(20)).toBe(true);
    expect(usesCountdownCopy(2)).toBe(true);
  });

  it('is FALSE without a date — otherwise the banner renders "Just null days to go."', () => {
    expect(usesCountdownCopy(null)).toBe(false);
    expect(usesCountdownCopy(undefined)).toBe(false);
  });

  it('is false for a past or imminent date, so stale dates get readiness copy', () => {
    expect(usesCountdownCopy(1)).toBe(false);
    expect(usesCountdownCopy(-40)).toBe(false);
  });
});

describe('daysUntil', () => {
  const now = new Date('2026-08-04T12:00:00Z').getTime();

  it('counts whole days ahead', () => {
    expect(daysUntil('2026-08-24', now)).toBe(20);
  });

  it('is null for missing or unparseable dates', () => {
    expect(daysUntil(null, now)).toBeNull();
    expect(daysUntil('', now)).toBeNull();
    expect(daysUntil('not-a-date', now)).toBeNull();
  });

  it('goes negative for a past date rather than clamping', () => {
    expect(daysUntil('2026-07-04', now)).toBeLessThan(0);
  });
});

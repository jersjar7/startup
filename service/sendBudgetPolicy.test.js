import { describe, it, expect } from 'vitest';
const {
  lifecycleAllowed, blockReason,
  DAILY_CAP, DAILY_RESERVE, DAILY_LIFECYCLE_MAX, MONTHLY_SOFT,
} = require('./sendBudgetPolicy');

// The rule this file protects: lifecycle email must never eat the daily
// headroom that verification and password-reset email depend on. Those go out
// through sendEmail with NO budget check, because they must never be blocked.
// So the only thing standing between a new signup and a rejected verification
// email is lifecycle stopping early enough.
describe('send budget policy', () => {
  it('reserves daily headroom for transactional email', () => {
    expect(DAILY_LIFECYCLE_MAX).toBe(DAILY_CAP - DAILY_RESERVE);
    expect(DAILY_RESERVE).toBeGreaterThan(0);
  });

  // 2026-09-09: 23 signups plus resets and resends needed 25 transactional
  // sends AFTER the morning batch had already run, against a reserve of 15.
  // The day closed at 103 sends against a 100/day plan cap. The reserve has to
  // cover a day like that, or the mail that fails is what a new user is waiting
  // on. Lower this only with newer numbers showing the tail actually shrank.
  it('reserves enough for the worst day actually observed', () => {
    const WORST_OBSERVED_TRANSACTIONAL_TAIL = 25;
    expect(DAILY_RESERVE).toBeGreaterThanOrEqual(WORST_OBSERVED_TRANSACTIONAL_TAIL);
  });

  it('allows a lifecycle send while under the daily line', () => {
    expect(lifecycleAllowed(DAILY_LIFECYCLE_MAX - 1, 0)).toBe(true);
  });

  it('stops lifecycle at the daily line, leaving the full reserve unspent', () => {
    expect(lifecycleAllowed(DAILY_LIFECYCLE_MAX, 0)).toBe(false);
    expect(DAILY_CAP - DAILY_LIFECYCLE_MAX).toBe(DAILY_RESERVE);
  });

  it('stops lifecycle at the monthly soft cap even with daily room to spare', () => {
    expect(lifecycleAllowed(0, MONTHLY_SOFT)).toBe(false);
  });

  it('names the daily limit as the reason when that is what bit', () => {
    expect(blockReason(DAILY_LIFECYCLE_MAX, 0)).toMatch(/daily lifecycle limit/);
    expect(blockReason(0, MONTHLY_SOFT)).toMatch(/monthly soft cap/);
    expect(blockReason(0, 0)).toBeNull();
  });
});

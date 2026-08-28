import { describe, it, expect } from 'vitest';
const fs = require('fs');
const path = require('path');
const { COLLECTED_SALE, isCollectedSale } = require('./collectedSales');

// The rule this file protects: `status: 'completed'` means we granted the
// product; it does not mean we were paid. The 2026-07 test-key incident put a
// real, unpaid $29 purchase in the collection, and it was counted as income
// until this filter existed.
describe('collected sales', () => {
  it('matches completed purchases that are neither uncollected nor comped', () => {
    expect(COLLECTED_SALE).toEqual({
      status: 'completed',
      uncollected: { $ne: true },
      comp: { $ne: true },
    });
  });

  it('counts a normal completed purchase', () => {
    expect(isCollectedSale({ status: 'completed', amount: 4900 })).toBe(true);
  });

  it('counts a completed purchase that explicitly says uncollected: false', () => {
    expect(isCollectedSale({ status: 'completed', uncollected: false })).toBe(true);
  });

  it('does NOT count a purchase we were never paid for', () => {
    expect(isCollectedSale({ status: 'completed', amount: 2900, uncollected: true })).toBe(false);
  });

  it('does NOT count a complimentary grant', () => {
    expect(isCollectedSale({ status: 'completed', amount: 0, tier: 'comp', comp: true })).toBe(false);
  });

  // A comp is not a mistake, so it is not marked `uncollected`. Both flags have
  // to be checked independently or one of the two leaks back into the count.
  it('keeps the two reasons separate', () => {
    const comp = { status: 'completed', comp: true };
    const unpaid = { status: 'completed', uncollected: true };
    expect(comp.uncollected).toBeUndefined();
    expect(unpaid.comp).toBeUndefined();
    expect(isCollectedSale(comp)).toBe(false);
    expect(isCollectedSale(unpaid)).toBe(false);
  });

  it('does not count a purchase that never completed', () => {
    expect(isCollectedSale({ status: 'pending' })).toBe(false);
  });

  it('handles missing rows', () => {
    expect(isCollectedSale(null)).toBe(false);
    expect(isCollectedSale(undefined)).toBe(false);
  });

  // $ne: true is deliberate, rather than `uncollected: false`. Every purchase
  // written before the flag existed has no `uncollected` field at all, and those
  // must keep counting as revenue.
  it('still counts legacy rows that predate the flags', () => {
    const legacy = { status: 'completed', amount: 4900 };
    expect('uncollected' in legacy).toBe(false);
    expect('comp' in legacy).toBe(false);
    expect(isCollectedSale(legacy)).toBe(true);
  });

  // The invariant that must never break: flagging a purchase as uncollected
  // takes money out of the reports, never the product out of a customer's
  // hands. Entitlement matches on status alone, on purpose.
  it('entitlement does not use the collected-sale filter', () => {
    const src = fs.readFileSync(path.join(__dirname, 'db', 'purchases.js'), 'utf8');
    const hasPurchased = src.slice(src.indexOf('async function hasPurchased'));
    expect(hasPurchased).toContain("status: 'completed'");
    expect(hasPurchased).not.toContain('uncollected');
    expect(hasPurchased).not.toContain('COLLECTED_SALE');
  });
});

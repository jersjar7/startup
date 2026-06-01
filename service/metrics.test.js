import { describe, it, expect } from 'vitest';
const { computeFunnelMetrics, pct } = require('./metrics');

describe('pct', () => {
  it('returns 0 when the denominator is 0', () => expect(pct(5, 0)).toBe(0));
  it('rounds to one decimal place', () => expect(pct(1, 3)).toBe(33.3));
  it('is 100 when equal', () => expect(pct(7, 7)).toBe(100));
});

describe('computeFunnelMetrics', () => {
  it('computes the funnel counts, revenue (dollars), and conversion rates', () => {
    const m = computeFunnelMetrics({
      signups: 100, diagnosticUsers: 60, checkoutStarts: 20, purchases: 8, revenueCents: 8 * 1499,
    });
    expect(m.signups).toBe(100);
    expect(m.revenue).toBe(119.92);
    expect(m.conversion.signupToDiagnostic).toBe(60);
    expect(m.conversion.signupToCheckout).toBe(20);
    expect(m.conversion.checkoutToPurchase).toBe(40);
    expect(m.conversion.signupToPurchase).toBe(8);
  });

  it('handles empty input without dividing by zero', () => {
    const m = computeFunnelMetrics();
    expect(m.signups).toBe(0);
    expect(m.revenue).toBe(0);
    expect(m.conversion.checkoutToPurchase).toBe(0);
  });
});

// Pure funnel-metric computation. Kept separate from the DB layer so the
// conversion math is testable on its own.

// Percentage of n out of d, rounded to one decimal (0 when d is 0).
function pct(n, d) {
  return d > 0 ? Math.round((n / d) * 1000) / 10 : 0;
}

function computeFunnelMetrics({
  signups = 0,
  diagnosticUsers = 0,
  checkoutStarts = 0,
  purchases = 0,
  revenueCents = 0,
} = {}) {
  return {
    signups,
    diagnosticUsers,
    checkoutStarts,
    purchases,
    revenue: Math.round(revenueCents) / 100,
    conversion: {
      signupToDiagnostic: pct(diagnosticUsers, signups),
      signupToCheckout: pct(checkoutStarts, signups),
      checkoutToPurchase: pct(purchases, checkoutStarts),
      signupToPurchase: pct(purchases, signups),
    },
  };
}

module.exports = { computeFunnelMetrics, pct };

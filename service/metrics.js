// Pure funnel-metric computation. Kept separate from the DB layer so the
// conversion math is testable on its own.

// Percentage of n out of d, rounded to one decimal (0 when d is 0).
function pct(n, d) {
  return d > 0 ? Math.round((n / d) * 1000) / 10 : 0;
}

function computeFunnelMetrics({
  signups = 0,
  diagnosticUsers = 0,
  quickstartActivated = 0,
  quickstartCompleted = 0,
  checkoutStarts = 0,
  purchases = 0,
  revenueCents = 0,
} = {}) {
  return {
    signups,
    diagnosticUsers,
    quickstartActivated,
    quickstartCompleted,
    checkoutStarts,
    purchases,
    revenue: Math.round(revenueCents) / 100,
    conversion: {
      // Onboarding: how many new users actually start (finish ≥1 quick-start
      // segment) and how many map all 15 chapters.
      signupToActivation: pct(quickstartActivated, signups),
      activationToCompletion: pct(quickstartCompleted, quickstartActivated),
      signupToDiagnostic: pct(diagnosticUsers, signups),
      signupToCheckout: pct(checkoutStarts, signups),
      checkoutToPurchase: pct(purchases, checkoutStarts),
      signupToPurchase: pct(purchases, signups),
    },
  };
}

module.exports = { computeFunnelMetrics, pct };

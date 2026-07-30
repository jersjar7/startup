// Guard against granting paid access for a payment made in the wrong Stripe mode.
//
// This exists because of a real incident: production silently reverted to a
// TEST secret key for ~12 days. Checkout still worked, Stripe still reported
// `payment_status: 'paid'`, both grant paths still granted lifetime access, and
// the owner still got a "you made a sale" email — for $0. A real student
// received the full paid Exam Simulation for free and it was counted as revenue.
//
// Nothing in the codebase inspected `livemode`, so nothing could tell the
// difference. This closes that.
//
// The rule is a MATCH, not "must be live": local development legitimately runs
// on sk_test and must keep working. What must never happen is a test-mode
// payment being honoured by a server holding live keys (or vice versa).

// True when this process is configured with a live secret key.
function serverIsLiveMode(key = process.env.STRIPE_SECRET_KEY) {
  return String(key || '').startsWith('sk_live_');
}

// Stripe puts `livemode` on both events and sessions. Treat a MISSING value as
// matching: older records and hand-built test fixtures have no such field, and
// this guard must never block a legitimate purchase because of a schema gap.
// The point is to catch a definite mismatch, not to be maximally suspicious.
function isModeMismatch(stripeObject, key = process.env.STRIPE_SECRET_KEY) {
  if (!stripeObject || typeof stripeObject.livemode !== 'boolean') return false;
  return stripeObject.livemode !== serverIsLiveMode(key);
}

// Human-readable for logs and admin surfaces.
function describeMode(key = process.env.STRIPE_SECRET_KEY) {
  if (!key) return 'unset';
  return serverIsLiveMode(key) ? 'live' : 'test';
}

module.exports = { serverIsLiveMode, isModeMismatch, describeMode };

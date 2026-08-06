// Report an exam-sim pitch impression or click.
//
// Three surfaces now lead to the paid product: the conditional banner, the
// permanent dashboard card, and the nav link. Until 2026-08-06 only the banner
// was instrumented, so the always-visible paths were invisible: we could see
// that 60% of banner viewers clicked, and nothing at all about whether the card
// anyone can see does any work.
//
// `via` must be one of the values allowlisted in service/routes/checkout.js, or
// the server records it as 'dashboard' and the surfaces blur together.
//
// Fire-and-forget by design: analytics must never delay a navigation or surface
// an error to somebody trying to reach the product.
export function trackPitch(action, via) {
  try {
    fetch(`/api/checkout/sim-banner/${action}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ via }),
    }).catch(() => {});
  } catch { /* never let tracking break a click */ }
}

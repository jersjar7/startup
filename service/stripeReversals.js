// Money that comes back out of a sale: refunds and card disputes.
//
// A purchase is stored by its Checkout session, but Stripe reports a refund or
// a dispute against the charge's payment intent. The webhook looks the session
// up from the payment intent and hands the result here. This file decides what
// that event means for the purchase, and applies it.
//
// The rules (owner, 2026-10-30; docs/adr/0036-refunds-and-disputes-from-stripe.md):
//   - A FULL refund revokes the product (status 'refunded', as ADR 0011).
//   - A PARTIAL refund changes nothing: it is a goodwill discount, not a return.
//   - A dispute opening revokes the product (status 'disputed').
//   - A dispute closing in our favour restores it; one we lose stays revoked.
//
// Every rule is guarded on the purchase's current status, so Stripe's retries
// and out-of-order deliveries cannot invent a state that never happened.

// Which purchase the event is about, and what it says. Pure: no lookups.
function readReversal(event) {
  const obj = event && event.data && event.data.object;
  if (!obj) return null;

  if (event.type === 'charge.refunded') {
    // `refunded` is true only once the whole charge has been returned.
    const full = obj.refunded === true;
    return { paymentIntent: obj.payment_intent || null, kind: full ? 'refund' : 'partial-refund' };
  }
  if (event.type === 'charge.dispute.created') {
    return { paymentIntent: obj.payment_intent || null, kind: 'dispute', disputeReason: obj.reason || null };
  }
  if (event.type === 'charge.dispute.closed') {
    // 'warning_closed' is an early inquiry that never became a chargeback.
    const ours = obj.status === 'won' || obj.status === 'warning_closed';
    return { paymentIntent: obj.payment_intent || null, kind: ours ? 'dispute-won' : 'dispute-lost' };
  }
  return null;
}

// The writes for one reversal against one purchase row, or null for none.
function planReversal(reversal, purchase, now = new Date()) {
  if (!reversal || !purchase) return null;
  const { kind } = reversal;

  if (kind === 'refund' && (purchase.status === 'completed' || purchase.status === 'disputed')) {
    return {
      purchase: { $set: { status: 'refunded', refundedAt: now, refundReason: 'Refunded in Stripe' } },
      user: { $set: { examSimAccess: false }, $unset: { examSimPurchaseDate: '' } },
    };
  }
  if (kind === 'dispute' && purchase.status === 'completed') {
    return {
      purchase: { $set: { status: 'disputed', disputedAt: now, disputeReason: reversal.disputeReason } },
      user: { $set: { examSimAccess: false } },
    };
  }
  if (kind === 'dispute-won' && purchase.status === 'disputed') {
    return {
      purchase: { $set: { status: 'completed', disputeOutcome: 'won' }, $unset: { disputedAt: '' } },
      user: { $set: { examSimAccess: true } },
    };
  }
  if (kind === 'dispute-lost' && purchase.status === 'disputed') {
    return { purchase: { $set: { disputeOutcome: 'lost' } }, user: null };
  }
  return null;
}

module.exports = { readReversal, planReversal };

# 0036. Stripe tells us about refunds and disputes, and access follows

- **Status:** Accepted
- **Date:** 2026-10-30
- **Extends:** [ADR 0011](0011-a-refund-revokes-the-product.md), which named this as the end state and left it unbuilt
- **Affects:** `service/stripeReversals.js`, `service/routes/webhook.js`, `service/routes/checkout.js` (`/status`), `service/db/purchases.js` (`applyPurchaseReversal`)

## Context

ADR 0011 made a refund revoke the Exam Simulation through `status: 'refunded'`,
but only when someone ran `service/scripts/refundPurchase.js` by hand. A
refund given in the Stripe dashboard alone left the buyer with the product and
the money in the revenue totals. Disputes (chargebacks) had no path at all.

Building the automatic path turned up a second hole. `GET /api/checkout/status`
records a purchase from the Checkout session when the webhook has not arrived
yet. A Checkout session still reports `payment_status: 'paid'` after its charge
is refunded, so a refunded buyer who reopened their old return link was
recorded as a buyer again and got the product back. That was true of manual
refunds under ADR 0011 too.

## Decision

The live webhook endpoint also listens to `charge.refunded`,
`charge.dispute.created` and `charge.dispute.closed`. The owner chose the rules
on 2026-10-30:

| Stripe says | Purchase becomes | Simulation |
| --- | --- | --- |
| Charge fully refunded | `refunded` (as ADR 0011) | Taken away |
| Charge partly refunded | unchanged | Kept: a partial refund is a goodwill discount, not a return |
| Dispute opened | `disputed` | Taken away while the bank decides |
| Dispute won, or an inquiry closed without a chargeback | `completed` again | Given back |
| Dispute lost | stays `disputed`, `disputeOutcome: 'lost'` | Stays away |

`disputed` works like `refunded`: it is not `completed`, so `hasPurchased()`
and `COLLECTED_SALE` both drop the row with no new check anywhere.

A purchase is stored by Checkout session and a charge names only its payment
intent, so the webhook asks Stripe for the session
(`checkout.sessions.list({ payment_intent })`) rather than storing a second key.
That works for every purchase already recorded.

Every write repeats the status it was planned from, so Stripe's retries and
out-of-order deliveries cannot double-apply. A failed lookup answers 500 so
Stripe delivers the event again.

`/api/checkout/status` now records a session only if no purchase row for it
exists. A row that exists but is not `completed` was refunded or disputed, and
the return link must not undo that.

## Consequences

- Refunding in the Stripe dashboard is now the whole job. `refundPurchase.js`
  stays for recording a reason and for `--undo`.
- The automatic refund records `refundReason: 'Refunded in Stripe'`. A specific
  reason still needs the script.
- A buyer under dispute can check out again, because `hasPurchased()` is false.
  Rare, and the second payment is real money; not guarded.
- The endpoint's event list lives in Stripe, not in the repo. If the endpoint is
  ever recreated, it must subscribe to all four events or refunds go back to
  being silent.

## Alternatives considered

**Store the payment intent on each purchase and match on it.** One less call to
Stripe per refund, but every purchase recorded before today has no payment
intent, so it would still need the lookup as a fallback. One path is simpler.

**Revoke on any refund, partial included.** The owner declined: a partial
refund is used as a goodwill gesture and should not take the product away.

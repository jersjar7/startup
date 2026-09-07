# 11. A refund revokes the product, and `status` is how we say so

Date: 2026-09-07

## Status

Accepted. Extends [ADR 0010](0010-uncollected-purchases-are-not-revenue.md),
which it deliberately does not contradict.

## Context

On 2026-09-07 a customer bought the $49 Exam Simulation and asked to cancel 23
minutes later, having started zero simulations. The site carries a 14-day
money-back guarantee in three places, including directly under the buy button,
so he was entitled to the refund without giving a reason.

Recording it exposed a gap. The codebase had no notion of a refund at all.
`docs/EXAM-SIMULATION.md` had already flagged it: refunds and disputes never
revoked `examSimAccess`, so a refunded customer kept the product and stayed in
the revenue totals. The money would leave the Stripe balance and the dashboard
would never notice.

ADR 0010 introduced `uncollected: true` for a purchase that was granted but
never paid for, and explicitly rejected `status: 'refunded'` for that case on
two grounds: changing the status would silently revoke the customer's access,
and "refunded" would have been a false statement because nothing was ever paid.

Both of those grounds invert for a real refund. Revoking access is exactly the
intent, and "refunded" is exactly what happened.

## Decision

A refunded purchase gets `status: 'refunded'`, plus `refundedAt` and a
`refundReason` string. The user document gets `examSimAccess: false` and loses
`examSimPurchaseDate`.

This single field change does both jobs at once, which is why it is the right
one:

1. **Entitlement ends.** `hasPurchased()` matches `status: 'completed'` alone,
   so moving the status off `completed` revokes the product with no new check
   anywhere in the app.
2. **Revenue drops it.** `COLLECTED_SALE` also requires `status: 'completed'`,
   so every revenue, sales-count and ARPPU surface excludes the row for free.
   No new flag in the shared filter.

The row itself stays, as in ADR 0010, because it is the only record of what the
customer bought and why they no longer have it.

`service/scripts/refundPurchase.js` is the supported path: dry-run by default,
`--reason` required, `--undo` to reverse, and it refuses to run against a
purchase not in the state it expects. It never talks to Stripe. Refund the card
in Stripe first; the script only records what Stripe already did.

## Consequences

- A refunded customer loses the Exam Simulation and keeps everything else. The
  free account, the study history, the XP and the streak are untouched.
- They can buy again later. `hasPurchased()` returns false, so checkout reopens
  normally rather than telling them they already own it.
- The two flags and the status now carry three distinct meanings, and the
  distinction is the useful part: `uncollected` is money that never arrived and
  the customer keeps the product, `comp` is a deliberate free grant, `refunded`
  is money returned and the product withdrawn.
- Nothing reconciles against Stripe. If a refund is issued in the dashboard and
  the script is never run, the customer keeps access and the dashboard keeps
  counting the money. A Stripe `charge.refunded` webhook would close that gap
  and is not built.
- The published Terms did not describe any of this. They were rewritten in the
  same change to state the guarantee, the price, and that a refund ends access
  to the simulation only. The Privacy Policy was corrected alongside it: it
  claimed we ran no analytics scripts, collected no names, and had no paid
  features, and all three had become false.

## Alternatives considered

**Add `refunded: true` to `COLLECTED_SALE` and leave the status alone.** The
symmetric-looking option, and wrong here. It would keep `hasPurchased()` true,
so the customer would keep the product after being given their money back, and
every entitlement check in the app would need a second condition added by hand.
ADR 0010 kept status untouched precisely because that case wanted access to
survive. This case wants the opposite.

**Delete the purchase row.** Erases the only explanation for why a former buyer
has no access and no charge, and makes the refund invisible to any later audit.
Rejected for the same reason ADR 0010 rejected it.

**Handle it entirely in Stripe and leave the database alone.** Stripe would be
correct and the product would still be granted. The dashboard reads the
database, not Stripe, so revenue would stay overstated indefinitely.

**Automate it from a `charge.refunded` webhook.** The right end state, and more
than the moment needed. Refunds are rare enough that a guarded, reversible
script with a recorded reason is safer than an untested webhook path that
revokes paid access automatically. Worth building when refunds stop being rare.

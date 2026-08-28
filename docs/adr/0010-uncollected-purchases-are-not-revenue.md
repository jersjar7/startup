# 10. A granted purchase we were never paid for is not revenue

Date: 2026-08-28

## Status

Accepted.

## Context

A `purchases` document with `status: 'completed'` has always meant two things at
once: *we granted the exam simulation*, and *we were paid for it*. Those two came
apart during the Stripe test-key incident. Production ran on `sk_test` from
2026-07-18 to 2026-07-30 (see `memory` note on payments and `service/stripeMode.js`).
On 2026-07-29 a real student checked out. Stripe reported the session as paid,
exactly as a live session would, the app recorded a completed $29 student
purchase, and access was granted. No money ever moved.

The bug that let it happen is fixed: `isModeMismatch` now refuses to grant on a
livemode mismatch in both the webhook and the `/checkout/status` self-heal path.
But the row it created stayed in the collection, and every revenue surface
matched on `status: 'completed'` alone. So the admin dashboard counted $29 we
never received as income, counted a sale we never made, and folded both into
average revenue per paying user. Reported totals were $677 across 18 purchases
when the truth was $648 across 17.

The owner's instruction: stop counting her money as income and stop counting it
as a sale.

## Decision

Add `uncollected: true` to a purchase that was granted but never paid for, and
introduce one shared filter, `COLLECTED_SALE` in `service/collectedSales.js`:

```js
{ status: 'completed', uncollected: { $ne: true }, comp: { $ne: true } }
```

Complimentary grants are excluded by the same filter (owner decision,
2026-08-28). A comp already carries `comp: true` and a `compReason`, and
`scripts/baseline-report.js` already counted them separately. They contribute $0,
so they never inflated revenue, but they did sit in the sales count and pull
average revenue per paying customer down. The two flags stay separate rather than
collapsing into one "free" flag, because the reason is the useful part: an
uncollected row is a mistake we absorbed, a comp is marketing spend.

Every revenue, sales-count and ARPPU surface matches through it: the funnel
counts and sales summary (`db/events.js`), the daily time-series and all-time
totals (`db/analytics.js`), the recent-purchases list, the paid flag on the
recent-users table, and sim-pitch conversion (`db/adminUsers.js`).

Three constraints on the decision:

1. **Entitlement does not use the filter.** `hasPurchased()` matches on status
   alone, and `examSimAccess` on the user document is untouched. The student
   keeps the product. The mistake was ours, and taking it back over a bookkeeping
   correction would be the wrong trade. `collectedSales.test.js` fails if
   `hasPurchased` ever starts reading the flag.
2. **The row stays.** It is a true record of who has access and why, so support
   can still see it. The admin user lookup shows it with "not collected".
3. **`$ne: true`, not `uncollected: false`.** Every purchase written before the
   flag existed has no such field, and those must keep counting as revenue.

## Alternatives considered

**Delete the purchase document.** Simplest arithmetic, and wrong. It would erase
the only record explaining why that student has access, and the next person to
audit her account would find an entitlement with no provenance.

**Set `status: 'refunded'` or similar.** This is the option that looks right and
is not. `hasPurchased()` matches `status: 'completed'`, so changing the status
silently revokes her access, which is the opposite of the intent, and "refunded"
would be a false statement besides: nothing was refunded because nothing was
paid.

**Subtract a hard-coded $29 in the dashboard.** Hides a data problem behind a
display fudge, and breaks the moment a second uncollected grant appears.

## Consequences

- Admin revenue, purchase count, ARPPU, the revenue time series and the
  sale-alert email running totals all now mean *money actually collected*.
- Reported all-time figures drop by one sale and $29 the moment this ships. That
  drop is a correction, not a regression, and the sales-goal ladder in memory
  should be read against the corrected number.
- There is now a supported way to record any future granted-but-unpaid purchase:
  `service/scripts/markUncollectedPurchase.js`, dry-run by default, reversible
  with `--undo`.
- Comps leave the sales count too, so "purchases" now means "people who paid us."
  Comped users keep their access, and `scripts/baseline-report.js` still reports
  `complimentaryGrants` separately, so the giveaway stays visible.

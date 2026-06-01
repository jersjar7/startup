# Launch Readiness — Paid Funnel Verification

**Date:** 2026-06-01
**Scope:** Verify the monetization funnel works end to end before any go-to-market spend. Product excellence work is complete and merged to main; this is the first launch-track item.

---

## Funnel verified (live, Stripe test mode)

Code review of `checkout.js`, `webhook.js`, `exam.js`, `db/purchases.js` plus live API verification against the real Stripe **test** API (throwaway user, cleaned up afterward):

| Step | Check | Result |
|------|-------|--------|
| Access gate (locked) | `POST /api/exam/start` with no purchase | ✅ 403 |
| Checkout session | `POST /api/checkout/create-session` | ✅ real `checkout.stripe.com` session URL (validates `STRIPE_SECRET_KEY` + `STRIPE_PRICE_ID`) |
| Purchase grant | record purchase → `POST /api/exam/start` | ✅ 200, attempt created, 19,200 s (5h20m) limit |
| Status reflects | `GET /api/checkout/status` | ✅ `{ purchased: true }` |
| Duplicate guard | second `create-session` | ✅ 400 "already own" |

**Architecture is sound and resilient:**
- Every exam route is gated behind `requirePurchase`.
- The webhook verifies the Stripe signature and dedupes by session id.
- `GET /api/checkout/status` has a Stripe-direct fallback that records the purchase if the webhook hasn't fired (covers local dev and webhook delays).
- `service/.env` (with the Stripe **test** key) is gitignored and untracked — no secret in the repo.

**Verdict: PASS.** Not browser-driven: Stripe's own hosted card page and the post-payment redirect→`/status` record (verified by code review + the `create-session` success + the grant path).

---

## Minor observations (not blockers)
1. `POST /api/exam/start` trusts client-supplied questions, including `correctAnswerId`, when scoring. The question bank is client-side by design, and the exam is self-assessment (no competitive stakes beyond XP), so this is acceptable — but XP from the exam could be inflated by a crafted request. Revisit only if XP ever gates something valuable.
2. The `/status` fallback calls `recordPurchase` without a pre-existence check (the webhook path does dedupe). Two concurrent `/status` calls for the same session could insert duplicate purchase rows. Harmless to access (`hasPurchased` still true); tidy up with a guard if it ever matters.

---

## Remaining launch-track items
- **Analytics / instrumentation — DONE.** Owner-gated `GET /api/admin/metrics` + `/admin` page show the conversion funnel (signups → diagnostic → checkout → purchase) and revenue. Signups/diagnostic/purchases are derived from existing collections; the one missing event, `checkout_started`, is now logged in `checkout.js` (new `funnelEvents` collection). Pure metric math in `metrics.js` (tested). Owner = `ADMIN_EMAIL` env (set it in `service/.env` to your account email; defaults to the owner's email). Note: `checkout→purchase` will read oddly until enough post-instrumentation traffic accrues, since historical purchases predate the `checkout_started` event.
- **Business plan inputs** — pricing rationale, market size, differentiation (990 problems, gamification, spaced repetition, diagrams at 1/30th competitor price), unit economics.
- **Pre-launch polish** — real Stripe webhook configured in production; transactional-email deliverability (Resend) check; basic error monitoring.

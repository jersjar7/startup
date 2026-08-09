# 0009. Keep unlimited simulation access; drop the two-sim bundle

- **Status:** Accepted
- **Date:** 2026-08-10
- **Affects:** `service/pricing.js`, `src/data/pricing.js`, growth-plan Days 15–18, the plan's revenue model
- **Supersedes for Week 3:** the bundle half of the plan's Day 15 price ladder

## Context

The growth plan's Day 15 specifies a new price ladder:

| | Standard | Student |
|---|---|---|
| Single simulation | $49 | $35 |
| **Two-sim bundle** | **$79** | **$59** |

The rationale is sound and is not in dispute: NCEES sells a 50-question practice
exam for about $50 and PrepFE starts at $79.99 for a smaller bank, so $29/$49
sits below the anchor set by the certifying body itself and reads as "probably
not the real thing".

The bundle, however, cannot be sold as specified, because of a fact about the
code that is not visible from outside it:

```js
async function requirePurchase(req, res, next) {
  const purchased = await DB.hasPurchased(userId);
  if (!purchased) return res.status(403).send({ msg: 'Exam Simulation purchase required' });
  next();
}
```

**Access is a boolean.** One purchase grants unlimited simulations, forever.
There is no attempt meter anywhere in the service, and `attemptNumber` is a
counter for display, not a limit. Customers already use it this way: 18 attempts
are recorded across 9 buyers, and one customer has three.

We also say so in public, on the page shipped on Day 11 and in the email footer
shipped on Day 12:

> One time, no subscription, and it does not expire.
> Each attempt draws a fresh 110 from a larger bank … a retake is a genuine
> second test rather than the same paper again.

So a $79 "two-sim bundle" would be strictly worse than the $49 single that
already includes an unlimited number of simulations. Nobody rational buys it,
and anyone who noticed the arithmetic would reasonably read it as a trick.

This is not confined to Day 15. Days 16–18 all presuppose metered attempts:
Sim #2 as a separately purchasable product, bundle checkout carrying tier
metadata, and a "fail the FE and get another simulation free" guarantee — which
is not an offer at all when retakes are already unlimited.

## Decision

**Keep unlimited access. Raise the student price only. Do not build the bundle.**

| | Was | Now |
|---|---|---|
| Standard | $49 | $49 (unchanged) |
| Student (verified .edu) | $29 | **$35** |
| Bundle | — | not built |

The owner made this call when the conflict was put to them, choosing to preserve
the never-expires pass over introducing metering.

The alternative — metering attempts so the bundle becomes real — was presented
and rejected. It would have required an attempt counter, quantity in checkout,
and grandfathering the 9 existing buyers to unlimited, and it would have made
the offer smaller than the one customers can see today.

## Consequences

**Good**

- The strongest, most differentiated property of the offer survives: buy once,
  sit as many full timed exams as you want, forever. Competitors meter this.
- No customer-facing downgrade, no grandfathering, no risk of a paying customer
  discovering their access now has limits.
- The price anchor problem is still addressed at the student tier, which is
  where the discount was deepest relative to the market.
- Day 16's Sim #2 remains worth building. More non-overlapping content makes
  "a retake is a genuine second test" more true; it just ships to every buyer
  rather than as a paid tier.

**Bad, and accepted**

- **The plan's AOV target of $39 → $60 is not reachable this way.** With no
  bundle and standard unchanged, the ceiling is $49 and the realistic blended
  figure lands near $42–45. The target needs re-deriving by the analyst; it
  should not be quietly restated as met.
- Days 17 and 18 need rewriting. Bundle checkout has nothing to sell, and the
  free-retake guarantee is already implied by unlimited access, so it cannot be
  offered as new value.
- Revenue growth now has to come from volume rather than order value, which
  leans harder on the Week 3 outreach work than the plan assumed.
- We give up a real pedagogical framing the plan identified — one sim at T-30 to
  find gaps, one at T-14 to confirm they closed. That sequencing is still good
  advice and can be given as guidance rather than sold as a product.

## Alternatives considered

**Meter attempts: single = 1 simulation, bundle = 2.** What the plan intended,
and the only version where Days 16–18 are coherent. Rejected by the owner: it
converts an unlimited pass into a limited one, which is a downgrade to the live
offer, requires grandfathering existing buyers, and is far more than the 60
minutes budgeted.

**Keep unlimited but sell a $79 tier with different content** — a written
diagnostic review, priority support. Preserves both the pass and a higher tier
for AOV. Rejected for now as inventing a product the plan did not specify and
nobody has asked for; it also adds a fulfilment obligation with real ongoing
cost, which is the opposite of the zero-marginal-cost logic behind the original
bundle.

**Raise standard to $79 with no bundle.** Reaches the AOV target through price
alone. Not chosen: with 9 sales total there is no evidence the market bears it,
and a 61% rise on the only paid product during the seasonal trough risks
learning nothing except that sales stopped.

## Notes

Recorded under the ADR-0005 exception. The plan is followed as written unless
new evidence contradicts it, and "the access model is boolean, so the bundle
cannot exist" is a hard fact about the code rather than a preference. The
concern was raised before any of it was built, and the owner chose the path.

The analyst should be told two things: the access model is unlimited-per-purchase
and always has been, and the AOV target therefore needs re-deriving.

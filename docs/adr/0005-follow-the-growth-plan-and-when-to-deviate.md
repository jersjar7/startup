# 0005. Follow the growth plan as written, and deviate only on evidence

- **Status:** Accepted
- **Date:** 2026-07-29
- **Affects:** how day-to-day work is chosen; `~/developer/fe4raccoons-marketing/analysis/90-day-growth-plan.xlsx`

## Context

A hired senior business analyst produced a day-by-day 90-day growth plan with
dated tasks, time estimates, a budget and a revenue model. The owner is paying
for that judgement and wants it applied, not reinterpreted.

The failure that prompted this was small and instructive. The plan specified the
attribution question as "a single **mandatory** tap". The implementation shipped
it as skippable, with a "Skip and go to Dashboard" link, on the reasoning that
hard-blocking felt hostile.

That was a product-judgement call substituted for the strategy being paid for.
Nobody asked for it, and the softening was invisible unless you compared the
plan text to the code. The owner's response was direct: follow the plan, raise
concerns in one line, do not water requirements down.

## Decision

**Implement what the plan says.** When a task specifies something concrete, build
that thing.

If something in the plan looks wrong, **say so in one line and implement it as
written anyway**, unless the owner says otherwise.

There is one clear exception, and it is about evidence rather than taste:

> **New data that contradicts the plan is a legitimate reason to deviate.
> Preference is not.**

The distinction in practice:

| Deviate | Do not deviate |
|---|---|
| A production test shows the prescribed approach silently loses data (ADR-0003) | The prescribed approach feels heavy-handed |
| Measurement shows the plan's premise was wrong — attribution was 50%, not 10%, and search led, not Reddit | A different sequencing seems tidier |
| A constraint appears that the plan could not know: Reddit banned organic posts | The estimate feels too aggressive |

When deviating, record **what the plan said, what was done instead, and the
evidence** — in the day's note in column L, and in an ADR if the reasoning is
non-obvious.

## Consequences

**Good**

- The owner gets the strategy they paid for, rather than a version filtered
  through an implementer's instincts.
- Deviations become visible and reviewable instead of quiet.
- The analyst can be given corrected data and re-plan against reality; that
  already happened once and reversed the channel strategy.

**Bad, and accepted**

- Some tasks get built despite reservations. Acceptable: the reservation is
  recorded, and being wrong in a documented way is better than being quietly
  right.
- Requires discipline when a plan item looks obviously improvable. The urge to
  "just make it better" is exactly what this rule exists to resist.
- The plan can be stale relative to the code. The plan is the strategy, not the
  spec; where the two disagree on facts, the measured facts win and the plan
  gets updated.

## Alternatives considered

**Treat the plan as advisory.** Rejected outright. It defeats the point of
hiring an analyst, and it is what happened accidentally with the mandatory tap.

**Escalate every disagreement before implementing.** Rejected as too slow. A day
with 45 minutes of work should not need a round trip over a wording preference.
One line of concern, then build, is the right ratio.

**Deviate freely when the code shows the plan is impractical.** Rejected because
"impractical" is where taste hides. The bar is a *measurement* or a *hard
external constraint*, not a judgement that something would be awkward.

## Notes

The rule cuts both ways and has been used more often to *contradict* the plan
with data than to soften it: the plan's attribution figure, its channel ranking,
and its revenue baseline were all wrong, and correcting them was the right call
precisely because measurement backed it.

See also `docs/ANALYTICS-ATTRIBUTION.md` for the corrected baselines.

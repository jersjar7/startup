# 0004. Widen the sim-pitch gate, and set the effort threshold at 25 problems

- **Status:** Accepted
- **Date:** 2026-08-04
- **Affects:** `src/dashboard/simPitchGate.js`, `src/dashboard/SimPitchBanner.jsx`, `service/routes/auth.js` (`/me` returns `problemsAnswered`)

## Context

The on-site banner is the main in-product pitch for the only paid item. Its gate
required an exam date on file **and** that date to be 2–30 days away, plus not
purchased and not recently snoozed.

Measured on 2026-08-04 against live data:

| | Users |
|---|---|
| Total | 270 |
| Have an exam date at all | 73 |
| Date 2–30 days out — **the entire eligible audience** | **15** |
| Excluded for sitting 31+ days out | 35 |
| Excluded for past or under 2 days | 23 |

The gate discarded 96% before the banner was considered. Of the handful who saw
it, **60% clicked**. A very high click rate on a microscopic audience says the
offer works and almost nobody sees it: a distribution problem, not a persuasion
problem.

The binding constraint was **the 28-day window, not missing exam dates**. 35
users were excluded purely for planning ahead.

A second population was invisible entirely: engaged studiers who never set an
exam date. A purely date-gated pitch cannot reach them at all.

## Decision

Show the banner to a non-buyer when **either** is true:

- they have **any future exam date**, with no upper bound, or
- they have answered **25 or more problems**

The lower bound of 2 days stays. Selling a 5h20m simulation to somebody sitting
the exam tomorrow is not a real offer.

A second copy variant was required, not optional. Every existing variant
interpolates the day count, so an undated user would have fallen through to the
final tier and rendered the literal string **"Just null days to go."** The
readiness variant leads with the user's own problem count and sells the
diagnostic value instead of inventing urgency for someone who never said when
they sit.

### Why 25

The threshold is evidence-based but **deliberately loose**. Problems answered by
the first 8 real buyers before purchasing:

```
9, 45, 52, 63, 64, 98, 106, 185      median 64
```

Seven of eight had answered 45 or more, which superficially argues for 45.
**Rejected as overfitting.** Eight data points cannot support a fine threshold;
two more sales could move it materially.

25 was chosen because only **1 of 8** buyers fell below it, so it costs almost
nothing in precision, while reaching 34 users instead of 18 — roughly double.

It is also not lower than 25, because the product is a five-and-a-half-hour
timed exam. Pitching it to someone who has answered eight problems makes the
offer look unserious.

Measured effect: **15 → 94 non-buyers** eligible (49 countdown, 45 readiness).

## Consequences

**Good**

- 6.3x reach on the only paid offer, at zero marginal cost.
- Users with a stale exam date are rescued: they get the readiness pitch instead
  of nothing.
- The gate is a tested pure function rather than inline logic, because it
  decides the reach of the paid product.

**Bad, and accepted**

- 94 users see a new pitch at once, roughly a third of the base.
- The snooze is a `localStorage` flag, so it is per-device. Someone who
  dismissed the old banner sees the new one again. Defensible because the offer
  and copy genuinely changed, but it is a re-prompt.
- 25 is a judgement call sitting on 8 observations. If it turns out to annoy
  users who are nowhere near ready, raise it — the constant is in one place.
- 166 non-buyers still see nothing. The banner is not the whole answer; a
  permanent always-visible entry point is the complement.

## Alternatives considered

**Widen the window only, keeping the date requirement.** Reaches 49 rather than
94 and needs no new copy. Rejected as leaving the larger half on the table —
undated studiers are the population a date-gated pitch can never reach.

**Include undated users but ask for their exam date first.** Would also feed the
exam-date capture target. Rejected because it puts a form between the user and
the offer, and the entire finding is that the offer converts when people simply
see it.

**Threshold at 45**, matching where 7 of 8 buyers sat. Rejected as overfitting 8
points; it halves reach for precision the sample cannot justify.

**Add a streak condition** as the plan also suggested. Rejected as redundant:
problems answered already captures sustained effort, and each extra clause makes
the gate harder to reason about.

## Notes

The estimate in the plan was "roughly 90 users". The measured figure is 94 — but
the plan's number was formed when only 5 users could see it, and Day 5's
onboarding capture had already lifted reach from 5 to 16 with no code change at
all. Two changes compounding, one of which nobody had to write code for.

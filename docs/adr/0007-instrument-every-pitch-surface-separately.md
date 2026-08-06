# 0007. Instrument every pitch surface separately

- **Status:** Accepted
- **Date:** 2026-08-06
- **Affects:** `src/exam/trackPitch.js`, `service/routes/checkout.js`, `SimPitchBanner.jsx`, `ExamSimCard.jsx`, `Header.jsx`

## Context

Three surfaces now lead a user to the paid Exam Simulation:

1. **The pitch banner** — conditional, shown to 94 qualifying non-buyers (ADR-0004)
2. **The dashboard card** — permanent and ungated, below the chapters table
3. **The nav link** — added today, visible on every screen

Only the first was instrumented. It logged `sim_banner_shown` and
`sim_banner_click`, which is how we know it reached 5 users and 3 clicked, a 60%
rate that drove the whole "distribution, not persuasion" conclusion.

The card logged **nothing**, despite having been live and visible to every
non-buyer the entire time. So the strongest claim available — *the offer
converts when people see it* — rested entirely on the surface that almost nobody
saw, while the surface everybody saw was invisible to us.

That asymmetry is dangerous in a specific way: it makes the conditional,
hard-to-reach surface look like the thing that works, purely because it is the
only thing measured. Plausible showed `/dashboard` at 228 visitors for the week
while `/exam` did not reach the top five pages, which hints the card is not
carrying much traffic, but hinting is not knowing.

Adding a third surface without fixing this would have compounded it.

## Decision

Every surface that pitches the paid product reports **which surface it is**.

The existing endpoint gained a `via` field rather than gaining siblings:

```
POST /api/checkout/sim-banner/:action   { via: 'banner' | 'card' | 'nav' }
```

`via` is **allowlisted server-side**. An unrecognised value is recorded as
`dashboard` rather than stored verbatim, so a client typo cannot silently
fragment the funnel into near-duplicate buckets.

Clients go through one shared `trackPitch(action, via)` helper so the three
surfaces cannot drift in how they report, and it is fire-and-forget so analytics
can never delay a navigation or surface an error to somebody trying to reach the
product.

The card logs impressions **only for non-buyers**. An owner looking at their own
attempt history is not being pitched anything, and counting them would inflate
the denominator of the one rate we care about.

## Consequences

**Good**

- Each entry point can be judged on its own conversion rather than assumed to
  work because a different one does.
- Removing a surface becomes an evidence-based decision. If the nav link earns
  nothing in a month, it can go without argument.
- The banner's 60% gets a fair comparison. It may simply reflect that the banner
  reaches people already close to their exam, in which case the number says more
  about the audience than the surface.

**Bad, and accepted**

- Events before 2026-08-06 all carry `via: 'dashboard'` and are all banner
  events. Any query spanning that boundary must treat `dashboard` as `banner`,
  which is a permanent wrinkle in the data.
- Three surfaces produce more impression events than one, on every dashboard
  load. Volume is trivial at this scale but it is not free.
- Impressions are logged client-side, so ad blockers and failed requests
  undercount them. Acceptable: the comparison between surfaces stays valid
  because all three are undercounted the same way.

## Alternatives considered

**Separate endpoints per surface** (`/sim-card/:action`, `/sim-nav/:action`).
Rejected as three routes doing one job, with three chances to diverge and a
guaranteed inconsistency the first time someone adds a fourth surface.

**Rename the event types** (`sim_card_click` rather than a `via` field).
Rejected because it breaks every existing query and makes "how many people were
pitched, by any route" a union across event names instead of a group-by.

**Instrument only the new nav link**, leaving the card dark. Rejected: the card
is the one surface everybody can see, so leaving it unmeasured preserves exactly
the blind spot that motivated this.

**Rely on Plausible page views of `/exam`.** Rejected as too coarse. It cannot
say which surface sent someone, cannot distinguish buyers from non-buyers, and
is undercounted by ad blockers with no way to compare like for like.

## Notes

This was not in the growth plan. It is a deviation justified by the rule in
ADR-0005: the plan's stated premise for this task — that the banner was the only
path to the product — was factually wrong, and the card had existed unmeasured
the whole time. Shipping a third unmeasured surface would have repeated the
mistake Week 1 was spent correcting.

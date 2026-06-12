# Study-Load Implementation Plan

_Created 2026-06-12. The single ordered checklist for applying the locked
study-load decisions without missing anything or harming existing users._

**Source of truth for the decisions:** `docs/mobile/study-load-deliberation.md`
(see its `## LOCKED DECISIONS` section). This file is the *how and in what
order*; that file is the *what and why*. Project memory: `study-load-policy`.

---

## Guiding rails (apply to EVERY task below)

1. **Ship dark, then flip.** New numbers are computed and logged alongside the
   old ones first; nothing a user sees changes until a stage is explicitly
   flipped behind a flag.
2. **Grandfather existing users.** Never jump a live user 5 → 30 overnight; ramp
   ceilings over 5–7 days. Never raise a displayed number without a one-line
   reason. Never auto-expand the default batch for someone in an active streak.
3. **Parity is sacred.** Any change to scheduling/pacing logic lands in BOTH
   `service/shared/scheduler.js` and `mobile/src/shared/scheduler.ts` in the
   same commit, with `SCHEDULER_VERSION` bumped in BOTH. The parity test is the
   enforcement.
4. **Soft, never hard.** Every cap shows a plain-language reason + a visible
   "Continue anyway." The only hard stops are the lastMile low-weight new-concept
   freeze and streak/abuse integrity.
5. **Honesty rail is absolute.** Projection capped at 98%, framed as an estimate,
   **never a pass probability**. Never show a confident number on stale mastery.
6. **Measure the right thing.** Optimize next-day-return, review-completion, and
   lapse-rate — never items-served or minutes-in-app.

## The model (recap)

Govern the day as **three streams**, never one number:
- **A — Due reviews:** emergent from the SM-2 scheduler, **never hard-capped**,
  only soft-batched for a finite finish line.
- **B — New learning:** the only real overload lever; soft ceiling.
- **C — Chapter practice:** unlimited (already true on web); the release valve.

---

## Stage 0 — Foundation (zero user impact) — IN PROGRESS

The shared scheduler brain + parity, no behavior change. Same numbers as today;
one source instead of two. Solves the report's "single highest operational risk"
(parity drift) first.

- [x] Canonical pure module `service/shared/scheduler.js` — SM-2 `nextSchedule`,
  `seedState`, `daysUntil`, `regimeForStudyDays`, `reviewTargetFor`,
  `computeDailyPlan`, `SCHEDULER_VERSION`. (Written, uncommitted.)
- [x] Mobile mirror `mobile/src/shared/scheduler.ts` — identical logic + version,
  dependency-free. (Written, uncommitted.)
- [x] Golden fixtures `service/shared/scheduler.fixtures.json`. (Written.)
- [ ] Parity test `service/shared/scheduler.parity.test.js` — runs every fixture
  through BOTH the canonical module and the mirror; asserts equal output +
  identical `SCHEDULER_VERSION`. Red on any drift.
- [ ] Delegate mobile `Sm2Scheduler.ts` + `AdaptivePacingPolicy.ts` to the mirror
  (keep the class names + domain interfaces; zero DI changes).
- [ ] Re-route web `service/scheduling.js` + `service/db/stats.js` through the
  canonical module via `seedState` + `nextSchedule` (persist ease/reps/lapses
  forward; legacy rows seeded so a matured item never snaps back to 1 day).
- [ ] Update `service/scheduling.test.js` for the new model; confirm full web
  suite green.
- **Acceptance:** all tests green on both trees; live behavior identical to
  today (verify a relaxed 6-months-out user still sees ~5–8/day).
- **User impact:** none.

## Stage 1 — Compute-dark (no user-facing change) — needs Stage 0

Compute the new exam-aware plan everywhere, log it, show nothing new.

- [ ] **Calibrate cards/minute FIRST** (decision Q4): measure real seconds-per-card
  from `sessionLog` and set the `0.6` conversion empirically. Then the 8/14/30
  ceilings, then fatigue bounds.
- [ ] Wire the web review route to call `computeDailyPlan` with the user's
  `examDate` + live `dueCount` and compute `reviewTarget` / `dynamicCeiling`
  **alongside** the flat-5 — both logged, flat-5 still served.
  - `dynamicCeiling = baseCeiling(8/14/30) + ceil(backlog / studyDays)`.
- [ ] Add the **minutes-budget governor** (decision: persona Devin): sum streams
  A+B against `minutesPerDay`; on overflow, protect due reviews first, defer new
  concepts. Compute-only this stage.
- [ ] **Coverage-anchored projection** (Q5, Q1): readiness denominator =
  concept-tier coverage × NCEES chapter weight (crude, chapter-level). Compute
  the honest projection (half-covered → ~60%, capped 98%) alongside the current
  one; log both.
- [ ] **Telemetry split** before any flip: separate review-completion vs
  new-completion; baseline next-day-return + lapse-rate. Dashboards must not read
  a target-driven completion dip as breakage.
- **Acceptance:** logs show new vs old side by side for real traffic; no UI delta.
- **User impact:** none.

## Stage 2 — Flip, grandfathered (BEHAVIOR CHANGE — owner green-light required)

Behind a flag, ramped for existing users. This is the only stage a user sees.

- [ ] Replace web flat-5 (`review.js:46`) — serve `reviewTarget`; **ramp
  `dynamicCeiling` over 5–7 days** for grandfathered users.
- [ ] **Soft "keep going"** on every surface past the target (web review +
  mobile) — never "come back tomorrow."
- [ ] **Continuous intensity lerp** 1.0 → 1.3 across studyDays 20 → 10 (kill the
  14-day cliff).
- [ ] **Horizon-aware interval cap** on the NEXT interval only:
  `min(60, ceil(0.25 * daysUntilExam))` so nothing is scheduled past the exam.
- [ ] **Blank-slate crammer path** (Q3): regime ∈ {crunch, lastMile} AND coverage
  < ~20% → lift the 40-card new-learning ceiling; per-sitting fatigue bounds
  govern; soft keep-going.
- [ ] **lastMile** (studyDays < 4): freeze only LOW-weight new concepts (adult-
  consent gap exception for the single highest-weight unopened chapter);
  triage-order the review queue by NCEES weight × weakness, not soonest-due.
- [ ] **Non-deferrable NCEES-weighted triage** for sub-14-day users — ship a crude
  readiness bar rather than leaving a late starter with just a ceiling.
- [ ] **Returner front-load** (Q6): ~1.25× steady `ceil(backlog/studyDays)` for the
  first ~3 days, soft, reviews protected first, then the rolling-3-day completion
  ratio relaxes it.
- [ ] **Recheck gate** (Q2): a returner-after-a-gap sees "your mastery may be rusty
  — 2-min recheck?" before any confident projection. Stored mastery untouched.
  No global decay.
- [ ] **Over-study guard** (persona Jordan): sticky, once-and-memorable spacing
  framing for the 2×-over-3-days early binger + a days-shown-up consistency hook.
  Never streak-loss fear.
- [ ] **Streak earn-rule**: define completion against due-reviews + a modest
  minimum (or the protected-review floor on an overflow day); grandfather current
  streaks; apply the new rule forward-only; never punish the exam-eve rest day.
- **Acceptance:** flag cohort shows healthy next-day-return and no opens-then-
  bounces (overwhelm-churn) signature; relaxed low-end users unchanged.
- **User impact:** HIGH — staged + flagged + grandfathered + owner-gated.

## Stage 3 — Fast-follows (after Stage 2 is healthy)

- [ ] **Trajectory-aware projection** (Q5): the number visibly moves as the user
  does the work (work-responsive curve), on top of coverage-anchoring.
- [ ] **Refine the readiness denominator** from crude chapter-level toward
  per-concept, tuned on telemetry.
- [ ] Instrument-tune the 8/14/30 ceilings and fatigue bounds against
  next-day-return + lapse-rate.

## Deferred — owner-gated (NOT in this plan's scope)

- **Full mastery decay** (platform-wide forgetting) + **drop attribution**
  ("Surveying −4%: trap missed 3×"). Superseded for now by the Stage-2 recheck
  gate. Revisit only when you want platform-wide decay and are ready to
  communicate it; ships with its own migration + comms. See `mastery-model-bug`
  memory and the deliberation report §6/§9.

---

## Decision → task traceability (so nothing is missed)

| Locked decision | Where it lands |
|---|---|
| 3-stream model | Stage 1 (governor) + Stage 2 (web flip) |
| Q1 crude NCEES-weighted readiness | Stage 1 (projection denominator) |
| Q2 recheck gate, defer decay | Stage 2 (recheck gate); decay → Deferred |
| Q3 blank-slate lift | Stage 2 (blank-slate path) |
| Q4 calibrate cards/min first | Stage 1 (first task) |
| Q5 coverage-anchor first, trajectory later | Stage 1 (coverage) + Stage 3 (trajectory) |
| Q6 1.25× returner front-load | Stage 2 (returner front-load) |
| Honest-but-bounded crammer stance | Stage 2 (blank-slate + lastMile + triage + keep-going) |
| Parity / ship-dark / grandfather rails | All stages (Guiding rails) |

## Web vs mobile change map

- **Web:** delete flat-5; route through `computeDailyPlan`; persist
  ease/reps/lapses; add coverage projection, recheck gate, triage ordering,
  soft keep-going, streak earn-rule, telemetry split.
- **Mobile:** delegate to the shared mirror; adopt continuous lerp + horizon cap
  + blank-slate lift + lastMile + minutes governor + over-study guard + recheck
  gate UI; surface the same soft keep-going.
- **Shared:** every logic change in both scheduler files + version bump + parity
  test.

## Success metrics

Next-day-return ↑, review-completion (its own metric) healthy, lapse-rate ↓,
relaxed-user low-end unchanged. NOT items-served, NOT minutes-in-app.

## How this slots into the broader backlog

Stage 0 IS backlog item "shared scheduler" (task #1). The unified mastery metric
and the cross-surface paper hand-off (P1) build on Stage 0's `computeDailyPlan`
+ projection and should follow Stage 1. XP table and visible sync state are
independent and can land anytime. See `docs/mobile/feedback-backlog.md`.

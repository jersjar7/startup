# Mobile app — implementation plan (first cut)

_How the 1,126-problem classification (`content-plan.md`) becomes the React
Native app. First-cut thinking — to be pressure-tested against
`../mobile-app-north-star.md` at every step. Nothing here ships without passing
the litmus test at the bottom._

## 1. Content data model — one bank, a thin mobile sidecar

Non-negotiable (from the North Star + the whole content-count discipline):
**one source of truth.** The mobile app imports the *same* `src/data/**`
problem objects the web uses — resolved by id through the existing
`problemPool.js`. We do **not** fork a mobile question bank.

The classification is a **sidecar keyed by problem id**, not a content copy:

```
src/data/mobile/tiers.js        // { [id]: { tier, interaction, needsPaper } }  (generated, committed)
src/data/mobile/cards.js        // { [id]: [ { kind, prompt, answerRef } ] }    (human-verified)
```

`tiers.js` is generated from `problem-classification.json` by a build script
(same pattern as `gen-stats.mjs`). `cards.js` starts as the mined drafts and is
promoted entry-by-entry as a human verifies each card. A problem with no
verified cards yet still works — it falls back to its native form. This keeps the
phone layer **additive**: editing a problem in the bank updates web + mobile at
once; the sidecar only annotates.

A resolved mobile item is therefore: `problemPool.getProblemById(id)` ⨝
`tiers[id]` ⨝ `cards[id]`. Shared logic package, two renderers (web/RN).

## 2. Three render surfaces, one per tier

| Tier | Phone surface | Component sketch |
|---|---|---|
| `concept` | Full practice. Prompt → user retrieves → reveal → self-grade or MCQ. | `<ConceptCard>` (recall-reveal) / `<TrapCard>` (tap-the-trap) |
| `phone-calc` | Retrieve **the approach** (formula/handbook/first move). Optional on-screen scratchpad to finish the number; the *graded* part is the method. | `<FormulaFirst>` → reveal → optional `<Scratchpad>` |
| `paper` | Retrieve the **setup** on phone; explicit hand-off to solve. Worked example available first (rule #4). | `<SetupCard>` → `<GrabPaper>` banner → `<WorkedExample>` |

The four interaction components (`recall-reveal`, `formula-first`,
`setup-not-solve`, `tap-the-trap`) cover 1,119 of 1,126 problems; `mcq` is a
7-item fallback. Each renders KaTeX (already in the stack) and, where present,
the SVG diagram via `react-native-svg` (the 104 diagram components port over).

**Generation is enforced in the UI**: the answer/formula is hidden until the
user commits to a recall (tap "reveal" = "I've retrieved it"). No passive
scrolling past answers — that's rule #1 made structural, not optional.

## 3. The daily loop (bounded, spaced, honest)

A session is a **defined set**, never an infinite feed (rule #5):

```
Today  →  [ N due retrieval items ]  +  [ 1 "stretch" paper setup ]  →  "Done."
           ↑ spaced-repetition queue        ↑ pushes toward effortful practice
```

- **N is small and finite** (e.g. 7–12), drawn by the spaced-repetition
  scheduler from items the user is forgetting, **interleaved across chapters**
  (rule #2) rather than blocked by topic.
- Mix tiers: mostly `concept`/`phone-calc` retrieval; seed **one** `paper` setup
  per session as the bridge to desk work — "here's the approach; tonight, solve
  it on paper." That single hand-off is the daily nudge toward real problem-solving.
- End screen says **"done for now,"** not "keep going." Reward is the streak +
  *readiness delta*, not minutes.

## 4. Spaced repetition — reuse the engine we already have

The web already stores `problemHistory` server-side (problem ids) and resurfaces
due items via `problemPool.js`. The mobile app uses the **same** scheduler and
the **same** server state, so a user's phone and web review queues are one
account. Each tier feeds the queue differently:

- `concept` / `phone-calc` → scheduled as normal retrieval items.
- `paper` → its **setup card** is the scheduled item (cheap, phone-sized);
  completing the full paper solve is logged as a heavier "deep practice" event,
  not crammed into the daily micro-loop.

Cards (the 2,388 mined micro-items) become **first-class schedulable items** with
their own ids (`<problemId>:card:<n>`), so a single problem can surface as a
trap card today and its formula card next week — spacing *within* a problem.

## 5. The phone↔paper hand-off (rule #6, made concrete)

- `<GrabPaper>` is a real UI state, not a disclaimer: it pauses the timer, shows
  the worked example first (CLT — rule #4), then "I solved it on paper → check my
  answer." Honest readiness: phone streaks never assert exam-readiness; the app
  distinguishes "reviewed the approach" from "solved it cold on paper."
- A **readiness signal** per chapter is computed from *paper* completions and
  cold-recall accuracy, **not** from card taps — directly answering rule #3
  (anti illusion-of-competence). "Familiar, not ready" stays visible.

## 6. Offline + widgets

- **Offline by default.** Content (~786 KB gzipped) + the sidecar bundle into the
  app; the daily queue is computed locally and synced opportunistically. The FE
  is studied in quiet rooms — offline isn't a nice-to-have, it's the expected
  mode.
- **Widgets** (native extension + a small shared data file): exam countdown and
  "concept of the day" (a single due `recall-reveal` or `tap-the-trap` card).
  Both are honest re-engagement triggers that pull toward a real retrieval rep —
  never a vanity metric.

## 7. Build order (phone-rich first, prove the loop)

1. **Engine + one surface.** `<TrapCard>` over the 1,257 mined trap cards — the
   biggest, most generative, lowest-risk asset. Wire the spaced scheduler. Ship a
   bounded daily loop on **one** phone-rich chapter (geotechnical or ethics).
2. **Concept + formula-first surfaces.** Add `<ConceptCard>` / `<FormulaFirst>`;
   roll out the phone-rich chapters (geo, surveying, statistics, materials,
   ethics, construction, transportation).
3. **The hand-off.** `<SetupCard>` + `<GrabPaper>` + `<WorkedExample>`; bring in
   the paper-heavy chapters as setup-only retrieval + paper solve.
4. **Readiness model + widgets.** Per-chapter readiness from paper completions;
   countdown + concept-of-the-day widgets.

Each phase is shippable and testable end-to-end before the next.

## 8. Before building — the verification debt (carry from content-plan.md)

- Human-verify cards **per chapter before that chapter ships** (start with the
  trap cards). No unverified card is ever shown.
- Audit the 45 reviewFlag + 45 medium-confidence boundary calls, and a sample of
  the 405 untyped lesson problems' inferred tiers.

## 9. Litmus-test self-check (every feature above)

| Litmus question | This plan |
|---|---|
| Active (generation)? | Reveal-gated retrieval; mcq is 7/1126. ✓ |
| Honest about readiness? | Readiness from paper solves, not taps; "familiar ≠ ready." ✓ |
| Right cognitive layer? | concept/phone-calc on phone; paper flagged, not faked. ✓ |
| Bounded session? | Finite daily set; "done for now." ✓ |
| Pulls toward effort? | One paper hand-off seeded daily; streak rewards reps. ✓ |
| Measured by learning? | Readiness delta is the metric, not minutes. ✓ |

If a future feature can't fill this table with ✓, it doesn't ship.

## 10. Adaptive pacing & the web complement (product scope)

**Mobile is the conductor, not the whole orchestra.** You can run 100% of your
*schedule* from the phone — it owns daily spaced retrieval and tells you (and
logs) the paper work to do — but you cannot get exam-ready *inside* the phone:
~29% of problems (`content-plan.md`) genuinely need paper, and full timed mock
exams belong on the desk/web. Phone and web are **two surfaces on one brain**
(one account, one bank, one spaced-repetition state): phone = anywhere/quiet
retrieval + the plan; web/desk = full solving + mock exams. "We won't pretend
scrolling makes you ready" is a trust feature, not a limitation.

**The daily load adapts to time-left.** Plan =
`f(exam date, current readiness, NCEES exam weighting, minutes/day the user picks)`.
The spacing effect says the optimal review gap scales with the retention interval
(Cepeda et al. 2008 — optimal gap ≈ 10–20% of the interval), so daily volume
*should* depend on how far the exam is. Three regimes:
- **Runway (8+ weeks):** light daily load, wide spacing, build breadth + depth
  incl. paper. More time ≠ grind harder — space it out, go deeper.
- **On pace (a few weeks):** balanced spaced plan aimed at readiness by exam day.
- **Crunch (<2 weeks / behind):** triage — compress intervals, prioritize
  highest-weight *weak* chapters, lean concept/phone-calc for fast coverage,
  targeted paper only on must-knows. The plan recompresses automatically after a
  missed day.

**Honest projection (anti-illusion, "readiness not minutes").** The user chooses
minutes/day; the app projects whether that pace actually reaches readiness by exam
day and **surfaces the gap** ("at 10 min/day you'll cover ~70% of high-yield; 20
min/day → ~90%") rather than implying any dose suffices. Setup screen, the
recompressing plan, and the web hand-off are mocked in `mobile-analysis/` batch 3.

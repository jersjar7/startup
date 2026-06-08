# Quick-Start Diagnostic — Design & Decisions

_Last updated: 2026-06-07. Owner-approved design. Supersedes the monolithic
30-question / ~87-minute diagnostic for the onboarding path._

This document is the source of truth for **why** the onboarding diagnostic works
the way it does. It exists so the design is respected in future changes and so
we never silently undo a decision without knowing what it cost. For the
learning-science evidence behind each choice, see
[`pedagogy-and-research.md`](./pedagogy-and-research.md).

---

## 1. The problem we were solving

A new user landing on the dashboard met a diagnostic that was marketed as
"5-minute" (in emails and the public guide) but was actually **30 questions at
real FE pace ≈ 87 minutes** (`src/diagnostic/DiagnosticExam.jsx`,
`TIME_PER_QUESTION = 174.6`). That mismatch is an activation killer: the promise
and the wall don't match, and a tired engineer is not going to start a 90-minute
exam as their first act on the platform.

We considered several redesigns and deliberately **rejected** two tempting ones:

- **A "trap" opener** (a deceptively hard question to humble the user). Rejected:
  it attacks self-efficacy at the exact moment we need to build it.
- **Letting the user pick which chapters to be tested on.** Rejected: a
  diagnostic's whole job is to surface *blind spots*, and the people with the
  most blind spots are the least able to identify them (Dunning–Kruger). User-
  chosen coverage optimizes for comfort over truth and quietly fails the users
  who need it most. See research doc §"Self-assessment is unreliable".

## 2. The core principle

> **The user controls _how far_ they go. The system controls _which chapters_.**

That single split is what makes the flow both motivating (autonomy, stop
anytime) and honest (coverage is driven by exam importance, not by what the user
feels safe answering).

## 3. The flow

1. **Intro** — "See where you stand. Answer 5 questions — about 5 minutes. You
   can stop anytime and study any chapter right away." Honest, low-commitment.
2. **Segment** — 5 questions from **one** chapter, presented one at a time with
   immediate feedback (✓/✗ + one-line why). The opener is the easiest question
   in the set (confidence-first), then it ramps. No traps.
3. **Segment result** — an **early read** for that chapter (a capped
   "familiarity" %, _not_ "mastery"), the finite **X / 15 chapters** map (already
   partly filled — endowed progress), XP, and streak.
4. **Checkpoint** — one decision, defaulting to continue: **"Keep going →
   next: \<Chapter\>"** vs **"Stop & start studying."** Honest helper copy: "The
   more you answer, the more complete your plan."
5. Repeat until all 15 chapters are mapped **or** the user stops. Stopping is a
   first-class outcome, not a failure.

## 4. Hard rules (do not regress these)

| Rule | Value | Why |
|---|---|---|
| Questions per segment | **Tiered 5 / 4 / 3 by exam weight** (concentrated on one chapter) | 1-per-chapter across 15 is statistical noise; a concentrated sample on one construct is a defensible rough read. Reliability is spent where it counts — see the tier table below. |
| Familiarity cap | **40** (`FAMILIARITY_CAP`) | 5 questions ≈ rough placement, not mastery. Even 5/5 → 40, never 100. Leaves headroom that motivates study. |
| Chapter order | **`mathematics` first, then by NCEES weight desc** | Math is high-weight _and_ foundational → a fair, winnable opener. After that, importance-first means an early stop still covers the highest-impact chapters. |
| Coverage control | **System-ordered, no user chapter-pick, no swap** | Prevents self-selection away from blind spots (Dunning–Kruger). |
| Finish line | **Always visible, finite ("X / 15"), seeded after segment 1** | Goal-gradient + endowed progress drive completion; an open-ended flow does not. |
| Off-ramps | **One checkpoint per segment, default = continue** | Each stop/continue gate is an exit; minimize them while keeping autonomy. |
| Framing | **"Stop anytime — study any chapter now"** | Never imply the user is "stuck" if they stop. That's false (lessons are open) and manipulative. |
| Label | **"early read" / "familiarity", never "mastery"** | Honesty; mastery is reserved for sustained evidence over time. |

### Questions per chapter (tiered by NCEES exam weight)

Reliability is concentrated on the chapters that matter most — which are also
the ones users reach first, because the order is importance-weighted. The
heavier reads are front-loaded; the low-weight tail is lighter. **Full map = 57
questions** (was 75).

| Tier | NCEES weight | Questions | Chapters |
|---|---|---|---|
| A | ≥ 10 | **5** | mathematics, water-resources, structural, geotechnical, transportation |
| B | 6–9 | **4** | statics, mechanics-materials |
| C | ≤ 5 | **3** | construction, statistics, ethics, economics, dynamics, materials, fluid-mechanics, surveying |

The map lives in `QUESTIONS_PER_CHAPTER` in `service/routes/quickstart.js` and is
surfaced to the client via `state.nextChapterQuestions`, so the frontend never
hard-codes a count. Floor is 3; the top-five are never trimmed below 5.

### The familiarity curve

`familiarity = round((correct / total) * 40)`, capped at 40, where `total` is the
chapter's tier size. Coarser tiers give coarser reads (lower stakes, last in
order):

| total | possible familiarity values |
|---|---|
| 5 | 0 · 8 · 16 · 24 · 32 · 40 |
| 4 | 0 · 10 · 20 · 30 · 40 |
| 3 | 0 · 13 · 27 · 40 |

If a chapter bank has fewer questions than its tier, `total` is the actual count;
the ratio is unchanged.

## 5. How it integrates with existing systems

The quick-start does **not** introduce a parallel mastery store. It writes into
the same `chapterMastery` structure the old diagnostic used, so the dashboard,
readiness gauge, and focus areas keep working unchanged:

```
userStats.chapterMastery[chapterId] = {
  diagnosticScore,   // seeded by quick-start, capped at 40 (was 60 for the monolith)
  studyScore,        // raised by studying (service/routes/sessions.js)
  totalMastery,      // min(diagnosticScore + studyScore, 100)
}
userStats.quickstartSampled = [chapterId, ...]   // NEW: which chapters have a read
```

- `diagnosticScore` is written as `max(existing, newFamiliarity)` so re-sampling
  never lowers a chapter.
- `quickstartSampled` is the new bit of state that drives the "X / 15" map and
  the "next chapter" pointer. It's separate from the legacy `diagnosticCompleted`
  flag so the two models don't collide.
- Readiness (`src/data/readiness.js`) already weights chapter mastery by NCEES
  exam weight, so a partial map produces a sensible (if low) readiness number.

## 6. Files

**Backend**
- `service/routes/quickstart.js` — `GET /api/quickstart/state`,
  `GET /api/quickstart/next`, `POST /api/quickstart/submit-segment`.
- `service/db/diagnostic.js` — `getQuickstartState` / `recordQuickstartSegment`
  helpers (share the `userStats` collection).
- `service/index.js` — mounts the router at `/api/quickstart`.
- Chapter order constant `SEGMENT_ORDER` lives in `quickstart.js` (single source
  of truth for ordering; the frontend asks the backend for the next chapter).

**Frontend**
- `src/quickstart/QuickStart.jsx` + `quickstart.css` — the whole flow.
- `src/quickstart/ChapterMap.jsx` — the X/15 map visualization.
- `src/data/exam-bank/index.js` — `getExamBankForChapter()` (already exists)
  supplies the 5 questions; the frontend sorts them easy→hard and grades client-
  side, exactly as the old diagnostic did.
- `src/app.jsx` — `/quickstart` route; chrome hidden like `/diagnostic`.
- `src/dashboard/dashboard.jsx` + `src/diagnostic/DiagnosticCard.jsx` — the card
  now points at `/quickstart` and shows "Continue your map (X/15)".

## 7. The monolith

The old `/diagnostic` route and its files stay mounted (no destructive deletes,
and existing attempts still render in review) but are **no longer the primary
path** — nothing in the product links a new user to it. If we later confirm zero
traffic, it can be removed.

## 8. Known, accepted trade-offs

- **Full coverage is still longer than the old test:** 57 questions (tiered
  5/4/3) to map everything vs. the old 30 — but the old 30 was one forced
  sitting, while this is opt-in and importance-ordered. The bet: most users map
  the top 3–5 chapters (the full 5-question reads) and stop, and that partial
  map is genuinely useful.
- **Confidence vs. importance can collide:** the highest-weight chapter could be
  one a given user is weak in. Mitigated by always opening a segment with the
  easiest question and by putting `mathematics` (foundational) first.
- **5 questions is still a rough read,** which is exactly why the number is
  capped and labeled "familiarity," never "mastery."

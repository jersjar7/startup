# Product Excellence Plan

**Created:** 2026-06-01
**Goal:** Finish FE for Raccoons to a standard we are genuinely proud of — across content, logic, scoring, design, and UI/UX. This is a craft exercise, not a go-to-market sprint. Payment, pricing, and business-model work come *after* the product is excellent.

**Method:** Graded against the five quality dimensions using the actual codebase (not the older content-readiness audit). Sequenced foundation-first: correctness before intelligence before polish.

---

## Grounded findings (2026-06-01)

### Content — strong
- 990 practice problems across 4 non-overlapping pools (lesson 330, exam-bank 440, chapter-practice 220), 107 lessons, 45 subtopics, 55+ diagram components.
- Open work: a uniform problem-quality pass; deepen diagram coverage on exam-bank + chapter-practice pools; consider "select all that apply" item types for CBT realism.

### Logic — one foundational crack
- `mastery.js`: mastery levels 0–3 with 14/30-day decay — sound. (Levels 4–5 reserved.)
- `db/stats.js`: SM-2 interval logic (×2.5, cap 30 days, reset on miss) — sound.
- **DEFECT:** `routes/review.js` resolves due problems against the stale Mongo `problems` collection keyed by `_id` (ObjectId), while `problemHistory.problemId` stores client string IDs (e.g. `stat-fri-cp1`). They never match → overdue items silently drop and the queue backfills with legacy seed problems in the wrong schema (`question`/`correctAnswer` vs `statement`/`correctAnswerId`). Spaced repetition is effectively broken.
- **Tech debt:** two sources of truth — the 990 client-side problems vs the Mongo `problems` collection (`db/problems.js`, the problem-seeding half of `seed.js`).

### Scoring — tracked, partially surfaced
- Dashboard already renders: XP, day-streak, per-chapter mastery bars (% based), diagnostic-derived chapter mastery, a Daily Review CTA.
- Missing: Focus Areas (weakest chapters + "practice now"), an exam-readiness %, post-session "study next" recommendations, an at-a-glance progress summary.

### Design / UI-UX — needs a hands-on pass
- Brand system is well-defined (CLAUDE.md + brand deck). Have not yet judged the *running* app screen-by-screen against it. Pending: launch the app and audit dashboard, study, problem, lesson, exam, diagnostic, results, profile, landing.

---

## Sequenced plan (foundation → intelligence → polish)

### 1. Learning-engine foundation (LOGIC) — DONE (pending live walkthrough)
Single source of truth + working spaced repetition.
- [x] Review now resolves due problem IDs against the client-side pools via a new `src/data/problemPool.js` resolver. Backend (`routes/review.js`) returns due refs (id + topic + reason); frontend (`problems/problems.jsx`) resolves and renders with the existing problem component.
- [x] Normal-study and chapter-practice attempts both feed `problemHistory` with client IDs through `/api/sessions`; review submit credits the resolved `topicId`.
- [x] Retired the stale runtime path: deleted `service/db/problems.js`, removed its wiring from `database.js`. (Removed the unseen-backfill that pulled stale seed problems — review now surfaces only genuinely-due items, which is the correct semantics.)
- [x] Added `src/data/problemPool.test.js` (resolver regression guard). Build + 31 tests green.
- [ ] Follow-up: remove the dead `problems`-collection seeding from `service/seed.js` (keep `topics` seeding — still used for study-page video URLs).
- [x] Live walkthrough (Playwright, throwaway seeded user, 2026-06-01): study session creates `problemHistory` with client ids; due items resurface in Daily Review and render with full schema + diagram; review submit reschedules so cleared items leave the queue. Screenshots captured. Closes the render gap.

### 2. Intelligence / scoring surface (SCORING + LOGIC) — DONE
Make the app feel like a coach, building on data we now trust. Scoring uses one shared model: `src/data/readiness.js` (used by both the dashboard and the session summary).
- [x] Exam-readiness %: chapter mastery weighted by NCEES exam questions (`Σ(masteryPct × weight) / 110`), shown as a headline meter on the dashboard. Uses the existing mastery model (no parallel accuracy metric) so the product has one coherent score. Canonical weights via `getExamWeight` in `exam-bank/index.js`.
- [x] Focus Areas card: top 3 chapters by `(100 - masteryPct) × examWeight` (low mastery × high exam weight), each with a Practice action. First sidebar block; shown once the student has any activity.
- [x] Post-session "Recommended next" on the summary screen: Daily Review when items are due, else the top focus-area chapter (excluding the one just completed).
- [x] Review prominence: a "reviews due" count badge + urgency styling on the Daily Review button (new `GET /api/review/count`).
- [ ] Deferred: queue-cleared bonus XP (nice-to-have; the per-session review bonus already exists).
- Verified live (Playwright): dashboard renders readiness 29%, badge "3", Focus Areas = Transportation/Water Resources/Structural; no console errors.

### 3. Content quality + diagrams
- [ ] Uniform quality pass for difficulty balance and distractor rigor.
- [ ] Extend diagram coverage to problems that would benefit (golden rule: givens only).

### 4. Design / UI-UX polish — AUDITED (2026-06-01, Playwright)
Captured all 12 screens (landing, login, dashboard, study, lesson, problems, review, diagnostic, profile, exam, terms, privacy) at 1280px and 390px against the brand system.
- **Result:** strong overall — consistent tokens, type, radii, shadows; clean two-column → stacked responsive behavior on mobile; proper disabled/empty states. No layout breakage found.
- [x] Fixed: lesson `application` intro rendered raw LaTeX (`$F \leq \mu_s N$`) — now wrapped in `MathText` (one render site, fixes every lesson).
- [x] Fixed: stale "320+ practice problems" marketing copy (landing pricing + exam gate) → "550+" (accurate free-tier count: 330 lesson + 220 chapter practice).
- [ ] Optional later: tighten diagnostic retake copy wording; consider interactive diagram hover states (deferred — not a brand violation).

### 5. Learning-engine test coverage — DONE
- [x] Extracted the SM-2 interval rule into a pure `service/scheduling.js` (`nextInterval`) — decoupled from the DB — and covered it with `service/scheduling.test.js` (reset-on-miss, ease growth, cap).
- [x] Covered the readiness/focus scoring model with `src/data/readiness.test.js` (weighting, mastered-threshold exclusion, exclude/limit options, label tiers).
- [x] Mastery/decay (`mastery.test.js`) and review resolution (`problemPool.test.js`) already covered.
- **Suites:** root (src) 40 tests, service 59 tests — all green; build clean.

---

## Definition of done (per dimension)
- **Content:** every problem solvable to its keyed answer; balanced difficulty; pools non-overlapping (verified).
- **Logic:** one source of truth; spaced repetition demonstrably resurfaces due items; no dead/stale data paths.
- **Scoring:** a learner can see where they stand and what to do next without self-diagnosing.
- **Design/UX:** every screen matches the brand deck; complete empty/loading/error states; clean on mobile.
- **Quality:** core learning logic covered by tests.

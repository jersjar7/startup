# Persona Panel Backlog — Web + Mobile Sync

**Source:** 5-persona user study (2026-06-10). Personas: Maya (22, bus
commuter, exam in 5 weeks), Dev (26, working EIT, efficiency-obsessed), Sofia
(24, retaker, trust-focused), Jake (23, streak-driven, phone-first), Marcus
(31, returner, needs one plan). Each reviewed `sync-design.md`, the phone app
(simulator screenshots), and the live website, then a synthesis pass deduped
their flags. Spec verdicts are folded into `sync-design.md` ("Closed
questions").

## Cross-persona themes

1. **One scheduling brain or none** — web queue and phone SM-2 are two
   algorithms today; a card cleared at lunch must never be "due" that evening.
2. **The Tuesday test** — phone work must be visible on the web the same
   evening (streak, due-queue, activity line). A silent v1 was unanimously
   rejected.
3. **Fix the foundation first** — web `studyScore` is never written; syncing
   into a broken mastery model "replicates a lie to a second screen."
4. **One honest number with one name** — web "Exam Readiness / On track to
   pass" vs phone "Concept mastery" violates the North Star on the flagship
   surface.
5. **The app must already know existing users** — sign-in before the
   diagnostic, or paying users redo work and meet a zero ring.
6. **The hand-off IS the product** — without `flaggedForPaper` → web
   "Tonight" card, it's two to-do lists sharing a login.
7. **Undefined semantics are landmines** — reset, XP, streak timezone rules:
   small to specify now, catastrophic in production.

## Backlog

Status: `[ ]` open · `[x]` done · `[~]` partially done / spec'd

### P0 — must exist for sync v1 not to betray users
- [ ] **Single shared scheduler + same-day due dedupe** (large) — one
  versioned module shared web+RN; invariant: graded on A ⇒ never due on B
  same local day. Floor if it slips: cross-surface same-day dedupe.
- [x] **Fix web studyScore so studying moves mastery** (medium) — CORRECTION
  (2026-06-10): already fixed + live since 380d6c2 (2026-06-04); the panel and
  spec v1 cited a stale doc. Residual defect found and fixed: diagnostic.js
  wrote `min(diag+study,100)` vs `max(diag,study)` elsewhere — unified to max
  (one formula, matches mobile). 125/125 service tests pass.
- [ ] **Same-day web visibility of phone work** (medium) — streak ticked,
  due-count decremented, dashboard activity line. No silent v1.
- [ ] **Account-first mobile onboarding** (medium) — "Already use
  fe4raccoons.com? Sign in" on screen one; import + skip diagnostic; guest
  path stays default.
- [x] **Define Reset semantics** (small) — spec'd in sync-design.md; mobile
  button rescoped to "Reset this device" (2026-06-10).
- [x] **Sync is free, never tier-gated** (small) — closed in writing in
  sync-design.md.
- [~] **XP/leaderboard rules for phone events** (medium) — principle spec'd
  (derived, per-day caps); exact XP-per-event-type table still to write.
- [x] **Streak spec: bounded-session qualifier, localDate everywhere,
  server-computed** (small) — spec'd in sync-design.md.
- [x] **Remove pass-implying labels on web** (small) — readiness.js tiers
  renamed to mastery language (2026-06-10).

### P1 — strongly demanded, schedule next
- [ ] **Unified mastery metric** (large) — one name/formula both surfaces;
  attribution on drops. (v2 in spec.)
- [ ] **Cross-surface daily plan + paper hand-off** (large) —
  `flaggedForPaper` events; web "Tonight" card; shared daily-pace progress.
  (v2 in spec.)
- [ ] **Visible sync state + live dashboard refresh** (medium) — "last synced
  12:42 from iPhone"; /ws nudge to refetch. (v3 in spec.)
- [x] **Ask-once merge prompt for exam date + pace** (small) — spec'd in
  sync-design.md What-syncs table.
- [x] **Fix familiarity conflict-rule contradiction** (small) — keep-max,
  seed-only, with provenance; spec'd.
- [x] **Never show a bare zero with history** (small) — Today hero zero-state
  reframed honestly (2026-06-10).
- [x] **Redeploy public SEO pages with build:seo** (small, ops) — deployed +
  content-verified 2026-06-10. Correction: the panel probed /fe-civil-exam,
  which was never a prerendered route; the real routes
  (/fe-civil-exam-guide, /fe-civil/<topic>, sitemap, llms.txt) are confirmed
  serving full HTML live.

### P2 — nice
- [x] **Close pre-session pedagogy leaks in Today queue** (small) — full
  prompts + type chips were a free recognition pass; replaced with aggregate
  summary (2026-06-10).
- [ ] **Home-screen widget** (medium) — streak + countdown + due count; after
  P0 invariants exist.

## Loop log

- **Round 1 (2026-06-10):** panel ran; spec amended (scheduler unification,
  Tuesday-test v1, closed questions, reset/streak/XP semantics); quick wins
  shipped: readiness labels, reset-button scope, Today zero-state,
  pre-session leak closure. Next round: implement v0 (studyScore) + mobile
  auth screen, then re-run personas against the build.

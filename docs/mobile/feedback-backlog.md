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
- [~] **Single shared scheduler + same-day due dedupe** (large) — v1 FLOOR
  SHIPPED 2026-06-11: cross-surface same-day dedupe live both ways (phone
  events update web problemHistory; web events fold into phone schedules
  incl. sibling cards). Full single-module scheduler still future. — one
  versioned module shared web+RN; invariant: graded on A ⇒ never due on B
  same local day. Floor if it slips: cross-surface same-day dedupe.
- [x] **Fix web studyScore so studying moves mastery** (medium) — CORRECTION
  (2026-06-10): already fixed + live since 380d6c2 (2026-06-04); the panel and
  spec v1 cited a stale doc. Residual defect found and fixed: diagnostic.js
  wrote `min(diag+study,100)` vs `max(diag,study)` elsewhere — unified to max
  (one formula, matches mobile). 125/125 service tests pass.
- [x] **Same-day web visibility of phone work** (medium) — SHIPPED
  2026-06-11: 'Today on your phone: 7 cards · 4 misses · synced 11:28 AM'
  dashboard strip + streak ticks from phone events (client-localDate rule).
  Original ask — streak ticked,
  due-count decremented, dashboard activity line. No silent v1.
- [x] **Account-first mobile onboarding** (medium) — DONE 2026-06-10:
  "I already have an account" on screen one → sign-in (same account as web,
  Bearer token via SecureStore); imports server examDate + diagnostic
  familiarity (keep-max merge), shows the import confirmation, skips the
  mobile diagnostic; guest path unchanged. Server: verifyAuth accepts
  Authorization: Bearer; login returns the token only to X-Client: mobile.
  E2E-verified against the real service with the QA account. NOTE: prod
  needs a service deploy before mobile sign-in works against fe4raccoons.com.
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

## Overnight polish loop (2026-06-10/11) — CONVERGED

13 rounds of capture → 6-agent panel (5 personas + senior edu-UX expert) →
implement → deploy. High/med findings per round: 77 → 45 → 26 → 15 → 10 → 11
→ 8 → 6 → 8 → 6 → 8 → 2 → **0 (6/6 satisfied)**. Real bugs caught and fixed
along the way: clipped tab bar, collapsed 54px buttons (flexBasis), UTC
streak rollover, LaTeX escape leaks, 77 formula cards answering half their
prompt, streak self-contradictions, a study-page grid regression.

Remaining LOW items (recorded, not blocking): auto-advance the exam-date
step; web KaTeX numeric options in mono; achievements earned-check icons;
login subtitle alignment; segmented progress bar on web problems; custom
reminder time; Profile streak flame treatment; jake's web in-session XP chip
(feature). Perception note: single NBSP inside mono spans can read as a wide
gap — verified single-space in source.

## Sync v1 (2026-06-11) — LIVE
Event log (reviewEvents) + push/pull/today endpoints + web emit + phone
outbox/SyncNow shipped and deployed. E2E: phone session → automatic push →
web dashboard shows activity line, streak ticked, mastery moved. Remaining
sync layers tracked as items 6-11 in the owner's list (one mastery number,
XP table, flaggedForPaper/Tonight card, sync-state UI, merge prompt,
settings write-back).

## Deliberate punts (owner-visible)
- **Web mastery decay** (item 26): NOT implemented, on purpose. Turning on
  decay silently drops every user's numbers platform-wide; the curve needs
  owner sign-off first, and "drop attribution" (panel verdict on visible
  drops) ships with it. The scoring modal correctly never claims decay.
- **Drop attribution** ("Surveying −4%: trap missed 3×"): blocked on decay —
  mastery currently can't go down (max() formula), so there's nothing to
  attribute yet.

## Loop log

- **Round 1 (2026-06-10):** panel ran; spec amended (scheduler unification,
  Tuesday-test v1, closed questions, reset/streak/XP semantics); quick wins
  shipped: readiness labels, reset-button scope, Today zero-state,
  pre-session leak closure. Next round: implement v0 (studyScore) + mobile
  auth screen, then re-run personas against the build.

## Study-load policy (2026-06-12) — DECISIONS LOCKED, plan written
Pedagogy-vs-personas deliberation done (13 agents). Daily volume = three
streams: due reviews (never hard-capped), new learning (soft ceiling), practice
(unlimited). Replaces the exam-blind web flat-5 (review.js:46) with a
backlog-and-horizon-aware plan. Owner ruled all 6 open questions + crammer
stance (honest-but-bounded) on 2026-06-12.
- Decisions + rationale: `docs/mobile/study-load-deliberation.md` (§LOCKED DECISIONS)
- Ordered build checklist: `docs/mobile/study-load-implementation-plan.md`
- Key calls: recheck gate (NOT global decay); crude NCEES-weighted readiness;
  calibrate cards/min first; coverage-anchor projection first; ship dark +
  grandfathered. Stage 0 (shared scheduler foundation) maps to the P0 "single
  shared scheduler" item above and is in progress.

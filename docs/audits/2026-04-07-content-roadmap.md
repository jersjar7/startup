# Content & Exam Readiness Roadmap

**Created:** 2026-04-07
**Updated:** 2026-04-08
**Based on:** [Content Readiness Audit](./2026-04-07-content-readiness.md) (original score: 58/100)
**Current Score: ~70/100** (after exam-bank expansion + refactoring + chapter-practice content)
**Goal:** Reach 80+ to become a standalone exam prep tool

---

## Updated Score (Post-Refactoring)

| # | Category | Max | Was | Now | Change | Why |
|---|----------|-----|-----|-----|--------|-----|
| 1 | Topic Coverage | 15 | 15 | **15** | — | Unchanged |
| 2 | Problem Volume | 20 | 8 | **15** | +7 | 770 Qs (exceeds 3x target of 504) |
| 3 | Problem Quality | 15 | 13 | **13** | — | Unchanged |
| 4 | Visual Aids | 10 | 9 | **9** | — | Unchanged |
| 5 | Adaptive Learning | 15 | 4 | **4** | — | Unchanged |
| 6 | Exam Simulation | 10 | 4 | **7** | +3 | 410 unique sim Qs = 3+ unique exams |
| 7 | Retention / SR | 10 | 5 | **5** | — | Unchanged |
| 8 | Analytics | 5 | 0 | **0** | — | Unchanged |
| | **TOTAL** | **100** | **58** | **68** | **+10** | |

### What's left to reach 80 (+12 more points needed)

| Improvement | Score Impact | Effort |
|-------------|-------------|--------|
| Write 220 chapter practice Qs | +2 (Volume 15 -> 17) | High (content) |
| Dashboard weakness targeting | +4 (Adaptive 4 -> 8) | Medium (code) |
| Review system fix + prominence | +3 (Retention 5 -> 8) | Medium (code) |
| Student analytics on dashboard | +3 (Analytics 0 -> 3) | Medium (code) |
| **Total** | **+12 (68 -> 80)** | |

---

## Completed Work

### Phase 1A: Exam Problem Expansion (COMPLETE)

440 exam-bank problems added across all 15 chapters (4 per lesson x 110 lessons). These live in `src/data/exam-bank/` as a dedicated pool.

| Chapter | Lesson Practice | Exam Bank | Total |
|---------|----------------|-----------|-------|
| Mathematics | 39 | 52 | 91 |
| Statistics | 18 | 24 | 42 |
| Ethics | 15 | 20 | 35 |
| Economics | 15 | 20 | 35 |
| Statics | 18 | 24 | 42 |
| Dynamics | 18 | 24 | 42 |
| Mechanics of Materials | 24 | 32 | 56 |
| Materials | 21 | 28 | 49 |
| Fluid Mechanics | 24 | 32 | 56 |
| Surveying | 21 | 28 | 49 |
| Water Resources | 24 | 32 | 56 |
| Structural | 24 | 32 | 56 |
| Geotechnical | 24 | 32 | 56 |
| Transportation | 24 | 32 | 56 |
| Construction | 21 | 28 | 49 |
| **Total** | **330** | **440** | **770** |

### Phase 1B: Question Bank Refactoring (COMPLETE)

4 non-overlapping question pools:

- **Pool 1: Lesson Practice** — 330 Qs (3/lesson) in lesson files
- **Pool 2: Chapter Practice** — 0/220 Qs (skeletons in `src/data/chapter-practice/`)
- **Pool 3: Diagnostic** — 30 fixed Qs (`src/data/exam-bank/diagnostic-ids.js`)
- **Pool 4: 110-Q Simulation** — ~410 Qs (remaining exam-bank, diagnostic excluded)

- [x] Created `src/data/exam-bank/` (15 chapter files + index + diagnostic IDs)
- [x] Removed `examProblems` from all 110 lesson files
- [x] Simplified `src/data/lessons/index.js` (only LESSONS + getLessonById)
- [x] Created `src/data/chapter-practice/` (15 empty skeleton files)
- [x] DiagnosticExam uses fixed 30-question set with shuffle
- [x] ExamSession imports from exam-bank
- [x] problems.jsx loads chapter practice from client-side data
- [x] study.jsx uses client-side problem count
- [x] Removed dead `GET /:topicId/problems` backend endpoint

---

## Remaining Work (Ordered by Priority)

### Phase 2: Chapter Practice Content (+2 pts, HIGH priority) — COMPLETE

**Why first:** The "Practice All" button on every chapter page previously showed "Coming Soon." This was the most visible broken experience for users. Pure content work — no code changes needed, infrastructure was ready.

**Deliverable (done):** 220 questions (2 per lesson) populate `src/data/chapter-practice/`. Authored and adversarially verified (every problem independently re-solved; answers, distractor rationales, and pool-overlap checked). Total problem count is now **990**. Each chapter-practice problem is distinct from the lesson-practice and exam-bank pools — verified zero ID collisions and no scenario overlap.

| Chapter | Target | Chapter | Target |
|---------|--------|---------|--------|
| Mathematics | 26 | Surveying | 14 |
| Statistics | 12 | Water Resources | 16 |
| Ethics | 10 | Structural | 16 |
| Economics | 10 | Geotechnical | 16 |
| Statics | 12 | Transportation | 16 |
| Dynamics | 12 | Construction | 14 |
| Mechanics of Materials | 16 | | |
| Materials | 14 | **Total** | **220** |
| Fluid Mechanics | 16 | | |

**How:** Use the `fe-lesson-content` skill pipeline. Batch 2-3 chapters per session.

**After completion:** Total problem count reaches 990. Competitive with PrepFE (700+), approaching PPI2Pass (1000+). Score: Problem Volume 15 -> 17.

---

### Phase 3: Dashboard Intelligence (+7 pts, HIGH priority)

**Why second:** This is the biggest single score improvement. The audit's two harshest gaps are "platform doesn't guide students to weak areas" (Adaptive 4/15) and "no student-facing analytics" (Analytics 0/5). These are really one feature: show useful data on the dashboard and act on it.

**Score impact:** Adaptive Learning 4 -> 8 (+4), Analytics 0 -> 3 (+3)

#### 3A: Per-Chapter Strength Bars on Dashboard
The backend already tracks `topicProgress[chapterId].attempted`, `.correct`, `.masteryLevel` per user. Surface this on the dashboard chapter list.

- [ ] Add accuracy ring or bar to each chapter card (correct/attempted)
- [ ] Color-code: green (80%+), yellow (50-80%), red (below 50%), gray (no data)
- [ ] Show mastery level (0-3) as a small label or fill indicator

**Effort:** Low. Data already exists in `/api/topics` response. Frontend-only change.

#### 3B: Focus Areas Section
- [ ] Compute weakness score: `(1 - accuracy) * NCEES_weight` per chapter
- [ ] Show "Focus Areas" card on dashboard with top 3 weakest chapters
- [ ] Each focus area has a "Practice Now" button linking to chapter practice or lesson
- [ ] Only show after student has attempted at least 10 problems total

**Effort:** Low-medium. Computation is client-side from existing API data.

#### 3C: Post-Session Recommendations
- [ ] After finishing a chapter practice or review session, show which topic to study next
- [ ] Logic: recommend the chapter with lowest accuracy that has available problems
- [ ] Add "Recommended Next" card to session summary screen

**Effort:** Low. Frontend-only, uses same weakness computation.

#### 3D: Progress Summary Section
- [ ] Add collapsible "Your Progress" section to dashboard (or separate tab)
- [ ] Show: total problems attempted, overall accuracy %, chapters at mastery 2+
- [ ] Show: XP earned this week, current streak, estimated exam readiness %
- [ ] Exam readiness = percentage of chapters where accuracy >= 70% and mastery >= 2

**Effort:** Medium. Mostly frontend, but may need a new API endpoint to aggregate stats efficiently.

---

### Phase 4: Review System Repair & Prominence (+3 pts, MEDIUM priority)

**Why third:** The review system exists but has two problems: (1) it pulls from 60 stale MongoDB seed problems that don't match current content, and (2) it's not visible enough on the dashboard. Must fix the data source before making it more prominent.

**Score impact:** Retention & Spaced Repetition 5 -> 8 (+3)

#### 4A: Fix the Review Data Source (CRITICAL prerequisite)
The review route (`/api/review`) calls `DB.getAllProblemsForTopics()` which reads from the `problems` MongoDB collection — 60 seed problems from 6 chapters with the wrong schema (`question`/`correctAnswer` labels instead of `statement`/`correctAnswerId`). These don't match the 770 client-side problems.

**Options (pick one):**
- [ ] **Option A (recommended):** Migrate review to use client-side data. The review queue (`problemHistory` collection) tracks which problem IDs are due. The frontend can resolve those IDs against the local exam-bank + chapter-practice pools. Backend only returns the due problem IDs, frontend renders them.
- [ ] **Option B:** Re-seed MongoDB with current exam-bank problems. Simpler backend, but creates a sync problem (two sources of truth).
- [ ] **Option C:** Drop MongoDB review entirely, build a client-side SM-2 system that stores intervals in `localStorage` or the existing `progress` collection.

**Effort:** Medium. The SM-2 interval logic in `db/stats.js` is solid — just the problem lookup is broken.

#### 4B: Review Prominence on Dashboard
- [ ] Show review count badge: "X reviews due" with color urgency
- [ ] Add "Start Review" CTA button on dashboard when reviews are due
- [ ] Add bonus XP for clearing entire review queue (e.g., +20 XP "Queue Cleared" bonus)

**Effort:** Low (once 4A is done).

#### 4C: Email Reminders (Optional, stretch)
- [ ] Send reminder emails when review queue exceeds 15 items (Resend already set up)
- [ ] Weekly digest email: "You have X reviews due, your streak is Y days"

**Effort:** Medium. Email templates + cron job or scheduled function.

---

### Phase 5: Timed Chapter Drills (+1-2 pts, LOW priority)

**Why last:** The chapter practice infrastructure already exists. Adding a timer is a small UI enhancement, not a new feature. The audit's deduction was "-3: no topic-specific timed drills" — but once chapter practice has content (Phase 2), this is 80% solved. A timer just makes it exam-realistic.

**Score impact:** Exam Simulation 7 -> 8 or 9 (+1-2)

- [ ] Add optional "Timed Mode" toggle to chapter practice session
- [ ] Timer: 2.91 min/question (FE exam pace), shown in top bar
- [ ] Show pace comparison in session summary: "You averaged 2.1 min/question (under the 2.91 min target)"
- [ ] Track drill history: timestamp, chapter, score, average time per question
- [ ] Show improvement trend on chapter page: "Your last 3 drill scores: 60%, 70%, 80%"

**Effort:** Low-medium. Timer UI can reuse the DiagnosticExam/ExamSession timer component. History needs a new API endpoint.

---

## Critical Path to 80

```
Phase 2 (Chapter Practice Content)  → 70/100  (+2)  ✓ DONE — current

Phase 3 (Dashboard Intelligence)    → 77/100  (+7)  ← next
Phase 4 (Review Repair + Prominence)→ 80/100  (+3)
─────────────────────────────────────────────
Phase 5 (Timed Drills)              → 81/100  (+1)  ← nice to have
```

Phases 2 and 3 can overlap — write content in batches while building dashboard features between sessions. Phase 4 is a prerequisite blocker only for its own sub-items (4B/4C depend on 4A).

---

## Known Technical Debt

These aren't scored in the audit but will bite you eventually:

1. **Review system data mismatch** — `problems` MongoDB collection has 60 stale seed problems. Review route depends on it. Must fix before review system is useful (tracked in Phase 4A).

2. **`service/seed.js`** — 1000-line seed script that populates the stale `problems` and `topics` collections. Can be deleted once review is migrated off MongoDB problems. The `topics` collection is still used by the study page for video URLs.

3. **`service/db/problems.js`** — Only exists for the review route. Delete after Phase 4A.

4. **Competitive comparison table** — The audit shows "Problem count: 321" but it's now 770 (990 after chapter practice). Update the audit doc when you want to use those numbers for marketing.

---

## Progress

| Phase | Score Impact | Status |
|-------|-------------|--------|
| 1A — Exam Problem Expansion | 58 -> 68 (+10) | Complete |
| 1B — Question Bank Refactoring | (infra, no score) | Complete |
| 2 — Chapter Practice Content | 68 -> 70 (+2) | Complete |
| 3 — Dashboard Intelligence | 70 -> 77 (+7) | Not started |
| 4 — Review Repair + Prominence | 77 -> 80 (+3) | Not started |
| 5 — Timed Drills | 80 -> 81 (+1) | Not started |

# Content & Exam Readiness Roadmap

**Created:** 2026-04-07
**Updated:** 2026-04-08
**Based on:** [Content Readiness Audit](./2026-04-07-content-readiness.md) (score: 58/100)
**Goal:** Raise the platform from "solid study supplement" (58) to "standalone exam prep tool" (80+)

---

## Phase 1 — Problem Volume Expansion & Question Bank Refactoring

### 1A: Exam Problem Expansion (COMPLETE)

440 exam-bank problems added across all 15 chapters (4 per lesson x 110 lessons). These now live in `src/data/exam-bank/` as a dedicated pool, separate from the 330 lesson practice problems.

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

### 1B: Question Bank Refactoring (COMPLETE)

Separated questions into 4 non-overlapping pools:

- **Pool 1: Lesson Practice** — 330 Qs (3/lesson) — stays in lesson files
- **Pool 2: Chapter Practice** — 0/220 Qs (skeleton files created, content TBD)
- **Pool 3: Diagnostic** — 30 fixed Qs — hand-picked in `src/data/exam-bank/diagnostic-ids.js`
- **Pool 4: 110-Q Simulation** — ~410 Qs — remaining exam-bank questions

Key changes:
- [x] Created `src/data/exam-bank/` with 15 chapter files + index + diagnostic IDs
- [x] Removed `examProblems` from all 110 lesson files
- [x] Simplified `src/data/lessons/index.js` (only LESSONS + getLessonById)
- [x] Created `src/data/chapter-practice/` with 15 empty skeleton files
- [x] Updated DiagnosticExam to use fixed 30-question set
- [x] Updated ExamSession to import from exam-bank
- [x] Updated problems.jsx to load chapter practice from client-side data
- [x] Updated study.jsx to use client-side problem count
- [x] Removed dead `GET /:topicId/problems` backend endpoint

### 1C: Chapter Practice Content (NOT STARTED)

Write 220 chapter practice questions (2 per lesson) to populate `src/data/chapter-practice/`. Use the `fe-lesson-content` skill pipeline.

| Chapter | Target Qs | Status |
|---------|-----------|--------|
| Mathematics | 26 | Not started |
| Statistics | 12 | Not started |
| Ethics | 10 | Not started |
| Economics | 10 | Not started |
| Statics | 12 | Not started |
| Dynamics | 12 | Not started |
| Mechanics of Materials | 16 | Not started |
| Materials | 14 | Not started |
| Fluid Mechanics | 16 | Not started |
| Surveying | 14 | Not started |
| Water Resources | 16 | Not started |
| Structural | 16 | Not started |
| Geotechnical | 16 | Not started |
| Transportation | 16 | Not started |
| Construction | 14 | Not started |
| **Total** | **220** | |

---

## Phase 2 — Weakness Targeting & Study Recommendations (4 -> 10 pts, +6)

Build intelligence that guides students to their weak areas instead of requiring self-diagnosis.

- [ ] Add per-chapter accuracy tracking: store correct/incorrect counts per chapter in the progress collection
- [ ] Compute weakness score: chapters with low accuracy + low mastery = high priority
- [ ] Add "Focus Areas" section to dashboard: show top 3 weakest chapters with "Practice Now" buttons
- [ ] Add post-session summary: "You got 2/5 in Fluids — we recommend reviewing Bernoulli's Equation"
- [ ] Add "Recommended Next" suggestion after completing a lesson: steer toward weak areas
- [ ] Add visual strength/weakness indicator on the chapter list (color-coded bars or rings)

---

## Phase 3 — Student Analytics Dashboard (0 -> 4 pts, +4)

Give students visibility into their own progress data.

- [ ] Create `/analytics` page (or section on dashboard)
- [ ] Show accuracy rate by chapter (bar chart or table)
- [ ] Show mastery level breakdown: how many lessons at each mastery level (0-3)
- [ ] Show study streak history and total XP earned
- [ ] Show time-based progress: problems solved per week over the last 4 weeks
- [ ] Show estimated exam readiness: percentage of chapters at mastery level 2+

---

## Phase 4 — Topic-Specific Timed Drills (4 -> 7 pts, +3)

Add focused practice sessions beyond full exam simulation.

- [ ] Add "Quick Drill" mode: 10-20 questions from a single chapter, timed
- [ ] Calculate time per question based on FE exam pacing (~3 min/question)
- [ ] Show drill results: score, time, comparison to target pace
- [ ] Add drill history so students can track improvement over time
- [ ] Consider making drills free (they drive engagement) while keeping full exam behind paywall

---

## Phase 5 — Review Queue Prominence & Reminders (5 -> 8 pts, +3)

Surface the existing SM-2 spaced repetition system more effectively.

- [ ] Add review count badge to dashboard: "12 reviews due" with visual urgency (green < 5, yellow 5-15, red 15+)
- [ ] Add review count to nav bar or sidebar so it's always visible
- [ ] Add bonus XP for clearing review queue (gamification incentive)
- [ ] Add email reminders for overdue reviews (requires email service — already set up via Resend)
- [ ] Add "Start Review Session" CTA on dashboard when reviews are due

---

## Progress

| Phase | Status |
|-------|--------|
| 1A — Exam Problem Expansion (440 Qs) | Complete |
| 1B — Question Bank Refactoring | Complete |
| 1C — Chapter Practice Content (220 Qs) | Not started |
| 2 — Weakness Targeting | Not started |
| 3 — Analytics Dashboard | Not started |
| 4 — Timed Drills | Not started |
| 5 — Review Prominence | Not started |

---

## Execution Notes

- **Phase 1C is the next big lift** — 220 new chapter practice problems. Batch using the `fe-lesson-content` skill pipeline.
- **Phase 2 depends on Phase 1C** somewhat — weakness targeting is more useful with chapter practice content to draw from.
- **Phases 3-5 are independent** — can be built in any order or in parallel.
- **Phase 5 is lowest effort, highest per-item impact** — could be done first for a quick win.
- Each item gets marked `[x]` with completion date when done.

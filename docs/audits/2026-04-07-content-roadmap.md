# Content & Exam Readiness Roadmap

**Created:** 2026-04-07
**Based on:** [Content Readiness Audit](./2026-04-07-content-readiness.md) (score: 58/100)
**Goal:** Raise the platform from "solid study supplement" (58) to "standalone exam prep tool" (80+)

---

## Phase 1 — Problem Volume Expansion (8 → 14 pts, +6)

Double the problem pool from 321 to 640+. Prioritize chapters with the highest NCEES exam weight first.

| Priority | Chapter | Current | Target | To Add |
|----------|---------|---------|--------|--------|
| 1 | Mathematics | 39 | 78 | 39 |
| 2 | Statics | 18 | 36 | 18 |
| 3 | Mechanics of Materials | 24 | 48 | 24 |
| 4 | Fluid Mechanics | 24 | 48 | 24 |
| 5 | Structural | 24 | 48 | 24 |
| 6 | Geotechnical | 24 | 48 | 24 |
| 7 | Dynamics | 18 | 36 | 18 |
| 8 | Water Resources | 24 | 48 | 24 |
| 9 | Surveying | 21 | 42 | 21 |
| 10 | Transportation | 24 | 48 | 24 |
| 11 | Construction | 21 | 42 | 21 |
| 12 | Materials Science | 21 | 42 | 21 |
| 13 | Statistics | 18 | 36 | 18 |
| 14 | Economics | 15 | 30 | 15 |
| 15 | Ethics | 15 | 30 | 15 |
| | **Total** | **330** | **660** | **330** |

### Guidelines
- [ ] New problems follow the same data model (id, statement, options, correctIndex, solution, eli5, commonTraps, difficulty, handbookRef)
- [ ] Each chapter should have a balanced difficulty mix: ~30% easy, ~50% medium, ~20% hard
- [ ] Add more hard problems — current pool skews easy/medium
- [ ] New problems should cover edge cases and common exam traps not yet represented
- [ ] Wire diagrams to any new problem that benefits from visualization

---

## Phase 2 — Weakness Targeting & Study Recommendations (4 → 10 pts, +6)

Build intelligence that guides students to their weak areas instead of requiring self-diagnosis.

- [ ] Add per-chapter accuracy tracking: store correct/incorrect counts per chapter in the progress collection
- [ ] Compute weakness score: chapters with low accuracy + low mastery = high priority
- [ ] Add "Focus Areas" section to dashboard: show top 3 weakest chapters with "Practice Now" buttons
- [ ] Add post-session summary: "You got 2/5 in Fluids — we recommend reviewing Bernoulli's Equation"
- [ ] Add "Recommended Next" suggestion after completing a lesson: steer toward weak areas
- [ ] Add visual strength/weakness indicator on the chapter list (color-coded bars or rings)

---

## Phase 3 — Student Analytics Dashboard (0 → 4 pts, +4)

Give students visibility into their own progress data.

- [ ] Create `/analytics` page (or section on dashboard)
- [ ] Show accuracy rate by chapter (bar chart or table)
- [ ] Show mastery level breakdown: how many lessons at each mastery level (0-3)
- [ ] Show study streak history and total XP earned
- [ ] Show time-based progress: problems solved per week over the last 4 weeks
- [ ] Show estimated exam readiness: percentage of chapters at mastery level 2+

---

## Phase 4 — Topic-Specific Timed Drills (4 → 7 pts, +3)

Add focused practice sessions beyond full exam simulation.

- [ ] Add "Quick Drill" mode: 10-20 questions from a single chapter, timed
- [ ] Calculate time per question based on FE exam pacing (~3 min/question)
- [ ] Show drill results: score, time, comparison to target pace
- [ ] Add drill history so students can track improvement over time
- [ ] Consider making drills free (they drive engagement) while keeping full exam behind paywall

---

## Phase 5 — Review Queue Prominence & Reminders (5 → 8 pts, +3)

Surface the existing SM-2 spaced repetition system more effectively.

- [ ] Add review count badge to dashboard: "12 reviews due" with visual urgency (green < 5, yellow 5-15, red 15+)
- [ ] Add review count to nav bar or sidebar so it's always visible
- [ ] Add bonus XP for clearing review queue (gamification incentive)
- [ ] Add email reminders for overdue reviews (requires email service — already set up via Resend)
- [ ] Add "Start Review Session" CTA on dashboard when reviews are due

---

## Progress

| Phase | Items | Done | Score Impact | Status |
|-------|-------|------|-------------|--------|
| 1 — Problem Volume | 330 problems | 0 | 8 → 14 (+6) | Not started |
| 2 — Weakness Targeting | 6 | 0 | 4 → 10 (+6) | Not started |
| 3 — Analytics Dashboard | 6 | 0 | 0 → 4 (+4) | Not started |
| 4 — Timed Drills | 5 | 0 | 4 → 7 (+3) | Not started |
| 5 — Review Prominence | 5 | 0 | 5 → 8 (+3) | Not started |
| **Total** | **352** | **0** | **58 → 80 (+22)** | |

---

## Execution Notes

- **Phase 1 is the biggest lift** — 330 new problems. Consider batching: 2-3 chapters per session using the existing `fe-lesson-content` skill pipeline.
- **Phase 2 depends on Phase 1** somewhat — weakness targeting is more useful with a larger problem pool to draw from.
- **Phases 3-5 are independent** — can be built in any order or in parallel.
- **Phase 5 is lowest effort, highest per-item impact** — could be done first for a quick win.
- Each item gets marked `[x]` with completion date when done.

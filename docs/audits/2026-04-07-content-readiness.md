# FE for Raccoons — Content & Exam Readiness Audit

**Date:** 2026-04-07
**Scope:** How well does the platform prepare students to pass the FE Civil exam?
**Overall Score: 58 / 100**

---

## Score Summary

| # | Category | Max | Score |
|---|----------|-----|-------|
| 1 | Topic Coverage | 15 | **15** |
| 2 | Problem Volume | 20 | **8** |
| 3 | Problem Quality & Realism | 15 | **13** |
| 4 | Visual Aids (Diagrams) | 10 | **9** |
| 5 | Adaptive Learning | 15 | **4** |
| 6 | Exam Simulation | 10 | **4** |
| 7 | Retention & Spaced Repetition | 10 | **5** |
| 8 | Analytics & Weakness Targeting | 5 | **0** |
| | **TOTAL** | **100** | **58** |

---

## Detailed Scores

### 1. Topic Coverage (15 / 15)

All 15 FE Civil exam sections are covered with 107 lessons across 45 subtopics. Every NCEES specification topic has at least one lesson. This matches or exceeds what most paid prep platforms offer in breadth.

| Metric | Value |
|--------|-------|
| Chapters | 15 / 15 |
| Lessons | 107 |
| Subtopics | 45 |
| Handbook references | Present on most problems |

### 2. Problem Volume (8 / 20)

321 problems across 15 chapters averages ~21 per chapter. The real FE exam has 110 questions. To build fluency, students need 3-5x the exam question count per topic area. Competitors like PPI2Pass offer 700-1000+ problems.

| Chapter | Problems | Target (3x) | Gap |
|---------|----------|-------------|-----|
| Mathematics | 39 | 60 | -21 |
| Statistics | 18 | 30 | -12 |
| Ethics | 15 | 24 | -9 |
| Economics | 15 | 24 | -9 |
| Statics | 18 | 30 | -12 |
| Dynamics | 18 | 30 | -12 |
| Mechanics of Materials | 24 | 36 | -12 |
| Materials Science | 21 | 30 | -9 |
| Fluid Mechanics | 24 | 36 | -12 |
| Surveying | 21 | 30 | -9 |
| Water Resources | 24 | 36 | -12 |
| Structural | 24 | 36 | -12 |
| Geotechnical | 24 | 36 | -12 |
| Transportation | 24 | 36 | -12 |
| Construction | 21 | 30 | -9 |
| **Total** | **321** | **504** | **-183** |

To reach the 3x target: **183 more problems needed.**
To reach 5x (competitive with paid platforms): **489 more problems.**

### 3. Problem Quality & Realism (13 / 15)

Problems closely mirror FE exam format: multiple-choice, computational with distractor choices based on common errors, and conceptual questions testing understanding. Each problem includes:

- Step-by-step solution
- ELI5 explanation
- Common traps/pitfalls
- Handbook page reference (when applicable)
- Difficulty rating (easy/medium/hard)

**Deductions:**
- -1: Some problems are slightly too straightforward for exam prep (easy problems dominate in some chapters)
- -1: No "select all that apply" or "fill-in" question types (though the real FE is primarily multiple-choice, the CBT format occasionally uses other types)

### 4. Visual Aids / Diagrams (9 / 10)

All 15 chapters have been audited for diagram needs. Every problem where a student benefits from visualizing a physical setup has an SVG diagram. Diagrams follow the golden rule: show only given values, never derived answers.

| Stat | Value |
|------|-------|
| Diagram components built | 55+ unique components |
| Problems with diagrams | ~80 problems |
| Chapters fully audited | 15 / 15 |
| Primitives library | Comprehensive (supports, arrows, dimensions, labels, angles) |

**Deduction:**
- -1: No interactive diagrams (e.g., drag to explore, hover for values). All diagrams are static SVGs. Interactive elements would deepen understanding for visual learners.

### 5. Adaptive Learning (4 / 15)

The platform tracks mastery levels (0-3) per lesson with decay, but does not use this data to guide the student's study path. Current state:

| Feature | Status |
|---------|--------|
| Mastery tracking per lesson | Yes (levels 0-3 with 14/30-day decay) |
| Spaced repetition intervals | Yes (SM-2 variant, review queue) |
| Difficulty-adaptive problem selection | No |
| Weakness-targeting recommendations | No |
| Personalized study plan | No |
| "You should review X" nudges | No |
| Smart problem ordering within lessons | No |

The SM-2 review system exists and works, but the platform never says "you're weak in Fluids, focus there." Students must self-diagnose.

### 6. Exam Simulation (4 / 10)

A 110-question timed exam simulation exists behind a Stripe paywall. This is a strong feature, but:

| Feature | Status |
|---------|--------|
| 110-question timed exam | Yes |
| Weighted topic distribution matching NCEES | Yes |
| Score breakdown by chapter | Yes |
| Multiple unique exam variants | Limited (draws from 321-problem pool) |
| Section-by-section timed drills | No |
| Performance comparison to passing threshold | No |
| Post-exam detailed review | Partial |

**Deductions:**
- -3: With only 321 total problems, exam simulations will repeat questions after 2-3 attempts. Students who memorize answers instead of learning concepts won't be caught.
- -3: No topic-specific timed drills (e.g., "20 Statics questions in 25 minutes") for targeted practice.

### 7. Retention & Spaced Repetition (5 / 10)

The SM-2 review queue exists and functions. However:

| Feature | Status |
|---------|--------|
| Review queue with overdue ordering | Yes |
| Interval adjustment on correct/incorrect | Yes |
| Visual indicator of due reviews on dashboard | No dedicated count |
| Push/email reminders for due reviews | No |
| Review session gamification (bonus XP for clearing queue) | No |
| Interleaving (mix topics in review) | Yes (inherent in queue) |

**Deductions:**
- -3: No notification or reminder system. If a student doesn't log in, their review queue grows silently.
- -2: Review queue exists but isn't prominently surfaced. Students may not realize they have overdue reviews.

### 8. Analytics & Weakness Targeting (0 / 5)

No student-facing analytics exist. Students cannot see:

- Which chapters they're strongest/weakest in
- Their accuracy rate by topic
- Time spent per chapter
- Progress toward exam readiness
- Comparison to other students' performance

---

## Competitive Comparison

| Feature | FE for Raccoons | PPI2Pass ($300) | PrepFE ($200) | School of PE ($500) |
|---------|----------------|-----------------|---------------|---------------------|
| Price | $5-10 | $300 | $200 | $500 |
| Problem count | 321 | 1000+ | 700+ | 800+ |
| All 15 topics | Yes | Yes | Yes | Yes |
| Step-by-step solutions | Yes | Yes | Partial | Yes |
| Gamification | Yes (XP, streaks, badges) | No | No | No |
| Diagrams | 55+ custom SVGs | Static images | Static images | Video-based |
| Spaced repetition | Yes (SM-2) | No | No | No |
| Mobile-friendly | Yes | Partial | Yes | No |
| Exam simulation | Yes (110Q timed) | Yes | Yes | Yes |
| Video lessons | No | Yes | No | Yes |
| Adaptive difficulty | No | No | No | No |

**Key insight:** FE for Raccoons offers unique advantages (gamification, spaced repetition, custom diagrams, mobile UX) at 1/30th the price of competitors. The gap is problem volume and study analytics.

---

## What Would Get This to 80/100

| Improvement | Current → Target | Points Gained |
|-------------|-----------------|---------------|
| Double problem count to 640+ | 8 → 14 | +6 |
| Add weakness-targeting study recommendations | 4 → 10 | +6 |
| Add student analytics dashboard | 0 → 4 | +4 |
| Add topic-specific timed drills | 4 → 7 | +3 |
| Add review queue prominence + reminders | 5 → 8 | +3 |
| **Total** | **58 → 80** | **+22** |

---

## Bottom Line

FE for Raccoons is a **solid 58/100** — genuinely useful as a study supplement today. The core learning mechanics (bite-sized lessons, immediate feedback, spaced repetition, diagrams) are better than most competitors. The gaps are in volume (need 2x more problems), intelligence (platform doesn't guide students to their weak areas), and visibility (students can't see their own progress data).

At $5-10, it's an exceptional value. To become a standalone "this is all you need to pass" tool, it needs to reach 80+ through more problems and smarter study guidance.

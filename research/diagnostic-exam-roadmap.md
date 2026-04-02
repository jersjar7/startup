# Diagnostic Exam & Question Bank Expansion — Implementation Roadmap

> **Status:** In Progress
> **Delete this file when fully implemented.**
> **Reference:** `research/civil/fe-civil-exam-topics.md` for chapter/lesson mapping.
> **Reference:** `research/civil/references/ncees-practice-exam-parsed.txt` for question style guide.

---

## Overview

Three connected features to build:

1. **Expanded Question Bank** — 4 `examProblems` per lesson (428 new questions)
2. **Diagnostic Exam** — 30-question timed assessment for new users
3. **Dashboard Integration** — mastery bar seeding, color coding, study prioritization

---

## Phase 1: Data Model Changes

### 1.1 Add `examProblems` array to lesson objects

Each lesson currently has a `problems` array with 3 items. Add a sibling `examProblems` array with 4 items.

**File pattern:** `src/data/lessons/<chapter>/<lesson>.js`

```js
export default {
  id: 'horizontal-curves',
  name: 'Horizontal Curves',
  // ... existing fields ...
  problems: [ /* existing 3 lesson problems — unchanged */ ],
  examProblems: [
    {
      // Same schema as problem objects
      id: 'trans-hc-ex1',
      type: 'computational',  // NEW FIELD: 'computational' | 'conceptual'
      statement: '...',
      choices: [{ id: 'c1', text: '...' }, ...],
      correctAnswerId: 'c1',
      difficulty: 'medium',
      eli5: '...',
      hint: '...',
      steps: [{ text: '...', latex: null }],
      handbookPage: 'p. 302',
      handbookFormula: '...',
      videoUrl: null,
      traps: ['...'],
      diagram: null,
    },
    // ... 3 more exam problems
  ],
};
```

**New field on problem objects:** `type: 'computational' | 'conceptual'`
- Added to examProblems only (existing lesson problems don't need it)
- Used by the diagnostic to ensure a balanced mix per chapter

**ID convention for exam problems:** `<chapter-abbrev>-<lesson-abbrev>-ex<N>`
- Example: `trans-hc-ex1`, `trans-hc-ex2`, `stat-ct-ex1`
- Distinguishes from lesson problems which use `-q<N>` suffix

### 1.2 Update `getLessonById` and lesson utilities

**File:** `src/data/lessons/index.js`

No changes needed to existing functions — `examProblems` is a new field that existing code won't touch. New code will access it directly.

Add a new utility function:

```js
export function getExamProblemsForChapter(chapterId) {
  const chapter = LESSONS[chapterId];
  if (!chapter) return [];
  const problems = [];
  for (const subtopic of chapter) {
    for (const lesson of subtopic.lessons) {
      if (lesson.examProblems) {
        problems.push(...lesson.examProblems.map(p => ({
          ...p,
          lessonId: lesson.id,
          subtopicId: subtopic.subtopicId,
          chapterId,
        })));
      }
    }
  }
  return problems;
}
```

### 1.3 Backend: Diagnostic results storage

**Collection:** `diagnosticResults` (new collection in MongoDB)

```js
{
  userId: ObjectId,
  attemptNumber: 1,          // increments on retake
  startedAt: ISODate,
  completedAt: ISODate,
  timeUsedSeconds: 4200,     // actual time spent
  timeLimitSeconds: 5238,    // 30 × 174.6s (2.91 min)
  questions: [
    {
      questionId: 'math-slq-ex1',
      chapterId: 'mathematics',
      lessonId: 'straight-lines-quadratics',
      type: 'computational',
      selectedAnswerId: 'c3',   // null if skipped
      correctAnswerId: 'c1',
      isCorrect: false,
      timeSpentSeconds: 145,
    },
    // ... 29 more
  ],
  chapterScores: {
    mathematics: { correct: 1, total: 2, masterySeeded: 30 },
    statistics: { correct: 2, total: 2, masterySeeded: 60 },
    // ... all 15 chapters
  },
  totalCorrect: 18,
  totalQuestions: 30,
  xpEarned: 440,  // 30×10 + 18×5
}
```

### 1.4 Backend: Update progress/mastery model

**Collection:** `progress` (existing — add diagnostic mastery fields)

Add to user's progress document:

```js
{
  userId: ObjectId,
  // ... existing fields ...
  diagnosticCompleted: true,
  diagnosticAttempts: 1,
  chapterMastery: {
    mathematics: {
      diagnosticScore: 30,       // from diagnostic (0, 30, or 60)
      studyScore: 25,            // from lesson completion + practice
      totalMastery: 55,          // diagnosticScore + studyScore (capped at 100)
    },
    // ... all 15 chapters
  },
}
```

**Mastery calculation:**

```
totalMastery = min(diagnosticScore + studyScore, 100)

Where:
  diagnosticScore = (correctInChapter / totalInChapter) × 60   // capped at 60
  studyScore = (lessonsCompleted / totalLessonsInChapter) × 40  // capped at 40
    - A lesson counts as "completed" when content is read AND ≥2/3 problems correct
```

If diagnostic not taken: `diagnosticScore = 0`, `studyScore` scales to fill full 100%.

```
studyScore (no diagnostic) = (lessonsCompleted / totalLessonsInChapter) × 100
```

---

## Phase 2: Write the 428 Exam-Pool Questions

### 2.1 Question writing approach

- Use `research/civil/references/ncees-practice-exam-parsed.txt` as a **style and difficulty guide**
- Write 100% original questions — never copy NCEES stems, numbers, or answer choices
- Each question follows the existing problem object schema + new `type` field
- Each lesson gets exactly 4 examProblems

### 2.2 Conceptual/computational mix by chapter type

| Chapter Type | Chapters | Mix per Lesson |
|---|---|---|
| Formula-heavy | Math, Statics, Dynamics, MoM, Fluids, Economics, Surveying | 3 computational + 1 conceptual |
| Balanced | Transportation, Geotech, Structural, Water Resources | 2 computational + 2 conceptual |
| Concept-heavy | Materials, Construction | 1 computational + 3 conceptual |
| All conceptual | Ethics | 0 computational + 4 conceptual |

### 2.3 Conceptual question types to include

Based on analysis of the NCEES practice exam, conceptual questions take these forms:

1. **"Which statement is true?"** — Given a scenario, identify the correct principle
2. **Definition/terminology** — "A lien is a..." / "The term 'projected' means..."
3. **Method selection** — "Which delivery method fits?" / "Which foundation provides least settlement?"
4. **Interpretation** — "CPI > 1 and SPI < 1 means..." / Identify the correct FBD
5. **Classification** — Match categories, identify soil type from Atterberg chart
6. **Scenario-based judgment** — Ethics scenarios, safety compliance questions

### 2.4 Writing order (by chapter)

Write in this order — high exam weight chapters first for maximum early value:

| Priority | Chapter | Exam Q's | Lessons | Exam Problems to Write |
|----------|---------|----------|---------|------------------------|
| 1 | Water Resources | 10–15 | 8 | 32 |
| 2 | Structural | 10–15 | 8 | 32 |
| 3 | Geotechnical | 10–15 | 8 | 32 |
| 4 | Transportation | 9–14 | 8 | 32 |
| 5 | Mathematics | 8–12 | 13 | 52 |
| 6 | Statics | 8–12 | 6 | 24 |
| 7 | Construction | 8–12 | 7 | 28 |
| 8 | MoM | 7–11 | 8 | 32 |
| 9 | Fluid Mechanics | 6–9 | 8 | 32 |
| 10 | Surveying | 6–9 | 7 | 28 |
| 11 | Economics | 5–8 | 5 | 20 |
| 12 | Materials | 5–8 | 7 | 28 |
| 13 | Statistics | 4–6 | 6 | 24 |
| 14 | Ethics | 4–6 | 5 | 20 |
| 15 | Dynamics | 4–6 | 6 | 24 |
| | **Total** | | **107** | **428** |

### 2.5 Quality checks per question

Before finalizing each exam problem, verify:

- [ ] Statement is clear, unambiguous, and original (not copied from NCEES)
- [ ] Exactly 4 choices: 1 correct, 1 plausible trap, 2 reasonable distractors
- [ ] Math is verified (compute the answer independently)
- [ ] `eli5` explains the approach AND the trap in 3–6 sentences
- [ ] `steps` array has a complete worked solution
- [ ] `traps` array has 1–2 common mistakes
- [ ] `handbookPage` references the correct FE Handbook page
- [ ] `type` is correctly set to `computational` or `conceptual`
- [ ] Dollar signs follow the MathText rendering rules (no `$` for currency)
- [ ] ID follows convention: `<chapter>-<lesson>-ex<N>`

---

## Phase 3: Diagnostic Exam UI

### 3.1 Pre-diagnostic welcome card (Dashboard)

**Location:** Top of dashboard, above chapter list.
**Shown to:** Users with `diagnosticCompleted === false` (or undefined).

**Content:**
```
Start With a Diagnostic

Before you dive into studying, take a quick 30-question diagnostic.
It mirrors the real FE exam pace and tells us exactly where you stand.

Why?
- Skip what you already know
- Focus on what actually needs work
- See how much studying you really need

This isn't graded. It's your compass.
Don't stress about questions you can't answer —
that's the whole point. Blank answers tell us where to help you.

30 questions · ~90 minutes · real FE pace

[Take the Diagnostic]        [Skip for now]
```

**Design notes:**
- White card on cream background with forest top accent bar
- "Take the Diagnostic" = ember CTA button
- "Skip for now" = text-only link, charcoal
- Phosphor icon: Exam or ClipboardText (Bold weight)

### 3.2 Diagnostic exam flow

**Route:** `/diagnostic` (new page)

**Question selection algorithm:**
1. For each of the 15 chapters, collect all `examProblems` across that chapter's lessons
2. Randomly select 2 questions per chapter
3. Ensure at least 1 computational and 1 conceptual where the chapter has both types
4. Shuffle the final 30 questions (don't group by chapter — student shouldn't game it)
5. On retake, exclude questions used in previous attempts (track by questionId)

**Exam UI:**
- One question at a time (same layout as lesson practice)
- Top bar: countdown timer (charcoal text, not alarming) + question counter ("12 of 30")
- No chapter labels shown on questions
- "Skip" button available (moves to next, can return later if time allows)
- "Flag for Review" toggle per question
- No feedback during exam (no green/red, no eli5)
- "Submit Exam" button appears after viewing all questions (or when timer expires)
- Confirmation modal before final submission: "Submit your diagnostic? You answered X of 30 questions."

**Timer behavior:**
- Total time: 30 × 2.91 minutes = 87.3 minutes → display as **87 min 18 sec**
- Show as `MM:SS` countdown in top bar
- At 10 minutes remaining: timer text turns ember (subtle warning)
- At 0:00: auto-submit with unanswered questions counted as incorrect
- Per-question time is tracked in the background (not shown to user) for analytics

**Navigation:**
- "Next" / "Previous" buttons
- Question grid (small numbered circles) showing answered/unanswered/flagged
- Can jump to any question at any time

### 3.3 Results screen

**Route:** `/diagnostic/results` (shown after submission)

**Layout:**
```
Your Diagnostic Results

You answered [X] of 30 correctly.           +[Y] XP earned
Here's where you stand:

[Chapter bars sorted by mastery, lowest first]

Fluid Mechanics     ░░░░░░░░░░░░░░░   0%   Focus here
Ethics              ██████░░░░░░░░░  30%   Needs work
Statics             ████████████░░░  60%   Strong start
...

Your personalized study plan is ready.
We'll prioritize the chapters where you'll get
the biggest score improvement on the real FE.

[Go to Dashboard]     [Review Answers]
```

**"Review Answers" page:**
- Shows each question with:
  - The student's answer (highlighted red if wrong, green if right)
  - The correct answer
  - The eli5 explanation
  - The steps walkthrough
- Grouped by chapter for easy scanning
- This is a learning opportunity — treat it like a study session

### 3.4 Rules & messaging UI elements

**Before starting the diagnostic (info panel or modal):**
- "30 questions covering all 15 FE topics"
- "You have ~87 minutes — the same pace as the real FE exam (2.91 min/question)"
- "Skip questions freely — that helps us identify your weak areas"
- "Your results set a starting point on your mastery bars (up to 60% per chapter)"
- "You need to study to push past 60% — the diagnostic is just your baseline"
- "You earn 10 XP for each question attempted + 5 XP bonus per correct answer"

**On the retake button (when locked):**
- "Retake available after reaching 60% mastery in at least 11 of 15 chapters"
- Show progress: "You're at 60%+ in X/11 chapters"

**Mastery bar tooltip (on hover/tap):**
- Red: "Below 40% — this chapter needs focused study"
- Ember: "40–70% — you know the basics, keep building"
- Sunbeam: "70–90% — you're getting close to exam-ready"
- Forest: "90–100% — exam-ready! You've proven mastery across all lessons"

---

## Phase 4: Dashboard Integration

### 4.1 Mastery bar colors

**Update the mastery bar component** to use 4-tier color coding:

```js
function getMasteryColor(mastery) {
  if (mastery >= 90) return 'var(--forest)';    // #2D7A5F
  if (mastery >= 70) return 'var(--sunbeam)';   // #F5B731
  if (mastery >= 40) return 'var(--ember)';     // #E8683A
  return 'var(--error)';                         // #D64045
}
```

**Background fills for the bar track:**
```js
function getMasteryBgColor(mastery) {
  if (mastery >= 90) return 'var(--forest-bg)';  // #E8F5EE
  if (mastery >= 70) return 'var(--sunbeam-bg)'; // #FEF7E0
  if (mastery >= 40) return 'var(--ember-bg)';   // #FEF0EA
  return '#FDE8E8';                               // light red bg
}
```

### 4.2 Chapter ordering after diagnostic

**Default order (no diagnostic):** Chapters 1–15 in spec order.

**After diagnostic:** Sort by priority score:

```js
function getChapterPriority(chapter) {
  const examWeight = getExamWeightMidpoint(chapter.id);  // e.g., 12.5 for Water Resources
  const mastery = chapter.totalMastery / 100;            // 0 to 1
  return examWeight * (1 - mastery);                     // higher = study first
}
// Sort descending by priority
```

This surfaces high-weight, low-mastery chapters first — maximum score improvement per hour studied.

### 4.3 Diagnostic card states

**State 1: Not taken (new user)**
- Large prominent card at top of dashboard
- Full messaging as described in Phase 3.1

**State 2: Skipped**
- Smaller card, still visible but not dominant
- "Recommended: Take the diagnostic to personalize your study plan"
- [Take the Diagnostic] button

**State 3: Completed, retake locked**
- Compact card showing last diagnostic summary
- "Last diagnostic: X/30 correct · [date]"
- "Retake unlocks at 60% mastery in 11/15 chapters (currently X/15)"
- Progress indicator toward unlock

**State 4: Completed, retake available**
- "Retake Diagnostic — see your improvement"
- "Last score: X/30 · [date]"
- [Retake] button

### 4.4 XP integration

**Diagnostic XP:**
- 10 XP per question attempted (not skipped)
- 5 XP per correct answer
- Range: 0 XP (all skipped) to 450 XP (30 attempted, all correct)
- Diagnostic counts as a study session for streak tracking

**On retake:**
- Same XP rules apply (10 + 5)
- Full XP awarded again — incentivizes retaking

---

## Phase 5: Chapter Tests (Future)

After the diagnostic and question bank are built, chapter tests become straightforward:

- "Test Yourself" button per chapter on dashboard
- Pulls from that chapter's `examProblems` pool
- All exam problems for the chapter (e.g., 32 for an 8-lesson chapter)
- Timed at 2.91 min/question
- Results update chapter mastery (studyScore component)
- XP: same 10+5 model

---

## Phase 6: Full Practice Exams (Future)

- 110 questions drawn proportionally from all chapters (matching NCEES weights)
- 5h20m timer (full exam simulation)
- Uses `examProblems` pool across all chapters
- Results comparable to diagnostic but with full coverage
- Premium feature potential (monetization)

---

## API Endpoints Needed

### Diagnostic
```
POST /api/diagnostic/start        → Creates attempt, returns question set
POST /api/diagnostic/submit       → Submits answers, computes scores, awards XP
GET  /api/diagnostic/results/:id  → Returns detailed results for review
GET  /api/diagnostic/history      → Returns all attempts for the user
GET  /api/diagnostic/can-retake   → Returns boolean + progress toward unlock
```

### Mastery
```
GET  /api/mastery                 → Returns all chapter mastery data for user
GET  /api/mastery/:chapterId      → Returns detailed mastery for one chapter
```

### Question Bank
```
GET  /api/exam-problems/:chapterId  → Returns exam problems for a chapter (for chapter tests)
```

---

## New Frontend Routes

```
/diagnostic              → Diagnostic exam page (question-by-question UI)
/diagnostic/results/:id  → Results review page
```

---

## New Components Needed

```
src/components/diagnostic/
  DiagnosticCard.jsx          → Dashboard card (4 states)
  DiagnosticExam.jsx          → Exam-taking UI (timer, questions, navigation)
  DiagnosticResults.jsx       → Results breakdown page
  DiagnosticReview.jsx        → Answer review with eli5/steps
  QuestionGrid.jsx            → Navigation grid (answered/flagged/skipped)

src/components/dashboard/
  MasteryBar.jsx              → Updated with 4-tier colors
  ChapterCard.jsx             → Updated with diagnostic score display
  StudyPriorityList.jsx       → Reordered chapter list by priority
```

---

## Database Changes Summary

### New collection: `diagnosticResults`
- Stores each diagnostic attempt with per-question detail
- Indexed by `userId` + `attemptNumber`

### Modified collection: `progress`
- Add `diagnosticCompleted: Boolean`
- Add `diagnosticAttempts: Number`
- Add `chapterMastery: { [chapterId]: { diagnosticScore, studyScore, totalMastery } }`

---

## Implementation Order

| Step | What | Depends On | Status |
|------|------|-----------|--------|
| 1 | Data model: add `examProblems` field + utility functions | Nothing | DONE |
| 2 | Write 428 exam questions (chapter by chapter) | Step 1 | IN PROGRESS (30/428 sample questions added) |
| 3 | Backend: diagnostic API endpoints | Step 1 | DONE |
| 4 | Backend: mastery calculation + storage | Step 3 | DONE |
| 5 | Frontend: DiagnosticExam component | Step 3 | DONE |
| 6 | Frontend: DiagnosticResults + Review | Step 4 | DONE |
| 7 | Frontend: MasteryBar 4-tier update | Nothing | DONE |
| 8 | Frontend: DiagnosticCard (4 states) | Steps 4, 7 | DONE |
| 9 | Frontend: Dashboard reordering + integration | Steps 6, 8 | DONE |
| 10 | Chapter tests (uses same exam pool) | Steps 2, 4 | Not started |

Steps 1 + 7 can start immediately (no dependencies).
Steps 2 and 3–4 can run in parallel (content writing vs. engineering).
Steps 5–9 are sequential frontend work.

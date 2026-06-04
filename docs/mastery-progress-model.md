# Mastery / Progress model — analysis & fix plan

**Status:** investigation (2026-06-04). No code changed yet. Owner asked to map
the model before fixing the "studying doesn't move mastery" bug.

## TL;DR (the bug)

After a user takes the diagnostic, **practicing problems never raises their
chapter mastery bars, Exam Readiness, or Focus Areas.** Verified live: studied
3 chapters after a diagnostic; their bars stayed at the diagnostic values.

Root cause: the dashboard shows `chapterMastery[ch].totalMastery =
diagnosticScore + studyScore`, and **`studyScore` is never written by any
endpoint** (`grep studyScore service/` → only read in `diagnostic.js`). Practice
writes a *different* structure (`topicProgress`) that the post-diagnostic
dashboard ignores.

## Three disconnected progress systems

| System | Keyed by | Written by | Read by | Notes |
|---|---|---|---|---|
| **A. `chapterMastery`** | chapterId (15) | `POST /api/diagnostic/submit` only | dashboard `getProgress` when a diagnostic exists | `{diagnosticScore (cap 60), studyScore (always 0), totalMastery}` |
| **B. `topicProgress`** | the id sent to `/api/sessions` | `POST /api/sessions` (practice + lessons) | dashboard `getProgress` *fallback* (no diagnostic), via `/api/topics` | masteryLevel 0–3 (`calculateEarnedMastery`) |
| **C. `problemHistory`** | (email, problemId) | sessions / reviews | spaced-repetition "Daily Review" | independent; fine |

### How the ids flow
- Practice `src/problems/problems.jsx:173` and lessons `src/lesson/lesson.jsx:10`
  both `POST /api/sessions` with **`topicId = chapterId`** (e.g. `statics`). Good
  — practice is chapter-grained and already uses chapter ids.
- `/api/sessions` (`service/routes/sessions.js`) writes `topicProgress[chapterId]`
  (attempted/correct/sessions → `masteryLevel`). It does **not** touch
  `chapterMastery`.
- Dashboard `getProgress` (`src/dashboard/dashboard.jsx:211`):
  - diagnostic exists → `chapterMastery[ch.id].totalMastery` → **frozen** (studyScore=0).
  - no diagnostic → `topicLookup[chapter.name]` from `GET /api/topics`.
- `GET /api/topics` (`service/routes/topics.js`) is backed by the **`topics`
  collection — a stale 6-row legacy seed**: `analytic-geometry, dynamics,
  fluid-mechanics, soils, materials, transportation`. It reads
  `topicProgress[topic.topicId]` and the dashboard matches it by **chapter
  *name***. Only **Dynamics, Materials, Fluid Mechanics** match (name *and*
  id), so even pre-diagnostic, practice only reflects on 3 of 15 chapters.
  (`Soils`≠`Geotechnical Eng.`, `Analytic Geometry`≠`Mathematics`, `Transportation`≠`Transportation Eng.`)

### Downstream
`Exam Readiness` and `Focus Areas` (`src/data/readiness.js`,
`computeReadiness`/`computeFocusAreas`) both consume the chapterId→mastery map
built from `getProgress` — so they inherit the same frozen source.

## Recommended fix

Make **practice feed `chapterMastery.studyScore`, keyed by chapterId** (which
sessions already send), and make the dashboard read `chapterMastery` for *all*
users:

1. **`/api/sessions`**: after updating `topicProgress[chapterId]`, recompute and
   write `chapterMastery[chapterId].studyScore` from that chapter's cumulative
   practice (attempted/correct already tracked in `topicProgress`). Set
   `totalMastery = min(diagnosticScore + studyScore, 100)`. (Optionally do the
   same in `/api/review` so review answers also count.)
2. **`studyScore` formula** (design choice): a curve over cumulative correct
   answers / accuracy for the chapter that can fill the ~40% headroom above the
   60% diagnostic cap, so a well-practiced chapter reaches ~100%. Diagnostic
   seeds, practice completes.
3. **`getProgress`**: prefer `chapterMastery[ch.id]` whenever it exists (even
   with `diagnosticScore=0`), so practice shows up **with or without** a
   diagnostic. Retire the `topicLookup[chapter.name]` path.
4. **Retire the legacy `topics` collection** (and the name-match) for mastery —
   it's misaligned with the 15-chapter model and becomes unused after (3).
   Keep `/api/topics` only if something else needs it.

### Decisions to confirm before coding
- studyScore curve shape (how fast practice raises mastery; how many correct
  answers ≈ "mastered").
- Backfill: existing users already have `topicProgress[chapterId]` attempted/
  correct → can seed `studyScore` on first post-fix session, or via a one-off
  migration.
- Grain: chapter-level is correct (practice is per chapter; subtopics are
  lesson-only). No per-subtopic mastery needed.

### Not affected / out of scope
- Spaced-repetition Daily Review (system C) works and is separate.
- XP, streak, badges (driven by `userStats`, work fine).

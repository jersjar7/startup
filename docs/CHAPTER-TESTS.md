# Chapter tests

A chapter test is a timed, exam-style test of one chapter, with answers shown
only at the end, that a professor can assign and a student can retake. It was
asked for by Prof. Alam (UWF) on 2026-10-28, who teaches chapter by chapter.
It sits next to chapter practice, it does not replace it.

Live since 2026-10-30. Both question sets are free, with no limit on tries
(the reasoning, and what was rejected, is in ADR 0035).

The first half of this document is how the feature works and how to test it.
The second half, from "Why a new bank", is the brief for writing the bank:
everyone who writes, solves or reviews a question follows it.

## What a student sees

**Chapter page** (`/study/:chapterId`, `src/study/ChapterFinish.jsx`). Under
the subtopics, two options side by side as equals:

- **Practice the chapter**: one problem at a time, answer after each. Shows
  "n of N problems".
- **Test yourself, timed**: "15 questions in 45 minutes, like the FE. Answers
  at the end." Shows "Not taken yet", "In progress", or "Best 73% · 2 tries".

The owner chose this layout on 2026-10-30 over a separate test card, and over
a list with one "next step" button under it (he found the button repeated the
rows above it). Practice teaches, the test measures; they are two products,
so neither is styled as the main one.

**Rules page** (`/test/:chapterId`, `src/chapterTest/ChapterTest.jsx`, intro
phase). Questions, time, best score, the rules, one button (Start the test,
Continue the test, or Take the test again), and **Your tries**: every finished
try with its date, score and a "See answers" link. That list is the only way
back to an old result, so it must stay.

The retake line says only what is true for this student:

| Situation | Line |
|---|---|
| never taken | Take it again later and your next try has all new questions. |
| next set never handed in | This try has all new questions. |
| both sets already seen | You have seen both question sets. This try repeats the one you saw longest ago. |
| a try is open | Your answers so far are saved. The clock kept running while you were away. |

**The test** (same page, test phase). The exam simulation's screen: clock,
question, figure, four choices, flag, question grid, Hand in. 3 minutes per
question. Tapping the chosen answer again clears it. Answers autosave (and are
kept in the browser too); flags are kept in the browser. Hand in asks to
confirm and says how many questions have no answer. At 0:00 the test hands
itself in. During the test the site header and footer are hidden.

**Result** (`/test/result/:attemptId`, `src/chapterTest/ChapterTestResult.jsx`).
Score with a one-line reading of it, a bar per topic, "Take it again with new
questions" (or just "Take it again" when no unseen set is left), a line
pointing to the exam simulation, then every question with the student's
answer, the right one, a note on every choice, the idea in plain words, the
worked solution and the handbook page. "Missed" filters to wrong answers.

## Question sets, never shown as versions

Each chapter has two sets, A and B, that share no question. Students never see
or pick a letter: the server picks with `nextVersion` in
`service/chapterTests.js`:

1. a try still open: that one;
2. otherwise the set handed in fewer times;
3. a tie: the set taken longest ago; A first.

So try 1 is A, try 2 is all new (B), try 3 repeats A, try 4 B. `nextIsNew` in
`GET /api/chapter-tests/:chapterId` says whether the next try is a set this
student has never handed in, and the pages use it so they never promise new
questions that are not new.

**Choice order changes every try.** Practice and the exam simulation already
shuffle choices; a test that did not would let a repeat try be answered from
memory of a letter, and it would pass on the bank's lean toward B and C (as
written: 69/95/95/69 correct answers over A-D). The order comes from the try
id and the question id (`choiceOrder`), so it is the same after a refresh, on
going back to a question, and in the review, and it is never stored. Choice
ids do not change, so grading does not depend on order. The cost: 273 of the
328 questions list numbers smallest to largest, as the FE does, and the
shuffle gives that up. Nothing in the bank refers to a choice by letter (no
"both A and B", no "all of the above"); keep it that way, a letter reference
would point at the wrong choice.

## How the server keeps it fair

Code: `service/chapterTests.js` (rules), `service/routes/chapterTests.js`
(`/api/chapter-tests`), `service/db/chapterTests.js` (collection
`chapterTestAttempts`). The bank is `service/chapter-tests.json`, written by
`scripts/gen-content.mjs`; it is never in `content.json` (the app download)
and never in the website bundle.

- **No answer before hand in.** While a try is open the browser gets
  `publicQuestion`: statement, choices, figure. No key, no notes, no solution.
  The review (`GET /attempts/:id`) is refused with 409 while the try is open.
- **Answers merge like the exam simulation's** (ADR 0002): autosave may clear
  an answer, hand in can only add one. Answers to questions the try did not
  ask are dropped.
- **A try stores its question ids**, so a later change to the bank cannot
  change what a past try asked.
- **The clock is the server's.** Deadline = start + 3 min per question. Hand
  in is accepted up to 2 minutes late (slow network on the last second) and
  marked `late` after that.
- **A try opened and left is not a score** (ADR 0001, same rule as the exam).
  When a student comes back after the deadline, the old try is graded from
  what was saved only if at least a tenth of it was answered (rounded up: 1 of
  6, 2 of 15). Below that it is retired (`retired: true`, no result): it never
  shows in Your tries and never counts as a try. This matters most for a
  professor looking at the test before assigning it.
- **Only your own tries.** Every query is by the signed-in email; anyone
  else's try is 404.
- **Account deletion** clears `chapterTestAttempts`, and an email change moves
  them (`service/db/accountDeletion.js`, `accountEmail.js`).

## Testing

- `npx vitest run service/chapterTests.test.js`: the bank (both sets, long
  enough, no shared ids, not in `content.json`), what the browser may see,
  grading, the answer merge, which set comes next, the genuinely-sat rule,
  and choice order (stable in a try, notes stay with their choice, different
  between tries, the correct answer even over A-D).
- `node --env-file=service/.env scripts/ct-e2e.mjs` walks a whole test as a
  student in a real browser, about 50 checks: before, during (change, clear,
  flag, refresh, leave and come back), hand in, review, back button, a second
  and third try, the clock running out, a try opened and left, a try worked
  on and left, and the security edges. It uses the QA account and deletes its
  tries before and after, so it runs against production. Set `SITE` to try a
  local copy first. Run it before shipping any change to chapter tests.

## The question bank

## Why a new bank

The site already has three banks and they share no questions: lesson exercises
(405, answers shown at once), chapter practice (248, answers shown at once) and
the exam simulation (473, the paid product). A test built from a free bank can
be looked up in advance, and one built from the simulation bank gives the paid
product away. So the tests get their own questions, and they are kept on the
server like the simulation's: the browser never receives an answer before the
test is handed in.

## Size

Two sets per chapter, A and B, that share no question, so a retake is new
questions at the same level (students never see the letters; see "Question
sets, never shown as versions"). Each test is as long as the chapter's share of
the real exam, at the top of its NCEES range (src/data/chapters.js):

| Chapter | Per test | | Chapter | Per test |
|---|---|---|---|---|
| Mathematics | 12 | | Fluid Mechanics | 9 |
| Probability & Statistics | 12 | | Surveying | 9 |
| Ethics | 6 | | Water Resources & Env. | 15 |
| Engineering Economics | 8 | | Structural | 15 |
| Statics | 12 | | Geotechnical | 15 |
| Dynamics | 6 | | Transportation | 14 |
| Mechanics of Materials | 11 | | Construction | 12 |
| Materials | 8 | | | |

164 questions per full set, 328 for both. Each version is written with two
spare questions so a question that fails review can be dropped without leaving
a hole.

## What a good question is

1. **New.** Not a reworded copy of any of the 1,126 existing problems or of
   another chapter test question: a different situation, different numbers,
   and where possible a different angle on the idea. `ct-check` flags close
   wording; a reviewer reads any flagged pair side by side.
2. **Like the real FE.** Four choices, one correct. Solvable in about three
   minutes with the FE Reference Handbook 10.5 and an approved calculator.
   Realistic engineering numbers and units (US customary and SI, as the exam
   mixes them). The setting is a real civil engineering situation where one
   fits: a footing, a culvert, a haul road, a survey traverse.
3. **Covers the chapter.** Each version follows the NCEES knowledge areas for
   its chapter (research/civil/fe-civil-exam-topics.md and the CBT spec), in
   proportion to how much each area is tested. Version A and version B each
   cover the whole chapter on their own.
4. **Fair as a pair.** A and B have the same difficulty mix: about 30% easy,
   50% medium, 20% hard. A student who retakes with B gets new questions at
   the same level, not an easier or harder test.
5. **Wrong answers that teach.** Every wrong choice is the result of a real
   mistake: a missed unit conversion, the wrong leg of a triangle, gross
   instead of net area, forgetting the factor of 2. `choiceNotes` says, for
   each choice, why it is right or which mistake produces it. No filler
   choices. Choices are listed in a sensible order (numbers ascending), and
   the correct position varies across the test.
6. **Fully solved.** `steps` walk through the solution; `eli5` explains it in
   plain English; `traps` lists the mistakes to avoid. `handbookPage` is a
   page verified in research/civil/fe-handbook-10-5.pdf (printed page number,
   which is in the page header; in the civil chapters it is PDF page minus 6),
   or `null` when the handbook does not cover it, with `handbookFormula` still
   given. A page number is never guessed.
7. **Correct.** The keyed answer is checked by an independent solver who never
   sees the key. Any disagreement is resolved or the question is dropped. When
   in doubt, drop it: two spare questions per version exist for this.
8. **Our own words.** Public sample questions and the NCEES practice exam are
   used only to learn what the exam asks and how; nothing is copied or closely
   paraphrased from them.

Writing conventions from the rest of the bank still apply: the word "dollars"
instead of a dollar sign in text (a dollar sign starts math), math in `$...$`
that KaTeX can parse, no em dashes.

## Figures

A question gets a figure whenever the real exam would show one: beams, trusses,
frames, sections, soil profiles, flow nets, channels, pipes and tanks, survey
traverses and curves, intersections and profiles, schedules and networks. A
question whose figure would only repeat the text gets none.

Figures are React SVG components, like every diagram on the site
(src/components/diagrams). Reuse an existing component when it draws exactly
what the question needs; otherwise draw a new one. Rules for new ones:

- **Where.** `src/components/diagrams/chapter-tests/<chapter>-<a|b>/`, one file
  per component, registered in that folder's `index.js` (`DIAGRAMS`). The name
  starts with `Ct<Chapter><Version>`, for example `CtGeotechnicalAFootingProfile`,
  so the 30 sets never collide. Marker ids inside a component are unique to it
  (`ctGeoAFootArrow`), since several figures can share a page.
- **Correct engineering.** Standard symbols drawn the standard way: pin
  (triangle on hatched ground), roller (circle or triangle on rollers), fixed
  support (hatched wall), hinge (open circle), water surface (inverted
  triangle), north arrow, dimension lines with end ticks or arrows. Loads point
  the way they act. Proportions follow the numbers: a 20 ft span is drawn
  twice as long as a 10 ft one. The owner is a civil engineer and checks
  drawings.
- **Readable labels.** Every label sits next to the thing it names and touches
  nothing else: no label over a line, an arrow or another label. Text is at
  least 11 units tall in a viewBox about 360 to 480 wide, which is what a phone
  shows. Every dimension has units.
- **Tight framing.** The viewBox fits the drawing with a small even margin, no
  large empty bands.
- **Brand colors only, through CSS variables:** `--charcoal` for structure and
  text, `--ember` for the load or quantity the question is about, `--info` for
  water, `--gray-400`/`--gray-500` for dimensions and secondary lines,
  `--forest` sparingly. No other colors.
- **Never gives the answer away.** The figure shows what the question gives,
  not what it asks for.
- **Props drive the numbers.** Values shown come from props, so the figure and
  the statement cannot disagree.

Every figure is rendered with `ct-render` and looked at before it is accepted.

## Data shape

Each version is a file `src/data/chapter-tests/<chapter>-<a|b>.js` exporting an
array. One question:

```js
{
  id: 'ct-geotechnical-a-01',          // ct-<chapter>-<a|b>-NN
  chapterId: 'geotechnical',
  version: 'A',
  topic: 'Shallow foundations',        // the NCEES knowledge area
  type: 'computational',               // or 'conceptual'
  difficulty: 'medium',                // easy | medium | hard
  statement: '...',
  choices: [{ id: 'c1', text: '...' }, { id: 'c2', ... }, { id: 'c3', ... }, { id: 'c4', ... }],
  correctAnswerId: 'c3',
  choiceNotes: ['Uses gross pressure ...', '...', 'Correct: ...', '...'],
  eli5: '...',
  hint: '...',
  steps: [{ text: '...', latex: '...' }, ...],
  handbookPage: 'p. 262',              // or null
  handbookFormula: 'q_{ult} = ...',
  traps: ['...'],
  diagram: { component: 'CtGeotechnicalAFootingProfile', props: { ... } },  // or null
}
```

## Tools

```
node scripts/ct-check.mjs <chapter>-<a|b>     # or: all
node scripts/ct-render.mjs <chapter>-<a|b> <outDir>
```

`ct-check` fails on schema errors, a broken answer key, duplicate choices,
KaTeX that does not parse, a figure that is missing or throws, and near-copies
of existing problems. `ct-render` writes every figure as a PNG, a
questions-only file for a blind solver, and the key for the reviewer.

## How the bank was made

Written overnight 2026-10-29 to 10-30 by a pipeline of agents, one chain per
chapter set, in this order:

1. **Writer**, following this brief, two spare questions per set.
2. **Blind solver**, given the questions without the key. Any question where
   its answer differed from the key went to review flagged.
3. **Reviewer**: the answer, the handbook page, near copies of existing
   problems, and every figure looked at as an image (orientation, scale,
   standard symbols, labels placed where they belong).
4. **Fixer**: applied the review or dropped the question.
5. **Blind recheck** of the fixed set, then `ct-check all`.

Outcome: 388 questions written (328 used, 60 spares), 222 figures. Reviewers
raised 155 issues, 70 of them in figures; all were applied. Blind re-solves
found no wrong key. `ct-check all` passes with one accepted warning:
transportation-a-04 looks like lesson problem trans-hc-q3, but asks for the
speed rather than the superelevation. The owner looked at a sample sheet of
figures on 2026-10-30 before the tests were built.

The NCEES practice exam was used only to match how questions are pitched
(length, difficulty, what is given); nothing was copied or paraphrased from it.

The bank lives in `src/data/chapter-tests/` and is imported only by
`scripts/gen-content.mjs`, so no question, key or solution is in the website
bundle (checked 2026-10-30 against the built bundle). The figures in
`src/components/diagrams/chapter-tests/` ARE in the bundle, because the browser
draws them; a figure therefore must show only what the question gives, never
the answer.

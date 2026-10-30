# Chapter tests: the question bank

A chapter test is a timed, exam-style test of one chapter, with answers shown
only at the end, that a professor can assign and a student can retake. It was
asked for by Prof. Alam (UWF) on 2026-10-28, who teaches chapter by chapter.
It sits next to chapter practice, it does not replace it.

This document is the brief for writing the bank. Everyone who writes, solves or
reviews a question follows it.

## Why a new bank

The site already has three banks and they share no questions: lesson exercises
(405, answers shown at once), chapter practice (248, answers shown at once) and
the exam simulation (473, the paid product). A test built from a free bank can
be looked up in advance, and one built from the simulation bank gives the paid
product away. So the tests get their own questions, and they are kept on the
server like the simulation's: the browser never receives an answer before the
test is handed in.

## Size

Two versions per chapter, A and B, that share no question, so a retake is new
questions at the same level. Each test is as long as the chapter's share of
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

Written 2026-10-30 by a pipeline of agents, one chain per chapter version:
writer, then a blind solver, then a reviewer (answers, handbook pages, near
copies, every figure looked at), then a fixer that applies the review or drops
the question. The whole bank then passes `ct-check all`.

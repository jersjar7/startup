# 0035. Chapter tests are free, and students never see which question set they get

- **Status:** Accepted
- **Date:** 2026-10-30
- **Affects:** `service/chapterTests.js` (`nextVersion`, `genuinelySat`, `choiceOrder`), `service/routes/chapterTests.js`, `src/study/ChapterFinish.jsx`, `src/chapterTest/`

## Context

Prof. Alam (UWF) asked for a timed test per chapter that he can assign while
teaching chapter by chapter. A new bank was written for it: two sets per
chapter (A and B) that share no question, 328 questions in use. See
docs/CHAPTER-TESTS.md.

Four questions had to be settled before it went live:

1. Does a free chapter test take sales from the paid exam simulation?
2. Should students see and choose "version A" and "version B"?
3. What happens to a test someone opens and leaves?
4. Should the choices be shuffled, given that the FE lists numeric answers
   smallest to largest?

## Decision

**Both sets are free, with no limit on tries.** A chapter test is one slice of
the exam, about 6 to 15 questions; the simulation is all fifteen chapters, 110
questions, under the real 5 h 20 min clock. They answer different questions
("do I know this chapter" against "am I ready for the exam"), so the free test
is a step toward the paid one, not a replacement. The result page says so in
one line and links to the simulation. Free also suits a professor assigning
it to a whole class.

**Sets are never shown.** The server picks the set (`nextVersion`): an open try
first, otherwise the set handed in fewer times, otherwise the one taken
longest ago. Try 2 is therefore all new questions. The page promises new
questions only when they are new (`nextIsNew`). On the chapter page the test
and chapter practice sit side by side as two equal options (owner's call on
the layout, 2026-10-30).

**A try opened and left counts only if it was genuinely sat**: at least a
tenth of it answered, rounded up. Otherwise it is retired with no score and
does not count as a try. This is ADR 0001's rule for the exam simulation,
applied here for the same reason: a professor looking at the test before
assigning it must not end up with a recorded 0%. The first version shipped
without it on 2026-10-30, was caught while writing the docs the same evening,
and no student had taken a test yet.

**Choices are shuffled per try**, in an order derived from the try and the
question, so it holds across a refresh and in the review.

## Consequences

**Good**

- A student can retake a chapter as often as they like, and the second try
  is a real second test, not the same questions.
- No page ever says "version", so there is nothing to explain and no choice
  that does not matter.
- Opening a test to look at it leaves no trace.
- A repeat try cannot be answered from memory of a letter, and the bank's
  lean toward B and C (69/95/95/69 correct answers over A-D, as written) never
  reaches the student; across tries the correct answer is even over A-D.

**Bad, and accepted**

- From the third try the questions repeat (only two sets exist). The page
  says so on the rules page rather than hiding it.
- Shuffling gives up the FE's smallest-to-largest order on the 273 questions
  with numeric choices. Practice and the exam simulation already shuffle, so
  the site is at least consistent; the bank can be rebalanced later and the
  shuffle removed if that order is wanted back.
- A student who answers less than a tenth and leaves loses those few answers.
- Unverified: whether free chapter tests change how many students buy the
  simulation. Cheapest test: compare simulation purchases in the 30 days
  before and after 2026-10-30, and the share of buyers who took a chapter
  test first.

## Alternatives considered

- **Set A free, set B in the paid pass.** Proposed first. Rejected by the
  owner: a retake is where a student learns whether they improved, and
  charging for it punishes the student who is doing the right thing. The
  simulation already gives a clear reason to pay.
- **Show versions A and B with a button each.** Built and reviewed on
  localhost. Rejected: the letters mean nothing to a student, and two Start
  buttons made the block look like an add-on beside chapter practice.
- **One "next step" button under the list.** Built and rejected by the owner:
  it repeated the rows above it.
- **Grade every abandoned try.** What first shipped. Rejected for the reason in
  ADR 0001.
- **Keep the bank's fixed choice order.** Faithful to the FE's numeric
  ordering, but it rewards memorizing letters on retakes and keeps the B/C
  lean. Rejected.

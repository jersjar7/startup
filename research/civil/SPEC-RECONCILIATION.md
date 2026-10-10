# The app's exam weighting against the current NCEES spec

_2026-10-09. The spec PDF is `fe-civil-cbt-spec.pdf` in this folder: NCEES FE
CIVIL CBT Exam Specifications, **effective beginning with the July 2020
examinations**, which is the one in force._

## The headline

The app is built on the **retired 2014 spec**. The two differ structurally, not
just in numbers:

| | 2014 (what the app uses) | July 2020 (current) |
|---|---|---|
| Knowledge areas | 15 | **14** |
| Mathematics | its own area | merged with Statistics into one area |
| Probability & Statistics | its own area | merged |

The app carries **Mathematics & Computational Tools** and **Probability &
Statistics** as two chapters worth 17 of 110 questions between them. The
current spec has a single **Mathematics and Statistics** area worth **8–12**.

## Where the weighting is wrong

Spec ranges are midpoints scaled to the 110-question exam, so the two columns
are comparable. Positive means the app practises a topic MORE than the exam
tests it.

| Chapter | App | Current spec | Error |
|---|---:|---:|---:|
| Mathematics + Statistics | 17 | 8.7 | **+8.3** |
| Construction Engineering | 5 | 8.7 | **−3.7** |
| Water Resources & Env. | 14 | 10.9 | **+3.1** |
| Fluid Mechanics | 4 | 6.5 | −2.5 |
| Surveying | 4 | 6.5 | −2.5 |
| Structural Engineering | 13 | 10.9 | +2.1 |
| Engineering Economics | 4 | 5.7 | −1.7 |
| Materials | 4 | 5.7 | −1.7 |
| Statics | 8 | 8.7 | −0.7 |
| Ethics | 4 | 4.4 | −0.4 |
| Dynamics | 4 | 4.4 | −0.4 |
| Mechanics of Materials | 8 | 7.9 | +0.1 |
| Geotechnical | 11 | 10.9 | ~0 |
| Transportation | 10 | 10.0 | ~0 |

**What that means for a student.** A 110-question simulation gives them about
**17 maths questions where the real exam gives about 9**, and about **5
construction questions where the real exam gives about 9**. Someone who
practises to this distribution is over-prepared on maths and under-prepared on
construction, surveying and fluids, and the mastery percentage they are shown
is weighted the same wrong way.

## Where the numbers live

Three places, all carrying the same 2014 distribution, kept in sync by hand:

| File | What it holds |
|---|---|
| `service/examWeights.js` | `EXAM_DISTRIBUTION`, the backend source of truth; drives weighted mastery |
| `src/data/exam-bank/index.js` | a hand-kept copy of the same map; drives which questions the simulation picks |
| `src/data/chapters.js` | the `qs` strings shown to users, e.g. `'11–17'` for Mathematics |

`service/examWeights.test.js` asserts the sum is 110, so any change has to keep
that true.

## What has NOT been decided

Whether to **merge** the two chapters or keep them separate and split the 8–12
between them. Merging matches the spec but rewrites chapter numbering, URLs
(`/fe-civil/statistics` is a public prerendered page), lesson folders and every
user's stored per-chapter progress. Keeping them separate and splitting the
weight is far cheaper and fixes the number a student is graded on, which is the
part that actually misleads.

That is a product call, not a mechanical one, and it is the reason this file
stops here rather than changing the weights.

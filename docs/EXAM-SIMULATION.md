# Exam Simulation — how it works, and the invariants that must not be broken

The paid Exam Simulation is the only paid product: 110 questions, a 5h20m limit,
and a 25-minute break after question 55, mirroring the real NCEES appointment.

This document exists because the feature was **badly broken for its first
customers** and the fixes rest on a few non-obvious invariants. Read this before
touching `service/routes/exam.js` or `src/exam/ExamSession.jsx`.

Related: `docs/DEPLOY.md` (the deploy preflight refuses to interrupt a live
exam), `docs/business-plan.md`.

Decisions behind this design: [ADR-0001](adr/0001-grade-abandoned-exams-only-if-genuinely-sat.md)
(when an abandoned exam is graded), [ADR-0002](adr/0002-separate-merge-semantics-for-autosave-and-submit.md)
(why autosave and submit merge differently), [ADR-0004](adr/0004-sim-pitch-gate-and-25-problem-threshold.md)
(who is shown the pitch).

---

## Invariants

**1. Submit can only ADD answers. It must never clear them.**

`service/examProgress.js` deliberately exposes two merges:

| Function | Null means | Used by |
|---|---|---|
| `mergeAutosave` | "the user cleared this answer" | `PATCH /exam/answers` |
| `mergeSubmission` | ignored — additive only | `POST /exam/submit` |

The client sends `selectedAnswerId: null` for every question it does not hold,
and a submitting client may hold only a fraction of the truth. Honouring those
nulls at submit deleted every autosaved answer and scored customers ~0%. If you
ever collapse these two functions back into one, you reintroduce that bug.

**2. Answers are keyed by `questionId`, never by array position.**

Position keys break the moment order changes, which is exactly what resume does.
The old client regenerated its own question set on resume, so index-keyed
answers were scored against the wrong questions and silently dropped.

**3. Resume must use the SERVER's stored questions.**

`/exam/start` returns `questions` for a resumed attempt. The client must render
those, not a locally regenerated set, or submitted ids will not match what is
being scored.

**4. The clock is a server-issued deadline, not a countdown.**

`/exam/start` returns `deadline` (epoch ms) from
`examProgress.js::examDeadlineMs`. The client re-derives the time remaining
every tick and on `visibilitychange`/`focus`. A plain `setInterval` decrement
stops when the tab is hidden or the laptop sleeps, which handed out unlimited
extra time on a timed exam.

**5. The 25-minute break sits OUTSIDE exam time.**

As in the real NCEES appointment. Break timestamps are **write-once** on the
server and the credit is capped at one full break, so a refresh cannot buy a
second break and a long absence cannot become unlimited time.

**6. Expiry GRADES the attempt, it does not discard it.**

An attempt past `limit + 30 min grace` is scored from its `savedAnswers` and
marked `completed` with `autoSubmitted: true`. Marking it `expired` and walking
away hid a customer's entire exam, because every UI surface filters on
`completed`. An attempt with no answers at all is still retired quietly, so
nobody gets a manufactured 0%.

**7. The expiry grace must equal the deploy preflight's.**

`service/examAttempt.js` and `service/checkActiveExamSims.js` both use
limit + 30 min. A test asserts the total is 350 minutes. If they drift, either
deploys get blocked by attempts the app already killed, or a deploy lands on
someone the app still considers active.

---

## Data model (`examAttempts`)

| Field | Meaning |
|---|---|
| `status` | `in_progress` \| `completed` \| `expired` |
| `questions` | the stored 110, with `correctAnswerId`; rewritten with `selectedAnswerId`/`isCorrect` at scoring |
| `savedAnswers` | `{ [questionId]: choiceId \| null }`, written by autosave |
| `savedIndex`, `savedFlagged` | resume position and flags |
| `breakStartedAt`, `breakEndedAt` | write-once; extend the deadline |
| `autoSubmitted` | true when graded by expiry rather than by the customer |
| `lateSubmission` | submitted past the deadline; recorded, never rejected |
| `timeUsedSeconds` | max(client-reported, server elapsed), capped at the limit |

A late submit is **recorded, not refused** — refusing it would throw away the
customer's work, which is the failure this whole area exists to prevent.

## Endpoints

- `POST /exam/start` — resumes (rehydrating answers/position/flags/break) or
  creates. Expires-and-grades a stale attempt first.
- `PATCH /exam/answers` — autosave. 8s debounce client-side. Everything optional
  and merged.
- `POST /exam/answers-beacon` — same handler. `navigator.sendBeacon` cannot send
  PATCH, and it is the only transport browsers guarantee to deliver on
  `pagehide`, which is exactly when answers used to vanish.
- `POST /exam/submit` — merges additively over `savedAnswers`, then delegates to
  `finalizeAttempt`, which is shared with the expiry path so a submitted and an
  auto-graded attempt can never diverge.

Client durability is two-layered: a localStorage mirror written synchronously on
every change (covers the gap before the next flush, and offline) plus the
debounced server flush. The server merges, so neither layer can blank the other.
A flush the server answers with an error is retried on the next tick, not only
one that never got through: `fetch` does not throw on a 5xx, so until
2026-10-29 a "Failed to save progress" reply counted as saved
(`src/exam/retrySave.js` decides which statuses retry).

---

## Known open issues (audited and verified, NOT fixed)

From a 9-agent read-only audit, 63 raw findings, 15 confirmed after adversarial
verification. None still destroy customer work.

1. **The client picks the questions.** FIXED 2026-10-17. The server picks
   (`service/examQuestions.js`): the exam's per-chapter weights, never a
   diagnostic question (`service/diagnosticIds.js`, kept equal to the
   website's list by its test), and questions the student has not met on an
   earlier attempt first, then the least-seen. A student's first two exams
   share no question; a third repeats about five (Statics and Construction run
   out first). Statement, choices, chapter and `correctAnswerId` come from
   `service/content.json` and the browser is sent the questions without the
   key. `/exam/start` answers a page that still posts its own questions with
   409 "reload", before creating an attempt; resume is unaffected.
   `service/examStart.test.js`, `service/examQuestions.test.js`.
   STILL OPEN, by design for now: the free preview, the diagnostic and quick
   start grade in the browser from the same bank, so the bank (answers
   included) is still in the site's code and a determined buyer could look up
   answers by question text. Closing that means moving those three to the
   server too. The stake is small: a looked-up score fools the buyer and adds at most
   2 XP a question (220 per exam) toward the leaderboard.
2. **Multi-tab last-write-wins.** FIXED 2026-10-17: every answer carries the
   time it was chosen (`answerTimes`, stored as `savedAnswerTimes`), and the
   flags and position carry one each (`savedFlaggedAt`, `savedIndexAt`). Saves,
   submit and resume keep the newest per question (`mergeAutosaveStamped`,
   stamped `mergeSubmission`, `src/exam/restoreAnswers.js`). A page loaded
   before stamps still saves wherever nothing stamped is stored. Stamps are
   capped at the server's clock so a fast clock cannot lock an answer.
   `service/examTwoTabs.test.js`, `src/exam/restoreAnswers.test.js`. Not
   covered: two saves landing in the same instant still read-modify-write.
3. **Submit is not idempotent.** FIXED 2026-10-17: completion is a one-time
   claim (`claimExamCompletion`, an update conditioned on the attempt not
   being completed). Only the submit that wins it logs the session, the exam
   event and the XP; a repeat, concurrent or later, gets the stored result
   back instead of an error. `service/examSubmitOnce.test.js`.
4. **Refunds and disputes never revoked `examSimAccess`.** FIXED 2026-10-30:
   the webhook listens for `charge.refunded` and `charge.dispute.*` and moves
   the purchase to `refunded` or `disputed` (a won dispute restores it; a
   partial refund changes nothing). The checkout return link no longer
   re-grants a refunded purchase. `service/stripeReversals.test.js`, ADR 0036.

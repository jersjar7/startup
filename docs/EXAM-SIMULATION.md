# Exam Simulation — how it works, and the invariants that must not be broken

The paid Exam Simulation is the only paid product: 110 questions, a 5h20m limit,
and a 25-minute break after question 55, mirroring the real NCEES appointment.

This document exists because the feature was **badly broken for its first
customers** and the fixes rest on a few non-obvious invariants. Read this before
touching `service/routes/exam.js` or `src/exam/ExamSession.jsx`.

Related: `docs/DEPLOY.md` (the deploy preflight refuses to interrupt a live
exam), `docs/business-plan.md`.

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

---

## Known open issues (audited and verified, NOT fixed)

From a 9-agent read-only audit, 63 raw findings, 15 confirmed after adversarial
verification. None still destroy customer work.

1. **The client picks the questions and sends the answer key.**
   `ExamSession.jsx` POSTs all 110 questions to `/exam/start` **including
   `correctAnswerId`**, and the server scores against that payload. Any paying
   user can forge 110/110, submit a 1-question exam, or read every answer. The
   full answer key is also in the JS bundle. Architecturally the biggest issue;
   the fix is server-side question selection.
2. **Multi-tab last-write-wins.** A whole-state flush from an older tab can
   revert newer answers and clobber `savedFlagged`/`savedIndex`. On resume the
   localStorage mirror is overlaid unconditionally with no `savedAt` comparison,
   so a stale mirror can revert newer server data.
3. **Submit is not idempotent.** Two concurrent submits double-award XP, streak
   and badges.
4. **Refunds and disputes never revoke `examSimAccess`.** There is no refund
   handling anywhere, so a refunded customer keeps the product and stays in
   revenue totals.

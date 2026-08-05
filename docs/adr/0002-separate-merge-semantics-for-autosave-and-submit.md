# 0002. Separate merge semantics for exam autosave and submit

- **Status:** Accepted
- **Date:** 2026-07-30
- **Affects:** `service/examProgress.js` (`mergeAutosave`, `mergeSubmission`), `service/routes/exam.js`, `src/exam/ExamSession.jsx`

## Context

Exam answers used to live only in React state. There were two endpoints, start
and submit, no autosave, and the resume path returned no answers. Any refresh
during the 5h20m exam wiped everything while the server clock kept running.
Three of the first six paying customers submitted single-digit answer counts and
scored 2–4% after hours of work.

The fix added `PATCH /exam/answers` autosave plus a merge on submit, and its
commit message claimed:

> submit MERGES over saved answers instead of replacing, so a client that lost
> state can never blank out good data.

**That claim was false as implemented**, and an audit caught it before it
reached production.

A single `mergeAnswers` was used by both paths. It treated `null` as "the user
deliberately cleared this answer" — correct for autosave, where the client is
reporting live state. But the client's submit payload sends
`selectedAnswerId: null` for **every** question it does not currently hold. So
submit did not merge, it deleted: any submitting client with a partial view
wiped the server's autosaved answers for everything it lacked.

The fuse was already lit. The countdown effect depended only on `[phase]`, so
the `submitExam` it called was captured at exam start. Running out of time — the
normal ending for a full-length exam — submitted the answer set from hours
earlier. On a fresh attempt that is nothing at all, so a timed-out exam would
have scored 0/110 **and destroyed the server's copy on the way**.

The single merge function was the root of it: one name, two incompatible
contracts.

## Decision

Split the merge into two functions whose names state their contract, and never
let them be used interchangeably:

| Function | `null` means | Used by |
|---|---|---|
| `mergeAutosave(stored, incoming)` | the user cleared this answer | `PATCH /exam/answers` |
| `mergeSubmission(stored, submitted)` | **ignored** — additive only | `POST /exam/submit` |

The client also stopped sending nulls at submit: it now sends only real
selections, so a partial client can add but never erase. Both changes are
deliberate belt and braces — either alone would fix the bug, and keeping both
means a future change to one side cannot silently reintroduce it.

Auto-submit reads answers from a ref rather than the closure, and fires through
`submitRef` refreshed every render.

## Consequences

**Good**

- The safety property the previous commit only claimed is now real and tested. A
  test reproduces the exact catastrophe: a blank auto-submit over 110 saved
  answers scores 110, not 0.
- The distinction is legible at the call site. `mergeSubmission` reads as
  "submit cannot destroy" without opening the file.
- The server no longer trusts a client's view of what is missing, only what is
  present. That is the correct trust boundary for a durability feature.

**Bad, and accepted**

- Two functions where one would do, with near-identical bodies. Real cost: a
  reader may assume they are duplicates and collapse them. Mitigated by naming
  and by comments in both, but the risk is permanent.
- A user cannot clear an answer *at submit time*. Deselecting is an autosave
  operation, which is fine because the client autosaves continuously, but it is
  a genuine asymmetry.

## Alternatives considered

**Keep one merge, stop sending nulls from the client.** The smaller change, and
it does fix today's bug. Rejected because it puts the entire safety property in
the client. Any future client — the Flutter app, a retry, a third-party — that
sends nulls silently reintroduces data loss with no server-side guard.

**Keep one merge, add an `allowClear` boolean.** Rejected on legibility.
`mergeAnswers(stored, incoming, false)` at a call site tells a reader nothing,
and boolean parameters are exactly what people get wrong under time pressure.
The whole failure was a contract mismatch, so the fix should be visible in the
name.

**Never honour null anywhere; make clearing a separate endpoint.** Cleanest in
theory. Rejected as disproportionate: deselecting is a normal part of taking an
exam and does not deserve its own round trip.

## Notes

The deeper lesson is not about merges. The original commit asserted a safety
property it did not have, and the code looked correct. It was caught only
because the area was audited adversarially before deploy. **A claimed invariant
that is not tested is just a comment.** `mergeSubmission` now has a test whose
name is the failure it prevents.

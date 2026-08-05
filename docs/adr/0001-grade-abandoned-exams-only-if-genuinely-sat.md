# 0001. Grade abandoned exams only if genuinely sat

- **Status:** Accepted
- **Date:** 2026-08-04
- **Affects:** `service/routes/exam.js` (`MIN_GRADED_FRACTION`, the expiry branch of `POST /exam/start`)

## Context

The paid Exam Simulation is a single timed session of 110 questions over 5h20m.
Many customers never press submit: they close the tab, their laptop sleeps, or
they simply run out of time.

Until 2026-07-30 an unsubmitted attempt was abandoned entirely. It sat at
`status: 'in_progress'` forever, was resumed with a dead 00:00 clock, and every
answer the customer had entered was thrown away. Three of the first six paying
customers were stranded this way, one for 46 days.

The fix introduced autosave plus **grade-on-expiry**: when an attempt's window
closes, score it from `savedAnswers` and mark it `completed` with
`autoSubmitted: true`, so the customer's work becomes a real graded result
instead of vanishing.

That fix shipped with the floor set at **more than zero answers**. Any attempt
with at least one answer was graded.

The flaw surfaced immediately, from a real account. A professor evaluating the
simulation for his university course opened it, answered **one** question to see
what the questions looked like, and left. Under the shipped rule his next visit
would have graded that as a **completed attempt scoring 1%**, recorded
permanently in his history.

Nobody sat an exam there. He was previewing the product, which is a legitimate
and expected way to evaluate it. Recording a score implies a sitting that did
not happen, and for someone deciding whether to recommend the product to
students it is actively misleading.

## Decision

An abandoned attempt is graded **only if at least 10% of the exam was answered**
(`MIN_GRADED_FRACTION = 0.1`, i.e. 11 of 110). Below that threshold the attempt
is retired quietly: `status: 'expired'`, no score, no history entry, and the
customer simply starts fresh.

The threshold is expressed as a fraction of `totalQuestions` rather than a fixed
count, so it stays correct if the exam length ever changes.

## Consequences

**Good**

- Browsing the questions to evaluate the product no longer manufactures a
  humiliating score.
- The original purpose is preserved: a customer who answered 60 questions and
  never pressed submit still gets a real graded result.
- Past Attempts stays a list of genuine sittings, which is what makes it useful
  for tracking readiness over time.

**Bad, and accepted**

- A customer who answered 8 questions and genuinely intended to continue loses
  that record. Judged acceptable: an 8/110 score is not useful to them either,
  and the attempt is retired rather than deleted, so nothing blocks a fresh
  start.
- The threshold is a judgement call. 10% is defensible but not derived from
  data, because there is no data on where "previewing" ends and "sitting"
  begins. Revisit if real abandoned attempts cluster near the boundary.

## Alternatives considered

**Grade everything with at least one answer** (what shipped, now replaced).
Simple, and it never loses data. Rejected because it fabricates results: it
cannot tell a preview from a sitting, and a 1% entry does real reputational harm
with the exact audience most worth impressing.

**Grade everything, but label it.** Keep `autoSubmitted: true` visible in the UI
so a 1% attempt reads as "auto-submitted, incomplete". Rejected because the
score is still recorded and still shown; a label mitigates the presentation but
not the underlying claim that an exam was taken.

**Ask the customer on their next visit** whether to keep or discard the
abandoned attempt. Rejected as the wrong moment: they arrive wanting to study,
and a modal about a stale attempt is friction in service of an edge case.

**Set the floor from buyer behaviour**, as was done for the sim-pitch threshold.
Not possible here: the buyer data answers "who is ready to buy", not "what
counts as an attempt". There is no equivalent evidence, so an explicit judgement
call is more honest than a number dressed up as analysis.

## Notes

Fixing the floor also resolved the specific case without touching the
professor's account. Reaching into a customer's data to clean up after our own
design flaw would have been the wrong instinct; changing the rule fixes it for
everyone, retroactively, on their next visit.

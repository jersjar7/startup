# 0019. The desk half is coverage, not a repetition curve

Date: 2026-09-25
Status: Accepted. Supersedes the desk-half bullet of
[0017](0017-mastery-one-number-two-halves.md); everything else in 0017 stands
(two halves, the games half at most 50, one composing function, both surfaces
show the halves).

## Context

0017 kept the desk half as the study curve the site had carried since the
learning-model work: each problem answered right at the desk counted with a
"maturity" that grew when the same problem was answered right again after
7 days and again after 21 days. The audit (`docs/mobile/sync-audit.md`, F1)
found nothing had ever written the interval that maturity read, so the curve
topped out between 55 and 88 depending on the chapter's size. Fix 1 made the
interval grow as designed, which meant a chapter could only reach 100 after
every problem had been re-asked twice on that schedule.

Shown the schedule, the owner's reaction was that being asked the same
problem again at 7 and 21 days "seems excessive" for a number meant to say
how much of a chapter a student has covered. The review queue already
exists for the problems a student got wrong; the curve was adding a second,
hidden repetition requirement on the problems they got right, and it moved
the number for reasons a student could not see.

## Decision

**The desk half is coverage.** For a chapter, it is the share of the
chapter's problems the student holds:

- a problem is held when it has been answered right at the desk at least
  once and is not currently sitting in the review queue after a miss (a
  missed problem is held again as soon as it is answered right once more);
- the denominator is the chapter's problem count from the content itself,
  so every chapter can reach 100 and Economics (50 problems) is not harder
  to finish than Mathematics (135);
- the diagnostic stays the floor, the games half stays at most 50, and the
  number is still the smaller of 100 and the sum.

Nothing is asked twice for the number's sake. The review queue, which asks
missed problems again, is unchanged; the interval bookkeeping stays in the
problem history for the queue but no longer feeds the number.

Alternative kept in mind: a shorter curve (one re-ask instead of two). It
would still hide a repetition rule inside a coverage figure, so it was not
taken.

## Consequences

- One formula in `service/mastery.js` (`computeStudyMastery`), derived from
  the event log like everything else under 0018, and re-run once across
  every account on deploy.
- Measured before the switch, on every production account: 225 accounts
  and 892 chapter figures moved, half up (average 6, at most 26) and half
  down (average 5, at most 33). No chapter sat at 100 either way.
- A student who works through a chapter's problems once, getting them right,
  sees the chapter reach 100 at the desk without a calendar in the way.
- The "How is this scored?" note on the dashboard says coverage, not
  repetition.

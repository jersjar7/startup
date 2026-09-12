# 14. No scheduled review on the phone; the student chooses what to revisit

Date: 2026-09-12

## Status

Accepted. Amends [0013](0013-games-keep-their-own-score.md), which stands in
every other respect. 0013 said the Review tab leaves the bottom bar **and**
that due-ness moves onto the lesson nodes in the chapter path. The first half
holds. The second half is dropped.

## Context

0013 removed the Review tab because it practised the website's problems on a
phone, which is the model the chapter path replaced. It promised a
replacement in the same breath: nodes that stop looking finished after a
while, so the path itself would say what to come back to.

Designing that replacement is what killed it. The logic was written out as a
decision tree (`docs/mobile/review-nodes.md`) and it needed, at a minimum: a
spacing ladder, a weakness score, a cap on how many nodes may ask at once, a
rule for how review ranks against unfinished and never-opened nodes, a rest
rule so a missed item stops nagging, an aging rule for abandoned chapters,
per-item timestamps the client does not currently store, calendar-day
arithmetic in the student's own zone, and a decision about the exam date. Nine
interlocking rules.

Every one of those rules is a guess, and we have nothing to check the guesses
against. Production holds no game events at all outside TestFlight: 180 iOS
events, all of them the owner's account and the QA bot. We would be tuning a
spaced-repetition schedule against zero observations of anybody using it, and
each rule would need unwinding later if it turned out wrong.

The owner's judgment, on reading the tree: this is too complex to be worth
building blind, and predicting what a student needs to revisit is a claim we
have not earned.

## Decision

**The phone does not schedule review.** No due dates, no review marks on
nodes, no ranking, no cap. A finished node is drawn as finished.

**Revisiting is available, not prescribed.** Every node stays open. A student
who wants to run an item again taps it and runs it again. That is the whole
feature, and it costs nothing to maintain because it is what the path already
does.

**The design work is parked, not discarded.** `docs/mobile/review-nodes.md`
keeps the tree, marked as parked, so the question does not have to be
re-thought from nothing when it is worth answering.

## Consequences

The phone gets simpler in the way that matters: it has one job, which is the
chapter path, and one number, which is the games' own. Nothing on the screen
makes a claim about the student's memory that we cannot support.

What we lose is the strongest argument for spaced retrieval, which is that
people do not choose to revisit what they are worst at. That loss is real, and
it is the reason this ADR is an amendment rather than a reversal: 0013's
reasoning about desk-earned mastery is untouched, and returning to a node
still moves the games' number when the student chooses to.

The trigger to revisit this is the same evidence 0013 waits on. Once real
students have played real sittings, the event log will show whether people
return to items on their own and whether the ones they skip are the ones they
miss. Build the schedule then, against data, or leave it alone.

## Alternatives considered

**Build the tree as designed, with the cap set conservatively.** Rejected for
the reason above: nine rules, no evidence, and each wrong one is a piece of
the interface that has to be explained away later.

**Keep the Review tab until the replacement is ready.** Rejected. The tab
practises whole problems on a phone, which 0013 decided against on its merits;
leaving it standing as a placeholder would keep shipping the thing we do not
believe in.

**A single "not seen in a while" mark, with no ladder or cap.** The cheapest
version, and the one to build first if this is ever revisited. Rejected for
now because even one mark implies the app knows what is worth returning to,
and it needs the same per-item timestamps the full design needs.

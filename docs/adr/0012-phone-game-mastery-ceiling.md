# 12. Phone games feed the one mastery number, capped at 60 percent

Date: 2026-09-07

## Status

Superseded by [0013](0013-games-keep-their-own-score.md) on 2026-09-12: games
now keep their own score and mastery stays desk-earned. The reasoning below is
left as it was written.

Originally: Accepted. Implements the games direction set on 2026-09-07 and obeys
[`../mobile-app-north-star.md`](../mobile-app-north-star.md), whose third rule
(honest readiness signalling) is the reason the cap exists.

## Context

The mobile app is being rebuilt around games. A chapter is a path, a lesson is
a node on that path, and a node opens that lesson's own games. The phone no
longer ships the website's lesson text, its three-problem practice, or
"Practice all [chapter]". Every game item is thumb-only and non-computational:
the student demonstrates what governs the answer and never works the arithmetic
(see [`../mobile/question-design.md`](../mobile/question-design.md)).

That raises the question this ADR answers: what does clearing a game actually
prove, and what should it move?

Two options were on the table.

**A separate phone score.** Games would earn their own number, and chapter
mastery would stay a desk-only measure. This keeps the mastery number pure, but
it makes the phone a toy that sits next to the real product, and it produces two
truths a student has to reconcile. It also contradicts the sync design already
built, where phone card reps strengthen web mastery under the heading "one
brain".

**The same number, uncapped.** Games would feed chapter mastery exactly as web
practice does. This is honest about the phone being real learning, but it lets a
student reach a high mastery figure, and the readiness language that comes with
it, having never once worked a problem through to a number on paper. That is
precisely the fluency illusion the north star was written to prevent: retrieval
that feels like competence, on an exam that is six hours of sit-down
calculation.

## Decision

Games feed **the same chapter mastery the website shows**, through the existing
sync pipeline, and **evidence that has only ever come from the phone is capped
so that games alone stop at 60 percent**.

Concretely, in `service/mastery.js`:

- `problemHistory` rows now carry `deskAttempts`. Web practice, review, and the
  exam simulation write desk attempts; phone games and cards do not.
- `computeStudyMastery` splits its evidence in two. Desk evidence counts in
  full. Phone-only evidence is capped at the evidence value that yields 60
  percent on the existing saturation curve.
- The cap is applied to the **evidence**, not to the resulting percentage, so a
  student who has been capped and then sits down at the desk resumes the same
  smooth curve instead of stepping up.

Rows written before `deskAttempts` existed are read as desk work. They were
earned before the ceiling did, and no one's mastery may drop because we changed
our minds.

The owner set the number at 60 on 2026-09-07. It was proposed at 70.

## Consequences

A student who only ever plays games will watch a chapter climb and then stop,
short of the top, with the app able to say why: you know what governs these
problems, now prove you can finish one on paper. That sentence is the product.

XP is unaffected and stays on the phone table, small and capped at 60 a day, so
couch play still cannot outrank desk work on the leaderboard.

The cost is that mastery now depends on where an answer came from, which is a
new thing the data model has to keep straight. If a future surface writes
problem history without saying which it is, it silently defaults to desk and
quietly loosens the ceiling. `service/mastery.test.js` pins the four cases
(phone-only, desk, legacy, mixed) and `service/syncEvents.test.js` pins the
event shape the phone client sends.

This ADR does not settle how the ceiling is *shown*. A capped chapter currently
looks the same as any other chapter sitting at 60. Saying so out loud, on the
path and on the dashboard, is the obvious follow-up.

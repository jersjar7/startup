# 13. Games keep their own score; mastery stays desk-earned

Date: 2026-09-12

## Status

Accepted. Supersedes
[0012](0012-phone-game-mastery-ceiling.md), which had phone games feeding the
one mastery number under a 60 percent ceiling.

## Context

ADR 0012 answered "what should clearing a game move?" with: the same chapter
mastery the website shows, capped so that games alone stop at 60 percent. That
decision was made on 2026-09-07, before the game chapters existed. All fifteen
chapters are now built, 375 items across 135 lessons, and the owner revisited
the question on 2026-09-12 while looking at what the phone had turned into.

Two things had changed.

The first is what the games actually became. They are concept items: which
formula governs, which way the sign goes, which of two readings the question
asked for. They are deliberately non-computational, and the board shows four
options with an explanation the moment you answer.

The second is what the phone still carried from before. The bottom bar's
**Review** tab is not games at all. It fetches the student's missed problems
from the website's bank and opens the old exercise screen, which is the model
the games direction replaced. The app was offering two different learning
models and blending both into one readiness figure.

Three considerations decided it.

**What recognition practice predicts.** On items matched for content and
cognitive level, one medical physiology study found 79 percent on multiple
choice, 73 percent on plain recall, and 26 percent on open-ended items that
required producing the reasoning. The FE is itself multiple choice, so the
relevant gap is not choice against essay: it is knowing which method governs
against carrying it out under time with a calculator and the handbook. Our
games sit on the first side of that line by design.

**What easy practice does to confidence.** Koriat and Bjork's illusion of
competence comes precisely from the answer being present while you study and
absent at the test. A game board shows the options and explains immediately.
That is the condition that produces a student who feels ready and is not, and
this product sells an exam simulation to people who have booked a date.

**What a weight would have to be worth.** The composite-score literature is
clear that weighting helps validity only up to a point and can reduce it past
that, and that a weight has to be derived from evidence that the components
predict the same outcome. We have no such evidence. Production holds 40,570
study events from 265 people on the web against 180 from iOS, and those 180 are
the owner's own account and the QA bot. No event has ever carried a game id,
because the games have only been on TestFlight. Sixty percent was a guess and
thirty would have been the same guess made smaller.

The deciding argument was which mistake is cheaper to undo. Separate now and
later find that games predict desk performance, and the numbers go up when we
blend. Blend now and later find it was flattering people, and every student's
readiness figure drops after they have planned around it.

## Decision

**Mastery means one thing: evidence that the student can finish whole problems,
earned at the desk.** Phone games contribute nothing to it. The
`PHONE_ONLY_CEILING_PCT` machinery in `service/mastery.js` goes, along with the
split evidence it exists to cap.

**Games get their own number**, computed from game events and shown as its own
thing: concepts held and chapters covered, not a percentage that could be
mistaken for readiness. It moves fast, because a sitting is six rounds, and it
is the number the phone celebrates.

**The two are shown next to each other and never combined.** If a single
headline is ever wanted, it is two-part ("concepts 78, problems 41"), not a
blend.

**The Review tab leaves the bottom bar.** Spaced return is still right; a tab
that practises the website's problems on the phone is not. Due-ness moves onto
the lesson nodes in the chapter path, where the student already is.

Rows written under 0012 keep their meaning: no one's mastery may drop because
we changed our minds, so the phone-only evidence already banked stays banked.
The ceiling simply stops applying to anything new.

## Consequences

The phone becomes honestly supplemental. It says: you know what governs these
problems. It stops implying you are 60 percent of the way to being ready, and
the website's number goes back to meaning what it says.

The cost is motivational, and it is real. Games no longer move the big number,
which is exactly why 0012 had them do it. The mitigation is that the games now
have a number of their own that moves every sitting, which the capped mastery
figure never did.

Removing the Review tab also removes the only place the phone practises whole
problems. That is deliberate: the desk is where that happens, and pretending
otherwise on a phone screen is what this ADR is against.

This decision is provisional in one specific way, and the check is written down
so it can actually be run. Once the app is in students' hands and there are
people with both game events and desk evidence, ask whether game accuracy
predicts desk and simulation performance after accounting for volume. If it
does, blend, with a weight the data chose rather than one we felt. If it does
not, this ADR was right for the reason it claims.

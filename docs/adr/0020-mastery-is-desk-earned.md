# 0020. Mastery is desk-earned: games are a warm-up, the readiness read a floor of 25

Date: 2026-09-25
Status: Accepted. Supersedes [0017](0017-mastery-one-number-two-halves.md)
(the two halves). Keeps [0019](0019-desk-half-is-coverage.md) (coverage) as
the whole of the number. Restores the spirit of
[0013](0013-games-keep-their-own-score.md): games keep their own count.

## Context

0017 let games on the phone add up to 50 points to a chapter's mastery, on
top of the desk work, "the cap is the hand-off". Once the desk half became
coverage (0019) the flaw was plain: a student who had answered half of a
chapter's problems and cleared every game saw the chapter at 100. Half the
problems unseen, and the site calling it mastered.

The owner's ruling (2026-09-25): mastery should represent exactly that,
mastery. The phone and its games exist to refresh ideas in a casual setting
and to set up the real learning, which is the desk work on the website. They
do not represent mastery and should not be counted as it. This is a
professional site; a percentage called mastery must be defensible to the
student on exam day.

The readiness read (the quick start's 3 to 5 questions per chapter, or the
older 57-question diagnostic) is different: it is real desk work, but a
short sample. It had been worth up to 40 (quick start) or 60 (the legacy
diagnostic). The owner's ruling: keep it, reduce it to at most 25.

## Decision

- **Mastery is desk-earned.** A chapter's number is its coverage: the share
  of the chapter's problems answered right at the desk and not currently
  sitting in the review queue (0019). Nothing else adds to it.
- **The readiness read is a floor of at most 25.** A chapter starts at
  25 times the share of its read answered right, and stays there only until
  coverage passes it. Every stored read, whatever cap it was written under,
  is rescaled to the 25 scale when the account is derived; new reads carry
  their cap in the event.
- **Games are a warm-up and say so.** The server still counts the chapter's
  games cleared and both surfaces show it, as a count, never as points: the
  website's chapter row says "warm-up 3 of 10 games" under the bar, only for
  accounts that have played; the phone's mastery tile says "warm-up 3 of
  10"; the chapter map's hand-off tile, when the last game is cleared, says
  the ideas are covered and mastery is earned at the desk.
- **One composing function**, as before, so every writer and both surfaces
  agree.

## Consequences

- A student with games only sees 0 on every chapter, with the warm-up count
  beside it. That is the truth and it points at the desk.
- A student with a perfect readiness read sees 25, not 40 or 60, until
  their desk work carries the chapter further.
- Every account was re-derived once under the new rule on deploy.
- The "games can take a chapter up to 50" copy on the dashboard sidebar,
  the scoring note, the phone's mastery page and the hand-off tile is gone.
- Phone builds before 875 read a games field that the server no longer
  sends; they show "games 0 of 50" on the mastery tile until updated. The
  number they show is right.

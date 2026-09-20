# 0017. Mastery is one number with two halves: the desk to 100, the games to 50

Date: 2026-09-20
Status: Accepted. Supersedes the "never combined" rule of
[0013](0013-games-keep-their-own-score.md); keeps its "games get their own
number" on the phone's map.

## Context

ADR 0013 (2026-09-12) took phone games out of mastery entirely: mastery
would mean desk-earned evidence only, games would keep a separate count, and
the two would sit next to each other and never be combined. In the code
that decision was never finished: the audit of 2026-09-19
(`docs/mobile/sync-audit.md`) found the 60 percent ceiling of ADR 0012
still in `service/mastery.js`, phone rounds still written as problem
evidence, and neither surface showing any split.

The audit also measured what the two halves could actually reach. Games
draw on one to three website problems each, so a chapter's games touched
17 to 48 problems and could never honestly carry a chapter past 24 to 54
percent under the problem-evidence model. And the desk could not reach 100
either, because the maturity the model weights by was never written. Both
"halves" were fictions until 2026-09-20.

The owner's decision, after the audit: games can carry a chapter to 50 and
no further; the desk can carry it from 0 to 100; mastery is one number on
both surfaces with the two halves visible; the cap is the hand-off, the
moment the phone says "the rest is desk work". This replaces 0013's "never
combined" because a student needs one number to act on, and because the
phone's contribution was becoming invisible rather than honest.

## Decision

**One number, two halves, one formula.**

- The **desk half** is the study curve over desk work (practice, review,
  the simulation), with the diagnostic as its floor, 0 to 100 on its own.
  Maturity grows from spaced right answers, as the model always said.
- The **games half** is 50 times the share of the chapter's games cleared
  on the phone, at most 50. A game is cleared when every round has a right
  answer, read from the phone's own events. Phone rounds are no longer
  problem evidence.
- The **number** is the smaller of 100 and the sum, composed by one server
  function (`composeMastery`) that every writer uses.
- **Both surfaces show the halves.** The website's chapter bars carry a
  mark at 50 and "games N of 50", only for accounts that have synced from a
  phone, so nobody sees a mark for an app they cannot use. The phone's
  mastery tiles show the same line, and a chapter with every game cleared
  says so on its map and points at the desk.
- The phone's map keeps its own count (rounds cleared, concepts held), as
  0013 wanted: that is the phone's celebration, not a percentage.

## Consequences

- One formula in one file; the quick start's additive blend and the
  diagnostic's rebuild-from-empty went with it.
- Every account was recomputed once under the new formula (340 accounts).
- A student who only plays games sees a chapter stop at 50 with the reason
  on screen; a student who never opens the app sees the bar they always had.
- Reaching 100 needs spaced re-answers at the desk, which today come from
  practice repeats and the simulation; whether known problems should come
  back on a schedule is a separate policy question the owner has not yet
  taken up.

# 0038. Metal league names, a fourth Profile figure, and XP the server decides

- **Status:** Accepted
- **Date:** 2026-11-01
- **Supersedes:** decision 1 of [ADR 0037](0037-weekly-leagues.md) (the tier names), and the "three facts" on the phone Profile from [ADR 0023](0023-names-and-the-pass-card.md) as described in `mobile/design/DESIGN.md`
- **Spec:** [docs/leagues-spec.md](../leagues-spec.md)

## Context

ADR 0037 named the five league tiers after construction materials. In review
the owner asked for names everyone ranks without thinking, like a music chart's
gold and platinum records. Seeing the mocks he also approved a small metal coin
beside each league title, with the title text kept charcoal, rather than a
coloured title or a tinted box.

The phone Profile showed three facts (ADR 0023). Leagues are the one thing a
student checks every week, and the Profile is where the app shows where a
student stands.

Before leagues went live we read where the top all-time students' XP came
from (read only, 2026-11-01). The leader's 105,315 XP was real study: 126
days since June, 6,675 answers at 91% and about 16 seconds each. But it came
from 653 problems answered about ten times each, and every repeat paid full
XP. The second student earned 32,145 XP in five days, 14,560 of it in one day,
at about five seconds a question. And the practice and review routes took the
browser's word for whether an answer was right, so anyone able to post JSON
could mark every answer correct. None of this mattered much on an all-time
board; it matters once a week's XP moves people between leagues.

## Decision

The owner approved these on 2026-11-01:

1. **Metal names.** The tiers are Copper, Bronze, Silver, Gold, Platinum,
   weakest to strongest (ids `copper` to `platinum`). Each league has a coin
   in its metal (`LeagueCoin`), the only place the five metal colours appear.
2. **A fourth Profile figure.** The phone Profile shows four facts, the
   fourth being the student's place in their league ("4th in Silver"). It
   opens the league page.
3. **XP once per problem per day.** A desk answer earns XP only the first
   time that problem is answered on the student's day. A repeat that day is
   still recorded and still counts for review and mastery; it earns nothing.
   Session and review bonuses are unchanged. Not retroactive: XP already
   earned stays.
4. **The server grades desk answers.** The website sends the choice picked;
   the server compares it with its own copy of the bank (`service/grading.js`,
   `service/content.json`). A problem the server does not hold earns nothing.
   An old browser tab that sends only right or wrong is still accepted, so no
   one loses a session: its right or wrong is kept for study history, but it
   earns only the attempt XP (5), never the correct XP (10).

The board also gains two things the mocks showed: how each place moved since
the start of the day (up, down, or new), from a once-a-day snapshot of each
group's places, and how many days each student studied this week.

## Consequences

- An all-time total built from repeats stays as it is; from now on a day of
  repeats earns a session bonus and nothing per answer.
- The live "+10" on the website practice screen is a guess the summary
  corrects; a repeat shows +10 live and 0 in the summary.
- `src/data/serverGrading.test.js` fails if the server's copy of the bank is
  missing a problem the website can ask or disagrees on its answer; the fix is
  `node scripts/gen-content.mjs`.
- Phone sync events still carry the phone's own grade. They stay capped at 60
  XP a day, which bounds what a forged phone event could be worth.
- The second student's week is not acted on.
- The session and review bonuses still pay for a session made only of
  repeats, so finishing many short repeat sessions still earns 15 to 25 XP
  each. Paying the bonus only when a session earned something is the next
  step if league boards show it being used.

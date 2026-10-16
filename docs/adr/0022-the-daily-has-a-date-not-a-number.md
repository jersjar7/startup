# 0022. A student sees the Daily's date, never its number

Date: 2026-10-16
Status: Accepted. Supersedes in part [0021](0021-the-daily.md): only what a
student is shown. Everything else in 0021 stands.

## Context

The Daily (ADR 0021) shipped in build 1104 naming each puzzle by a running
number, the way Wordle does: "Daily No. 2" on the tab, at the top of each
game, on the results, in the 8am notification ("Daily No. N is ready"), on
the share card and in the copied text ("FE for Raccoons Daily No. N").

The owner asked what the number was for. The honest answer was: very little,
and it costs us something.

- **What Wordle's number does.** Wordle numbers its puzzles mostly in the
  shared result ("Wordle 1,234 4/6"). There it is a short label that tells
  two people they played the same puzzle. Inside the game it is small print.
- **We do not need that label.** Every student gets the same three games on
  the same day, so the date already says "same puzzle".
- **What the number costs.** A student who joins months in sees "No. 160"
  and reads it as 159 they missed. That is the opposite of what a new
  student should feel on their first day.
- **It means nothing to our students anyway.** People use the app for the
  weeks before their exam, not for years. A running count past a few dozen is
  not a milestone for anybody here.
- **The number that is theirs is the streak.** It counts up from the day
  they started, so a late joiner and a day-one student start equal.

## Decision

Nothing a student sees carries the Daily's number. They see the date and the
words "Today's Daily".

| Where | Was | Now |
| --- | --- | --- |
| Tab, card eyebrow | NO. N · SAME FOR EVERYONE | SAME FOR EVERYONE |
| Tab, results eyebrow | DAILY NO. N · X PLAYED | TODAY'S DAILY · X PLAYED |
| Before each game | DAILY NO. N | TODAY'S DAILY |
| Top of each game | DAILY NO. N · GAME i OF 3 | TODAY'S DAILY · GAME i OF 3 |
| End of the Daily | DAILY NO. N | TODAY'S DAILY |
| 8am notification | Daily No. N is ready | Today's Daily is ready |
| Share card title | Daily No. N | The Daily (the date is in the corner) |
| Copied text | FE for Raccoons Daily No. N | FE for Raccoons Daily, Oct 16 |
| Shared image file | fe4raccoons-daily-N.png | fe4raccoons-daily-2026-10-16.png |

The number stays on the server, unchanged, for our own use: it is how a
result is matched to its puzzle (`/api/daily/:number/result`), how the
no-repeat cycle is tracked, and how streaks are counted. The API still
returns it and the phone still uses it for those calls. It is an internal
key, like a database id.

## Guarding against regression

- `mobile/test/daily_test.dart` checks the tab before and after playing, the
  step screen, the end screen and the share card, and fails if any of them
  shows "Daily No", "DAILY NO" or "NO. " followed by a digit. The copied
  text is checked word for word.
- `mobile/test/notification_plan_test.dart` fails if any planned
  notification's title contains "No.".
- The note at the top of `mobile/lib/features/daily/daily_calendar.dart`
  says the number is never shown and points here.

If someone wants a number back, for example for a "100 Dailies" badge, count
the student's own Dailies (their total or their streak), never the puzzle's
place in the calendar.

## Consequences

- A student's first Daily looks exactly like everyone else's.
- The date and the number never disagree: the phone asks by its own date
  and the server works the number out from that date, so the date a student
  sees is the puzzle they played.
- If we ever do need a public puzzle id (say, a web page per Daily), it
  should be the date in the URL, not the number.

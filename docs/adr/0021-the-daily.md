# 0021. The Daily: one shared puzzle a day, picked by the server, built from the games we have

Date: 2026-10-15
Status: Accepted. Keeps [0020](0020-mastery-is-desk-earned.md): nothing
here touches mastery.

## Context

The tester's notes on build 1075 asked for three things that turned out to
be one: a quick random start or "chapter of the day" (point 3a), a quick fire
of three quizzes from different chapters (point 4), and a quiz of the day
that every user can do, with a streak, "think Wordle" (point 5). The owner
added the native-app part: a notification at a time people are awake, and a
place to compare students, first all of them and later by university.

Students with the app are mostly close to their exam, so the owner also
lifted the old cap of two notifications a day: reminders that keep the
concepts familiar are the point.

## Decision

- **A third tab, the Daily.** Three whole games from three different
  chapters, the same for every student that day, played once. A new one
  opens at the student's own midnight.
- **Built from the existing games, played whole.** A single round lifted
  out of its game often makes no sense on its own ("Same setup, different
  triangle"), and the concept sheet before each game is what turns a guess
  into something learned. Nothing new is authored for the Daily.
- **The server picks, once a day, and stores the pick.** Every phone could
  work the three out from the date alone, but a phone on an older version
  knows fewer games, so on the day after an update students would be
  comparing scores on different puzzles. A pick is stored the first time a
  day is asked for and never changes, even if the catalog does.
- **No game repeats until every game has come up once.** Chapters are drawn
  by exam weight scaled by how much of the chapter is unplayed this cycle,
  so heavy chapters come up more often without running dry long before the
  light ones. A cycle is about 123 days.
- **Score is rounds right on the first try; time breaks ties.** The clock
  runs only while a game is on screen, so reading the concept first never
  costs anything.
- **Comparison starts with how everyone did,** not a ranked list: the spread
  of scores, the top two names and you. At about 35 weekly users a ranked
  list would look empty. A school's own board opens once five of its
  students play the same day (school from sign-up, grouped by email domain
  where there is one).
- **Practice, never mastery.** The Daily's rounds go to the event log like
  any game's; they count as practice and show on the website. The streak is
  the Daily's own and is the first app-only badge to come (point 8).
- **Notifications, all local:** 8am "Daily No. N is ready" every day; 8pm
  "still open" only while today's Daily is not done (naming the streak when
  there is one); 12:30 every day of the last three weeks before the exam,
  with the countdown copy on 21, 14, 7 and 3 days out. All stop two days
  before the exam, as before. Three a day at most.

## Consequences

- The Daily needs the server once a day. A phone that has fetched today's
  Daily plays it without a signal and sends the score when it can.
- A phone missing one of the day's games says so and asks for an update
  rather than playing a different puzzle.
- iOS keeps 64 pending notifications, so at two or three a day the schedule
  reaches about three weeks ahead. It is re-armed on every open, so only a
  student who has not opened the app in three weeks stops hearing from it.
- Results rows are keyed by email, so account deletion and email change
  both cover the new collection.
- Times are reported by the phone. Someone could fake a fast time; for a
  practice board that is an acceptable risk, and the server never accepts
  less than a second a round.

## Alternatives considered

- **A personal "quick fire" on the home tab** (the first proposal): covered
  3a and 4 but not 5, and would have been rebuilt as soon as the shared
  Daily arrived.
- **Pick on the phone from the date:** no server work, but breaks the one
  promise that makes it a Daily (same puzzle for everyone) whenever versions
  differ.
- **A new bank of Daily questions:** more writing, and it would teach less
  than the games, which already carry their concept sheets.
- **Single rounds from many games:** rounds lean on their game's setup and
  read as nonsense alone.

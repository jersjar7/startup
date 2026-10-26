# Monthly challenges: spec

Status: Approved by the owner 2026-10-25, all three decisions as
recommended. The decisions are recorded in ADR 0027; the build is under way.

## What it is

One chapter a month. For that month, every student is invited to clear all
of the chapter's lessons, on the phone, on the website, or both. Finishing
earns that month's coin. Everyone works on the same chapter, so students can
see how the others are doing, the way they can with the Daily.

The App Store side is an in-app event with the Challenge badge, one a month.
Apple shows it on our product page and in search, and anyone can tap "Notify
me" to be told when it starts. The event only works if the app has something
real to show, which is what this spec adds.

## What it is not

- **Not mastery.** Clearing a lesson is something done, not proof the
  chapter is known (ADR 0020). The challenge never moves the mastery number,
  and no screen suggests it does.
- **Not new content.** It is built from the lessons, games and practice
  problems that already exist. Nothing is written for a challenge except its
  name, one line of copy and its coin.
- **Not a leaderboard race.** Finishing is the goal. Speed is not rewarded,
  the same rule the rest of the app follows for an adult audience.

## The goal, and what counts

**A challenge is cleared lesson by lesson.** Statics has 7 lessons, so the
November card says "7 lessons". A lesson counts as cleared in the challenge
when, during the challenge's dates, the student does one of these:

- **On the phone:** clears every game in that lesson's path node. Every
  round right, retries allowed, the same rule the map already uses.
- **At the desk:** answers every practice problem in that lesson right on
  the website. Every Statics lesson has 3.

Either way counts the same toward finishing. The website and the phone show
the same progress, because both read the one record (ADR 0018).

**What counts is only work done during the challenge.** A lesson cleared in
October does not count toward November. That is what makes it a challenge
rather than a checklist, and for a student weeks from the exam, coming back
to a chapter is the point.

**Two marks, so the honest difference stays visible.** Each lesson on the
challenge card shows how it was cleared: a filled mark for the desk and an
outline for the phone. A student who clears all seven at the desk gets the
coin with a gold rim, labelled "Finished at the desk". This is how the
challenge keeps the rule that the desk is where readiness is earned, without
locking out phone-only students.

Recommendation reasoned from what it means to a student: the phone finish is
what the App Store event promises and what a student on a bus can do. The
desk finish is the one that predicts exam day. Showing both on the same card
nudges toward the desk without punishing the phone.

## Calendar

- One challenge per calendar month, from the 1st to the last day, in the
  student's own time zone (the same local day the Daily uses).
- The App Store event is promoted from 14 days before the 1st, the most
  Apple allows.
- **A yearly cycle of the twelve chapters the exam asks most about**
  (ADR 0029), the same month every year. Ethics, Dynamics and Statistics
  never get a month: they are the three lightest, 10 of the 110 questions.

  | Month | Chapter | Month | Chapter |
  |---|---|---|---|
  | December | Statics | June | Mechanics of Materials |
  | January | Geotechnical | July | Mathematics |
  | February | Structural | August | Engineering Economics |
  | March | Water Resources | September | Materials |
  | April | Transportation | October | Fluid Mechanics |
  | May | Construction | November | Surveying |

- The calendar lives in one file on the server (`service/challenges.json`):
  `since` and the twelve months, each with its chapter, name and, where
  needed, a shorter App Store name. The App Store event copy is taken from
  the same entry.

## On the phone

Built to `mobile/design/DESIGN.md` like any screen.

1. **Study home.** While a challenge runs, the home (ADR 0015, one chapter)
   offers the challenge chapter. One line names it, with progress such as
   "3 of 7 lessons", and taps into the chapter's path. A student mid-way
   through another chapter keeps it, and the challenge stays one tap away.
2. **The path.** The challenge's lesson nodes carry a ring. The ring closes
   when that lesson is cleared this month, either way.
3. **The challenge sheet.** Opened from the line on the home: the coin at
   the top, unearned and dim, then the seven lessons with their marks, the
   days left, and "N students finished so far". When five or more students
   from the same school take part, a school line appears, the same rule as
   the Daily.
4. **The moment.** Finishing plays the coin moment in Rive (ADR 0024: every
   badge's moment is Rive). The gold rim gets its own short moment if it
   comes later. Haptics as for badges, no sound.
5. **Badges page.** Each finished challenge adds its coin, named by month:
   "Statics, December 2026". These are app badges, worked out from the
   synced record like the others.
6. **Notifications,** inside the existing cap of three a day, all local:
   - The 1st, in the 8am slot: "The Statics challenge starts today".
   - The 15th, if not finished: the 8pm slot carries "4 of 7 Statics
     lessons, 16 days left" instead of the Daily reminder, unless the Daily
     is still open.
   - Three days before the end, if not finished: the same.
   - Nothing at all for a student who has finished.
7. **Guests** see the challenge sheet and its lessons, with the account
   line that Profile and the Daily already use (ADR 0026). Rounds a guest
   plays during the month count once they sign up, because the guest log is
   sent in on sign-up with its dates.

## On the website

Built to the website's brand system (the website keeps its own colours;
it borrows app shapes, never app colours).

1. **Dashboard.** A challenge card near the top while one runs: the chapter,
   the seven lessons with their marks, the days left, and a link to the
   first uncleared lesson. It hides once the student has finished at the
   desk.
2. **Lesson pages** in the challenge chapter carry a small "Statics
   challenge" overline, with that lesson's status.
3. **Profile.** Finished challenges appear with the website's badges.
4. **A public page, `/challenge`,** shows this month's challenge with its
   lessons and the finished count. It gives the App Store event, emails and
   social posts somewhere to link. It has to be added to both route lists
   (`scripts/prerender.mjs` and `service/prerenderedRoutes.js`), or crawlers
   see the landing page instead.
5. **Email.** The Sunday digest gets one line on the challenge while it
   runs. A launch email on the 1st is decision 3 below.

## On the server

1. **Challenge progress is worked out from the event log, never stored**,
   the same choice made for the app badges (ADR 0024). The deriver gains
   one pure function: given the calendar entry and the account's events,
   which lessons are cleared this month and how. Unit tests cover it
   against the log alone.
2. **Two reads:**
   - `GET /api/challenge/current`, public: this month's entry, the lessons,
     and the finished count. The phone, the public page and guests use it.
   - `GET /api/account/state` gains the student's challenge progress and
     their finished challenges, so both surfaces read it the way they read
     everything else.
3. **The finished count** is computed when asked for and cached for a few
   minutes. At a few hundred accounts that costs nothing.
4. **Account deletion** needs nothing new, because nothing new is stored.

## App Store

- One in-app event per month, badge Challenge, name and copy from the
  calendar entry, art from the existing builder in
  `fe4raccoons-marketing/appstore-growth`.
- **The first event can only run once the app version with the challenge
  is live.** 1.1 is still in review, so the challenge ships in the next
  version. That makes December the realistic first month. The November
  Statics event already in App Store Connect moves to December, with its
  text changed from "Statics rounds" to "Statics lessons".
- Each event is submitted for review on its own, about three weeks before
  its month. That leaves a week for Apple before the 14-day promotion
  starts.

## Build order and size

1. Server: calendar file, the deriver function, the two reads, tests. About
   a day.
2. Website: dashboard card, lesson overline, the public page, the digest
   line. About a day.
3. Phone: home line, path rings, challenge sheet, notifications, badges
   page entry. About two days.
4. Rive: one coin moment with month and chapter as inputs, plus the gold
   rim. About a day.
5. App Store: the December event, art rebuilt with "lessons", submitted for
   review once the version is out.

Server and website can ship before the app. The website would then run
December's challenge for desk students even if the app version is late.

## Tests that guard it

- The deriver function: a lesson cleared before the 1st does not count; one
  cleared on the last local day does; the phone and desk ways both count;
  the gold rim needs all seven at the desk.
- Neither surface's mastery figure changes when a challenge lesson is
  cleared (a test on the deriver output).
- The phone's notification plan never goes over three a day and has no
  challenge notification for a finished student.
- The public route is in both prerender lists (the existing drift test
  covers it once the route is added).

## Decisions for the owner

1. **Do the phone and the desk count the same toward finishing?**
   Recommended: yes, with the two marks and the gold rim for a desk finish.
   The alternative, desk only, would make the App Store event promise
   something the app cannot deliver alone.
2. **First month December, Statics, then chapters by exam weight?**
   Recommended: yes.
3. **A launch email to every account on the 1st of each month?**
   Recommended: yes, one short email per month, with the same opt-out as
   the digest. Twelve emails a year on top of the weekly digest.

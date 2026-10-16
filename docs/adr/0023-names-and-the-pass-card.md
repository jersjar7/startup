# 0023. Two names, one card, and the card where the student already is

Date: 2026-10-16
Status: Accepted 2026-10-16, with section 6 added at the owner's request. Builds on the pass card plan in
`docs/EXAM-OUTCOME-AND-PASS-CARD.md` and replaces its section 4.4 ("The name").

The owner asked for an analysis from first principles, not a build of the
approach discussed so far: "I don't know what's the best way to do this and
you actually do know and I want you to lead on this."

## What a name is used for

Measured or read from the code on 2026-10-16:

| Use | Where | What it needs | Today, with no name |
| --- | --- | --- | --- |
| Saying hello | The app's Profile, the website's dashboard | A first name, casual is fine | "Welcome back" with no name |
| Emails | Countdown and follow-up emails ("Hey Sam, it's Jerson") | A first name, casual is fine | "Hey, it's Jerson" |
| Public boards | The weekly leaderboard, the Daily's top two | Something to show other students | The first three letters of the email and stars: `jer***` |
| The pass card | The image a student posts to LinkedIn, with ", EIT" | Their real full name, as on a credential | Asked for on the spot |

Two findings fall out of that table.

**There are two different names.** Three of the four uses want what the
student is called: casual, first name only, public on the boards. The card
wants who the student is: full and formal, published once under their own
identity. Today both come out of the same `firstName` and `lastName` fields,
which is why a casual name ends up on a credential, and why asking for a
formal name at sign-up would be more than most students want shown on a
leaderboard.

**Most students have neither.** 212 of 644 accounts have a first name (33%);
53 of the 233 made in the last 30 days (23%). Account creation does not take a
name (`POST /api/auth/create`); it only arrives later through the website's
dashboard (`PUT /api/auth/profile`). And the gap shows in public: the Daily,
which launched this week, puts `jer***` on its board for every unnamed
student.

## Decision

### 1. Keep the two names apart

- **`firstName` (and `lastName`)** stay what they are: what we call the
  student. Casual is fine. Used for hello, emails and the boards (which
  already show only the first name and a last initial).
- **`cardName`** is new: the full name printed on the pass card. Written only
  by the card flow, read only by the card. Empty until the first card.

The card's name question is filled in with `cardName` when there is one, else
with the first and last name, else empty. It is always shown, because the card
is published under the student's identity and a casual name with ", EIT" after
it is worse than one more tap.

Why a separate field rather than "the card's answer becomes the account
name": the card's link comes from an email, and emails get forwarded. A token
from an email can already fill a blank name but never change one that exists
(`service/routes/email.js`), and that rule is right. Writing the card's answer
to its own field keeps the rule intact, and keeps a student's formal name off
the public boards unless they choose it as what to be called.

### 2. Ask for the first name when the account is made, in both places

One optional step, "What should we call you?", in the app's sign-up and on the
website's sign-up, sent with the creation request. The caption says honestly
where it shows: "Shown on the Daily's board and in hello. You can change it
any time." The website's dashboard prompt stays as the catch-up for accounts
made before this.

This is the one place the analysis comes out the same as the earlier
discussion, for a reason that was not on the table then: the boards. Without
a name a student is `jer***` in front of everyone, and the Daily makes that
daily. One optional field at sign-up is the cheapest fix, and it serves three
uses at once.

The app needs a name row in the account sheet so the caption is true; the
website already has its dashboard and settings.

### 3. Make the card where the student says they passed

There are two ways to say "I passed", and the card follows each one:

- **In the app.** The app's own notification asks "How did the FE go?" nine
  days after the exam, and the outcome card on Profile takes the answer.
  Today a pass ends the conversation. It should go straight on to the name
  question and the card, drawn by the app's painter, saved to Photos or
  shared. **This is the most important piece:** it is the path every app
  student is sent down, and it needs no links at all.
- **In the email.** The website records the answer and offers the card, as
  today. On a desktop, that is the end of it.

For the email on a phone that has the app, the app claims the email's answer
links (`/api/email/exam-result/*`, `/api/email/exam-attempt/*`) and
`/pass-card/*`, so the tap from Mail opens the app on the same flow as the
in-app answer. It has to be the answer link itself: iOS and Android open an
app only for a link tapped outside the browser, and the card link is tapped
on the website's result page, inside the browser. (Apple's documented
Universal Links behavior; **unverified on our domain**. The check is one tap
from Mail on a TestFlight phone.) The website also adds Apple's Smart App
Banner to the result and card pages, so a phone that has the app but opened
the website anyway gets a one-tap way across.

Order matters here. The results email goes to every student with an exam
date, and most of them have never installed the app, which launched this
month. The website flow has to be complete on its own; the app's claim on the
links is a better experience for the few who have both.

### 4. Keep both renderers

The card is drawn twice today, in the browser (Canvas, live) and in Flutter
(`pass_card.dart`, built and tested, not yet on any screen), from one shared
layout file. A single server-side renderer serving one PNG to both was
considered and rejected for now:

- It needs a rasterizer on the server, which the outcome plan avoided on
  purpose, and the browser renderer is already live.
- The app's painter is already built and tested, so wiring it up costs a
  screen; replacing both costs a rewrite.
- What it would buy, a shareable link with the card as its preview, is a
  growth feature worth its own decision later, not part of getting the card
  right.

### 5. A permanent place for the card

Once a pass is recorded, the card is in the account for good: "Your pass
card" on the app's Profile, and on the website's dashboard. Nobody has to
find an old email to get it again.

### 6. Ask in the app as persistently as by email, and stop everywhere at the first answer

The owner's addition: send the outcome question as an app notification too,
for students who have the app, until they answer, and stop both the emails
and the notifications as soon as they answer in either place.

What already does this (read from the code, 2026-10-16):

- **The emails** ask on days 9, 16, 30 and 60 after the exam, then stop for
  good, and skip anyone whose outcome is answered or declined
  (`service/examOutcome.js`, `ASK_DAYS`; `sendExamOutcomeAsks`). The answer is
  one server field, so an answer in the app stops the emails too.
- **The question on the app's Profile** follows the same four days and the
  same stop (`shouldAskOutcome`, `outcomeAskDays`).

What does not:

- **The app's notification fires once, on day 9** (`outcomeAfterDays` in
  `notification_plan.dart`). It follows none of the later ask days.
- **It does not know about an answer.** The plan never reads whether the
  outcome is resolved, so a student who answered by email still gets "How did
  the FE go?" on their phone.

Decision:

- The notification asks on the same four days as the email, at the same
  hour of the student's morning, and never more than those four. "Until they
  respond" stops at day 60 on both, because a fifth ask two months on reads as
  nagging rather than interest.
- The plan reads the answered and declined state from the account (already
  sent to the app as `examOutcomeResolved`) and drops every outcome
  notification once it is set. The app re-arms its notifications on every
  launch, so an answer by email is honoured the next time the app opens.
- **The known limit:** these are local notifications, armed on the phone
  ahead of time, and only the app can take one back. A student who answers by
  email and does not open the app before the next ask day will still get that
  one notification. Tapping it then opens a thank-you (and the card, after a
  pass) instead of the question. Closing the gap entirely needs server-sent
  push notifications, which the app does not have; that is a decision of its
  own, not part of this one.

## Build order

1. **The app's card after an in-app "I passed"**: name question, card, save
   or share. The biggest gap, and it needs nothing else.
2. **`cardName` and the always-shown, filled-in name question**, on the
   website and in the app. Small server change, small change on each side.
3. **"What should we call you?" at sign-up**, both places, with creation
   accepting `firstName`, and the app's account-sheet name row.
4. **The app claiming the email's links**, and the Smart App Banner.
5. **"Your pass card" on Profile and the dashboard.**
6. **The outcome notification on all four ask days, dropped once answered**
   (section 6). Independent of the rest; it can ship first.

Each step ships on its own and leaves nothing half-done for the student.

## Rejected

- **One name for everything, confirmed at card time** (the earlier plan):
  either the card renames the account through a forwarded link, or the
  student's casual name keeps showing on a credential.
- **Ask for the full legal name at sign-up**: more than most students will
  give a study app on day one, and it would put formal names on public boards.
- **Ask for no name until the card**: leaves two thirds of students as
  `jer***` on the boards and nameless in every email.
- **Claim only `/pass-card/*` for the app**: never opens the app from the
  email, because that link is tapped inside the browser.
- **A server-side renderer now**: see section 4.

## The cases

`docs/mobile/name-profile-passcard-cases.md` lists every case with what
happens and how it is tested. It will be updated to this decision before
anything is built.

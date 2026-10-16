# Names, the new Profile, and the pass card: every case

Written 2026-10-16, before building, at the owner's request ("make sure all
cases are covered in the website and the app"). Brought in line with
[ADR 0023](../adr/0023-names-and-the-pass-card.md) the same day: two names
(what we call you, and the name on the card), the card made where the student
says they passed, and the outcome asked as persistently in the app as by
email. Three changes that depend on each other:

1. The app's sign-up asks what to call the student.
2. Profile becomes a page of type with two faces, empty and underway.
3. The pass card always asks for the name it prints, and opens in the app
   when the email is read on a phone that has it.

Each case below says what happens and where. A case marked **new work** is
missing today.

## What was found while checking

- **Most accounts have no name.** 212 of 644 accounts have a first name
  (33%), and 53 of the 233 made in the last 30 days (23%). Measured on the
  live database, 2026-10-16.
- **Account creation ignores a name.** `POST /api/auth/create` takes email,
  password, acquisition, school and graduation. A name only arrives later
  through `PUT /api/auth/profile`. **New work:** accept `firstName` at
  creation, cleaned by the same `sanitizeName` the profile route uses.
- **The app has nowhere to change a name.** The account sheet has no name row.
  The name step's caption promises "you can change it any time", so
  **new work:** a name row in the account sheet, using the existing
  `PUT /api/auth/profile`.
- **The app has no pass card screen.** The card's drawing exists
  (`mobile/lib/features/profile/pass_card.dart`, with tests), but nothing
  opens it. After "I passed" on the app's outcome card the flow ends. Flow
  5.2 of `docs/EXAM-OUTCOME-AND-PASS-CARD.md` was never wired. **New work.**
- **The results emails are already on in production.**
  `EXAM_OUTCOME_ENABLED=1` is set on the server, so students passing in the
  coming weeks will meet this flow.
- **The app only claims email-verification links.** `/verify-email/*` is the
  one path in `service/appLinks.js`, so the results email always opens the
  website, on a phone or not.

## How a phone decides between the app and the website

iOS and Android open the app for a link only when the app claims that link's
path (Universal Links, App Links), the app is installed, and the link is
tapped from outside the browser: from Mail, Gmail or Messages. A link tapped
inside Safari or Chrome that goes to the same website stays in the browser.
That last rule is Apple's documented Universal Links behavior. It is
**unverified on our domain**; the cheapest check is one tap of each link on a
TestFlight phone once the paths are claimed.

That rule decides the design. The email's buttons go to
`/api/email/exam-result/<token>`. The website's result page then links to
`/pass-card/<token>`, and that second tap happens inside the browser. So
claiming `/pass-card/*` alone would never open the app from the email. The app
has to claim the email's own link:

| Path the app claims | Why |
| --- | --- |
| `/verify-email/*` | Already claimed |
| `/api/email/exam-result/*` | The email's "I passed / Not this time / I did not sit it" buttons |
| `/api/email/exam-attempt/*` | The attempt buttons on the result page and in the email |
| `/pass-card/*` | A pass card link pasted or forwarded into another app |

On a desktop, or a phone without the app, nothing changes: the same links open
the website as they do today.

## Cases: the name step (app sign-up)

| # | Case | What happens |
| --- | --- | --- |
| N1 | Types a first name | Sent with account creation, saved as `firstName` |
| N2 | Taps Skip | No name. Greetings drop the name ("Good start.") |
| N3 | Types spaces only, or junk | Treated as skipped. The server's `sanitizeName` has the final say |
| N4 | Types a very long name | The field stops at 40 characters, the same limit as the pass card |
| N5 | Goes back from the password step | Returns to the name step with the name still typed |
| N6 | The email is already taken | Returns to the email step, as today; the name is kept |
| N7 | Wants to change the name later | The account sheet's new name row (**new work**) |
| N8 | Signs up on the website | The same optional step on the website's sign-up (ADR 0023). The dashboard prompt stays for older accounts |
| N10 | The step's caption | "Shown on the Daily's board and in hello. You can change it any time." The boards show the first name and a last initial, as today |
| N11 | No name, on a board | Unchanged for now (`jer***`); the step exists to make this rare |
| N9 | Signs in to an existing account in the app | The name comes from the account; nothing is asked |

## Cases: Profile

| # | Case | What happens |
| --- | --- | --- |
| P1 | Nothing done anywhere | Empty face: "your FE prep starts here", the app's 15 chapters and 135 lessons, the exam question, Start here on Mathematics |
| P2 | Studied on the website, nothing in the app | Empty face with the website's days, mastery and exam date; Start here on the chapter with the most points left |
| P3 | The website figures fail to load (offline, server down) | Falls back to P1's face rather than showing zeros |
| P4 | First round cleared, in Study or in the Daily | Switches to the underway face for good |
| P5 | The round was cleared offline | Counts at once; progress is on the phone first and syncs later |
| P6 | Lesson finished | "Carry on" moves to the next lesson; rounds left count that lesson |
| P7 | Chapter finished | The next chapter in the order the Study tab already uses |
| P8 | Everything finished | Headline "Every lesson done", the pill opens Study for review |
| P9 | No name | Headlines without the name |
| P10 | Exam date not set | "When is your exam?" with "Set the date" |
| P11 | Exam today, tomorrow, or in the quiet days | "Today", "1 day to the exam"; no reminders in the last two days, as now |
| P12 | Exam date has passed | The outcome question takes the facts' place, as the outcome card does today (it must not be lost in the redesign) |
| P13 | Passed and answered | The facts make room for "Your pass card", which opens it (the permanent place, section 4.5 of the outcome doc) |
| P14 | Small phone (iPhone SE) or large text size | The page scrolls; nothing is cut off |
| P15 | Progress reset or account deleted | Back to the empty face |
| P16 | The Daily | Never on Profile; it has its own tab |

## Cases: the pass card

| # | Case | Where | What happens |
| --- | --- | --- | --- |
| C1 | Taps "I passed" in the email on a phone with the app | App | The app opens, records the answer, shows the congratulations, then the name question and the card (**new work**) |
| C2 | Same, phone without the app | Website | As today, with the always-ask name question |
| C3 | Same, on a desktop | Website | As today, with the always-ask name question |
| C4 | Answers "I passed" on the app's outcome card | App | Straight into the same name question and card (**new work**) |
| C5 | The question is filled in | Both | With `cardName` if a card was made before, else the first and last name, else empty. Always shown, always editable |
| C6 | The name confirmed | Both | Saved as `cardName`, the card's own field. `firstName` and `lastName` are never written by the card, so a forwarded email can never rename an account or put a formal name on the boards |
| C7 | No first name on the account at all | Both | The card's name also fills the blank first and last name, as the link does today (blank only) |
| C8 | Comes back for the card later | Both | Filled in with `cardName` |
| C9 | Typing in the name field | Website | The faded card preview follows what is typed |
| C10 | Saves the image, photo access allowed | App | Saved to Photos (the first photo-permission ask in the app) |
| C11 | Photo access refused | App | The share sheet instead, which needs no permission |
| C12 | Shares to LinkedIn | Both | Website: download, then open LinkedIn, as today. App: the share sheet |
| C13 | The app opens from the link while signed out, or signed in as someone else | App | Works anyway: the email's token identifies the account, as it does on the website. Nothing else of the signed-in account is shown or changed |
| C14 | The link is old, or the student did not pass | Both | "Link not found" / no card, the same single answer for both so the link cannot reveal who passed |
| C15 | A mail client opens the link by itself before the student does | Both | Recording stays idempotent, as today: a second open cannot change a real answer |
| C16 | An app version from before this change | App | Does not claim the new paths, so the link opens the website, which works |
| C17 | Taps "Not this time" or "I did not sit it" on a phone with the app | App | The app records it and shows its own ending (the new exam date offer, the weakest chapter) |

## Cases: asking for the outcome

| # | Case | What happens |
| --- | --- | --- |
| O1 | Exam date passes, no answer | Email on days 9, 16, 30 and 60 (as today), and an app notification on the same four days for students with the app (**new work**: today only day 9) |
| O2 | Answers in the app | The emails stop (one server field, as today) and the app drops its remaining notifications at once |
| O3 | Answers by email, then opens the app | The app re-arms without the outcome notifications |
| O4 | Answers by email and does not open the app before the next ask day | One already-armed notification still fires (only the app can take a local notification back). Tapping it opens a thank-you, and the card after a pass, not the question |
| O5 | Declines ("I'd rather not say") | Everything stops, as for an answer |
| O6 | Day 60 passes with no answer | Both stop for good |
| O7 | Reminders turned off in the app | No outcome notifications; the emails continue unless unsubscribed |
| O8 | Unsubscribed from emails | No emails; the app's notifications follow the app's own switch |
| O9 | Exam date moved after the asks started | The asks follow the new date on both, as the countdowns do |

## Tests that will cover them

- Server: creation with and without a name; `cardName` written by the card
  route and never `firstName` when one exists; the claimed paths in
  `apple-app-site-association` and the Android intent filter.
- Website: the always-ask flow for C5 to C9, in `PassCard.test.jsx`.
- App, widget tests: N1 to N11, P1 to P16, C4 to C14, C17.
- App, the notification plan: O1 to O9 against a fake clock, as the
  existing reminder tests do.
- App, the walk-through file (`daily_journeys_test.dart` style): sign-up with a
  name, then Profile greets by it; a first round flips Profile; a results link
  opened in the app records the answer and reaches the card.
- Simulator (`scripts/device-tests.sh`): the card saves to Photos.
- By hand on a TestFlight phone: the email's link opens the app (C1), and the
  same link opens the website on a desktop (C3).

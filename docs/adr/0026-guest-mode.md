# 0026. A guest can study without an account; everything that belongs to an account still asks for one

Date: 2026-10-20
Status: Accepted 2026-10-20 (owner approved the screens, day and night)

## Context

Apple rejected iOS 1.0 (build 1075) on 2026-10-20 under guideline 5.1.1(v):

> The app requires users to register or log in to access features that are
> not account based. Specifically, the app requires users to register before
> accessing learning material.

The app was account-first by design (the persona panel's P0, see
`docs/mobile/` and memory "sync-design-panel"). The app is a companion to
fe4raccoons.com, where the real work happens and an account is required.

What was found before deciding (research, 2026-10-20):

- **Measured, Apple's own text.** 5.1.1(v): "If your app doesn't include
  significant account-based features, let people use it without a login."
  Registration may be asked for "when directly relevant to the core
  functionality".
- **Measured, the App Review Board's reply to another developer** (Apple
  forums thread 724336): asking users to register "for tracking users'
  purchases and game progresses is acceptable, requiring users to fully
  register for an account before entering the game is not ... Once the user
  decides to use account-based features, the app may present the
  registration or login feature at that time."
- **Unverified.** No case was found where an explanation alone, without
  opening the app, got a 5.1.1(v) rejection reversed.
- **Disproven as an option.** A 7-day guest period followed by a lockout:
  after day 7 it requires registration for non-account content, which is
  the rejection itself; Apple's only time-limited trials are a free
  "XX-day Trial" in-app purchase that unlocks paid functionality (3.1.1),
  and 2.2 says trial versions do not belong on the App Store.

## Decision

1. **A third way in.** "Try a round first" on the tour's last screen and on
   the welcome screen, under the account button, which stays first.
2. **Study is fully open to a guest**: every chapter, round and concept
   sheet. Those are the same for everyone, which is what Apple called
   "learning material".
3. **Everything that belongs to an account still asks for one**: the Daily
   (ranked against everyone and keeps a streak), mastery, badges, XP, sync
   with the website, the exam date and reminders, reporting a round, and
   everything on the website including the exam simulation. Profile and the
   Daily say what an account adds instead of showing their content; a grey
   dot on those two dock items says "needs an account". The Daily still
   shows today's three concepts, from a public preview, and points out they
   are free in Study.
4. **Nothing about a guest reaches the database.** A guest's answered rounds
   go to `GuestLog` (plain preferences, dies with the app) instead of
   `POST /sync/events`. The only server calls a guest makes are the public
   study content and `GET /api/daily/preview`, neither of which reads or
   writes an account. On sign-up or sign-in the log is sent to the new
   account in one batch, so nothing done as a guest is lost; a failed send
   keeps it for next time.
5. **No guest account on the server.** A silent anonymous account was the
   other approach found. It would have kept the Daily and sync working for a
   guest, but it puts rows in the database for people who never chose to
   sign up, and Apple then treats it as an account that needs deletion. The
   owner chose the phone-only guest.
6. **Signing out now clears the phone's rounds.** Before this, a signed-out
   phone kept the last account's map, which a guest would then have
   inherited, and which would have been sent to the guest's own account on
   sign-up. The server keeps every account's record; signing in restores
   it. A launch that fails for lack of signal keeps the rounds.

## Consequences

- The App Review notes no longer say an account is required; they say how
  to try the app without one.
- A guest who deletes the app loses their guest rounds. The screens say the
  rounds are kept on this phone.
- The Daily's preview is a new public route; the first request of a day
  creates that day's pick, which happened on the first signed-in request
  before.
- **Two bugs the end-to-end test found before release** (owner asked for
  integration tests, 2026-10-20). A guest's rounds were sent once at
  sign-up and never again if that send failed; and they went in one push,
  which the server refuses above 200 events, so a guest with more than 200
  rounds would never have had them moved. Now they go in batches of
  `GameSync.maxBatch`, each removed from the phone once it lands, and the
  next launch sends whatever is left. Every event keeps the eventId it was
  given when the round was answered, so a retry is never counted twice
  (before, a fresh id was made on every send, for every round, guest or
  not).
- Tests:
  - `mobile/test/guest_journey_test.dart`, end to end on the real router and
    screens: fresh install, Skip, "Try a round first", two rounds on the real
    game screen, Profile, the real sign-up form, the rounds on the account,
    the account's own home; the tour's last page; a relaunch as a guest; and
    450 rounds with no signal on the second batch and a relaunch, every round
    landing once. Each fix was broken on purpose and the tests failed.
  - `service/guestAdoption.test.js` pushes the exact body the app sent
    (`mobile/test/fixtures/guest-adoption-events.json`, written by the
    journey test) through the real sync and account routes: accepted,
    shown as the guest's cleared rounds, kept once on a retry, refused
    without an account, and the batch size matches the app's.
  - `mobile/test/guest_mode_test.dart` (the screens, day and night) and
    `service/dailyRoute.test.js` (the preview reads no account; playing
    still needs one).

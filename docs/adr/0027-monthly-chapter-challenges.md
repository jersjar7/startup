# 0027. Monthly chapter challenges: cleared lesson by lesson, on either surface, never mastery

Date: 2026-10-25
Status: Accepted 2026-10-25 (owner approved all three decisions in
`docs/challenges.md`). Keeps [0020](0020-mastery-is-desk-earned.md): nothing
here touches mastery. Builds on [0018](0018-one-record-per-account.md),
[0021](0021-the-daily.md), [0024](0024-app-badges.md) and
[0026](0026-guest-mode.md).

## Context

The App Store lets an app run in-app events, one of whose badges is
Challenge. A November Statics Challenge was drafted on 2026-10-20 as an event
only: the app had nothing that marked it, so a student would have done the
ordinary lessons with no progress and no finish. The owner, 2026-10-24: if we
run a challenge each month, build it into the app and the website, and spec
it first. The spec is `docs/challenges.md`; this records the decisions in it
that someone could reasonably reverse by accident.

## Decision

1. **One chapter a month, cleared lesson by lesson, during the month.** A
   lesson counts when, between the 1st and the last day (the student's local
   day), all of its games are cleared on the phone or all of its practice
   problems are answered right on the website. Work from before the month
   does not count.
2. **Both surfaces count the same toward finishing, and the card shows
   which.** A desk clear is a filled mark, a phone clear an outline. All
   lessons cleared at the desk earns the coin's gold rim, "Finished at the
   desk".
3. **Never mastery.** Finishing says what was done, like a badge.
4. **Derived from the event log, never stored**, by one pure function the
   deriver calls, the same choice as the app badges.
5. **The calendar is one file on the server** (`service/challenges.json`).
   December 2026 is Statics, the first month; after that chapters follow
   exam weight.
6. **A short launch email to every account on the 1st**, with the digest's
   opt-out.

## Consequences

- The App Store event promises something the app can deliver alone, which
  Apple requires, while the desk finish stays the one with the gold rim.
- A phone-only student can finish, so "finished" alone does not mean ready.
  The two marks are how the card says so; a later change that drops them
  drops the honesty this decision rests on.
- The first challenge needs the app version after 1.1, so it starts in
  December; the website can run it even if that version is late.
- Twelve more emails a year per account.

## Alternatives considered

- **Desk only.** Truest to 0020, but the App Store event would advertise
  something the app could not do alone.
- **Phone only, as first drafted.** Leaves out the surface where readiness
  is earned.
- **Any clear ever counts.** A student who did Statics in October would
  finish on the 1st with nothing to do; that is a checklist, not a challenge.
- **Storing progress on the account.** A second record free to drift from
  the log (rejected for the same reason in 0024).

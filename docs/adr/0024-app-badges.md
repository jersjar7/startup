# 0024. The app's own badges, worked out on the phone, drawn by Rive

Date: 2026-10-16
Status: Accepted 2026-10-16 (owner). Builds on ADR 0020 (mastery is
desk-earned) and ADR 0021 (the Daily).

## Context

The tester's point 8 (build 1075): the account sheet said "Badges 0" and
the Profile was "nothing but zeros". The twelve badges that existed were the
website's (study sessions, points, mastery levels, a perfect website
session). A student who only uses the app could earn almost none of them, so
the number was zero by construction, not because the student had done
nothing.

## Decision

1. **Nineteen badges the app awards for things done in the app.** One per
   chapter, its drawing from the chapter card, for that chapter's first
   finished lesson; and four milestones: Flawless (a whole lesson right the
   first time), First Daily, Seven in a row (Dailies on consecutive days),
   Every chapter (a round played in all fifteen). The account sheet's
   Badges figure now counts these and opens a Badges page.

2. **None of them touches mastery.** They say what was done, never how well
   it is known (ADR 0020). The page never says otherwise.

3. **Worked out on the phone, from what it already syncs, with no new
   server storage.** The rounds cleared come from the event log the phone
   already restores on sign-in; the longest Daily run comes with every
   Daily the server sends. A student signing in on a new phone has the same
   badges as soon as their progress arrives.

   *Rejected: storing badges on the account.* It would be a second record of
   facts the server already holds, free to drift from them, and it would
   need a migration and a sync path for nothing the derivation cannot do.

4. **Announced only at the moment of earning, on this phone.** A badge is
   shown when the round (or the Daily) that earned it is played here. Badges
   that arrive with a restore are simply there. Otherwise a reinstall would
   replay months of celebrations at once.

5. **Every badge's moment is a Rive animation at the level of the mock the
   owner approved** ("Rive and all our animations should use Rive at this
   level of detail", clarified as: every badge). The coin is tossed, flips,
   lands with a squash, confetti and a ring go out, the raccoon pops over the
   card, and the badge's drawing traces itself onto the face. One file holds
   all nineteen; the app picks the drawing and the colours.

   The drawings are not redrawn for Rive. They are exported from the same
   Dart painters the chapter cards use, so a drawing changed in the app and
   re-exported is changed on the coin too.

6. **Haptics yes, sound no.** A medium tap as the coin lands and a light one
   as the drawing completes, fired by events in the animation so they land
   on the frame. No sound for now, so there is no sound setting to add
   (owner, 2026-10-16). Rive can carry audio if that changes.

7. **Reduced motion is respected.** With the phone's reduce motion setting on,
   the moment is the finished card, still, with one light tap.

## Consequences

- The website's badges still exist and still show on the website. The app
  no longer counts them; the two sets are separate on purpose.
- Changing a drawing is three commands (export, generate, build), spelled
  out in `docs/mobile/badges.md`. A test fails when the app and the Rive
  file disagree on the badges, their order, or the names they share.
- The first Daily badge for an account that played Dailies before this
  build arrives quietly with the next Daily fetch, not as a moment.

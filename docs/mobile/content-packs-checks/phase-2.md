# Phase 2 results: the app learns to play packs

Date: 2026-10-27 (overnight, owner asleep). Branch `content-packs-phase2`.
Plan: [content-packs-migration.md](../content-packs-migration.md). How packs
work: [content-packs.md](../content-packs.md).

## The answer

Built and tested, behind a switch that is off for every student. A
developer build turns it on with `--dart-define=PACKS=true`. With the
switch off the app is exactly as before (checked: the full test suite, and a
test that the switched-off app opens every pack game as the built-in one).

## What was built

- **Holding a pack** (`mobile/lib/features/packs/pack_store.dart`). The app
  carries the published FE Civil pack inside it (`assets/packs/`), so the
  first lesson never waits on a download and works offline (rule 3). A
  newer pack downloaded later is kept on the phone and used from the next
  start.
- **Updating quietly.** At launch the app asks the server whether there is
  a newer version. If there is, it downloads it, checks it against the hash
  the server published, writes it whole, and only then points at it. A
  download that is cut off, damaged, or in a layout this app cannot read is
  ignored and the current pack keeps working. Nothing is shown to the
  student.
- **No round is interrupted** (rule 4). A game keeps the version it opened
  with; a newer pack reaches the next lesson opened.
- **Playing from the pack.** Every game opens through one route
  (`/games/play/:id`). With the switch on, a game the pack holds plays from
  the pack; everything else plays the built-in game as before.
- **"Update the app to play this lesson"** (`update_needed_screen.dart`).
  Shown only for a lesson this app is too old for; every other lesson keeps
  working. No version numbers and no "pack" (rule 5). The button opens the
  app's store page. Screenshot: `mobile/test/goldens/packs/update-needed.png`.
  **Needs the owner's approval** (plan, phase 2).
- **Reports carry the pack.** A report from a pack round or its concept
  sheet now says which pack version the student saw (`fe-civil@2`) and the
  game's own name, so a report can be matched to the exact wording even
  after a fix ships without an app release. The server and the owner's
  email show it.

## Checks run

| Check | Result |
|---|---|
| Holding and updating (`test/packs/pack_store_test.dart`, 14 tests) | Loads with no network; a newer version downloads, is checked and survives a restart; same version downloads nothing; a wrong hash, a newer layout, no signal, and a file damaged on disk are each ignored with the current pack still working; a round in progress keeps its version. |
| The bundled pack | Byte for byte a version the server published. |
| Which screen a student gets | Switched off: built-in game. Switched on: the pack's game. Too old for the lesson: the update screen, and only for that lesson. |
| Reports | A report from a pack round names the game and the pack version. |
| On the iPhone simulator (`integration_test/packs_device_test.dart`, iPhone 17 Pro) | The bundled pack opens with no download; the live server's pack downloads and matches its published hash; every round of every pack game is played to the end on the device; an old app is shown the update screen. 4 of 4 passed. |
| Everything else | The full mobile suite (3,422) and the website and server suite pass. |

## Open for the owner

1. **The update screen** needs approving (screenshot above).
2. **The first app version that reads packs is assumed to be 1.2.0.** The
   app in the stores is 1.1.0. A developer build is also 1.1.0 until the
   version is raised, so with the switch on it shows the update screen for
   every pack lesson; the device test plays them by telling the store it is
   1.2.0. Raise the version when the release is cut.
3. **Android in-app update** (the plan's "in-app update on Android") is not
   built; the button opens the Play Store page on both phones. It needs a
   plugin and a real Play build to test.

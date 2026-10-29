# Testing the app in the simulator

The app talks to **production** (`https://fe4raccoons.com/api`) — the same
always-on server the website uses. The content API and per-device sessions are
deployed, so there's **nothing to run locally**.

## Run it
```
cd mobile
open -a Simulator     # if no simulator is booted
flutter run
```
That's it. No backend to start.

## Try the flow
1. Onboarding → **Sign in** with your real account (e.g. admin@oqupa.com), or
   **Create account** with a fresh email.
2. Study a lesson, answer some problems.
3. Open the **website** (fe4raccoons.com) signed in as the same account — your
   XP / mastery / review should reflect what you did on the app, and you stay
   signed in on both at once (per-device sessions).

Because it's the live database, it's real data. Everything is fair game except
**Delete account**, which really deletes.

## Local backend (only if you're changing the backend)
Point `apiBaseUrl` in `lib/core/network/api_config.dart` at `_local`, then:
```
cd service && node index.js      # serves localhost:4000, loads .env
```
Regenerate content/figures if the curriculum changes:
```
npm run gen:content && npm run gen:figures
```

## Checking the drawn figures

Most items answer by pointing at a picture, so the picture is the question. Two
things guard them:

```
flutter test test/figures_test.dart      # fonts, path building, drawn text
flutter test --update-goldens test/contact_sheet_test.dart
python3 tool/contact_sheet.py            # build/contact-sheets/
```

The test catches what eyes miss: a character no bundled face can draw, a path
that never draws at all, a combining mark that lands on a letter's shoulder.
Framing and collisions still need looking at, one figure at a time and blown
up — reading the contact sheets at three across is the wrong scale for it.

`docs/mobile/figures.md` has the rules and the review pass.

## Running the tests

```
cd mobile
flutter test --timeout 10m        # everyday run, a few minutes
```

Two pack checks are slow, so `dart_test.yaml` skips them in the everyday
run. Run them by naming the file with `--run-skipped`:

| Check | When to run it | Command | Time |
|---|---|---|---|
| Pack against built-in games, pixel for pixel | A chapter's games change: that chapter only | `flutter test --run-skipped test/packs/parity_test.dart --dart-define=PARITY=<chapter>` | about 20 minutes |
| The same, every chapter | The shared drawing code changes (`lib/features/packs/`, the recording shims, or figures several chapters use) | `flutter test --run-skipped --timeout 60m test/packs/parity_test.dart` | about 3.5 hours |
| Build the pack | Before publishing a new pack version, and before any parity run (parity reads the built pack) | `flutter test --run-skipped test/packs/build_pack_test.dart` | about 35 minutes |

One game alone: add `--dart-define=PARITY_GAME=<game id>` to the chapter
command. The iPhone simulator run of every pack game
(`integration_test/packs_device_test.dart`, about 80 minutes) follows the
same rule as the full comparison.

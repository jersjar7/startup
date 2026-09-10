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

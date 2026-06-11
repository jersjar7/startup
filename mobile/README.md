# FE for Raccoons — mobile app

React Native (Expo SDK 56) study app for the FE Civil exam. Daily spaced-retrieval
of concepts + an honest hand-off to paper for problem-solving. Built on the
pedagogy in `../docs/mobile-app-north-star.md` and the visual language in
`../docs/mobile/visual-language.md`.

## Run it

```bash
cd mobile
npm install
npm run ios       # iOS simulator via Expo Go (needs Xcode)
npm run android   # Android emulator via Expo Go
npm run web       # browser (react-native-web) — used for fast dev/verification
```

First launch → onboarding (promise → exam date → pace → quick diagnostic) → the app.

## What's in it

A complete core loop: **onboarding + diagnostic → daily session (recall cards +
tap-the-trap problems) → spaced-repetition write-back → mastery that moves →
streaks → done**. Four tabs (Today / Practice / Mastery / Profile), chapter
practice, editable plan, reset. Math renders natively (Unicode); content is
offline-bundled.

## Architecture

Clean architecture — see `ARCHITECTURE.md`. `domain/` (pure) ← `data/` (adapters)
and `presentation/` (RN), wired in `di/container.ts`. All persistence is local
(`AsyncStorage`); there is no backend/account yet.

## Content

Bundled, generated from the real bank — **not** hand-maintained here:

```bash
# from the repo ROOT (not mobile/):
node scripts/generate-mobile-content.mjs
# → mobile/src/data/sources/content/generated/{problems,cards,chapters}.json
```

Currently **795 tap-the-trap problems + 424 formula-recall cards** across all 15
chapters. Regenerate after the web bank or `docs/mobile/problem-classification.json`
changes.

## Verifying changes

```bash
npx tsc --noEmit                      # type-check (must be clean)
npx expo export --platform web        # then serve mobile/dist + screenshot
```

The web target is the fast verification loop. **Caveats:** `react-native-webview`
does not render on web (we removed it); RN `Alert` is a no-op on web (use
OptionSheet); to skip onboarding in a web test, seed localStorage keys
`fe4r:plan:preferences` / `fe4r:diagnostic:familiarity`. For true native checks,
run on the iOS simulator (`xcrun simctl io <udid> screenshot`).

## Known gaps / next steps

- **Fonts:** loaded via `@expo-google-fonts` (DM Sans / Inter / JetBrains Mono).
- **Cards:** only formula-recall + 6 hand-written samples; concept/cloze recall
  cards need authoring.
- **Math:** native Unicode rendering (good for the phone's simpler math); true
  KaTeX-SVG is a future fidelity upgrade.
- **No** backend/account, push notifications, or App Store build yet. To ship:
  set up [EAS Build](https://docs.expo.dev/build/introduction/) + an Apple
  Developer account, then TestFlight.

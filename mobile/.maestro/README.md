# Maestro UI flows

End-to-end UI tests that drive the real app (taps, scrolls, assertions) on an
iOS simulator or Android emulator, capturing screenshots at each milestone.

## Run
Requires a native dev build installed on a booted device + Metro running:

    npx expo run:ios      # or: npx expo run:android   (builds + installs + Metro)

Then, from a directory where screenshots should land:

    maestro test path/to/mobile/.maestro/01-onboarding.yaml

Run them in order (01 onboards and the rest assume an onboarded account).
Maestro needs a JRE on PATH (e.g. Android Studio's bundled JDK).

## Flows
- `01-onboarding` — promise → exam date → pace → diagnostic → Today
- `02-review`     — answer recall + tap-the-trap cards through to the Done screen
- `03-navigation` — the four bottom tabs
- `04-settings`   — sound toggle, reminder sheet, reset confirmation

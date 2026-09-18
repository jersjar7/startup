# Mobile UI kit

The look and feel the FE for Raccoons phone app is being moved to, as of
2026-09-18. It started as an AI-generated reference pack (pristine copy at
`~/developer/fe4raccoons-design/fe-app-ui-kit/`) and was rebuilt here so that
every screen is a feature the app has, in a palette derived from the brand,
in the brand's three faces.

## Contents

- `DESIGN.md`: the rules. Principles, colors, type, components, motion,
  voice, banned patterns, and the table translating each of our screens.
- `tokens.json`: colors, type styles, radii, spacing, sizes and motion in a
  stack-neutral format. Map into `lib/core/theme/` once.
- `AGENT-INSTRUCTIONS.md`: the block that lives in the repo's CLAUDE.md.
- `reference-screens/png/`: eleven screenshots at 2x (780 by 1688).
- `reference-screens/html/`: the same screens as plain HTML with inline
  styles, generated from `tokens.json`.
- `build-screens.mjs`, `render.mjs`: regenerate the HTML and the PNGs
  (`node build-screens.mjs && node render.mjs`; rendering uses the local
  Google Chrome headless).

## What changed from the AI kit

Dropped, because the app does not have them: Apple and Google sign-in, the
passwordless link, the campus code, the study-hours gauge, the solid-or-shaky
self-rating deck, the five-week plan route, daily sets and "drill 10 quick
ones", the five-destination dock.

Rebuilt on what the app has: email and password sign-up with a verify-by-link
sheet, log in with a password step, the onboarding exercise as a real round,
the chapter peek, the Profile home with the exam countdown, days studied and
concept mastery, the Study tab's one-chapter and grid views, a two-item dock.

Kept as a proposal, not built: `04-exam-date`, setting the exam date on the
phone. Today the date is set on the website.

Palette: the kit's ink, paper, lime and orange became fog, cream, spring and
ember, all derived from the brand tokens (see DESIGN.md and ADR 0016).
Fonts: DM Sans, Inter and JetBrains Mono replace Bricolage Grotesque and
Geist.

## Why this reads as an app and the old screens read as a form

`docs/mobile/native-not-form.md`.

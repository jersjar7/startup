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

## App icon source

`icon-master-1024.png` is the master the launcher icons are generated from.
Keep it here so nobody has to go hunting for the original artwork.

It is the owner's raccoon-and-4 mark with **the corners filled in the circle's
own charcoal (`#2F2F2E`)**. The artwork arrived as a charcoal circle on a white
square. iOS icons are full-bleed squares that the OS masks itself, so shipping
the white corners would have produced a dark circle floating inside a white
rounded square. The fill is the circle's colour rather than brand charcoal
`#2C2C2C` (three shades off) so there is no seam where the old circle edge was.

This directory is NOT a Flutter asset bundle. `pubspec.yaml` does not list it,
so nothing here ships inside the app binary.

### Regenerating every size

    python3 - <<'PY'
    from PIL import Image
    m = Image.open("design/icon-master-1024.png").convert("RGB")
    IOS = {"Icon-App-20x20@1x.png":20,  "Icon-App-20x20@2x.png":40,  "Icon-App-20x20@3x.png":60,
           "Icon-App-29x29@1x.png":29,  "Icon-App-29x29@2x.png":58,  "Icon-App-29x29@3x.png":87,
           "Icon-App-40x40@1x.png":40,  "Icon-App-40x40@2x.png":80,  "Icon-App-40x40@3x.png":120,
           "Icon-App-60x60@2x.png":120, "Icon-App-60x60@3x.png":180,
           "Icon-App-76x76@1x.png":76,  "Icon-App-76x76@2x.png":152,
           "Icon-App-83.5x83.5@2x.png":167, "Icon-App-1024x1024@1x.png":1024}
    for n, px in IOS.items():
        m.resize((px, px), Image.LANCZOS).convert("RGB").save(
            f"ios/Runner/Assets.xcassets/AppIcon.appiconset/{n}")
    for d, px in {"mdpi":48, "hdpi":72, "xhdpi":96, "xxhdpi":144, "xxxhdpi":192}.items():
        m.resize((px, px), Image.LANCZOS).convert("RGB").save(
            f"android/app/src/main/res/mipmap-{d}/ic_launcher.png")
    PY

**Save as RGB, never RGBA.** The App Store rejects an icon with an alpha
channel, and `.convert("RGB")` is what guarantees it.

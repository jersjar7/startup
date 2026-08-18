# App icon source

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

## Regenerating every size

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

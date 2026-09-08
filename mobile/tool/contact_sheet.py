#!/usr/bin/env python3
"""Assemble one reviewable sheet per lesson from the golden screenshots.

    flutter test --update-goldens test/contact_sheet_test.dart
    python3 tool/contact_sheet.py

Every round of every item in a lesson lands on one image, in order, labelled.
The point is that a lesson can be reviewed by scanning rather than played.
"""
import pathlib
import sys

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
GOLDENS = ROOT / "test" / "goldens"
OUT = ROOT / "build" / "contact-sheets"

COLUMNS = 6
PAD = 18
LABEL = 26
SCALE = 0.42
CREAM = (255, 249, 240)
INK = (108, 99, 88)


def main() -> int:
    if not GOLDENS.exists():
        print("no goldens yet: run flutter test --update-goldens first")
        return 1

    OUT.mkdir(parents=True, exist_ok=True)
    for lesson in sorted(p for p in GOLDENS.iterdir() if p.is_dir()):
        shots = sorted(lesson.glob("*.png"))
        if not shots:
            continue

        thumbs = []
        for shot in shots:
            im = Image.open(shot)
            im = im.resize(
                (int(im.width * SCALE), int(im.height * SCALE)), Image.LANCZOS
            )
            thumbs.append((shot.stem, im))

        cols = min(COLUMNS, len(thumbs))
        rows = (len(thumbs) + cols - 1) // cols
        w, h = thumbs[0][1].size
        sheet = Image.new(
            "RGB",
            (cols * (w + PAD) + PAD, rows * (h + LABEL + PAD) + PAD),
            CREAM,
        )
        draw = ImageDraw.Draw(sheet)

        for i, (name, im) in enumerate(thumbs):
            x = PAD + (i % cols) * (w + PAD)
            y = PAD + (i // cols) * (h + LABEL + PAD)
            sheet.paste(im, (x, y))
            draw.rectangle([x, y, x + w, y + h], outline=(230, 220, 205))
            draw.text((x + 2, y + h + 6), name, fill=INK)

        path = OUT / f"{lesson.name}.png"
        sheet.save(path)
        print(f"{path.relative_to(ROOT)}  ({len(thumbs)} rounds)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

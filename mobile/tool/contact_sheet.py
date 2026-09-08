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

# Three across, four down: twelve rounds a page, each big enough to actually
# read. A lesson with more than twelve rounds gets numbered pages.
COLUMNS = 3
ROWS_PER_PAGE = 4
PAD = 22
LABEL = 30
SCALE = 0.9
CREAM = (255, 249, 240)
INK = (108, 99, 88)


def _trim_empty_bottom(im: Image.Image) -> Image.Image:
    """Cut the dead space under the button.

    Every round is rendered on a tall phone and most of them end well above the
    bottom, so untrimmed thumbnails are mostly empty and the sheet has to be
    scrolled to read anything.
    """
    im = im.convert("RGB")
    pixels = im.load()
    background = pixels[2, im.height - 2]
    last = im.height - 1
    for y in range(im.height - 1, -1, -1):
        row_has_content = any(
            pixels[x, y] != background for x in range(0, im.width, 3)
        )
        if row_has_content:
            last = y
            break
    return im.crop((0, 0, im.width, min(im.height, last + 24)))


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
            im = _trim_empty_bottom(Image.open(shot))
            im = im.resize(
                (int(im.width * SCALE), int(im.height * SCALE)), Image.LANCZOS
            )
            thumbs.append((shot.stem, im))

        per_page = COLUMNS * ROWS_PER_PAGE
        pages = [
            thumbs[i : i + per_page] for i in range(0, len(thumbs), per_page)
        ]

        for page_no, page in enumerate(pages, start=1):
            cols = min(COLUMNS, len(page))
            rows = (len(page) + cols - 1) // cols
            w, h = page[0][1].size
            sheet = Image.new(
                "RGB",
                (cols * (w + PAD) + PAD, rows * (h + LABEL + PAD) + PAD),
                CREAM,
            )
            draw = ImageDraw.Draw(sheet)

            for i, (name, im) in enumerate(page):
                x = PAD + (i % cols) * (w + PAD)
                y = PAD + (i // cols) * (h + LABEL + PAD)
                sheet.paste(im, (x, y))
                draw.rectangle([x, y, x + w, y + h], outline=(230, 220, 205))
                draw.text((x + 4, y + h + 8), name, fill=INK)

            suffix = "" if len(pages) == 1 else f"-p{page_no}"
            path = OUT / f"{lesson.name}{suffix}.png"
            sheet.save(path)
            print(
                f"{path.relative_to(ROOT)}  "
                f"({len(page)} rounds, page {page_no} of {len(pages)})"
            )
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Builds the App Store screenshots.

    python3 design/appstore/build.py          (from mobile/)

Takes the app screens photographed by `test/appstore_test.dart` and composes
one poster per slot at 1320 x 2868, the 6.9 inch class, which is the only
iPhone class Apple requires: every smaller size is scaled down from it.

The layout follows what the strongest education listings do (Brilliant,
Quizlet, Pocket Prep): caption on top, the app screen below in a plain
rounded card with no iPhone bezel, bleeding off the bottom edge. No bezel is
also the safe choice, because Apple's marketing guidelines only allow an
Apple-supplied one, used unmodified, with no added shadow.

Two rules this file exists to keep:
  - Every poster has the same ground, the same headline position and the same
    card geometry. The first three sit side by side in search results and are
    read as one composition whether or not they were designed as one.
  - Nothing has an alpha channel. Apple rejects screenshots that do.
"""

import json
import pathlib
import subprocess
import sys

HERE = pathlib.Path(__file__).parent
SHOTS = HERE.parent.parent / 'test' / 'goldens' / 'appstore'
OUT = HERE / 'out'
WORK = HERE / 'work'
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'

W, H = 1320, 2868

# The brand's own values (mobile/design/tokens.json and the website's deck).
CREAM = '#FFF9F0'
CHARCOAL = '#2C2C2C'
EMBER = '#E8683A'
INK2 = '#6B6358'
PILLS = {
    'ember': ('#FEF0EA', '#C4471A'),
    'sunbeam': ('#FEF7E0', '#8A6410'),
    'forest': ('#E8F5EE', '#1F5C46'),
}

PAGE = """<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@500;600;700;800&display=swap">
<style>
  @page {{ size: {W}px {H}px; margin: 0 }}
  * {{ box-sizing: border-box }}
  html, body {{ margin: 0; padding: 0; width: {W}px; height: {H}px; overflow: hidden }}
  body {{ background: {cream}; font-family: 'DM Sans', system-ui, sans-serif;
          -webkit-font-smoothing: antialiased }}
  .pad {{ padding: 132px 106px 0 }}
  .pill {{ display: inline-block; background: {pill_bg}; color: {pill_ink};
           font-weight: 600; font-size: 46px; letter-spacing: .085em;
           text-transform: uppercase; padding: 20px 34px 18px; border-radius: 999px }}
  h1 {{ margin: 44px 0 0; font-weight: 700; font-size: 104px; line-height: 1.04;
        letter-spacing: -.042em; color: {charcoal}; max-width: 1050px }}
  h1 em {{ font-style: normal; color: {ember} }}
  .card {{ position: absolute; left: 50%; transform: translateX(-50%);
           top: {card_top}px; width: {card_w}px; border-radius: 46px;
           overflow: hidden; background: #FFFFFF;
           box-shadow: 0 3px 10px rgba(44,44,44,.07), 0 26px 64px rgba(44,44,44,.13) }}
  .card img {{ display: block; width: 100%; height: auto }}
</style></head><body>
  <div class="pad">
    <span class="pill">{overline}</span>
    <h1>{headline}</h1>
  </div>
  <div class="card"><img src="{shot}" alt=""></div>
</body></html>
"""


def build(frames, card_w=1112, card_top=620):
    OUT.mkdir(exist_ok=True)
    WORK.mkdir(exist_ok=True)
    for f in frames:
        shot = SHOTS / f['shot']
        if not shot.exists():
            sys.exit(f"missing screen: {shot}")
        pill_bg, pill_ink = PILLS[f.get('pill', 'ember')]
        html = PAGE.format(
            W=W, H=H, cream=CREAM, charcoal=CHARCOAL, ember=EMBER,
            pill_bg=pill_bg, pill_ink=pill_ink,
            overline=f['overline'],
            headline=f['headline'],
            shot=shot.as_uri(),
            card_w=f.get('card_w', card_w),
            card_top=f.get('card_top', card_top),
        )
        page = WORK / f"{f['name']}.html"
        page.write_text(html, encoding='utf-8')
        png = OUT / f"{f['name']}.png"
        subprocess.run(
            [CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
             f'--window-size={W},{H}', '--force-device-scale-factor=1',
             '--virtual-time-budget=6000', f'--screenshot={png}', page.as_uri()],
            check=True, capture_output=True,
        )
        flatten(png)
        print('built', png.name)


def flatten(png):
    """Apple rejects a screenshot with an alpha channel. Drop it, on cream."""
    from PIL import Image
    im = Image.open(png)
    if im.mode in ('RGBA', 'LA', 'P'):
        ground = Image.new('RGB', im.size, CREAM)
        ground.paste(im.convert('RGBA'), (0, 0), im.convert('RGBA'))
        im = ground
    else:
        im = im.convert('RGB')
    if im.size != (W, H):
        sys.exit(f'{png.name} came out {im.size}, not {(W, H)}')
    im.save(png)


def sheets(frames):
    """A contact sheet to judge the set, and the row of 150 pixel tiles that
    is what a stranger actually sees in search. Anything unreadable in the
    tile row is decoration and should come out."""
    from PIL import Image, ImageDraw
    ims = [Image.open(OUT / f"{f['name']}.png") for f in frames]

    tw = 300
    th = round(H * tw / W)
    cols = min(4, len(ims))
    rows = (len(ims) + cols - 1) // cols
    sheet = Image.new('RGB', (cols * (tw + 16) + 16, rows * (th + 16) + 16), CREAM)
    for i, im in enumerate(ims):
        x = 16 + (i % cols) * (tw + 16)
        y = 16 + (i // cols) * (th + 16)
        sheet.paste(im.resize((tw, th), Image.LANCZOS), (x, y))
    sheet.save(HERE / 'contact-sheet.png')

    sw = 150
    sh = round(H * sw / W)
    strip = Image.new('RGB', (len(ims) * (sw + 10) + 10, sh + 40), (240, 240, 240))
    d = ImageDraw.Draw(strip)
    for i, im in enumerate(ims):
        strip.paste(im.resize((sw, sh), Image.LANCZOS), (10 + i * (sw + 10), 10))
        d.text((12 + i * (sw + 10), sh + 18), frames[i]['name'], fill=(60, 60, 60))
    strip.save(HERE / 'search-tiles.png')
    print('contact-sheet.png and search-tiles.png written')


if __name__ == '__main__':
    data = json.loads((HERE / 'frames.json').read_text())
    build(data['frames'])
    sheets(data['frames'])

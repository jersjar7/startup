#!/usr/bin/env python3
"""Builds the store screenshots, for both stores.

    python3 design/appstore/build.py          (from mobile/)

Takes the app screens photographed by `test/appstore_test.dart` and composes
one poster per slot, in two sizes from the same frames.json:

  appstore  1320 x 2868 -> design/appstore/out/
            The 6.9 inch class, the only iPhone class Apple requires; every
            smaller size is scaled down from it.
  play      1080 x 1920 -> design/play/screenshots/
            Play wants 9:16 or 16:9. The iPhone poster is 2.17:1, so it is
            not a crop or a resize of the Apple one: it is the same design
            laid out again on a shorter canvas.

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
WORK = HERE / 'work'
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'

# Every length below is quoted at the 1320-wide poster and multiplied by the
# target's scale, so the two sizes cannot drift apart by hand. The two
# overrides exist because the Play canvas is 930 pixels shorter, not narrower:
# the type scales, the vertical room does not.
TARGETS = {
    'appstore': {
        'w': 1320, 'h': 2868, 'out': HERE / 'out',
        'pad_top': 132, 'card_top': 620,
    },
    'play': {
        'w': 1080, 'h': 1920, 'out': HERE.parent / 'play' / 'screenshots',
        'pad_top': 96, 'card_top': 500,
    },
}

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
  .pad {{ padding: {pad_top}px {pad_side}px 0 }}
  .pill {{ display: inline-block; background: {pill_bg}; color: {pill_ink};
           font-weight: 600; font-size: {pill_fs}px; letter-spacing: .085em;
           text-transform: uppercase; padding: {pill_pt}px {pill_px}px {pill_pb}px;
           border-radius: 999px }}
  h1 {{ margin: {h1_mt}px 0 0; font-weight: 700; font-size: {h1_fs}px; line-height: 1.04;
        letter-spacing: -.042em; color: {charcoal}; max-width: {h1_maxw}px }}
  h1 em {{ font-style: normal; color: {ember} }}
  .card {{ position: absolute; left: 50%; transform: translateX(-50%);
           top: {card_top}px; width: {card_w}px; border-radius: {card_r}px;
           overflow: hidden; background: #FFFFFF;
           box-shadow: 0 {sh1}px {sh2}px rgba(44,44,44,.07), 0 {sh3}px {sh4}px rgba(44,44,44,.13) }}
  .card img {{ display: block; width: 100%; height: auto }}
</style></head><body>
  <div class="pad">
    <span class="pill">{overline}</span>
    <h1>{headline}</h1>
  </div>
  <div class="card"><img src="{shot}" alt=""></div>
</body></html>
"""

def build(frames, target, card_w=1112):
    W, H = target['w'], target['h']
    s = W / 1320
    out = target['out']
    out.mkdir(parents=True, exist_ok=True)
    WORK.mkdir(exist_ok=True)

    def n(v):
        return round(v * s)

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
            pad_top=target['pad_top'], pad_side=n(106),
            pill_fs=n(46), pill_pt=n(20), pill_px=n(34), pill_pb=n(18),
            h1_mt=n(44), h1_fs=n(104), h1_maxw=n(1050),
            card_r=n(46), sh1=n(3), sh2=n(10), sh3=n(26), sh4=n(64),
            card_w=n(f.get('card_w', card_w)),
            card_top=f.get('card_top_' + target['key'], target['card_top']),
        )
        page = WORK / f"{target['key']}-{f['name']}.html"
        page.write_text(html, encoding='utf-8')
        png = out / f"{f['name']}.png"
        subprocess.run(
            [CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
             f'--window-size={W},{H}', '--force-device-scale-factor=1',
             '--virtual-time-budget=6000', f'--screenshot={png}', page.as_uri()],
            check=True, capture_output=True,
        )
        flatten(png, (W, H))
        print('built', target['key'], png.name)


FEATURE = """<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@500;600;700&family=JetBrains+Mono:wght@500&display=swap">
<style>
  * {{ box-sizing: border-box }}
  html, body {{ margin: 0; padding: 0; width: 1024px; height: 500px; overflow: hidden }}
  body {{ background: {cream}; font-family: 'DM Sans', system-ui, sans-serif;
          -webkit-font-smoothing: antialiased; display: flex; align-items: center }}
  .copy {{ padding-left: 72px; width: 650px }}
  .pill {{ display: inline-block; background: #FEF0EA; color: #C4471A;
           font-weight: 600; font-size: 17px; letter-spacing: .09em;
           text-transform: uppercase; padding: 8px 16px 7px; border-radius: 999px }}
  h1 {{ margin: 20px 0 0; font-weight: 700; font-size: 62px; line-height: 1.03;
        letter-spacing: -.04em; color: {charcoal} }}
  h1 em {{ font-style: normal; color: {ember} }}
  .counts {{ margin-top: 24px; font-family: 'JetBrains Mono', monospace;
             font-weight: 500; font-size: 20px; letter-spacing: .01em;
             color: {ink2} }}
  .mark {{ margin-left: auto; margin-right: 78px; width: 282px; height: 282px;
           border-radius: 64px; overflow: hidden; flex: none;
           box-shadow: 0 2px 8px rgba(44,44,44,.08), 0 20px 48px rgba(44,44,44,.16) }}
  .mark img {{ display: block; width: 100%; height: 100% }}
</style></head><body>
  <div class="copy">
    <span class="pill">FE Civil exam prep</span>
    <h1>The whole exam,<br><em>completely free</em></h1>
    <div class="counts">15 chapters &middot; 135 lessons &middot; 2,269 rounds</div>
  </div>
  <div class="mark"><img src="{icon}" alt=""></div>
</body></html>
"""


def feature_graphic():
    """Play's feature graphic, 1024 x 500. The App Store has no equivalent,
    so this is the one listing asset with no Apple version to copy.

    It is the only place a stranger sees the app before any screenshot, and
    Play crops the edges on some surfaces, so everything that has to be read
    sits well inside the frame. Thumbnailed to 240 wide it still has to work:
    hence two lines of headline and nothing else competing with them."""
    out = TARGETS['play']['out'].parent
    out.mkdir(parents=True, exist_ok=True)
    icon = (HERE.parent / 'icon-master-1024.png').as_uri()
    page = WORK / 'play-feature.html'
    page.write_text(FEATURE.format(cream=CREAM, charcoal=CHARCOAL, ember=EMBER,
                                   ink2=INK2, icon=icon), encoding='utf-8')
    png = out / 'feature-graphic.png'
    subprocess.run(
        [CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
         '--window-size=1024,500', '--force-device-scale-factor=1',
         '--virtual-time-budget=6000', f'--screenshot={png}', page.as_uri()],
        check=True, capture_output=True,
    )
    flatten(png, (1024, 500))
    print('built play', png.name)


def flatten(png, size):
    """Apple rejects a screenshot with an alpha channel. Drop it, on cream."""
    from PIL import Image
    im = Image.open(png)
    if im.mode in ('RGBA', 'LA', 'P'):
        ground = Image.new('RGB', im.size, CREAM)
        ground.paste(im.convert('RGBA'), (0, 0), im.convert('RGBA'))
        im = ground
    else:
        im = im.convert('RGB')
    if im.size != size:
        sys.exit(f'{png.name} came out {im.size}, not {size}')
    im.save(png)


def sheets(frames, target):
    """A contact sheet to judge the set, and the row of 150 pixel tiles that
    is what a stranger actually sees in search. Anything unreadable in the
    tile row is decoration and should come out."""
    from PIL import Image, ImageDraw
    W, H = target['w'], target['h']
    ims = [Image.open(target['out'] / f"{f['name']}.png") for f in frames]

    tw = 300
    th = round(H * tw / W)
    cols = min(4, len(ims))
    rows = (len(ims) + cols - 1) // cols
    sheet = Image.new('RGB', (cols * (tw + 16) + 16, rows * (th + 16) + 16), CREAM)
    for i, im in enumerate(ims):
        x = 16 + (i % cols) * (tw + 16)
        y = 16 + (i // cols) * (th + 16)
        sheet.paste(im.resize((tw, th), Image.LANCZOS), (x, y))
    sheet.save(HERE / f"contact-sheet-{target['key']}.png")

    sw = 150
    sh = round(H * sw / W)
    strip = Image.new('RGB', (len(ims) * (sw + 10) + 10, sh + 40), (240, 240, 240))
    d = ImageDraw.Draw(strip)
    for i, im in enumerate(ims):
        strip.paste(im.resize((sw, sh), Image.LANCZOS), (10 + i * (sw + 10), 10))
        d.text((12 + i * (sw + 10), sh + 18), frames[i]['name'], fill=(60, 60, 60))
    strip.save(HERE / f"search-tiles-{target['key']}.png")
    print(f"contact-sheet-{target['key']}.png and search-tiles-{target['key']}.png written")


if __name__ == '__main__':
    data = json.loads((HERE / 'frames.json').read_text())
    wanted = sys.argv[1:] or list(TARGETS)
    for key in wanted:
        if key not in TARGETS:
            sys.exit(f'unknown target {key}; have {", ".join(TARGETS)}')
        target = dict(TARGETS[key], key=key)
        build(data['frames'], target)
        sheets(data['frames'], target)
        if key == 'play':
            feature_graphic()

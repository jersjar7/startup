#!/usr/bin/env python3
"""Builds the tablet store screenshots: App Store 13-inch iPad and Google
Play 7-inch and 10-inch tablets.

    design/appstore/ipad/capture.sh     (photographs the app on the iPad)
    python3 design/appstore/ipad/build.py

The screens in shots/ are the real app, photographed on an iPad Pro 13-inch
simulator in landscape by capture.sh. This script sets each one in a 3D
iPad, lifts the drawing the screen is about out of it, and adds the overline
and headline, at the exact pixel size each store asks for. Headless Chrome
draws it; the PNG is flattened (Apple rejects an alpha channel) and its size
checked.

The look, the words and the order are the phone set the owner approved and
that has been live on the App Store since 2026-11-01 (the "students" set in
~/developer/fe4raccoons-marketing/appstore-growth/build.py): real screens in
3D devices, the drawing lifted out over its own spot, the badge moment's
coins, glints and confetti, type alone with no pill behind it. Only the
device changes, from a phone to a tablet.

Outputs:
    design/appstore/ipad/out/      2752 x 2064, App Store 13-inch iPad
    design/play/tablet/7in/        1920 x 1200, Play 7-inch tablet
    design/play/tablet/10in/       2560 x 1600, Play 10-inch tablet
    contact sheets beside each
"""
import math
import os
import pathlib
import random
import subprocess
import sys

from PIL import Image, ImageDraw

HERE = pathlib.Path(__file__).resolve().parent
MOBILE = HERE.parents[2]
SHOTS = pathlib.Path(os.environ.get('SHOTS_DIR', HERE / 'shots'))
MARKS = HERE / 'assets' / 'marks'
WORK = HERE / 'work'
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
ONLY = sys.argv[1] if len(sys.argv) > 1 else ''

# Brand tokens (mobile/design/tokens.json).
CHAR, CREAM, CREAM_D, FOG = '#2C2C2C', '#FFF9F0', '#F5EDE0', '#E3DFD7'
SPRING, FOREST, EMBER, SUN, BUTTER, PEACH = (
    '#63F0A8', '#2D7A5F', '#F0703F', '#F5B731', '#F9D28A', '#FEB89C')
EM = '#E8683A'   # the headline's ember word, as on the phone set

DAY = dict(ground=CREAM, ink=CHAR, grid='rgba(44,44,44,.055)', line='rgba(44,44,44,.10)',
           shadow='rgba(44,44,44,.20)', bezel='#1E1D1B', night=False)
OVERLINE = {'ember': '#C4471A', 'forest': '#1F5C46', 'sunbeam': '#8A5A00'}
FONTS = ('<link rel="stylesheet" href="https://fonts.googleapis.com/css2?'
         'family=DM+Sans:wght@500;600;700;800&family=Inter:wght@600&display=swap">')

# The captures: an iPad Pro 13-inch in landscape, 1376 by 1032 points at 2x.
SHOT_W, SHOT_H = 2752, 2064

# Where each screen's drawing sits, in the capture's own pixels (x, y, w, h),
# and the point on it a finger would work. Read off the captures.
DRAWINGS = {
    # the flow net under the sheet pile wall, inside the round's drawing pane
    'round-net': ((70, 756, 1708, 684), None, 24),
    # the concept sheet's first picture: a footing pressing the soft clay
    'round-concept': ((1880, 508, 826, 418), None, 16),
    # the Daily's three concepts, without the pill
    'daily': ((1312, 300, 1320, 1474), None, 0),
}

# iPadOS 26 draws a small window-resize grabber in the bottom right corner of
# every app (x 2695 to 2745, y 2006 to 2057). It is system chrome, like the
# status bar, and is filled with the plain ground sampled just above it. No
# app content reaches that corner in any of the six captures.
GRABBER = (2688, 1998, SHOT_W, SHOT_H)
GRABBER_SAMPLE = (2748, 1992)


def em(word):
    return f'<em style="font-style:normal;color:{EM}">{word}</em>'


# The six, in the phone set's order and words (students set, 2026-10-24).
FRAMES = [
    dict(name='01-try', shot='guest-study', overline='No account needed', color='forest',
         headline=f'Start a round<br>before you {em("sign up")}',
         coins=[('mathematics', .075, .80, 270, 'spring', 10)],
         far=[('statics', .90, .16, 150, 'butter', -12)], seed=21),
    dict(name='02-daily', shot='daily', overline='Every morning', color='sunbeam',
         headline=f'Three concepts.<br>Every {em("day")}.', glow=SUN,
         lift='daily', grow=1.05, anchor='right',
         coins=[('ethics', .075, .80, 240, 'cream', 12)],
         far=[('statistics', .90, .16, 140, 'spring', -10)], seed=22),
    dict(name='03-results', shot='daily-done', overline='After you play', color='ember',
         headline=f'See how you did<br>against {em("everyone")}', glow=SUN,
         coins=[('water-resources', .075, .80, 230, 'butter', 12)], seed=23),
    dict(name='04-round', shot='round-net', overline='Your turn', color='forest',
         headline=f'See the concept.<br>Then {em("work it")}.', lift='round-net', bp='flownet',
         grow=1.1, anchor='right',
         coins=[('fluid-mechanics', .075, .80, 250, 'spring', 12)], seed=24),
    dict(name='05-sheet', shot='round-concept', overline='Why it works that way', color='sunbeam',
         headline=f'Every idea starts<br>with a {em("picture")}', lift='round-concept', bp='truss',
         grow=1.04, nudge=6, coins=[('geotechnical', .075, .80, 250, 'butter', 12)], seed=25),
    dict(name='06-map', shot='grid', overline='Fifteen chapters', color='ember',
         headline='One path through<br>the whole exam',
         coins=[('ethics', .075, .80, 270, 'spring', 10)],
         far=[('surveying', .90, .16, 150, 'cream', -10)], seed=26),
]


def shot_path(name):
    p = WORK / 'clean' / f'{name}.png'
    src = SHOTS / f'{name}.png'
    if not src.exists():
        raise SystemExit(f'missing capture: {src} (run capture.sh)')
    if not p.exists() or p.stat().st_mtime < src.stat().st_mtime:
        im = Image.open(src).convert('RGB')
        if im.size != (SHOT_W, SHOT_H):
            raise SystemExit(f'{src.name} is {im.size}, wanted {(SHOT_W, SHOT_H)} (landscape)')
        # paint the grabber out with the ground beside it
        ImageDraw.Draw(im).rectangle(GRABBER, fill=im.getpixel(GRABBER_SAMPLE))
        p.parent.mkdir(parents=True, exist_ok=True)
        im.save(p)
    return p.as_uri()


def mark(chapter):
    return (MARKS / f'{chapter}-charcoal.png').as_uri()


def rgba(hexc, a):
    hexc = hexc.lstrip('#')
    r, g, b = (int(hexc[i:i + 2], 16) for i in (0, 2, 4))
    return f'rgba({r},{g},{b},{a:.3f})'


def shade(hexc, k):
    hexc = hexc.lstrip('#')
    r, g, b = (int(int(hexc[i:i + 2], 16) * k) for i in (0, 2, 4))
    return f'#{r:02X}{g:02X}{b:02X}'


def render(path, html, w, h, ground):
    WORK.mkdir(exist_ok=True)
    page = WORK / f'{path.parent.name}--{path.stem}.html'
    page.write_text(html, encoding='utf-8')
    path.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
         f'--window-size={w},{h}', '--force-device-scale-factor=1',
         '--virtual-time-budget=10000', f'--screenshot={path}', page.as_uri()],
        check=True, capture_output=True,
    )
    im = Image.open(path)
    if im.size != (w, h):
        raise SystemExit(f'{path.name} came out {im.size}, wanted {(w, h)}')
    flat = Image.new('RGB', im.size, ground)
    rgba_im = im.convert('RGBA')
    flat.paste(rgba_im, (0, 0), rgba_im)
    flat.save(path)
    print('built', path.relative_to(MOBILE), f'{w}x{h}')


def page(w, h, body):
    return f"""<!doctype html><html><head><meta charset="utf-8">{FONTS}<style>
  * {{ box-sizing: border-box }}
  html, body {{ margin: 0; width: {w}px; height: {h}px; overflow: hidden }}
  body {{ background: {CREAM}; font-family: 'DM Sans', sans-serif;
          -webkit-font-smoothing: antialiased; position: relative }}
  .abs {{ position: absolute }}
  .stage {{ position: absolute; inset: 0; perspective: {int(max(w, h) * 1.6)}px;
            perspective-origin: 60% 45% }}
</style></head><body>{body}</body></html>"""


# ── the pieces, from the approved phone set ─────────────────────────────────

def ground(w, h, glows, grid=56, grid_fade=(60, 55)):
    out = []
    for (x, y, r, col, a) in glows:
        out.append(f'<div class="abs" style="left:{x - r}px;top:{y - r}px;width:{2 * r}px;height:{2 * r}px;'
                   f'border-radius:50%;background:radial-gradient(circle, {rgba(col, a)} 0%, {rgba(col, a * .45)} 38%, {rgba(col, 0)} 70%)"></div>')
    fx, fy = grid_fade
    out.append(f'<div class="abs" style="inset:0;background-image:'
               f'linear-gradient({DAY["grid"]} 2px, transparent 2px),'
               f'linear-gradient(90deg, {DAY["grid"]} 2px, transparent 2px);'
               f'background-size:{grid}px {grid}px;background-position:{w // 2}px {h // 2}px;'
               f'-webkit-mask-image:radial-gradient(ellipse {fx}% {fy}% at 55% 55%, #000 30%, transparent 100%)"></div>')
    return '\n'.join(out)


COINS = {
    'spring': (SPRING, FOREST, SPRING),
    'butter': (BUTTER, '#B8862C', SUN),
    'cream': (CREAM, '#CFC3B1', BUTTER),
}


def coin(chapter, x, y, d, kind='spring', rot=0, tilt=.92, blur=0, glow=True, shadow=True, z=75):
    """The badge coin from the Rive moment, centred on (x, y)."""
    face, rim, gl = COINS[kind]
    plinth = d * 0.067
    parts = []
    if glow:
        g = d * 2.1
        parts.append(f'<div class="abs" style="left:{x - g / 2}px;top:{y - g / 2 + plinth}px;width:{g}px;height:{g}px;'
                     f'border-radius:50%;background:radial-gradient(circle, {rgba(gl, .42)} 0%, {rgba(gl, .2)} 30%, {rgba(gl, 0)} 66%);z-index:{z}"></div>')
    if shadow:
        sw, sh = d * 1.05, d * .17
        parts.append(f'<div class="abs" style="left:{x - sw / 2}px;top:{y + d * tilt / 2 + plinth + d * .06}px;'
                     f'width:{sw}px;height:{sh}px;border-radius:50%;filter:blur({d * .03 + blur}px);'
                     f'background:radial-gradient(ellipse, rgba(44,44,44,.30), rgba(44,44,44,0) 70%);z-index:{z}"></div>')
    lw = max(2, d * .011)
    parts.append(f"""<div class="abs" style="left:{x - d / 2}px;top:{y - d / 2}px;width:{d}px;height:{d}px;
      transform:rotate({rot}deg) scaleY({tilt});filter:{'blur(%.1fpx)' % blur if blur else 'none'};z-index:{z + 1}">
      <div class="abs" style="left:0;top:{plinth}px;width:{d}px;height:{d}px;border-radius:50%;
        background:linear-gradient(180deg, {rim} 30%, {shade(rim, .62)} 100%)"></div>
      <div class="abs" style="inset:0;border-radius:50%;overflow:hidden;
        background:radial-gradient(circle at 36% 24%, rgba(255,255,255,.42) 0%, rgba(255,255,255,0) 58%),
                   linear-gradient(180deg, rgba(44,44,44,0) 48%, rgba(44,44,44,.16) 100%), {face};
        box-shadow:inset 0 {lw}px 0 rgba(255,255,255,.45), inset 0 -{lw}px 0 rgba(44,44,44,.10)">
        <div class="abs" style="inset:{d * .057}px;border-radius:50%;border:{lw}px solid transparent;
          border-color:rgba(255,255,255,.32) rgba(255,255,255,.12) rgba(44,44,44,.12) rgba(255,255,255,.12)"></div>
        <img class="abs" src="{mark(chapter)}" style="left:17%;top:17%;width:66%;height:66%">
        <div class="abs" style="left:-30%;top:-20%;width:18%;height:140%;transform:rotate(24deg);
          background:linear-gradient(90deg, rgba(255,255,255,0), rgba(255,255,255,.22), rgba(255,255,255,0))"></div>
      </div>
    </div>""")
    return '\n'.join(parts)


def confetti(seed, boxes, n, unit, colors=(EMBER, SUN, SPRING), z=55):
    rnd = random.Random(seed)
    out = []
    for i in range(n):
        bx, by, bw, bh = boxes[i % len(boxes)]
        x, y = bx + rnd.random() * bw, by + rnd.random() * bh
        col = colors[i % len(colors)]
        cap = rnd.random() < .55
        s = unit * (.6 + rnd.random() * .9)
        w, h = (s * 1.9, s * .55) if cap else (s * .8, s * .8)
        r = h / 2 if cap else s * .14
        far = rnd.random() < .22
        out.append(f'<div class="abs" style="left:{x:.0f}px;top:{y:.0f}px;width:{w:.0f}px;height:{h:.0f}px;'
                   f'border-radius:{r:.0f}px;background:{col};transform:rotate({rnd.uniform(-80, 80):.0f}deg);'
                   f'filter:{"blur(%dpx)" % (unit * .18) if far else "none"};opacity:{.55 if far else 1};'
                   f'box-shadow:inset 0 -{max(1, h * .18):.0f}px 0 rgba(44,44,44,.14);z-index:{z}"></div>')
    return '\n'.join(out)


def glint(x, y, s, color=SUN, z=56):
    return (f'<svg class="abs" style="left:{x - s / 2}px;top:{y - s / 2}px;z-index:{z}" '
            f'width="{s}" height="{s}" viewBox="-50 -50 100 100"><path fill="{color}" '
            f'd="M0 -50 C 6 -14 14 -6 50 0 C 14 6 6 14 0 50 C -6 14 -14 6 -50 0 C -14 -6 -6 -14 0 -50 Z"/></svg>')


def tap(x, y, d, z=5):
    """A finger's mark: the point being worked, with the rings going out."""
    return (f'<div class="abs" style="left:{x - d * 1.5}px;top:{y - d * 1.5}px;width:{d * 3}px;height:{d * 3}px;'
            f'border-radius:50%;border:{d * .07}px solid {rgba(SPRING, .45)};z-index:{z}"></div>'
            f'<div class="abs" style="left:{x - d}px;top:{y - d}px;width:{d * 2}px;height:{d * 2}px;'
            f'border-radius:50%;border:{d * .12}px solid {rgba(SPRING, .85)};background:{rgba(SPRING, .18)};z-index:{z}"></div>'
            f'<div class="abs" style="left:{x - d * .42}px;top:{y - d * .42}px;width:{d * .84}px;height:{d * .84}px;'
            f'border-radius:50%;background:{EMBER};box-shadow:0 0 0 {d * .12}px #fff, 0 {d * .1}px {d * .4}px rgba(44,44,44,.3);z-index:{z}"></div>')


def bp_mohr(cx, cy, r, color, sw):
    return (f'<svg class="abs" style="left:0;top:0;overflow:visible" width="1" height="1">'
            f'<g fill="none" stroke="{color}" stroke-width="{sw}" stroke-linecap="round">'
            f'<circle cx="{cx}" cy="{cy}" r="{r}"/>'
            f'<line x1="{cx - r * 1.9}" y1="{cy}" x2="{cx + r * 1.6}" y2="{cy}"/>'
            f'<line x1="{cx - r * 1.35}" y1="{cy - r * 1.3}" x2="{cx - r * 1.35}" y2="{cy + r * 1.3}"/>'
            f'<line x1="{cx - r * .8}" y1="{cy + r * .6}" x2="{cx + r * .8}" y2="{cy - r * .6}" stroke-dasharray="{sw * 4} {sw * 4}"/>'
            f'<circle cx="{cx + r * .8}" cy="{cy - r * .6}" r="{sw * 3}" fill="{color}"/>'
            f'<circle cx="{cx - r * .8}" cy="{cy + r * .6}" r="{sw * 3}" fill="{color}"/>'
            f'</g></svg>')


def bp_truss(x, y, w, color, sw):
    h = w * .32
    n = 4
    dx = w / n
    top = [(x + dx * (i + .5), y) for i in range(n)]
    bot = [(x + dx * i, y + h) for i in range(n + 1)]
    seg = []
    for i in range(n):
        seg += [(bot[i], bot[i + 1]), (bot[i], top[i]), (top[i], bot[i + 1])]
    for i in range(n - 1):
        seg.append((top[i], top[i + 1]))
    lines = ''.join(f'<line x1="{a[0]}" y1="{a[1]}" x2="{b[0]}" y2="{b[1]}"/>' for a, b in seg)
    joints = ''.join(f'<circle cx="{p[0]}" cy="{p[1]}" r="{sw * 1.6}" fill="{color}"/>' for p in top + bot)
    return (f'<svg class="abs" style="left:0;top:0;overflow:visible" width="1" height="1">'
            f'<g fill="none" stroke="{color}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round">'
            f'{lines}</g><g stroke="none">{joints}</g></svg>')


def bp_flownet(cx, cy, w, color, sw):
    paths = []
    for k in range(4):
        rx, ry = w * (.18 + k * .1), w * (.12 + k * .075)
        paths.append(f'<path d="M{cx - rx} {cy} A {rx} {ry} 0 0 0 {cx + rx} {cy}"/>')
    for k in range(-5, 6):
        ang = math.pi / 2 + k * .25
        x0, y0 = cx + math.cos(ang) * w * .1, cy + math.sin(ang) * w * .07
        x1, y1 = cx + math.cos(ang) * w * .5, cy + math.sin(ang) * w * .38
        paths.append(f'<line x1="{x0}" y1="{y0}" x2="{x1}" y2="{y1}" stroke-dasharray="{sw * 3} {sw * 3}"/>')
    paths.append(f'<line x1="{cx - w * .6}" y1="{cy}" x2="{cx + w * .6}" y2="{cy}"/>')
    return (f'<svg class="abs" style="left:0;top:0;overflow:visible" width="1" height="1">'
            f'<g fill="none" stroke="{color}" stroke-width="{sw}" stroke-linecap="round">{"".join(paths)}</g></svg>')


# ── the tablet ──────────────────────────────────────────────────────────────

# iPad Pro 13-inch (M5): 281.6 by 215.5 by 5.1 mm, a uniform bezel of about
# 8.4 mm around a 264.8 by 198.6 mm screen. Held in landscape with the top
# of the iPad on the left: the top button sits on the left edge near the top,
# the volume buttons on the top edge near the left, and the landscape front
# camera in the middle of the top bezel.
BEZEL = 8.4 / 281.6
THICKNESS = 5.1 / 281.6
SCREEN_R = 0.0185   # screen corner radius (about 18 points on a 1032 point high screen)
BUTTONS = (('left', .14, .09),          # top button: edge, start, length (of that edge)
           ('top', .10, .07), ('top', .19, .07))


def tablet_body(w, h, r):
    depth = w * THICKNESS
    step = 1.5
    n = max(2, round(depth / step))
    hi, lo = 128, 62
    out = []
    for i in range(n):
        f = i / (n - 1)
        l = round(hi - (hi - lo) * f)
        edge = 'box-shadow:inset 0 0 0 1px rgba(255,255,255,.22);' if i in (0, n - 1) else ''
        out.append(f'<div class="abs" style="inset:0;border-radius:{r}px;background:rgb({l},{l - 1},{l - 3});{edge}'
                   f'transform:translateZ({-(i + 1) * step:.1f}px)"></div>')
    bump = max(3, w * .0045)
    a, b = round(n * .2), round(n * .8)
    for side, start, ln in BUTTONS:
        for i in range(a, b + 1):
            l = round(158 - 52 * (i - a) / max(1, b - a))
            if side == 'left':
                geo = f'left:{-bump:.1f}px;top:{start * h:.1f}px;width:{bump + .5:.1f}px;height:{ln * h:.1f}px'
            else:
                geo = f'top:{-bump:.1f}px;left:{start * w:.1f}px;height:{bump + .5:.1f}px;width:{ln * w:.1f}px'
            out.append(f'<div class="abs" style="{geo};border-radius:{bump:.1f}px;background:rgb({l},{l - 1},{l - 3});'
                       f'box-shadow:0 0 0 .6px rgba(0,0,0,.4), inset 0 1px 0 rgba(255,255,255,.35);'
                       f'transform:translateZ({-(i + 1) * step:.1f}px)"></div>')
    out.insert(0, f'<div class="abs" style="inset:0;border-radius:{r}px;background:#1d1d1f;transform:translateZ({-(n + 1) * step:.1f}px);'
                  f'box-shadow:0 {w * .008}px {w * .025}px rgba(44,44,44,.16), 0 {w * .05}px {w * .13}px {DAY["shadow"]}"></div>')
    return '\n'.join(out)


def tablet(name, x, y, w, transform='', z=20, inside=''):
    """The real screen in an iPad, its top left at (x, y), w wide outside.
    `inside` is drawn over the screen in the capture's own pixels."""
    pad = w * BEZEL
    sw = w - 2 * pad
    s = sw / SHOT_W
    sh = SHOT_H * s
    h = sh + 2 * pad
    sr = sh * SCREEN_R
    r = sr + pad
    rim = max(2.5, w * .0035)
    cam = pad * .32
    return f"""<div class="abs" style="left:{x}px;top:{y}px;width:{w}px;height:{h}px;z-index:{z};
        transform-style:preserve-3d;transform:{transform};transform-origin:50% 50%">
      {tablet_body(w, h, r)}
      <div class="abs" style="inset:0;border-radius:{r}px;background:linear-gradient(140deg, #A3A19D 0%, #74726E 30%, #908E8A 60%, #62605C 100%)"></div>
      <div class="abs" style="inset:{rim}px;border-radius:{r - rim}px;background:{DAY['bezel']};
        box-shadow:inset 0 0 0 {max(1.5, w * .0012)}px rgba(255,255,255,.08)"></div>
      <div class="abs" style="left:{w / 2 - cam / 2}px;top:{pad / 2 - cam / 2}px;width:{cam}px;height:{cam}px;border-radius:50%;
        background:radial-gradient(circle at 40% 35%, #3a4552 0%, #101215 60%)"></div>
      <div class="abs" style="left:{pad}px;top:{pad}px;width:{sw}px;height:{sh}px;border-radius:{sr}px;overflow:hidden">
        <img src="{shot_path(name)}" style="display:block;width:100%">
        <div class="abs" style="left:0;top:0;width:{SHOT_W}px;height:{SHOT_H}px;transform:scale({s});transform-origin:0 0">{inside}</div>
        <div class="abs" style="inset:0;background:linear-gradient(115deg, rgba(255,255,255,.09) 0%, rgba(255,255,255,0) 30%)"></div>
      </div>
    </div>""", h


def lifted(name, x, y, w, rot=0, z=60, key=None, finger=True):
    """The drawing a screen is about, lifted out of the tablet and shown
    larger on its own card, centred on (x, y)."""
    (bx, by, bw, bh), pt, rad0 = DRAWINGS[key or name]
    s = w / bw
    h = bh * s
    rad = rad0 * s if rad0 else w * .035
    fing = tap((pt[0] - bx) * s, (pt[1] - by) * s, w * .03) if finger and pt else ''
    return f"""<div class="abs" style="left:{x - w / 2}px;top:{y - h / 2}px;width:{w}px;height:{h}px;z-index:{z};
        transform:rotate({rot}deg)">
      <div class="abs" style="inset:-{w * .02}px;border-radius:{rad + w * .02}px;background:#FFFFFF;
        box-shadow:0 {w * .01}px {w * .025}px rgba(44,44,44,.12), 0 {w * .055}px {w * .13}px {DAY['shadow']}"></div>
      <div class="abs" style="inset:0;border-radius:{rad}px;overflow:hidden">
        <img src="{shot_path(name)}" class="abs" style="left:{-bx * s}px;top:{-by * s}px;width:{SHOT_W * s}px">
      </div>
      {fing}
    </div>"""


# ── the poster ──────────────────────────────────────────────────────────────

def layout(w, h):
    """Where the words and the tablet go. On a 4:3 canvas (the iPad's own
    shape) the headline sits above the tablet, as on the phone set; on Play's
    16:10 canvases there is width to spare and not height, so the words sit
    to the left of it."""
    if w / h < 1.45:
        u = h / 2064
        tw = 1960 * u
        return dict(u=u, side=False, text_x=150 * u, text_y=140 * u, text_w=w - 300 * u,
                    over=50 * u, head=118 * u,
                    tab_x=w - tw - 230 * u, tab_y=505 * u, tab_w=tw)
    u = h / 1600
    tw = 1560 * u
    return dict(u=u, side=True, text_x=110 * u, text_y=300 * u, text_w=w - tw - 250 * u,
                over=34 * u, head=80 * u,
                tab_x=w - tw - 130 * u, tab_y=(h - tw * (215.5 / 281.6)) / 2 + 40 * u, tab_w=tw)


TILT = 'rotateY(-10deg) rotateX(4deg) rotateZ(-1.6deg)'


def over_screen(key, L):
    """Where a region of the capture lands on the poster once the capture is
    in the tablet: its centre and its width. The tablet's small turns are
    left out; the lifted card is drawn larger to cover them."""
    (bx, by, bw, bh), _, _ = DRAWINGS[key]
    pad = L['tab_w'] * BEZEL
    s = (L['tab_w'] - 2 * pad) / SHOT_W
    th = SHOT_H * s + 2 * pad
    ox, oy = L['tab_x'] + L['tab_w'] / 2, L['tab_y'] + th / 2
    x = L['tab_x'] + pad + (bx + bw / 2) * s
    y = L['tab_y'] + pad + (by + bh / 2) * s
    # the tablet turns about its centre: a little narrower (Y turn) and a
    # small roll (Z turn)
    t = math.radians(-1.6)
    dx, dy = (x - ox) * math.cos(math.radians(10)), y - oy
    return (ox + dx * math.cos(t) - dy * math.sin(t),
            oy + dx * math.sin(t) + dy * math.cos(t), bw * s)


def poster(F, w, h, out):
    L = layout(w, h)
    u = L['u']
    glow = F.get('glow', SPRING)
    body = [ground(w, h, [(w * .58, h * .62, 1000 * u, glow, .30), (w * .06, h * .9, 700 * u, BUTTER, .35),
                          (w * .96, h * .25, 600 * u, PEACH, .28)], grid=int(56 * u))]
    line = DAY['line']
    bp = F.get('bp')
    if bp == 'mohr':
        body.append(bp_mohr(w * .82, h * .17, 250 * u, line, 5 * u))
    elif bp == 'truss':
        body.append(bp_truss(w * .52, h * .05, 900 * u, line, 5 * u))
    elif bp == 'flownet':
        body.append(bp_flownet(w * .78, h * .13, 900 * u, line, 5 * u))
    # Overline and headline: type alone, never on a pill (owner, 2026-10-20).
    body.append(f"""<div class="abs" style="left:{L['text_x']}px;top:{L['text_y']}px;width:{L['text_w']}px;z-index:90">
      <div style="color:{OVERLINE[F['color']]};font-weight:600;font-size:{L['over']}px;letter-spacing:.085em;
        text-transform:uppercase">{F['overline']}</div>
      <h1 style="margin:{L['over'] * .75}px 0 0;font-weight:700;font-size:{L['head']}px;line-height:1.04;
        letter-spacing:-.042em;color:{CHAR}">{F['headline']}</h1>
    </div>""")
    inside = ''
    if F.get('finger_on_screen'):
        px, py = F['finger_on_screen']
        inside = tap(px, py, 46)
    dev, th = tablet(F['shot'], L['tab_x'], L['tab_y'], L['tab_w'], TILT, z=20, inside=inside)
    body.append(f'<div class="stage">{dev}</div>')
    if F.get('lift'):
        lx, ly, lw = over_screen(F['lift'], L)
        grow = F.get('grow', 1.16)
        if F.get('anchor') == 'right':
            # grow away from the answers only: the right edge stays put
            lx -= lw * (grow - 1) / 2 + 14 * u
        body.append(lifted(F['shot'], lx, ly + F.get('nudge', 0) * u, lw * grow, rot=1.2,
                           key=F['lift'], z=60, finger=F.get('finger', True)))
    for (ch, fx, fy, d, kind, rot) in F.get('coins', []):
        body.append(coin(ch, fx * w, fy * h, d * u, kind, rot=rot))
    for (ch, fx, fy, d, kind, rot) in F.get('far', []):
        if L['side']:
            # beside the words there is no room above the tablet: the far
            # coin drifts in the open space under the headline instead
            fx, fy = .25, .62
        body.append(coin(ch, fx * w, fy * h, d * u, kind, rot=rot, tilt=.85, blur=2, glow=False, shadow=False, z=5))
    boxes = ([(w * .62, h * .04, w * .3, h * .16), (w * .015, h * .55, w * .06, h * .3), (w * .93, h * .55, w * .05, h * .3)]
             if not L['side'] else
             [(w * .03, h * .62, w * .2, h * .3), (w * .4, h * .015, w * .4, h * .06), (w * .955, h * .4, w * .035, h * .4)])
    body.append(confetti(F.get('seed', 1), boxes, 16, 30 * u))
    body.append(glint(w * .93, h * .09, 54 * u))
    body.append(glint(w * .04, h * .5 if not L['side'] else h * .9, 40 * u))
    render(out, page(w, h, '\n'.join(body)), w, h, CREAM)


def contact_sheet(paths, out, cols=3):
    ims = [Image.open(p) for p in paths]
    tw = 900
    th = round(tw * ims[0].height / ims[0].width)
    gap = 40
    rows = math.ceil(len(ims) / cols)
    sheet = Image.new('RGB', (cols * tw + (cols + 1) * gap, rows * (th + 70) + gap), '#E3DFD7')
    d = ImageDraw.Draw(sheet)
    for i, (p, im) in enumerate(zip(paths, ims)):
        x = gap + (i % cols) * (tw + gap)
        y = gap + (i // cols) * (th + 70)
        sheet.paste(im.resize((tw, th), Image.LANCZOS), (x, y))
        d.text((x, y + th + 12), f'{p.name}  {im.width}x{im.height}', fill='#2C2C2C')
    sheet.save(out)
    print('contact sheet', out.relative_to(MOBILE))


STORES = [
    ('appstore', 2752, 2064, HERE / 'out'),
    ('play-10in', 2560, 1600, MOBILE / 'design' / 'play' / 'tablet' / '10in'),
    ('play-7in', 1920, 1200, MOBILE / 'design' / 'play' / 'tablet' / '7in'),
]


def main():
    for store, w, h, out in STORES:
        if ONLY and ONLY not in store:
            continue
        built = []
        for F in FRAMES:
            p = out / f'{F["name"]}.png'
            poster(F, w, h, p)
            built.append(p)
        sheet = (HERE / 'contact-sheet-ipad.png' if store == 'appstore'
                 else MOBILE / 'design' / 'play' / 'tablet' / f'contact-sheet-{store}.png')
        contact_sheet(built, sheet)


if __name__ == '__main__':
    main()

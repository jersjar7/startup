"""3x crops of the road as the APP draws it, for checking against the
approved mockups (road/png/checks/), and a measured check of the pin.

    flutter test tool/road_shots_test.dart     (from mobile/, writes road/app/)
    python3 design/road/app_checks.py           (from mobile/)

The shots are rendered by the app's own widgets at 3x, and points.json holds
every joint (each segment leaving and arriving), the middle of every segment,
and the pin's anchor with the road's true centre curve around it, all from
the app's own geometry. Each crop is centred on its point, with small ember
ticks on the edges marking it. Marker crops also draw the centre curve in
thin ember and a dot on the anchor.

For every marker the script measures, from PIXELS, where the coin's spring
ring actually ends straight below its centre, and prints how far that is
from the anchor; and, from the render tree, how far the drawn coin bottom
and the contact shadow's centre are from the anchor.
"""
import json, math, os
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.join(HERE, 'app')
OUT = os.path.join(APP, 'checks')
os.makedirs(OUT, exist_ok=True)
S = 3  # the shots' pixel ratio
TICK = (0xE8, 0x68, 0x3A)
SPRING = (0x63, 0xF0, 0xA8)

points = json.load(open(os.path.join(APP, 'points.json')))


def crop(img, x, y, half):
    box = (round((x - half) * S), round((y - half) * S), round((x + half) * S), round((y + half) * S))
    c = img.crop(box)
    d = ImageDraw.Draw(c)
    cx, cy = (x * S - box[0]), (y * S - box[1])
    w, h = c.size
    for (a, b, e, f) in [(cx, 0, cx, 14), (cx, h - 14, cx, h), (0, cy, 14, cy), (w - 14, cy, w, cy)]:
        d.line([(a, b), (e, f)], fill=TICK, width=3)
    return c, d, cx, cy


def ring_bottom(img, x, y, coin):
    """The lowest spring pixel straight below the coin's centre, in logical
    points, searching from the centre down past the anchor."""
    px = img.load()
    X = round(x * S)
    centre = (y - (coin / 2 + 3)) * S
    last = None
    for j in range(int(centre), int((y + 6) * S)):
        p = px[X, j][:3]
        if sum(abs(a - b) for a, b in zip(p, SPRING)) < 60:
            last = j
    # The bottom EDGE of the last spring pixel row.
    return None if last is None else (last + 1) / S


report = []
for shot, pts in points.items():
    path = os.path.join(APP, shot + '.png')
    if not os.path.exists(path):
        continue
    img = Image.open(path).convert('RGB')
    for p in pts:
        name = p['name']
        if name == 'state':
            report.append(f"{shot}: fill {p['fill']:.3f}  line {p['line']:.3f}")
            continue
        if name == 'marker':
            c, d, cx, cy = crop(img, p['x'], p['y'], 48)
            curve = [(cx + u * S, cy + v * S) for u, v in p['curve']]
            if len(curve) > 1:
                d.line(curve, fill=TICK, width=2)
            d.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], fill=TICK)
            c.save(os.path.join(OUT, f'{shot}-marker.png'))
            bottom = ring_bottom(img, p['x'], p['y'], p['coin'])
            cb = p['coinBottom']
            sc = p['shadowCentre']
            near = min((math.hypot(u, v) for u, v in p['curve']), default=None)  # sampled every 0.5% of the segment
            report.append(
                f"{shot}: pin anchor ({p['x']:.2f}, {p['y']:.2f}); "
                f"ring bottom in pixels {'n/a' if bottom is None else f'{bottom - p['y']:+.2f}'} pt; "
                f"coin bottom {math.hypot(cb[0] - p['x'], cb[1] - p['y']):.3f} pt; "
                f"shadow centre {math.hypot(sc[0] - p['x'], sc[1] - p['y']):.3f} pt; "
                f"anchor to curve {'on a platform face' if near is None else f'{near:.3f} pt'}")
            continue
        # The first few roads cover every kind (walked, the one being
        # walked, pale); the moment shots only need the road that opens.
        seg = int(name.split('-')[0][3:])
        if seg > 3 or (shot.startswith('moment-') and seg not in (2, 3)):
            continue
        c, _, _, _ = crop(img, p['x'], p['y'], 36)
        c.save(os.path.join(OUT, f'{shot}-{name}.png'))

open(os.path.join(OUT, 'report.txt'), 'w').write('\n'.join(report) + '\n')
print('\n'.join(report))
print('crops in', OUT)

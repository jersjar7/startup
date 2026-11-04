"""3x zoomed crops of every joint, a walked and a pale segment, and the
marker, in day and night, for checking the road before it is shown.

Each page writes the page position of its joints, segment middles and marker
into a hidden <pre id="checks"> on load (see checkHtml in road.mjs). This
script reads that with headless Chrome, crops the 2x PNG around each point and
scales it to 3x. Small ticks on the crop edges mark the exact point.

On every marker crop that sits on a road, the script shoots the same page
again with the pin hidden, finds the centre-line dashes in that picture on
both sides of where the pin sits (pixels of the line colour with the road's
top on both sides of them, so platform faces never count), fits a curve
through them along the road's direction, and draws that fitted dash line
across the normal crop in thin ember. The pin is on the
centre line when the ember line runs through its centre. The distance from
the fitted line to the pin's centre, measured square to the road, is printed
in CSS px.

    python3 road/checks.py      (from mobile/design, after rendering)
"""
import html, json, math, os, re, subprocess, tempfile
import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
DESIGN = os.path.dirname(HERE)
OUT = os.path.join(HERE, 'png', 'checks')
CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
os.makedirs(OUT, exist_ok=True)

PAGES = [
    ('road', 'R02-phone-mid-day', 390, 844, 'day'),
    ('road', 'R04-phone-mid-night', 390, 844, 'night'),
    ('road', 'R01-phone-new-day', 390, 844, 'day'),
    ('road', 'R03-phone-new-night', 390, 844, 'night'),
    ('road', 'R05-storyboard', 2016, 830, 'day'),
    ('tablet-screens', 'T01-study-landscape', 1180, 820, 'day'),
    ('tablet-screens', 'T01n-study-landscape-night', 1180, 820, 'night'),
]
TICK = '#E8683A'
LINE = {'day': (0xFF, 0xF9, 0xF0), 'night': (0xF2, 0xEC, 0xE2)}
TOP = {'day': (0x2C, 0x2C, 0x2C), 'night': (0x34, 0x31, 0x2C)}


def dash_fit(img, x, y, ang, mode, coin=0, reach=40, band=9):
    """Fits v = a + b*u + c*u^2 through the dash pixels around (x, y), where
    u runs along the road (screen angle `ang`) and v square to it, in 2x
    pixels. Returns (a, b, c, n_before, n_after) or None."""
    px = img.load()
    tx, ty = math.cos(ang), math.sin(ang)
    X, Y = x * 2, y * 2
    us, vs = [], []
    for j in range(int(Y - reach * 2), int(Y + reach * 2)):
        for i in range(int(X - reach * 2), int(X + reach * 2)):
            if not (0 <= i < img.width and 0 <= j < img.height):
                continue
            dx, dy = i + 0.5 - X, j + 0.5 - Y
            u, v = dx * tx + dy * ty, -dx * ty + dy * tx
            if math.hypot(dx, dy) < coin * 2 or abs(v) > band * 2 or abs(u) > reach * 2:
                continue
            if sum(abs(a - b) for a, b in zip(px[i, j], LINE[mode])) < 36:
                # A dash has the road's top on both sides of it; a cream
                # platform face does not.
                sides = [(round(i - ty * o), round(j + tx * o)) for o in (8, -8)]
                if all(0 <= a < img.width and 0 <= b < img.height
                       and sum(abs(p - q) for p, q in zip(px[a, b], TOP[mode])) < 40 for a, b in sides):
                    us.append(u); vs.append(v)
    us, vs = np.array(us), np.array(vs)
    if len(us) < 12:
        return None
    c2, c1, c0 = np.polyfit(us, vs, 2)
    return c0, c1, c2, int((us < 0).sum()), int((us > 0).sum())


def without_pin(folder, name, w, h):
    """The same page shot at 2x with the marker hidden."""
    src = os.path.join(DESIGN, folder, 'html', name + '.html')
    tmp = os.path.join(DESIGN, folder, 'html', '_nopin-' + name + '.html')
    shot = os.path.join(tempfile.gettempdir(), 'nopin-' + name + '.png')
    open(tmp, 'w').write(open(src).read().replace('z-index:200;', 'z-index:200;visibility:hidden;'))
    try:
        subprocess.run([CHROME, '--headless=new', '--hide-scrollbars', '--disable-gpu',
                        '--allow-file-access-from-files', f'--window-size={w},{h}',
                        '--force-device-scale-factor=2', '--virtual-time-budget=4000',
                        f'--screenshot={shot}', 'file://' + tmp], capture_output=True)
    finally:
        os.remove(tmp)
    return Image.open(shot).convert('RGB')


def points(folder, name, w, h):
    url = 'file://' + os.path.join(DESIGN, folder, 'html', name + '.html')
    dom = subprocess.run([CHROME, '--headless=new', '--hide-scrollbars', '--disable-gpu',
                          '--allow-file-access-from-files', f'--window-size={w},{h}',
                          '--virtual-time-budget=4000', '--dump-dom', url],
                         capture_output=True, text=True).stdout
    m = re.search(r'<pre id="checks"[^>]*>(.*?)</pre>', dom, re.S)
    return json.loads(html.unescape(m.group(1))) if m else []


def crop(img, x, y, half, out, fit=None, ang=None):
    box = [round((x - half) * 2), round((y - half) * 2), round((x + half) * 2), round((y + half) * 2)]
    c = img.crop(box).resize((half * 6, half * 6), Image.LANCZOS)
    d = ImageDraw.Draw(c)
    cx = cy = half * 3
    for a, b in (((cx, 0), (cx, 14)), ((cx, half * 6 - 14), (cx, half * 6)),
                 ((0, cy), (14, cy)), ((half * 6 - 14, cy), (half * 6, cy))):
        d.line([a, b], fill=TICK, width=3)
    if fit is not None:
        # The fitted dash line, from 2x image pixels to this 3x crop (x1.5).
        c0, c1, c2 = fit[:3]
        tx, ty = math.cos(ang), math.sin(ang)
        line = []
        for k in range(-half * 2 - 20, half * 2 + 21, 2):
            u = float(k); v = c0 + c1 * u + c2 * u * u
            line.append((cx + 1.5 * (u * tx - v * ty), cy + 1.5 * (u * ty + v * tx)))
        d.line(line, fill=TICK, width=2)
    c.save(os.path.join(OUT, out + '.png'))
    return out + '.png'


made, report = [], []
for folder, name, w, h, mode in PAGES:
    img = Image.open(os.path.join(DESIGN, folder, 'png', name + '.png')).convert('RGB')
    short = name.split('-')[0]
    seen = {}
    bare = without_pin(folder, name, w, h)
    for label, x, y, a in points(folder, name, w, h):
        if label == 'marker':
            n = seen.get('marker', 0); seen['marker'] = n + 1
            out = f'{short}-{mode}-marker' + (f'-frame{n + 1}' if short == 'R05' else '')
            fit = dash_fit(bare, x, y, float(a), mode) if a else None
            made.append(crop(img, x, y, 48, out, fit, float(a) if a else None))
            if fit:
                # The same spot with the pin hidden: the pin's outline and
                # centre over the bare road, so the dash line under it shows.
                made.append(crop(bare, x, y, 48, out + '-pin-hidden', fit, float(a)))
                rad = (18 if short.startswith('T') else 16) * 3
                im = Image.open(os.path.join(OUT, out + '-pin-hidden.png'))
                dd = ImageDraw.Draw(im); m = 48 * 3
                dd.ellipse([m - rad, m - rad, m + rad, m + rad], outline=TICK, width=2)
                dd.line([m - 7, m, m + 7, m], fill=TICK, width=2); dd.line([m, m - 7, m, m + 7], fill=TICK, width=2)
                im.save(os.path.join(OUT, out + '-pin-hidden.png'))
                report.append(f'{out}: pin centre is {fit[0] / 2:+.2f} px from the dash line, square to the road ({fit[3]} dash px behind it, {fit[4]} ahead)')
            else:
                report.append(f'{out}: ' + ('first platform, no road through it' if not a else 'too few dash pixels to fit'))
            continue
        if short == 'R05':
            continue
        if short in ('R01', 'R03'):
            continue  # R01/R03 only add the marker on the first node
        if not (40 < x < w - 40 and 40 < y < h - 40):
            continue  # runs off the screen
        part = 'joint' if ('leave' in label or 'arrive' in label) else 'segment'
        made.append(crop(img, x, y, 36 if part == 'joint' else 44, f'{short}-{mode}-{label}'))
print('\n'.join(report))
print(len(made), 'crops')

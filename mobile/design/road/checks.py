"""3x zoomed crops of every joint, a walked and a pale segment, and the
marker, in day and night, for checking the road before it is shown.

Each page writes the page position of its joints, segment middles and marker
into a hidden <pre id="checks"> on load (see checkHtml in road.mjs). This
script reads that with headless Chrome, crops the 2x PNG around each point and
scales it to 3x. Small ticks on the crop edges mark the exact point, so the
marker's centre and the road's centre line can be compared by eye.

    python3 road/checks.py      (from mobile/design, after rendering)
"""
import html, json, os, re, subprocess
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


def points(folder, name, w, h):
    url = 'file://' + os.path.join(DESIGN, folder, 'html', name + '.html')
    dom = subprocess.run([CHROME, '--headless=new', '--hide-scrollbars', '--disable-gpu',
                          '--allow-file-access-from-files', f'--window-size={w},{h}',
                          '--virtual-time-budget=4000', '--dump-dom', url],
                         capture_output=True, text=True).stdout
    m = re.search(r'<pre id="checks"[^>]*>(.*?)</pre>', dom, re.S)
    return json.loads(html.unescape(m.group(1))) if m else []


def crop(img, x, y, half, out):
    box = [round((x - half) * 2), round((y - half) * 2), round((x + half) * 2), round((y + half) * 2)]
    c = img.crop(box).resize((half * 6, half * 6), Image.LANCZOS)
    d = ImageDraw.Draw(c)
    cx = cy = half * 3
    for a, b in (((cx, 0), (cx, 14)), ((cx, half * 6 - 14), (cx, half * 6)),
                 ((0, cy), (14, cy)), ((half * 6 - 14, cy), (half * 6, cy))):
        d.line([a, b], fill=TICK, width=3)
    c.save(os.path.join(OUT, out + '.png'))
    return out + '.png'


made = []
for folder, name, w, h, mode in PAGES:
    img = Image.open(os.path.join(DESIGN, folder, 'png', name + '.png')).convert('RGB')
    short = name.split('-')[0]
    seen = {}
    for label, x, y in points(folder, name, w, h):
        if label == 'marker':
            n = seen.get('marker', 0); seen['marker'] = n + 1
            made.append(crop(img, x, y, 40, f'{short}-{mode}-marker' + (f'-frame{n + 1}' if short == 'R05' else '')))
            continue
        if short == 'R05':
            continue
        if short in ('R01', 'R03'):
            continue  # R01/R03 only add the marker on the first node
        if not (40 < x < w - 40 and 40 < y < h - 40):
            continue  # runs off the screen
        part = 'joint' if ('leave' in label or 'arrive' in label) else 'segment'
        made.append(crop(img, x, y, 36 if part == 'joint' else 44, f'{short}-{mode}-{label}'))
print('\n'.join(made))

"""Finds the raccoon pin's coin in every frame of a recording and draws where
it went, independently of the app's own numbers.

    python3 design/road/coin_trace.py VIDEO OUT_PREFIX --coin PX [--turn]
        [--from SECONDS --to SECONDS]

VIDEO is a raw simulator recording; --turn turns it back a quarter (the
tablet demo draws itself turned). --coin is the coin's outer diameter in
the video's pixels (38 pt on the phone at 3x is 114; 42 pt on the iPad at
2x is 84). Every frame is taken at 60 a second.

The coin is found by matching: a ring-and-disc template (spring ring,
charcoal inside) finds it in the first frame, then that frame's own coin,
masked to its circle, is matched in every frame near where it was last. The
coin's bottom point (its anchor) is the matched centre plus the radius.

Writes OUT_PREFIX-trace.png (every frame's anchor as a dot over the last
frame, joined in order), OUT_PREFIX-strip.png (every 2nd frame of the walk,
cropped to it) and OUT_PREFIX-trace.json (the points), and prints the walk's
steps.
"""
import argparse
import json
import math
import os
import subprocess
import tempfile

import cv2
import numpy as np


def frames(video, turn, start, end):
    tmp = tempfile.mkdtemp()
    vf = 'fps=60' + (',transpose=2' if turn else '')
    cmd = ['ffmpeg', '-v', 'error', '-i', video]
    if start is not None:
        cmd += ['-ss', str(start)]
    if end is not None:
        cmd += ['-to', str(end)]
    cmd += ['-vf', vf, os.path.join(tmp, '%05d.png')]
    subprocess.run(cmd, check=True)
    names = sorted(os.listdir(tmp))
    return [os.path.join(tmp, n) for n in names]


def ring_template(d, ground):
    t = np.zeros((d, d, 3), np.uint8)
    t[:] = ground  # the page's own ground, so night matches too
    c = (d // 2, d // 2)
    cv2.circle(t, c, d // 2, (168, 240, 99), -1)  # spring, BGR
    cv2.circle(t, c, d // 2 - max(2, d // 13), (44, 44, 44), -1)
    return t


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('video')
    ap.add_argument('out')
    ap.add_argument('--coin', type=int, required=True)
    ap.add_argument('--turn', action='store_true')
    ap.add_argument('--from', dest='start', type=float)
    ap.add_argument('--to', dest='end', type=float)
    a = ap.parse_args()

    files = frames(a.video, a.turn, a.start, a.end)
    d = a.coin
    first = cv2.imread(files[0])
    # 1. Find the coin in the first frame with a drawn ring-and-disc.
    ground = np.median(first.reshape(-1, 3), axis=0).astype(np.uint8)
    res = cv2.matchTemplate(first, ring_template(d, ground), cv2.TM_CCOEFF_NORMED)
    _, _, _, (x, y) = cv2.minMaxLoc(res)
    templ = first[y:y + d, x:x + d].copy()
    mask = np.zeros((d, d), np.uint8)
    cv2.circle(mask, (d // 2, d // 2), d // 2 - 1, 255, -1)
    mask3 = cv2.merge([mask, mask, mask])

    # 2. Follow it, frame by frame, near where it was.
    pts = []
    px, py = x, y
    reach = d
    for f in files:
        img = cv2.imread(f)
        h, w = img.shape[:2]
        x0, y0 = max(0, px - reach), max(0, py - reach)
        x1, y1 = min(w, px + d + reach), min(h, py + d + reach)
        win = img[y0:y1, x0:x1]
        r = cv2.matchTemplate(win, templ, cv2.TM_SQDIFF, mask=mask3)
        _, _, (mx, my), _ = cv2.minMaxLoc(r)
        # Sub-pixel: a parabola through the best score and its neighbours.
        def sub(v_m, v_0, v_p):
            den = v_m - 2 * v_0 + v_p
            return 0.0 if den == 0 else 0.5 * (v_m - v_p) / den
        dx = dy = 0.0
        if 0 < mx < r.shape[1] - 1:
            dx = sub(r[my, mx - 1], r[my, mx], r[my, mx + 1])
        if 0 < my < r.shape[0] - 1:
            dy = sub(r[my - 1, mx], r[my, mx], r[my + 1, mx])
        px, py = x0 + mx, y0 + my
        cx, cy = x0 + mx + dx + (d - 1) / 2, y0 + my + dy + (d - 1) / 2
        pts.append((float(cx), float(cy + d / 2)))  # the anchor: the coin's bottom point

    # 3. The walk: from the first frame that moves to the last.
    steps = [math.dist(p, q) for p, q in zip(pts, pts[1:])]
    moving = [i for i, s in enumerate(steps) if s > 0.75]
    i0, i1 = moving[0], moving[-1] + 1
    walk = pts[i0:i1 + 1]
    wsteps = sorted(steps[i0:i1])
    median = wsteps[len(wsteps) // 2]
    print(f'{a.video}: {len(files)} frames, walk {i1 - i0} frames '
          f'({(i1 - i0) / 60 * 1000:.0f} ms); step px max {wsteps[-1]:.2f}, '
          f'median {median:.2f}, ratio {wsteps[-1] / median:.2f}')

    # The trace: every frame's anchor over the last frame.
    last = cv2.imread(files[-1])
    for p, q in zip(walk, walk[1:]):
        cv2.line(last, tuple(map(round, p)), tuple(map(round, q)), (58, 104, 232), 2)
    for p in walk:
        cv2.circle(last, tuple(map(round, p)), 4, (58, 104, 232), -1)
    xs = [p[0] for p in walk]
    ys = [p[1] for p in walk]
    pad = int(d * 1.6)
    bx0, by0 = max(0, int(min(xs)) - pad), max(0, int(min(ys)) - pad - d)
    bx1 = min(last.shape[1], int(max(xs)) + pad)
    by1 = min(last.shape[0], int(max(ys)) + pad)
    cv2.imwrite(a.out + '-trace.png', last[by0:by1, bx0:bx1])

    # The strip: every 2nd frame of the walk, cropped the same way.
    tiles = []
    for k in range(i0, i1 + 1, 2):
        im = cv2.imread(files[k])[by0:by1, bx0:bx1].copy()
        cv2.putText(im, f'{(k - i0) / 60 * 1000:.0f} ms', (8, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.9, (44, 44, 44), 2)
        p = pts[k]
        cv2.circle(im, (round(p[0]) - bx0, round(p[1]) - by0), 4, (58, 104, 232), -1)
        tiles.append(im)
    th, tw = tiles[0].shape[:2]
    scale = min(1.0, 360 / tw)
    tiles = [cv2.resize(t, (int(tw * scale), int(th * scale))) for t in tiles]
    th, tw = tiles[0].shape[:2]
    cols = 8
    rows = math.ceil(len(tiles) / cols)
    sheet = np.full((rows * th, cols * tw, 3), 255, np.uint8)
    for n, t in enumerate(tiles):
        sheet[(n // cols) * th:(n // cols + 1) * th, (n % cols) * tw:(n % cols + 1) * tw] = t
    cv2.imwrite(a.out + '-strip.png', sheet)
    json.dump({'anchors': pts, 'walk': [i0, i1]}, open(a.out + '-trace.json', 'w'))


if __name__ == '__main__':
    main()

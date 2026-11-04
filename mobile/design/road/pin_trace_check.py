"""Checks the raccoon pin's walk frame by frame, from the road demo's log.

    flutter run -t lib/dev/road_moment.dart --dart-define=LOG=true > run.log
    python3 design/road/pin_trace_check.py run.log [more.log ...]

The demo prints one PINPATH line per walk (the two roads' centre curves on
their tops, the finished platform's face, and the walk's own path) and one
PINTRACE line per drawn frame (the pin's anchor, its glow's centre, which
part of the walk it is on and how high it stands). For every walk this
checks, in logical points:

- the anchor is on the path in every frame: on a road's centre curve; or,
  on a joint, on the curve lifted part of the way up the step; or on the
  face, inside its rim;
- the glow is centred on the anchor in every frame it shows;
- no jumps: the largest step between frames against the median step;
- the walk passes through the face centre.
"""
import json
import math
import sys


def near(q, line):
    best = math.inf
    for (ax, ay), (bx, by) in zip(line, line[1:]):
        dx, dy = bx - ax, by - ay
        l2 = dx * dx + dy * dy
        t = 0 if l2 == 0 else max(0, min(1, ((q[0] - ax) * dx + (q[1] - ay) * dy) / l2))
        best = min(best, math.hypot(q[0] - (ax + dx * t), q[1] - (ay + dy * t)))
    return best


def walks(lines):
    path, frames = None, []
    for line in lines:
        if 'PINPATH ' in line:
            if path and frames:
                yield path, frames
            path, frames = json.loads(line.split('PINPATH ', 1)[1]), []
        elif 'PINTRACE ' in line and path:
            frames.append(json.loads(line.split('PINTRACE ', 1)[1]))
    if path and frames:
        yield path, frames


def check(path, frames):
    k, plinth, road = path['k'], path['plinth'], path['road']
    cx, cy = path['center']
    r = path['r']
    off = []
    for f in frames:
        q, part, h = f['anchor'], f['part'], f['height']
        if part == 'oldRoad':
            d = near(q, path['into'])
        elif part == 'newRoad':
            d = near(q, path['out'])
        elif part in ('jointUp', 'jointDown'):
            assert road - 1e-6 <= h <= plinth + 1e-6, f
            lowered = (q[0], q[1] + h - road)
            d = near(lowered, path['into'] if part == 'jointUp' else path['out'])
        else:
            assert abs(h - plinth) < 1e-6, f
            gx, gy = q[0], (q[1] + plinth) / k
            d = max(0.0, math.hypot(gx - cx, gy - cy) - r)
        off.append(d)
    glow = [math.dist(f['glowCenter'], f['anchor']) for f in frames if f['glow'] > 0]
    pts = [f['anchor'] for f in frames]
    steps = [math.dist(a, b) for a, b in zip(pts, pts[1:])]
    dts = [b['ms'] - a['ms'] for a, b in zip(frames, frames[1:])]
    s = sorted(steps)
    median = s[len(s) // 2]
    # The same per 1/60 s, so a frame the device skipped is not a "jump".
    rate = sorted(st / dt * (1000 / 60) for st, dt in zip(steps, dts) if dt > 0)
    parts = []
    for f in frames:
        if not parts or parts[-1] != f['part']:
            parts.append(f['part'])
    return {
        'frames': len(frames),
        'ms': (frames[0]['ms'], frames[-1]['ms']),
        'parts': parts,
        'max_off_path': max(off),
        'max_glow_offset': max(glow) if glow else None,
        'max_step': s[-1],
        'median_step': median,
        'step_ratio': s[-1] / median,
        'max_frame_gap_ms': max(dts),
        'step_ratio_per_60th': rate[-1] / rate[len(rate) // 2],
        'face_centre_to_path': near(path['faceCenter'], path['path']),
        'face_centre_to_frames': near(path['faceCenter'], pts),
    }


def main():
    for name in sys.argv[1:]:
        for i, (path, frames) in enumerate(walks(open(name, errors='replace'))):
            res = check(path, frames)
            print(f'{name} walk {i + 1}:')
            for key, value in res.items():
                if isinstance(value, float):
                    value = f'{value:.3f}'
                print(f'  {key}: {value}')


if __name__ == '__main__':
    main()

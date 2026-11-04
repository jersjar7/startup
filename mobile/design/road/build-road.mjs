// Generates road/html/*.html: the road between lesson nodes (ROAD.md), in
// the isometric-style view the owner chose on 2026-11-03.
//
//   node road/build-road.mjs      # writes the HTML
//   node road/render-road.mjs     # screenshots them to road/png/
//   python3 road/checks.py        # 3x crops of every joint, segment, marker
//
// R01 phone, new student, day      R02 phone, mid-chapter, day
// R03 phone, new student, night    R04 phone, mid-chapter, night
// R05 the finishing storyboard     R05b reduced motion
// R06 one segment, close up
// The tablet paths are tablet-screens T01 to T03p, drawn with the same
// road.mjs.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { roadDay, roadNight, roadSize, K, isoPath, placeLabel, marker } from './road.mjs';

const T = JSON.parse(readFileSync(new URL('../tokens.json', import.meta.url)));
const day = {
  fog: T.color.fog, charcoal: T.color.charcoal, cream: T.color.cream, creamDark: T.color.creamDark,
  spring: T.color.spring, springField: T.color.spring, forest: T.color.forest,
  muted: T.color.mutedOnLight, plinth: '#CDBFA8', ember: T.color.ember, springInk: T.color.spring, ...roadDay,
};
// Night values from lib/core/theme/app_colors.dart (ADR 0025, "Warm night").
const night = {
  ...day, fog: '#1B1A18', charcoal: '#F2ECE2', cream: '#272522', creamDark: '#3A3732',
  springField: '#1C4532', forest: '#5FD69A', muted: '#A89F93', plinth: '#5A544C',
  springInk: '#1E7A4E', ...roadNight,
};
const C = Object.fromEntries(Object.keys(day).map((k) => [k, `var(--${k})`]));
const vars = (p) => Object.entries(p).map(([k, v]) => `--${k}:${v};`).join('');
const F = { display: `'DM Sans', sans-serif`, body: `'Inter', sans-serif`, mono: `'JetBrains Mono', monospace` };
const FONTS = '../../../assets/fonts/';
const PEEK = '../../../assets/brand/raccoon_peek.png';


const page = (title, W, H, body, { nightMode = false, ground = C.fog } = {}) => `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=${W}"><title>${title}</title>
<style>
@font-face{font-family:'DM Sans';font-weight:600;src:url(${FONTS}DMSans-SemiBold.ttf)}
@font-face{font-family:'DM Sans';font-weight:700;src:url(${FONTS}DMSans-Bold.ttf)}
@font-face{font-family:'DM Sans';font-weight:800;src:url(${FONTS}DMSans-ExtraBold.ttf)}
@font-face{font-family:'Inter';font-weight:400;src:url(${FONTS}Inter-Regular.ttf)}
@font-face{font-family:'Inter';font-weight:500;src:url(${FONTS}Inter-Medium.ttf)}
@font-face{font-family:'JetBrains Mono';font-weight:500;src:url(${FONTS}JetBrainsMono-Medium.ttf)}
@font-face{font-family:'JetBrains Mono';font-weight:600;src:url(${FONTS}JetBrainsMono-SemiBold.ttf)}
:root{${vars(nightMode ? night : day)}}
body{margin:0;font-family:${F.body};background:${ground};color:${C.charcoal};-webkit-font-smoothing:antialiased}
</style></head><body>
<div style="width:${W}px;height:${H}px;box-sizing:border-box;position:relative;overflow:hidden;background:${ground};color:${C.charcoal};">
${body}
</div></body></html>
`;
const abs = (x, y, w, h, inner, extra = '') =>
  `<div style="position:absolute;left:${x}px;top:${y}px;${w != null ? `width:${w}px;` : ''}${h != null ? `height:${h}px;` : ''}${extra}">${inner}</div>`;
const eyebrow = (t, color = C.charcoal, size = 12) =>
  `<span style="font-family:${F.mono};font-size:${size}px;font-weight:600;letter-spacing:0.06em;text-transform:uppercase;color:${color};">${t}</span>`;
const checkSvg = (s, w) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>`;

const mathNodes = [
  { section: 'Analytic geometry · 6', name: 'Straight Lines &amp; Quadratics' },
  { name: 'Logarithms' },
  { name: 'Right Triangle Trigonometry' },
  { name: 'Law of Sines &amp; Law of Cosines' },
  { name: 'Unit Circle &amp; Trig Identities' },
  { name: 'Circles &amp; Conic Sections' },
];
const withState = (doneCount, nowFrac) => mathNodes.map((n, i) => ({
  ...n,
  state: i < doneCount ? 'done' : i === doneCount && nowFrac != null ? 'now' : 'todo',
  frac: nowFrac,
  sub: i < doneCount ? 'all 3 done' : i === doneCount && nowFrac != null ? `${Math.round(nowFrac * 3)} of 3 done` : '0 of 3 done',
}));

// The phone path: platforms 84 across, 70 either side, 120 apart on screen.
const PH = { r: 42, amp: 70, row: 120, labelW: 156, labelGap: 28, edge: 12, name: 14, detail: 10.5 };

// A path with its labels. Labels stay flat and sit beside their platform,
// moved off the road when they would cross it.
const pathHtml = (nodes, width, m, opts = {}) => {
  const p = isoPath({ nodes, width, r: m.r, size: roadSize.phone, col: C, row: m.row, amp: m.amp, peek: PEEK, ...opts });
  const obstacles = [...p.obstacles];
  obstacles.push(...p.markerObstacles);
  const label = (n) => {
    const right = n.x <= width / 2;
    const now = n.state === 'now';
    const subColor = now ? C.charcoal : n.state === 'done' ? C.forest : C.muted;
    const inner = `<span style="display:flex;flex-direction:column;gap:3px;${right ? '' : 'align-items:flex-end;text-align:right;'}"><span style="font-family:${F.display};font-weight:700;font-size:${m.name}px;line-height:1.15;letter-spacing:-0.02em;color:${C.charcoal};">${n.name}</span><span style="font-family:${F.mono};font-size:${m.detail}px;color:${subColor};">${n.sub}</span></span>`;
    const box = now ? `<span style="display:inline-block;padding:12px 14px;border-radius:20px;background:${C.springField};">${inner}</span>` : inner;
    const gap = m.r + m.labelGap;
    const room = right ? width - (n.x + gap) - m.edge : n.x - gap - m.edge;
    const w = Math.min(m.labelW, room);
    const lines = Math.ceil((n.name.replace(/&amp;/g, '&').length * m.name * 0.55) / (w - (now ? 28 : 0)));
    const h = lines * m.name * 1.15 + 3 + m.detail * 1.25 + (now ? 24 : 0);
    const x0 = right ? n.x + gap : n.x - gap - w;
    const cy = placeLabel({ x0, x1: x0 + w, cy: n.T, h, obstacles });
    return `<div style="position:absolute;z-index:90;top:${cy}px;left:${x0}px;width:${w}px;transform:translateY(-50%);display:flex;${right ? '' : 'justify-content:flex-end;'}">${box}</div>`;
  };
  return {
    ...p,
    html: `<svg aria-hidden="true" width="${width}" height="${p.height}" style="position:absolute;left:0;top:0;overflow:visible" fill="none">${p.svg}</svg>
${p.sections.map((s) => `<div style="position:absolute;z-index:80;left:24px;top:${s.y + 4}px;">${eyebrow(s.text, C.muted)}</div>`).join('')}
${opts.labels === false ? '' : p.placed.map(label).join('')}
${p.markerHtml}${p.checkHtml}`,
  };
};

// ── the phone ──
const W = 390, H = 844;
const phoneTop = (cleared) => `
${abs(20, 48, 48, 48, `<span style="display:flex;align-items:center;justify-content:center;width:48px;height:48px;border-radius:24px;background:${C.charcoal};color:${C.fog};"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"/></svg></span>`)}
${abs(270, 64, 96, null, `<div style="text-align:right;">${eyebrow('Chapter 1', C.muted)}</div>`)}
${abs(24, 116, 342, null, `<h1 style="margin:0;font-family:${F.display};font-weight:800;font-size:32px;line-height:1;letter-spacing:-0.045em;">Mathematics &amp; Computational Tools</h1>`)}
${abs(24, 196, null, null, `<span style="display:inline-flex;align-items:center;height:34px;padding:0 14px;border-radius:17px;background:${C.charcoal};color:${C.springInk};font-family:${F.mono};font-size:12px;font-weight:600;">${cleared} of 16 cleared</span>`)}`;
const PATH_TOP = 238;
const phone = (title, nodes, cleared, opts, nightMode) => {
  const p = pathHtml(nodes, W, PH, opts);
  return page(title, W, H, `${phoneTop(cleared)}${abs(0, PATH_TOP, W, H - PATH_TOP, p.html)}`, { nightMode });
};

const out = {};
const fresh = withState(0, null);
const mid = withState(2, 1 / 3);
const midOpts = { markerAt: { seg: 1, f: 0.72 } };
out['R01-phone-new-day'] = phone('Road, phone, new student', fresh, 0, { markerAt: {} }, false);
out['R02-phone-mid-day'] = phone('Road, phone, mid-chapter', mid, 2, midOpts, false);
out['R03-phone-new-night'] = phone('Road, phone, new student, night', fresh, 0, { markerAt: {} }, true);
out['R04-phone-mid-night'] = phone('Road, phone, mid-chapter, night', mid, 2, midOpts, true);

// ── the storyboard: the road from Right Triangle Trig to Law of Sines ──
// Times run from when the finished lesson settles (its own pop has played).
const ease = (t) => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2);
const span = (t, a, b) => ease(Math.min(1, Math.max(0, (t - a) / (b - a))));
const back = (t) => { const c = 1.7; return 1 + (c + 1) * Math.pow(t - 1, 3) + c * Math.pow(t - 1, 2); };
const at = (t) => {
  const rise = Math.min(1, Math.max(0, t / 300));
  const bounce = Math.min(1, Math.max(0, (t - 1800) / 300));
  const scale = t < 300 ? 0.95 + 0.05 * back(rise) : t < 1800 ? 1 : 1 + 0.05 * Math.sin(Math.PI * bounce) * (1 - bounce * 0.3);
  const lift = t < 300 ? 4 * Math.sin(Math.PI * rise) : 0;
  return { fill: span(t, 150, 1200), line: span(t, 400, 1200), pulse: t >= 1200 && t <= 1800 ? span(t, 1200, 1800) : null, scale, lift };
};
const FRAMES = [
  [0, 'Ready', 'The finished platform has turned charcoal with its check. The road ahead is a pale slab; the next platform waits at 95%.', '0 ms'],
  [300, 'The next platform rises', '95% to 100% with a 4 pt lift and a slight overshoot.', '0 to 300 ms'],
  [700, 'The road fills', 'The charcoal top runs from the finished platform along the curve. Ease in-out.', '150 to 1200 ms'],
  [1200, 'The centre line draws in', 'Cream dashes reveal behind the fill, never ahead of it.', '400 to 1200 ms'],
  [1500, 'A pulse runs ahead', 'A small spring glow travels the road to the next platform. The marker follows just behind it, on the centre line.', '1200 to 1800 ms'],
  [2100, 'Arrival', 'The next platform does one small bounce and settles at 100%. The marker parks on the road where it meets it. No breath yet: that waits until the lesson is started.', '1800 to 2100 ms'],
];
const FW = 300, FH = 270;
const crop = (p) => {
  const n2 = p.placed[2];
  return `<div style="position:relative;width:${FW}px;height:${FH}px;border-radius:24px;overflow:hidden;background:${C.fog};"><div style="position:absolute;left:${-(n2.x - 60)}px;top:${-(n2.T - 70)}px;width:${W}px;height:${p.height}px;">${p.html}</div></div>`;
};
const frame = (t) => {
  const s = at(t);
  const markerF = s.pulse != null ? Math.max(0, s.pulse * 0.8 - 0.08) : t >= 1800 ? 0.72 : null;
  return crop(pathHtml(withState(3, null), W, PH, {
    seg: (i) => (i === 2 ? { fill: s.fill, line: s.line, pulse: s.pulse } : {}),
    nodeFx: (i) => (i === 3 ? { scale: s.scale, lift: s.lift } : {}),
    markerAt: markerF != null ? { seg: 2, f: markerF } : { seg: 1, f: 0.72 },
    labels: false,
  }));
};
const SBW = 6 * FW + 5 * 24 + 96, SBH = 830;
const timeline = () => {
  const total = 2100, w = SBW - 96, x = (ms) => (ms / total) * w;
  const bars = [['Platform rises', 0, 300], ['Road fills', 150, 1200], ['Centre line', 400, 1200], ['Pulse', 1200, 1800], ['Bounce', 1800, 2100]];
  return bars.map(([name, a, b], i) => `
<div style="position:absolute;left:0;top:${i * 34}px;width:${w}px;height:24px;">
  <div style="position:absolute;left:${x(a)}px;width:${x(b) - x(a)}px;height:24px;border-radius:12px;background:${C.charcoal};"></div>
  <div style="position:absolute;left:${x(a) + 12}px;top:4px;font-family:${F.mono};font-size:11px;font-weight:600;color:${C.fog};white-space:nowrap;">${name} · ${b - a} ms</div>
</div>`).join('') + `<div style="position:absolute;left:0;top:${bars.length * 34 + 4}px;width:${w}px;display:flex;justify-content:space-between;font-family:${F.mono};font-size:11px;color:${C.muted};">${[0, 300, 600, 900, 1200, 1500, 1800, 2100].map((m) => `<span>${m}</span>`).join('')}</div>`;
};
out['R05-storyboard'] = page('Road, finishing storyboard', SBW, SBH, `
${abs(48, 40, 1400, null, `${eyebrow('The road opens · phone, day · times from when the finished lesson settles', C.muted)}<h1 style="margin:10px 0 0;font-family:${F.display};font-weight:800;font-size:36px;letter-spacing:-0.04em;">Finishing a lesson opens the road to the next one</h1>`)}
${FRAMES.map(([t, name, what, when], i) => abs(48 + i * (FW + 24), 140, FW, null, `${frame(t)}
<div style="margin-top:14px;font-family:${F.mono};font-size:12px;font-weight:600;color:${C.charcoal};">${i + 1} · ${when}</div>
<div style="margin-top:6px;font-family:${F.display};font-weight:700;font-size:17px;letter-spacing:-0.02em;">${name}</div>
<div style="margin-top:6px;font-size:13px;line-height:1.5;color:${C.muted};">${what}</div>`)).join('')}
${abs(48, 590, SBW - 96, 220, timeline())}
${abs(48, 790, SBW - 96, null, `<div style="font-family:${F.mono};font-size:12px;font-weight:600;color:${C.muted};">Ease in-out on the road, line and pulse. A slight overshoot on the platform only. Total 2.1 s, and the student can tap anywhere meanwhile.</div>`)}
`);

const rmFrame = (after) => crop(pathHtml(withState(3, null), W, PH, {
  seg: (i) => (i === 2 ? (after ? { fill: 1, line: 1 } : { fill: 0 }) : {}),
  markerAt: after ? { seg: 2, f: 0.72 } : { seg: 1, f: 0.72 },
  labels: false,
}));
out['R05b-reduced-motion'] = page('Road, reduced motion', 2 * FW + 24 + 96 + 420, 520, `
${abs(48, 40, 900, null, `${eyebrow('Reduce motion is on', C.muted)}<h1 style="margin:10px 0 0;font-family:${F.display};font-weight:800;font-size:32px;letter-spacing:-0.04em;">One quiet cross-fade instead</h1>`)}
${abs(48, 140, FW, null, `${rmFrame(false)}<div style="margin-top:14px;font-family:${F.mono};font-size:12px;font-weight:600;">Before</div>`)}
${abs(48 + FW + 24, 140, FW, null, `${rmFrame(true)}<div style="margin-top:14px;font-family:${F.mono};font-size:12px;font-weight:600;">After · 180 ms</div>`)}
${abs(48 + 2 * FW + 64, 150, 380, null, `<div style="font-size:15px;line-height:1.6;">
<p style="margin:0 0 12px;">The whole segment, top, side wall and centre line together, cross-fades in over 180 ms.</p>
<p style="margin:0 0 12px;">No fill running along the curve, no pulse, no lift and no bounce. Every platform sits at 100%.</p>
<p style="margin:0;">The marker fades out where it was and in at its new place, in the same 180 ms.</p></div>`)}
`);

// ── one segment, close up ──
const closeUp = () => {
  const two = (st) => [{ name: 'a', state: 'done', sub: '' }, { name: 'b', state: st, sub: '' }];
  const R = 42, size = roadSize.phone;
  const base = isoPath({ nodes: two('todo'), width: 300, r: R, size, col: C, row: 120, amp: 70, top: 0 });
  const curve = base.curves[0], a = base.placed[0], HR = size.road;
  const view = [a.x - 50, a.T - 34, 220, 150]; // the two platforms and the road
  const scene = (fill, nightMode, k, v = view, extra = '') => {
    const p = isoPath({ nodes: two('todo'), width: 300, r: R, size, col: C, row: 120, amp: 70, top: 0, seg: () => ({ fill, line: fill }) });
    return `<div style="${vars(nightMode ? night : day)}"><svg width="${v[2] * k}" height="${v[3] * k}" viewBox="${v.join(' ')}" fill="none" style="display:block;border-radius:24px;background:${C.fog};">${p.svg}${extra}</svg></div>`;
  };
  const scr = (q, h) => ({ x: q.x, y: q.y * K - h });
  const lead = (n, from, to, k = 1) => `<line x1="${from.x}" y1="${from.y}" x2="${to.x}" y2="${to.y}" stroke="${C.ember}" stroke-width="${0.5 / k}"/><circle cx="${from.x}" cy="${from.y}" r="${1.1 / k}" fill="${C.ember}"/><circle cx="${to.x}" cy="${to.y}" r="${3.6 / k}" fill="${C.ember}"/><text x="${to.x}" y="${to.y + 1.4 / k}" text-anchor="middle" font-family="JetBrains Mono" font-weight="600" font-size="${4 / k}" fill="#FFFFFF">${n}</text>`;
  const q = curve.at(0.5);
  const nx = Math.cos(q.angle + Math.PI / 2), ny = Math.sin(q.angle + Math.PI / 2);
  const side = ny > 0 ? 1 : -1; // the ground normal that points toward the viewer
  const edge = (o, at = q) => {
    const ax = Math.cos(at.angle + Math.PI / 2), ay = Math.sin(at.angle + Math.PI / 2);
    return { x: at.x + side * ax * o, y: at.y + side * ay * o };
  };
  const top = scr(q, HR);
  const near = scr(edge(size.width / 2 - 1, curve.at(0.64)), HR);
  const wall = scr(edge(size.width / 2), HR / 2 - 1);
  const shadow = scr(edge(size.width / 2 + 4), -size.shadowY);
  const surf = scr(edge(-5, curve.at(0.36)), HR);
  const leads = lead(1, surf, { x: surf.x + 6, y: surf.y - 26 }) + lead(2, near, { x: near.x + 30, y: near.y - 12 })
    + lead(3, top, { x: top.x + 28, y: top.y - 22 }) + lead(4, wall, { x: wall.x + 22, y: wall.y + 14 }) + lead(5, shadow, { x: shadow.x - 6, y: shadow.y + 20 });
  // The joint where the road leaves the first platform.
  const j0 = scr(curve.at(0), HR);
  const JV = [j0.x - 20, j0.y - 14, 40, 26];
  const lip = { x: j0.x, y: j0.y };
  const plinthPt = { x: a.x + R * 0.55, y: a.Y + R * K * 0.83 - 2 };
  const jl = lead(6, lip, { x: JV[0] + 34, y: JV[1] + 5 }, 2.6) + lead(7, plinthPt, { x: JV[0] + 5, y: JV[1] + 22 }, 2.6);
  const callout = (n, x, y, text) => `<div style="position:absolute;left:${x}px;top:${y}px;display:flex;gap:10px;align-items:baseline;max-width:460px;"><span style="font-family:${F.mono};font-weight:600;font-size:13px;color:${C.charcoal};">${n}</span><span style="font-size:14px;line-height:1.5;">${text}</span></div>`;
  return `
${abs(48, 40, 1300, null, `${eyebrow('One segment · phone sizes at 4x', C.muted)}<h1 style="margin:10px 0 0;font-family:${F.display};font-weight:800;font-size:36px;letter-spacing:-0.04em;">Platforms and a road, one material</h1>`)}
${abs(48, 140, 880, 600, scene(1, false, 4, view, leads))}
${abs(970, 150, 382, null, `<div style="position:relative;height:520px;">
${callout(1, 0, 0, '<b>Top.</b> Charcoal, 20 wide on the ground, like a finished platform&rsquo;s face.')}
${callout(2, 0, 72, '<b>Rim.</b> tile2, 2 wide on both edges of the top: a lit edge, never a second surface.')}
${callout(3, 0, 120, '<b>Centre line.</b> Cream, 2 wide, 7 on and 9 off.')}
${callout(4, 0, 168, '<b>Side wall.</b> Plinth tan, 8 tall, under the near edge. The platforms are 14, so they stand taller.')}
${callout(5, 0, 266, '<b>Shadow.</b> pipOff on the ground, blurred, under the wall.')}
${callout(6, 0, 316, '<b>Joint.</b> The road ends at the platform&rsquo;s side, in front of it, 6 below its face, with a tan lip along the cut. At the far end the next platform hides the road.')}
</div>`)}
${abs(48, 790, 520, null, `${scene(1, false, 13, JV, jl)}<div style="margin-top:12px;font-family:${F.mono};font-size:12px;font-weight:600;">The joint, close up</div><div style="font-size:13px;color:${C.muted};line-height:1.5;margin-top:4px;">6 the lip where the road meets the platform. 7 the platform&rsquo;s side, standing above the road.</div>`)}
${abs(620, 790, 340, null, `${scene(0, false, 1.5)}<div style="margin-top:12px;font-family:${F.mono};font-size:12px;font-weight:600;">Not walked yet, day</div><div style="font-size:13px;color:${C.muted};line-height:1.5;margin-top:4px;">creamDark top, cream rim, plinth tan wall, half the shadow. No line.</div>`)}
${abs(1000, 790, 340, null, `${scene(1, true, 1.5)}<div style="margin-top:12px;font-family:${F.mono};font-size:12px;font-weight:600;">Walked, night</div><div style="font-size:13px;color:${C.muted};line-height:1.5;margin-top:4px;">tile top, lineOnDark rim, night plinth wall, night ink line.</div>`)}
`;
};
out['R06-segment-closeup'] = page('Road, one segment', 1400, 1240, closeUp());

const dir = new URL('./html/', import.meta.url);
mkdirSync(dir, { recursive: true });
for (const [name, html] of Object.entries(out)) writeFileSync(new URL(`${name}.html`, dir), html);
console.log('wrote', Object.keys(out).length, 'road screens');

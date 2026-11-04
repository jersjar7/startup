// Generates road/html/*.html: the road between lesson nodes (ROAD.md).
//
//   node road/build-road.mjs      # writes the HTML
//   node road/render-road.mjs     # screenshots them to road/png/
//
// R01 phone, new student, day      R02 phone, mid-chapter, day
// R03 phone, new student, night    R04 phone, mid-chapter, night
// R05 the finishing storyboard     R06 one segment, close up
// The tablet path is tablet-screens T01 (and every other tablet path),
// which draws its road with the same road.mjs.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { roadDay, roadNight, roadSize, segmentCurve, segmentSvg, marker } from './road.mjs';

const T = JSON.parse(readFileSync(new URL('../tokens.json', import.meta.url)));
const day = {
  fog: T.color.fog, charcoal: T.color.charcoal, cream: T.color.cream, creamDark: T.color.creamDark,
  spring: T.color.spring, springField: T.color.spring, forest: T.color.forest,
  muted: T.color.mutedOnLight, plinth: '#CDBFA8', ember: T.color.ember, check: T.color.spring, springInk: T.color.spring, ...roadDay,
};
// Night values from lib/core/theme/app_colors.dart (ADR 0025, "Warm night").
const night = {
  ...day, fog: '#1B1A18', charcoal: '#F2ECE2', cream: '#272522', creamDark: '#3A3732',
  springField: '#1C4532', forest: '#5FD69A', muted: '#A89F93', plinth: '#5A544C',
  check: '#1C4532', springInk: '#1E7A4E', ...roadNight,
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

// A node, as the Rive artboard draws it: done, now (ring), todo. `scale` and
// `lift` are the arrival moment's two numbers.
const disc = (n, d, { scale = 1, lift = 0, ring = false } = {}) => {
  const r = d / 2;
  const plinth = `0 ${Math.round(d * 0.08)}px 0 ${C.plinth}`;
  const ringed = ring ? `, 0 0 0 6px ${C.fog}, 0 0 0 10px ${C.charcoal}` : '';
  let face;
  if (n.state === 'done') face = `<span style="display:flex;align-items:center;justify-content:center;width:${d}px;height:${d}px;border-radius:${r}px;background:${C.charcoal};color:${C.spring};box-shadow:${plinth}${ringed};">${checkSvg(d * 0.4, 3)}</span>`;
  else if (n.state === 'now') {
    const pct = Math.round((n.frac ?? 0) * 100);
    face = `<span style="position:relative;display:block;width:${d}px;height:${d}px;border-radius:${r}px;background:conic-gradient(${C.charcoal} 0 ${pct}%, ${C.spring} ${pct}% 100%);box-shadow:${plinth}${ringed};"><span style="position:absolute;inset:${Math.round(d * 0.11)}px;border-radius:50%;background:${C.cream};"></span></span>`;
  } else face = `<span style="display:block;width:${d}px;height:${d}px;border-radius:${r}px;background:${C.cream};box-shadow:${plinth}${ringed};"></span>`;
  return `<div style="transform:translateY(${-lift}px) scale(${scale});transform-origin:50% 60%;">${face}</div>`;
};

const mathNodes = [
  { section: 'Analytic geometry · 6', name: 'Straight Lines &amp; Quadratics' },
  { name: 'Logarithms' },
  { name: 'Right Triangle Trigonometry' },
  { name: 'Law of Sines &amp; Law of Cosines' },
  { name: 'Unit Circle &amp; Trig Identities' },
  { name: 'Circles &amp; Conic Sections' },
  { section: 'Single-variable calculus · 4', name: 'Derivatives &amp; Derivative Rules' },
];
const withState = (doneCount, nowFrac) => mathNodes.map((n, i) => ({
  ...n,
  state: i < doneCount ? 'done' : i === doneCount && nowFrac != null ? 'now' : 'todo',
  frac: nowFrac,
  sub: i < doneCount ? 'all 3 done' : i === doneCount && nowFrac != null ? `${Math.round(nowFrac * 3)} of 3 done` : '0 of 3 done',
}));

// The phone's metrics, from PathMetrics.phone at 390 wide.
const PH = { node: 84, amp: 70, row: 124, header: 48, top: 26, topSpace: 10, labelW: 156, labelGap: 28, edge: 12 };

// Places the nodes the way ChapterPath.build does.
const layout = (nodes, width, m) => {
  const placed = [], sections = [];
  let y = m.top;
  nodes.forEach((n, i) => {
    if (n.section) { sections.push({ y, text: n.section }); y += m.header; }
    const x = width / 2 + (i % 2 === 0 ? -m.amp : m.amp);
    placed.push({ ...n, x, y: y + m.topSpace + m.node / 2 });
    y += m.row;
  });
  return { placed, sections, height: y + 40 };
};

// A path: road segments, section eyebrows, nodes, labels, and the marker.
// `seg(i)` gives segment i its own { fill, line, pulse }.
const pathHtml = (nodes, width, m, size, { seg = () => ({}), nodeFx = () => ({}), markerAt = null, ringed = null, labels = true } = {}) => {
  const { placed, sections, height } = layout(nodes, width, m);
  const r = m.node / 2;
  const curves = [];
  let svg = '';
  for (let i = 0; i < placed.length - 1; i++) {
    const a = placed[i], b = placed[i + 1];
    const curve = segmentCurve({ x: a.x, y: a.y }, { x: b.x, y: b.y }, r);
    curves.push(curve);
    const walked = a.state === 'done' ? { fill: 1, line: 1 } : {};
    svg += segmentSvg(curve, { ...walked, ...seg(i), size, col: C });
  }
  const label = (n, i) => {
    const right = n.x <= width / 2;
    const now = n.state === 'now';
    const subColor = now ? C.charcoal : n.state === 'done' ? C.forest : C.muted;
    const inner = `<span style="display:flex;flex-direction:column;gap:3px;${right ? '' : 'align-items:flex-end;text-align:right;'}"><span style="font-family:${F.display};font-weight:700;font-size:${m.nameSize ?? 14}px;line-height:1.15;letter-spacing:-0.02em;color:${C.charcoal};">${n.name}</span><span style="font-family:${F.mono};font-size:${m.detailSize ?? 10.5}px;color:${subColor};">${n.sub}</span></span>`;
    const box = now ? `<span style="display:inline-block;padding:12px 14px;border-radius:20px;background:${C.springField};">${inner}</span>` : inner;
    const gap = r + m.labelGap;
    const room = right ? width - (n.x + gap) - m.edge : n.x - gap - m.edge;
    const w = Math.min(m.labelW, room);
    const pos = right ? `left:${n.x + gap}px;` : `left:${n.x - gap - w}px;`;
    return `<div style="position:absolute;top:${n.y}px;${pos}width:${w}px;transform:translateY(-50%);display:flex;${right ? '' : 'justify-content:flex-end;'}">${box}</div>`;
  };
  let mk = '';
  if (markerAt) {
    const p = markerAt.seg != null ? curves[markerAt.seg].at(markerAt.f) : { x: placed[0].x, y: placed[0].y - r - 6 };
    mk = marker(p.x, p.y, PEEK, m.marker ?? 32, { ring: C.fog });
  }
  return {
    height,
    placed,
    curves,
    html: `<svg aria-hidden="true" width="${width}" height="${height}" style="position:absolute;left:0;top:0;overflow:visible" fill="none">${svg}</svg>
${sections.map((s) => `<div style="position:absolute;left:24px;top:${s.y + 10}px;padding:4px 12px 4px 0;background:${C.fog};">${eyebrow(s.text, C.muted)}</div>`).join('')}
${placed.map((n, i) => `<div style="position:absolute;left:${n.x - r}px;top:${n.y - r}px;z-index:2;">${disc(n, m.node, { ring: ringed === i, ...nodeFx(i) })}</div>`).join('')}
${labels ? placed.map(label).join('') : ''}
${mk}`,
  };
};

// ── the phone ──
const W = 390, H = 844;
const phoneTop = (cleared) => `
${abs(20, 48, 48, 48, `<span style="display:flex;align-items:center;justify-content:center;width:48px;height:48px;border-radius:24px;background:${C.charcoal};color:${C.fog};"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"/></svg></span>`)}
${abs(270, 64, 96, null, `<div style="text-align:right;">${eyebrow('Chapter 1', C.muted)}</div>`)}
${abs(24, 116, 342, null, `<h1 style="margin:0;font-family:${F.display};font-weight:800;font-size:32px;line-height:1;letter-spacing:-0.045em;">Mathematics &amp; Computational Tools</h1>`)}
${abs(24, 196, null, null, `<span style="display:inline-flex;align-items:center;height:34px;padding:0 14px;border-radius:17px;background:${C.charcoal};color:${C.springInk};font-family:${F.mono};font-size:12px;font-weight:600;">${cleared} of 16 cleared</span>`)}`;

const phone = (title, nodes, cleared, opts, nightMode) => {
  const p = pathHtml(nodes, W, PH, roadSize.phone, opts);
  return page(title, W, H, `${phoneTop(cleared)}${abs(0, 238, W, H - 238, p.html)}`, { nightMode });
};

const out = {};
const fresh = withState(0, null);
const mid = withState(2, 1 / 3);
const midOpts = { markerAt: { seg: 1, f: 0.72 } };
out['R01-phone-new-day'] = phone('Road, phone, new student', fresh, 0, { markerAt: {} }, false);
out['R02-phone-mid-day'] = phone('Road, phone, mid-chapter', mid, 2, midOpts, false);
out['R03-phone-new-night'] = phone('Road, phone, new student, night', fresh, 0, { markerAt: {} }, true);
out['R04-phone-mid-night'] = phone('Road, phone, mid-chapter, night', mid, 2, midOpts, true);

// ── the storyboard: segment 2 to 3 opens after Right Triangle Trig is done ──
// Times run from when the finished lesson settles (its own pop has already played).
const ease = (t) => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2);
const span = (t, a, b) => ease(Math.min(1, Math.max(0, (t - a) / (b - a))));
const back = (t) => { const c = 1.7; return 1 + (c + 1) * Math.pow(t - 1, 3) + c * Math.pow(t - 1, 2); };
const at = (t) => {
  const rise = Math.min(1, Math.max(0, t / 300));
  const bounce = Math.min(1, Math.max(0, (t - 1800) / 300));
  const scale = t < 300 ? 0.95 + 0.05 * back(rise) : t < 1800 ? 1 : 1 + 0.05 * Math.sin(Math.PI * bounce) * (1 - bounce * 0.3);
  const lift = t < 300 ? 4 * Math.sin(Math.PI * rise) : 0;
  return {
    fill: span(t, 150, 1200), line: span(t, 400, 1200),
    pulse: t >= 1200 && t <= 1800 ? span(t, 1200, 1800) : null,
    scale, lift,
  };
};
const FRAMES = [
  [0, 'Ready', 'The finished node has turned charcoal with its check. The road ahead is a pale slab; the next node waits at 95%.', '0 ms'],
  [300, 'The next node rises', '95% to 100% with a 4 pt lift and a slight overshoot.', '0 to 300 ms'],
  [700, 'The road fills', 'The dark surface and its wall run from the finished node along the curve together. Ease in-out.', '150 to 1200 ms'],
  [1200, 'The centre line draws in', 'Cream dashes reveal behind the fill, never ahead of it.', '400 to 1200 ms'],
  [1500, 'A pulse runs ahead', 'A small spring glow travels the road to the next node. The marker follows just behind it.', '1200 to 1800 ms'],
  [2100, 'Arrival', 'The next node does one small bounce and settles at 100%. The marker parks where the road meets it. No breath yet: that waits until the lesson is started.', '1800 to 2100 ms'],
];
const FW = 300, FH = 270;
const frame = (t, nightMode = false) => {
  const s = at(t);
  const nodes = withState(3, null);
  // The marker trails the pulse a little, so the glow is seen running ahead.
  const markerF = s.pulse != null ? Math.max(0, s.pulse * 0.8 - 0.08) : t >= 1800 ? 0.72 : null;
  const opts = {
    seg: (i) => (i === 2 ? { fill: s.fill, line: s.line, pulse: s.pulse } : {}),
    nodeFx: (i) => (i === 3 ? { scale: s.scale, lift: s.lift } : {}),
    markerAt: markerF != null ? { seg: 2, f: markerF } : { seg: 1, f: 0.72 },
    labels: false,
  };
  const p = pathHtml(nodes, W, PH, roadSize.phone, opts);
  const n2 = p.placed[2];
  // Crop to the two nodes this moment is about.
  return `<div style="position:relative;width:${FW}px;height:${FH}px;border-radius:24px;overflow:hidden;background:${C.fog};"><div style="position:absolute;left:${-(n2.x - 60)}px;top:${-(n2.y - 70)}px;width:${W}px;height:${p.height}px;">${p.html}</div></div>`;
};
const SBW = 6 * FW + 5 * 24 + 96, SBH = 810;
const timeline = () => {
  const total = 2100, w = SBW - 96, x = (ms) => (ms / total) * w;
  const bars = [
    ['Node rises', 0, 300], ['Road fills', 150, 1200], ['Centre line', 400, 1200], ['Pulse', 1200, 1800], ['Bounce', 1800, 2100],
  ];
  return bars.map(([name, a, b], i) => `
<div style="position:absolute;left:0;top:${i * 34}px;width:${w}px;height:24px;">
  <div style="position:absolute;left:${x(a)}px;width:${x(b) - x(a)}px;height:24px;border-radius:12px;background:${C.charcoal};"></div>
  <div style="position:absolute;left:${x(a) + 12}px;top:4px;font-family:${F.mono};font-size:11px;font-weight:600;color:${C.fog};white-space:nowrap;">${name} · ${b - a} ms</div>
</div>`).join('') + `<div style="position:absolute;left:0;top:${bars.length * 34 + 4}px;width:${w}px;display:flex;justify-content:space-between;font-family:${F.mono};font-size:11px;color:${C.muted};">${[0, 300, 600, 900, 1200, 1500, 1800, 2100].map((m) => `<span>${m}</span>`).join('')}</div>`;
};
const rmFrame = (afterState) => {
  const nodes = withState(3, null);
  const opts = {
    seg: (i) => (i === 2 ? (afterState ? { fill: 1, line: 1 } : { fill: 0 }) : {}),
    markerAt: afterState ? { seg: 2, f: 0.72 } : { seg: 1, f: 0.72 },
    labels: false,
  };
  const p = pathHtml(nodes, W, PH, roadSize.phone, opts);
  const n2 = p.placed[2];
  return `<div style="position:relative;width:${FW}px;height:${FH}px;border-radius:24px;overflow:hidden;background:${C.fog};"><div style="position:absolute;left:${-(n2.x - 60)}px;top:${-(n2.y - 80)}px;width:${W}px;height:${p.height}px;">${p.html}</div></div>`;
};
out['R05-storyboard'] = page('Road, finishing storyboard', SBW, SBH, `
${abs(48, 40, 1200, null, `${eyebrow('The road opens · phone, day · times from when the finished lesson settles', C.muted)}<h1 style="margin:10px 0 0;font-family:${F.display};font-weight:800;font-size:36px;letter-spacing:-0.04em;">Finishing a lesson opens the road to the next one</h1>`)}
${FRAMES.map(([t, name, what, when], i) => abs(48 + i * (FW + 24), 140, FW, null, `${frame(t)}
<div style="margin-top:14px;font-family:${F.mono};font-size:12px;font-weight:600;color:${C.charcoal};">${i + 1} · ${when}</div>
<div style="margin-top:6px;font-family:${F.display};font-weight:700;font-size:17px;letter-spacing:-0.02em;">${name}</div>
<div style="margin-top:6px;font-size:13px;line-height:1.5;color:${C.muted};">${what}</div>`)).join('')}
${abs(48, 560, SBW - 96, 220, timeline())}
${abs(48, 760, SBW - 96, null, `<div style="font-family:${F.mono};font-size:12px;font-weight:600;color:${C.muted};">Ease in-out on the road, line and pulse. A slight overshoot on the node only. Total 2.1 s, and the student can tap anywhere meanwhile.</div>`)}
`);

out['R05b-reduced-motion'] = page('Road, reduced motion', 2 * FW + 24 + 96 + 420, 520, `
${abs(48, 40, 900, null, `${eyebrow('Reduce motion is on', C.muted)}<h1 style="margin:10px 0 0;font-family:${F.display};font-weight:800;font-size:32px;letter-spacing:-0.04em;">One quiet cross-fade instead</h1>`)}
${abs(48, 140, FW, null, `${rmFrame(false)}<div style="margin-top:14px;font-family:${F.mono};font-size:12px;font-weight:600;">Before</div>`)}
${abs(48 + FW + 24, 140, FW, null, `${rmFrame(true)}<div style="margin-top:14px;font-family:${F.mono};font-size:12px;font-weight:600;">After · 180 ms</div>`)}
${abs(48 + 2 * FW + 64, 150, 380, null, `<div style="font-size:15px;line-height:1.6;">
<p style="margin:0 0 12px;">The whole segment, charcoal and centre line together, cross-fades in over 180 ms.</p>
<p style="margin:0 0 12px;">No fill running along the curve, no pulse, no lift and no bounce. Every node sits at 100%.</p>
<p style="margin:0;">The marker fades out where it was and in at its new place, in the same 180 ms.</p></div>`)}
`);

// ── one segment, close up ──
const closeUp = () => {
  const S = 4; // drawn at 4x
  const a = { x: 30, y: 30 }, b = { x: 170, y: 154 };
  const r = 42;
  const curve = segmentCurve(a, b, r);
  // Numbered leaders, in road units: from the exact layer out to clear ground.
  // Numbered leaders, in road units: from the exact layer out to clear ground.
  // Surface, rim and line are measured across the road; wall and shadow
  // straight down from the lower edge, where they show.
  const D = roadSize.phone.depth, HW = roadSize.phone.width / 2;
  const leaders = () => [[1, 0.42, 'across', -5, -26], [2, 0.56, 'across', -9, -22], [3, 0.7, 'across', 0, -30], [4, 0.5, 'down', D / 2, 0], [5, 0.36, 'down', D + 4, 0]].map(([n, f, how, o, out]) => {
    const q = curve.at(f);
    const nx = Math.cos(q.angle + Math.PI / 2), ny = Math.sin(q.angle + Math.PI / 2);
    let sx, sy, ex, ey;
    if (how === 'across') {
      sx = q.x + nx * o; sy = q.y + ny * o; ex = q.x + nx * (o + out); ey = q.y + ny * (o + out);
    } else {
      sx = q.x; sy = q.y + HW / Math.abs(Math.cos(q.angle)) + o; ex = sx - 20; ey = sy + 16;
    }
    return `<line x1="${sx}" y1="${sy}" x2="${ex}" y2="${ey}" stroke="${C.ember}" stroke-width="0.5"/><circle cx="${sx}" cy="${sy}" r="1.1" fill="${C.ember}"/><circle cx="${ex}" cy="${ey}" r="3.6" fill="${C.ember}"/><text x="${ex}" y="${ey + 1.4}" text-anchor="middle" font-family="JetBrains Mono" font-weight="600" font-size="4" fill="#FFFFFF">${n}</text>`;
  }).join('');
  const svgAt = (opts, nightMode, k = S) => `<div style="${vars(nightMode ? night : day)}"><svg width="${200 * k}" height="${190 * k}" viewBox="0 0 200 190" fill="none" style="display:block;border-radius:24px;background:${C.fog};">${segmentSvg(curve, { size: roadSize.phone, col: C, ...opts })}
<circle cx="${a.x}" cy="${a.y + 7}" r="${r}" fill="${C.plinth}"/><circle cx="${a.x}" cy="${a.y}" r="${r}" fill="${C.charcoal}"/>
<circle cx="${b.x}" cy="${b.y + 7}" r="${r}" fill="${C.plinth}"/><circle cx="${b.x}" cy="${b.y}" r="${r}" fill="${C.cream}"/>${k === S ? leaders() : ''}</svg></div>`;
  const p = curve.at(0.5);
  const callout = (n, x, y, text) => `<div style="position:absolute;left:${x}px;top:${y}px;display:flex;gap:10px;align-items:baseline;max-width:300px;"><span style="font-family:${F.mono};font-weight:600;font-size:13px;color:${C.charcoal};">${n}</span><span style="font-size:14px;line-height:1.5;">${text}</span></div>`;
  const dot = (n, x, y) => `<div style="position:absolute;left:${x - 13}px;top:${y - 13}px;width:26px;height:26px;border-radius:13px;background:${C.ember};color:#fff;font-family:${F.mono};font-weight:600;font-size:12px;display:flex;align-items:center;justify-content:center;">${n}</div>`;
  const px = p.x * 4, py = p.y * 4;
  const nx = Math.cos(p.angle + Math.PI / 2), ny = Math.sin(p.angle + Math.PI / 2);
  return `
${abs(48, 40, 1300, null, `${eyebrow('One segment · phone sizes at 4x', C.muted)}<h1 style="margin:10px 0 0;font-family:${F.display};font-weight:800;font-size:36px;letter-spacing:-0.04em;">A road, not a racing track</h1>`)}
${abs(48, 140, 800, 760, `${svgAt({ fill: 1, line: 1 }, false)}`)}
${abs(890, 150, 460, null, `<div style="position:relative;height:370px;">
${callout(1, 0, 0, '<b>Surface.</b> tile, 16 wide: dark charcoal grey, so the wall under it can be darker.')}
${callout(2, 0, 80, '<b>Rim.</b> tile2, 2 each side: the lit top edge of the slab.')}
${callout(3, 0, 140, '<b>Centre line.</b> Cream, 2 wide, 7 on and 9 off, round ends.')}
${callout(4, 0, 200, '<b>Wall.</b> Charcoal, 4 deep, under the downward-facing edge. The node plinth is 7, so the nodes stand taller than the road.')}
${callout(5, 0, 290, '<b>Shadow.</b> pipOff, 7 down, blurred 3, on the ground under the wall.')}
</div>`)}
${abs(890, 500, 220, null, `${svgAt({ fill: 0 }, false, 1.1)}<div style="margin-top:12px;font-family:${F.mono};font-size:12px;font-weight:600;">Not walked yet, day</div><div style="font-size:13px;color:${C.muted};line-height:1.5;margin-top:4px;">creamDark slab, cream rim, plinth wall, half the shadow. No line.</div>`)}
${abs(1130, 500, 220, null, `${svgAt({ fill: 1, line: 1 }, true, 1.1)}<div style="margin-top:12px;font-family:${F.mono};font-size:12px;font-weight:600;">Walked, night</div><div style="font-size:13px;color:${C.muted};line-height:1.5;margin-top:4px;">lineOnDark surface, plinth rim, tile wall, night ink line.</div>`)}
`;
};
out['R06-segment-closeup'] = page('Road, one segment', 1400, 940, closeUp());

const dir = new URL('./html/', import.meta.url);
mkdirSync(dir, { recursive: true });
for (const [name, html] of Object.entries(out)) writeFileSync(new URL(`${name}.html`, dir), html);
console.log('wrote', Object.keys(out).length, 'road screens');

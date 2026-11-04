// Generates tablet-screens/html/*.html: the tablet layouts of TABLET.md.
//
//   node build-tablet-screens.mjs     # writes the HTML
//   node render-tablet.mjs            # screenshots them to tablet-screens/png/
//
// Same language as build-screens.mjs (the phone references) and the same
// tokens.json, plus the small `tablet` block TABLET.md proposes. Every value
// that is not in tokens.json is named at the top of this file so the builder
// can see what a tablet adds. Content is the app's own: real chapters,
// lessons, games and copy from lib/features.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { roadDay, roadNight, roadSize, isoPath, placeLabel } from './road/road.mjs';

const T = JSON.parse(readFileSync(new URL('./tokens.json', import.meta.url)));
const TB = T.tablet;

// Colours as CSS variables, so the one night picture is the same markup.
const day = {
  fog: T.color.fog, charcoal: T.color.charcoal, tile: T.color.tile, tile2: T.color.tile2,
  cream: T.color.cream, creamDark: T.color.creamDark, spring: T.color.spring,
  springField: T.color.spring, ember: T.color.ember, peach: T.color.peach,
  butter: T.color.butter, sunbeam: T.color.sunbeam, forest: T.color.forest,
  muted: T.color.mutedOnLight, mutedDark: T.color.mutedOnDark, pipOff: T.color.pipOff,
  onCharcoal: T.color.cream, onAccent: T.color.charcoal, paper: '#FDFCF8',
  plinth: '#CDBFA8', sheet: T.color.cream, line: 'rgba(44,44,44,0.12)', emberBg: '#FEF0EA',
  forestBg: '#E8F5EE', white: '#FFFFFF', scrim: 'rgba(44,44,44,0.45)', grid: 'rgba(100,160,140,0.10)',
  gridFine: 'rgba(100,160,140,0.05)', ...roadDay,
};
// Night values from lib/core/theme/app_colors.dart (ADR 0025, "Warm night").
const night = {
  ...day, fog: '#1B1A18', charcoal: '#F2ECE2', tile: '#34312C', tile2: '#403C36',
  cream: '#272522', creamDark: '#3A3732', springField: '#1C4532', ember: '#F27A4C',
  peach: '#3A2219', butter: '#2B2418', forest: '#5FD69A', muted: '#A89F93',
  mutedDark: '#A89F93', pipOff: 'rgba(242,236,226,0.2)', onCharcoal: '#1B1A18',
  paper: '#24221F', plinth: '#5A544C', sheet: '#2E2B27', line: 'rgba(242,236,226,0.14)',
  emberBg: '#3A2219', forestBg: '#1C3328', white: '#24221F', scrim: 'rgba(0,0,0,0.78)',
  grid: 'rgba(120,190,160,0.10)', gridFine: 'rgba(120,190,160,0.05)', ...roadNight,
};
const vars = (p) => Object.entries(p).map(([k, v]) => `--${k}:${v};`).join('');
const C = Object.fromEntries(Object.keys(day).map((k) => [k, `var(--${k})`]));
const F = {
  display: `'DM Sans', sans-serif`,
  body: `'Inter', sans-serif`,
  mono: `'JetBrains Mono', monospace`,
};
const FONTS = '../../../assets/fonts/';
const RACCOON = '../../../assets/brand/raccoon_peek.png';

// The chapter marks, as in build-screens.mjs: stand-ins for chapter_marks.dart.
const glyph = {
  mathematics: '<path d="M4 20V4M4 20h16"/><path d="M7 6c1.5 10 3.5 12 5 12s3.5-2 5-12"/>',
  statistics: '<path d="M3 19c6 0 6-14 9-14s3 14 9 14"/><path d="M12 5v14" stroke-dasharray="1.2 2.2"/>',
  ethics: '<path d="M12 4v16M7 20h10M5 8h14"/><path d="M5 8l-2.5 6h5zM19 8l-2.5 6h5z"/>',
  economics: '<path d="M3 17h18"/><path d="M8 17V10m5 7V8m5 9V6"/>',
  statics: '<path d="M3 17l5-9 5 9 5-9 3 9M3 17h18M8 8h10"/>',
  dynamics: '<path d="M3 18Q12 2 21 18"/><path d="M12 6v12" stroke-dasharray="1.2 2.2"/>',
  'mechanics-materials': '<path d="M3 15q9 4 18 0"/><path d="M12 5v7M10 10l2 2 2-2"/>',
  materials: '<path d="M4 20V4M4 20h16"/><path d="M4 20c2-10 4-14 6-14s5 2 9 1"/>',
  'fluid-mechanics': '<path d="M6 4v10a6 6 0 0 0 12 0V4"/><path d="M6 9h4M14 11h4"/>',
  surveying: '<path d="M5 8l9-4 5 8-10 7z"/>',
  'water-resources': '<path d="M3 6l4 12h10l4-12"/><path d="M5 11h14"/>',
  structural: '<path d="M4 20V8h16v12"/><path d="M6 8V5m4 3V5m4 3V5m4 3V5M4 5h16"/>',
  geotechnical: '<path d="M9 4v6h6V4M5 10h14"/><path d="M3 14h18"/><path d="M3 18h18" stroke-dasharray="2 2.5"/>',
  transportation: '<path d="M3 20C8 13 16 13 21 6"/><path d="M3 14C8 7 15 7 19 2"/>',
  construction: '<path d="M4 4h16M4 8h7M8 12h8M13 16h7"/>',
};
const chapters = [
  ['mathematics', 'Mathematics', '3/16'], ['statistics', 'Probability & Statistics', '0/6'],
  ['ethics', 'Ethics & Professional Practice', '0/7'], ['economics', 'Engineering Economics', '0/6'],
  ['statics', 'Statics', '1/7'], ['dynamics', 'Dynamics', '0/6'], ['mechanics-materials', 'Mechanics of Materials', '0/9'],
  ['materials', 'Materials', '0/10'], ['fluid-mechanics', 'Fluid Mechanics', '0/8'], ['surveying', 'Surveying', '0/8'],
  ['water-resources', 'Water Resources & Environmental', '0/11'], ['structural', 'Structural Engineering', '0/11'],
  ['geotechnical', 'Geotechnical Engineering', '0/12'], ['transportation', 'Transportation Engineering', '0/11'],
  ['construction', 'Construction Engineering', '0/7'],
];
const mark = (id, color, size, stroke = 1.6) =>
  `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="${color}" stroke-width="${stroke}" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${glyph[id]}</svg>`;

// ── primitives ──
const page = (title, W, H, ground, body, { nightMode = false, css = '' } = {}) => `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=${W}">
<title>${title}</title>
<style>
@font-face{font-family:'DM Sans';font-weight:500;src:url(${FONTS}DMSans-Medium.ttf)}
@font-face{font-family:'DM Sans';font-weight:600;src:url(${FONTS}DMSans-SemiBold.ttf)}
@font-face{font-family:'DM Sans';font-weight:700;src:url(${FONTS}DMSans-Bold.ttf)}
@font-face{font-family:'DM Sans';font-weight:800;src:url(${FONTS}DMSans-ExtraBold.ttf)}
@font-face{font-family:'Inter';font-weight:400;src:url(${FONTS}Inter-Regular.ttf)}
@font-face{font-family:'Inter';font-weight:500;src:url(${FONTS}Inter-Medium.ttf)}
@font-face{font-family:'Inter';font-weight:600;src:url(${FONTS}Inter-SemiBold.ttf)}
@font-face{font-family:'JetBrains Mono';font-weight:500;src:url(${FONTS}JetBrainsMono-Medium.ttf)}
@font-face{font-family:'JetBrains Mono';font-weight:600;src:url(${FONTS}JetBrainsMono-SemiBold.ttf)}
@font-face{font-family:'JetBrains Mono';font-weight:700;src:url(${FONTS}JetBrainsMono-Bold.ttf)}
:root{${vars(nightMode ? night : day)}}
body{margin:0;font-family:${F.body};background:${ground};color:${C.charcoal};-webkit-font-smoothing:antialiased}
a{color:inherit;text-decoration:none}
a:focus-visible,button:focus-visible{outline:3px solid ${C.ember};outline-offset:3px}
button{font-family:inherit;cursor:pointer}
${css}
</style>
</head>
<body>
<div style="width:${W}px;height:${H}px;box-sizing:border-box;position:relative;overflow:hidden;background:${ground};color:${C.charcoal};">
${body}
</div>
</body>
</html>
`;

const abs = (x, y, w, h, inner, extra = '') =>
  `<div style="position:absolute;left:${x}px;top:${y}px;${w != null ? `width:${w}px;` : ''}${h != null ? `height:${h}px;` : ''}${extra}">${inner}</div>`;
const eyebrow = (t, color = C.charcoal, size = 12) =>
  `<span style="font-family:${F.mono};font-size:${size}px;font-weight:600;letter-spacing:0.06em;text-transform:uppercase;color:${color};">${t}</span>`;
const headline = (html, size = 48, color = C.charcoal, extra = '') =>
  `<h1 style="margin:0;font-family:${F.display};font-weight:800;font-size:${size}px;line-height:0.98;letter-spacing:-0.045em;color:${color};text-wrap:balance;${extra}">${html}</h1>`;
const arrow = (s = 28) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M13 6l6 6-6 6"/></svg>`;
const ico = {
  back: `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"/></svg>`,
  close: `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M6 6l12 12"/><path d="M18 6L6 18"/></svg>`,
  grid: `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linejoin="round"><rect x="4" y="4" width="7" height="7" rx="2"/><rect x="13" y="4" width="7" height="7" rx="2"/><rect x="4" y="13" width="7" height="7" rx="2"/><rect x="13" y="13" width="7" height="7" rx="2"/></svg>`,
  single: `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linejoin="round"><rect x="5" y="5" width="14" height="14" rx="4"/></svg>`,
  book: `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H12v16H6.5A2.5 2.5 0 0 0 4 21z"/><path d="M20 5.5A2.5 2.5 0 0 0 17.5 3H12v16h5.5a2.5 2.5 0 0 1 2.5 2z"/></svg>`,
  flag: `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 21V4"/><path d="M5 4h12l-2.5 4.5L17 13H5"/></svg>`,
  check: (s = 20, w = 2.6) => `<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>`,
  play: `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5l11 7-11 7z"/></svg>`,
  up: `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5"/><path d="M6 11l6-6 6 6"/></svg>`,
  down: `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M6 13l6 6 6-6"/></svg>`,
};
const roundIcon = (label, svg) =>
  `<span aria-label="${label}" role="button" style="display:flex;align-items:center;justify-content:center;width:48px;height:48px;border-radius:24px;background:${C.charcoal};color:${C.onCharcoal};flex-shrink:0;">${svg}</span>`;
const cueDot = (ring = C.fog) => `<span aria-hidden="true" style="position:absolute;top:2px;right:2px;width:12px;height:12px;border-radius:6px;background:${C.ember};box-shadow:0 0 0 2.5px ${ring};"></span>`;
const creamButton = (label, svg, { dot = false, size = 48, on = false } = {}) =>
  `<span aria-label="${label}" role="button" style="position:relative;display:flex;align-items:center;justify-content:center;width:${size}px;height:${size}px;border-radius:${size / 2}px;background:${on ? C.charcoal : C.cream};color:${on ? C.onCharcoal : C.charcoal};flex-shrink:0;">${svg}${dot ? cueDot() : ''}</span>`;
// The pill: charcoal, a spring circle with the arrow. On a tablet it never
// runs wider than tablet.size.pillMax and sits at the right of its column.
const pill = (label, { width = null, disabled = false } = {}) => `
<span role="button" style="display:flex;align-items:center;justify-content:space-between;height:72px;${width ? `width:${width}px;` : ''}box-sizing:border-box;padding:0 8px 0 28px;border-radius:36px;background:${C.charcoal};color:${C.onCharcoal};${disabled ? 'opacity:0.42;' : ''}">
<span style="font-family:${F.display};font-weight:700;font-size:22px;letter-spacing:-0.02em;">${label}</span>
<span style="display:flex;align-items:center;justify-content:center;width:56px;height:56px;border-radius:28px;background:${C.spring};color:${C.onAccent};">${arrow()}</span>
</span>`;
const outlinePill = (label, width = null) =>
  `<span role="button" style="display:flex;align-items:center;justify-content:center;height:64px;${width ? `width:${width}px;` : ''}box-sizing:border-box;border-radius:32px;border:2px solid ${C.charcoal};font-weight:600;font-size:17px;">${label}</span>`;
const pips = (done, total, width) =>
  `<div style="display:grid;width:${width}px;grid-template-columns:repeat(${total},minmax(0,1fr));gap:4px;">${Array.from({ length: total }, (_, i) => `<span style="height:12px;border-radius:6px;background:${i < done ? C.charcoal : C.pipOff};"></span>`).join('')}</div>`;

// ── the rail: the dock turned on its side ──
const person = (fill) => `<svg width="24" height="24" viewBox="0 0 24 24" fill="${fill ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8.5" r="3.5"/><path d="M5 20c1-4 4-5.5 7-5.5s6 1.5 7 5.5z"/></svg>`;
const bookI = (fill) => `<svg width="24" height="24" viewBox="0 0 24 24" fill="${fill ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H12v16H6.5A2.5 2.5 0 0 0 4 21z"/><path d="M20 5.5A2.5 2.5 0 0 0 17.5 3H12v16h5.5a2.5 2.5 0 0 1 2.5 2z"/></svg>`;
const sun = (fill) => `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="4" fill="${fill ? 'currentColor' : 'none'}"/><path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5.3 5.3l1.4 1.4M17.3 17.3l1.4 1.4M5.3 18.7l1.4-1.4M17.3 6.7l1.4-1.4"/></svg>`;
const RAIL = TB.size.rail;
const rail = (active, H, { dailyDot = false } = {}) => {
  const item = (label, off, on, isOn, dot) => `
<span role="link" aria-label="${label}"${isOn ? ' aria-current="page"' : ''} style="display:flex;flex-direction:column;align-items:center;gap:4px;width:${RAIL}px;color:${isOn ? C.charcoal : C.muted};">
<span style="position:relative;display:flex;align-items:center;justify-content:center;width:54px;height:54px;border-radius:27px;${isOn ? `background:${C.spring};color:${C.onAccent};` : ''}">${isOn ? on : off}${dot ? `<span style="position:absolute;top:8px;right:8px;width:12px;height:12px;border-radius:6px;background:${C.ember};box-shadow:0 0 0 2.5px ${C.cream};"></span>` : ''}</span>
<span style="font-family:${F.display};font-size:12px;font-weight:600;letter-spacing:-0.01em;">${label}</span>
</span>`;
  return `<nav aria-label="Main" style="position:absolute;left:0;top:0;width:${RAIL}px;height:${H}px;box-sizing:border-box;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:28px;border-radius:0 40px 40px 0;background:${C.cream};box-shadow:6px 0 30px rgba(44,44,44,0.10);z-index:5;">
${item('Profile', person(false), person(true), active === 'profile')}
${item('Study', bookI(false), bookI(true), active === 'study')}
${item('Daily', sun(false), sun(true), active === 'daily', dailyDot)}
</nav>`;
};

// ── the chapter path, drawn into a pane ──
// nodes: {name, sub, state: 'done'|'now'|'todo', frac?, section?}
const path = ({ width, top, nodes, node = 92, step = 150, amp = 110, highlight = null, labelW = 210 }) => {
  // The isometric path (road/ROAD.md): platforms and a raised road, drawn
  // by the same road/road.mjs as the phone. The zigzag's middle line is the
  // pane's middle line (TABLET.md, "The path"); labels stay flat beside
  // their platform and move off the road when they would cross it.
  const r = node / 2;
  const ringAt = nodes.findIndex((n) => n.name === highlight);
  const nowAt = nodes.findIndex((n) => n.state === 'now');
  const p = isoPath({
    nodes, width, r, size: roadSize.tablet, col: C, row: step, amp, top, sectionGap: 54,
    ring: ringAt >= 0 ? ringAt : null, peek: RACCOON, markerD: 36,
    markerAt: nowAt > 0 ? { seg: nowAt - 1, f: 0.55 } : null,
  });
  const obstacles = [...p.obstacles];
  if (p.markerPt) for (let t = 0; t < 6.28; t += 0.5) obstacles.push({ x: p.markerPt.x + 22 * Math.cos(t), y: p.markerPt.y + 22 * Math.sin(t) });
  const label = (n) => {
    const right = n.x <= width / 2; // node on the left, label to its right
    const tileOn = n.state === 'now';
    const subColor = n.state === 'done' ? C.forest : tileOn ? C.onAccent : C.muted;
    const inner = `<span style="display:flex;flex-direction:column;gap:4px;${right ? '' : 'align-items:flex-end;text-align:right;'}"><span style="font-family:${F.display};font-weight:700;font-size:16px;line-height:1.15;letter-spacing:-0.02em;color:${tileOn ? C.onAccent : C.charcoal};">${n.name}</span><span style="font-family:${F.mono};font-size:11.5px;color:${subColor};">${n.sub}</span></span>`;
    const box = tileOn
      ? `<span style="display:inline-block;padding:12px 16px;border-radius:20px;background:${C.spring};">${inner}</span>`
      : inner;
    // Clear of the ground ring by 18.
    const gap = r + 28;
    const x0 = right ? n.x + gap : n.x - gap - labelW;
    const lines = Math.ceil((n.name.replace(/&amp;/g, '&').length * 8.8) / (labelW - (tileOn ? 32 : 0)));
    const h = lines * 18.4 + 4 + 14 + (tileOn ? 24 : 0);
    const cy = placeLabel({ x0, x1: x0 + labelW, cy: n.T, h, obstacles });
    return `<div style="position:absolute;z-index:90;top:${cy}px;left:${x0}px;width:${labelW}px;transform:translateY(-50%);display:flex;${right ? '' : 'justify-content:flex-end;'}">${box}</div>`;
  };
  return {
    height: p.height,
    html: `<svg aria-hidden="true" width="${width}" height="${p.height}" style="position:absolute;left:0;top:0;overflow:visible;" fill="none">${p.svg}</svg>
${p.sections.map((s) => `<div style="position:absolute;z-index:80;left:0;top:${s.y + 4}px;">${eyebrow(s.text, C.muted)}</div>`).join('')}
${p.placed.map(label).join('')}
${p.markerHtml}${p.checkHtml}`,
  };
};

const mathNodes = [
  { section: 'Analytic geometry · 6', name: 'Straight Lines &amp; Quadratics', sub: 'all 3 done', state: 'done' },
  { name: 'Logarithms', sub: 'all 3 done', state: 'done' },
  { name: 'Right Triangle Trigonometry', sub: '1 of 3 done', state: 'now', frac: 0.33 },
  { name: 'Law of Sines &amp; Law of Cosines', sub: '0 of 3 done', state: 'todo' },
  { name: 'Unit Circle &amp; Trig Identities', sub: '0 of 3 done', state: 'todo' },
  { name: 'Circles &amp; Conic Sections', sub: '0 of 3 done', state: 'todo' },
  { section: 'Single-variable calculus · 4', name: 'Derivatives &amp; Derivative Rules', sub: '0 of 3 done', state: 'todo' },
  { name: 'Applications of Derivatives', sub: '0 of 3 done', state: 'todo' },
];
const staticsNodes = [
  { section: 'Forces &amp; equilibrium · 2', name: 'Force Systems &amp; Resultants', sub: 'all 3 done', state: 'done' },
  { name: 'Equilibrium &amp; Free Body Diagrams', sub: '0 of 3 done', state: 'todo' },
  { section: 'Trusses &amp; friction · 3', name: 'Trusses: Method of Joints &amp; Sections', sub: '0 of 3 done', state: 'todo' },
  { name: 'Friction', sub: '0 of 4 done', state: 'todo' },
  { name: 'Frames &amp; Machines', sub: '0 of 3 done', state: 'todo' },
  { section: 'Section properties · 2', name: 'Centroids of Composite Shapes', sub: '0 of 3 done', state: 'todo' },
];

// ── the Study pieces ──
const chip = (t) => `<span style="display:inline-flex;align-items:center;height:40px;padding:0 16px;border-radius:20px;background:${C.charcoal};color:${C.spring};font-family:${F.mono};font-size:13px;font-weight:600;">${t}</span>`;
const dots = (n, at, color = C.charcoal) =>
  `<div style="display:flex;gap:7px;align-items:center;">${Array.from({ length: n }, (_, i) => `<span style="width:${i === at ? 9 : 6}px;height:${i === at ? 9 : 6}px;border-radius:5px;background:${color};opacity:${i === at ? 1 : 0.3};"></span>`).join('')}</div>`;

// One chapter, as the Study tile draws it, sized to a pane.
const chapterTile = ({ w, h, id = 'mathematics', num = 1, weight = '8 to 12 with Stats', name = 'Mathematics', caption = '3 of 16 lessons · next: Right Triangle Trigonometry', button = 'Continue', disc = 200, glyphSize = 124, nameSize = 52 }) => `
<div style="width:${w}px;height:${h}px;box-sizing:border-box;padding:30px 28px 28px;border-radius:36px 36px 64px 64px;background:${C.cream};display:flex;flex-direction:column;">
<div style="display:flex;justify-content:space-between;">${eyebrow('Chapter ' + num)}${eyebrow(weight, C.muted)}</div>
<div style="flex-grow:1;display:flex;align-items:center;justify-content:center;"><span style="display:flex;align-items:center;justify-content:center;width:${disc}px;height:${disc}px;border-radius:50%;background:${C.springField};color:${C.charcoal};">${mark(id, 'currentColor', glyphSize, 1.5)}</span></div>
${headline(name, nameSize)}
<div style="margin:12px 0 22px;font-family:${F.mono};font-size:14px;line-height:1.45;color:${C.muted};">${caption}</div>
${pill(button)}
</div>`;

const gridTiles = (cols, tileW, tileH, { flight = 'mathematics', selected = null, gap = 10, nameSize = 13 } = {}) => `
<div style="display:grid;grid-template-columns:repeat(${cols},${tileW}px);gap:${gap}px;">
${chapters.map(([id, name, count]) => {
  const isFlight = id === flight;
  const isSel = id === selected;
  const bg = isSel ? C.charcoal : isFlight ? C.spring : C.cream;
  const fg = isSel ? C.onCharcoal : isFlight ? C.onAccent : C.charcoal;
  const mk = isSel ? C.spring : isFlight ? C.onAccent : C.muted;
  const cnt = isSel ? C.mutedDark : isFlight ? C.onAccent : count.startsWith('0') ? C.muted : C.forest;
  return `<div style="height:${tileH}px;box-sizing:border-box;padding:14px 14px 13px;border-radius:24px;background:${bg};color:${fg};display:flex;flex-direction:column;justify-content:space-between;">
${mark(id, mk, 28, 1.7)}
<div style="display:flex;flex-direction:column;gap:4px;"><span style="font-family:${F.display};font-weight:700;font-size:${nameSize}px;line-height:1.15;letter-spacing:-0.01em;">${name.replace('&', '&amp;')}</span><span style="font-family:${F.mono};font-size:11.5px;color:${cnt};">${count}</span></div>
</div>`;
}).join('')}
</div>`;

// The path pane of the Study tab, on its own fog.
const pathPane = (x, y, w, h, nodes, chipText, opts = {}) => {
  const p = path({ width: w, top: 72, nodes, ...opts });
  return abs(x, y, w, h, `${abs(0, 0, null, null, chip(chipText))}${p.html}`, 'overflow:hidden;');
};

// ── the round pieces (Which Ratio, Right Triangle Trigonometry) ──
const gridPaper = (w, h, cell = 40) => `background-color:${C.paper};background-image:linear-gradient(${C.grid} 1px, transparent 1px),linear-gradient(90deg, ${C.grid} 1px, transparent 1px),linear-gradient(${C.gridFine} 1px, transparent 1px),linear-gradient(90deg, ${C.gridFine} 1px, transparent 1px);background-size:${cell}px ${cell}px,${cell}px ${cell}px,${cell / 5}px ${cell / 5}px,${cell / 5}px ${cell / 5}px;width:${w}px;height:${h}px;border-radius:24px;position:relative;overflow:hidden;`;
// The game's drawing, from trig_figures: a right triangle, the angle at the
// left corner, the known side labelled, the wanted one a question mark.
// `s` is the figure scale (TABLET.md, "Drawings"): strokes and labels grow
// with the box, up to tablet.figure.maxScale.
const triangle = (w, h, s = 1, { answered = false } = {}) => {
  const pad = 46 * s;
  const x0 = pad, y0 = h - pad, x1 = w - pad, y1 = pad * 0.9;
  const sq = 13 * s;
  return `<div style="${gridPaper(w, h, Math.round(40 * s))}">
<svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" fill="none" style="position:absolute;inset:0;">
<path d="M${x0} ${y0} L${x1} ${y0} L${x1} ${y1} Z" stroke="${C.charcoal}" stroke-width="${3 * s}" stroke-linejoin="round"/>
<path d="M${x1 - sq} ${y0} L${x1 - sq} ${y0 - sq} L${x1} ${y0 - sq}" stroke="${C.muted}" stroke-width="${1.6 * s}"/>
${answered ? `<path d="M${x1} ${y0} L${x1} ${y1}" stroke="${C.ember}" stroke-width="${5 * s}" stroke-linecap="round"/><path d="M${x0} ${y0} L${x1} ${y0}" stroke="${C.ember}" stroke-width="${5 * s}" stroke-linecap="round"/>` : ''}
<path d="M${x0 + 34 * s} ${y0} A ${34 * s} ${34 * s} 0 0 0 ${x0 + 34 * s * Math.cos(Math.atan((y0 - y1) / (x1 - x0)))} ${y0 - 34 * s * Math.sin(Math.atan((y0 - y1) / (x1 - x0)))}" stroke="${C.ember}" stroke-width="${2.4 * s}"/>
<text x="${x0 + 46 * s}" y="${y0 - 8 * s}" font-family="JetBrains Mono" font-weight="700" font-size="${13 * s}" fill="${C.ember}">θ</text>
<text x="${(x0 + x1) / 2}" y="${y0 + 24 * s}" text-anchor="middle" font-family="DM Sans" font-weight="700" font-size="${13 * s}" fill="${C.charcoal}">${answered ? 'adjacent, known' : 'known'}</text>
<text x="${x1 + 12 * s}" y="${(y0 + y1) / 2}" font-family="DM Sans" font-weight="700" font-size="${14 * s}" fill="${C.ember}">${answered ? 'opp' : '?'}</text>
</svg></div>`;
};
const ratioButtons = (state, w, h = 68) => {
  // state: null | 'chosen' | 'answered'
  const one = (label) => {
    let border = C.line, fill = C.white, bw = 1;
    if (state === 'chosen' && label === 'tan') { border = C.ember; fill = C.emberBg; bw = 2; }
    if (state === 'answered' && label === 'tan') { border = C.forest; fill = C.forestBg; bw = 2; }
    return `<span role="button" style="flex:1;display:flex;align-items:center;justify-content:center;height:${h}px;border-radius:${h > 80 ? 20 : 14}px;box-sizing:border-box;border:${bw}px solid ${border};background:${fill};font-family:${F.display};font-weight:700;font-size:${h > 80 ? 26 : 20}px;">${label}</span>`;
  };
  return `<div style="display:flex;gap:10px;width:${w}px;">${one('sin')}${one('cos')}${one('tan')}</div>`;
};
const roundHeader = (w, { done = 0, total = 8, count = '0 / 8', bookOn = false, bookDot = false, pipsW = null } = {}) => `
<div style="display:flex;align-items:center;gap:14px;width:${w}px;">
${roundIcon('Close', ico.close)}
${pips(done, total, pipsW ?? w - 48 - 48 - 14 * 3 - 60)}
<span style="width:60px;">${eyebrow(count)}</span>
<span style="flex-grow:1;"></span>
${creamButton(bookOn ? 'Close the concept' : 'The concept', ico.book, { dot: bookDot, on: bookOn })}
</div>`;
const ROUND_CONTEXT = 'You are 50 m from a building on level ground and you measure the angle up to its roof. You want the height.';
const feedbackPanel = (w) => `
<div style="position:relative;width:${w}px;box-sizing:border-box;padding:20px 22px 20px;border-radius:28px;background:${C.springField};color:${C.onAccent};">
<div style="display:flex;flex-direction:column;gap:8px;">${eyebrow('Correct', C.onAccent)}
<div style="font-size:16px;line-height:1.5;">Adjacent and opposite are connected by tan. Remember cos is cozy with the adjacent side, the one touching the angle.</div></div>
</div>`;
const tanRule = (size = 22) => `<div style="font-family:'Times New Roman',serif;font-style:italic;font-size:${size}px;display:flex;align-items:center;gap:8px;color:${C.charcoal};"><span>tan θ =</span><span style="display:inline-flex;flex-direction:column;align-items:center;font-style:normal;font-size:${size * 0.85}px;line-height:1.1;"><span>opp</span><span style="border-top:1.5px solid currentColor;padding-top:2px;">adj</span></span></div>`;

// The concept sheet's content (ratiosBrief, lesson_brief.dart).
const STEPS = [
  ['Same shape, same ratios', 'Every right triangle with the same angle has sides in the same proportions, however big it is drawn. Those fixed proportions are what sine, cosine and tangent are.'],
  ['Three pairings, three names', 'Opposite over hypotenuse is sine. Adjacent over hypotenuse is cosine. Opposite over adjacent is tangent. SOH CAH TOA is just those three read out.'],
  ['Pick by what you have', 'Do not pick a ratio and hope. List the side you know and the side you want, then take the ratio that has both of them in it. Only one will.'],
  ['The one people mix up', 'Cos is cozy with the adjacent side, the one leaning against the angle.'],
];
const SPOKEN = [['SOH', 'sin θ', 'opp', 'hyp', 'sine is opposite over hypotenuse'], ['CAH', 'cos θ', 'adj', 'hyp', 'cosine is adjacent over hypotenuse'], ['TOA', 'tan θ', 'opp', 'adj', 'tangent is opposite over adjacent']];
const frac = (a, b, size) => `<span style="display:inline-flex;flex-direction:column;align-items:center;font-style:normal;font-size:${size * 0.82}px;line-height:1.1;"><span>${a}</span><span style="border-top:1.5px solid currentColor;padding-top:2px;">${b}</span></span>`;
const spokenTile = ([lab, fn, a, b, said], w, size = 20) => `
<div style="width:${w}px;box-sizing:border-box;padding:14px 16px 14px;border-radius:22px;background:${C.creamDark};display:flex;flex-direction:column;gap:8px;">
${eyebrow(lab, C.muted, 11)}
<div style="font-family:'Times New Roman',serif;font-style:italic;font-size:${size}px;display:flex;align-items:center;gap:8px;">${fn} =${frac(a, b, size)}</div>
<div style="font-size:13px;line-height:1.35;color:${C.muted};">${said}</div>
</div>`;
// The picture: the game's own painter, one thing happening (ratiosPicture).
const ratiosPicture = (w, h, s = 1) => {
  const pad = 40 * s;
  const x0 = pad, y0 = h - pad, x1 = w - pad * 1.4, y1 = pad * 0.8;
  return `<div style="${gridPaper(w, h, Math.round(40 * s))}">
<svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" fill="none" style="position:absolute;inset:0;">
<path d="M${x0} ${y0} L${x1} ${y0} L${x1} ${y1} Z" stroke="${C.charcoal}" stroke-width="${2.6 * s}" stroke-linejoin="round"/>
<path d="M${x1} ${y0} L${x1} ${y1}" stroke="${C.ember}" stroke-width="${5 * s}" stroke-linecap="round"/>
<path d="M${x1 - 12 * s} ${y0} L${x1 - 12 * s} ${y0 - 12 * s} L${x1} ${y0 - 12 * s}" stroke="${C.muted}" stroke-width="${1.4 * s}"/>
<text x="${x0 + 40 * s}" y="${y0 - 8 * s}" font-family="JetBrains Mono" font-weight="700" font-size="${12 * s}" fill="${C.ember}">θ</text>
<text x="${(x0 + x1) / 2}" y="${y0 + 20 * s}" text-anchor="middle" font-family="DM Sans" font-weight="700" font-size="${11.5 * s}" fill="${C.charcoal}">Adjacent</text>
<text x="${(x0 + x1) / 2 - 10 * s}" y="${(y0 + y1) / 2 - 8 * s}" text-anchor="middle" font-family="DM Sans" font-weight="700" font-size="${11.5 * s}" fill="${C.charcoal}" transform="rotate(${-Math.atan((y0 - y1) / (x1 - x0)) * 180 / Math.PI} ${(x0 + x1) / 2 - 10 * s} ${(y0 + y1) / 2 - 8 * s})">Hypotenuse</text>
<text x="${x1 + 18 * s}" y="${(y0 + y1) / 2}" font-family="DM Sans" font-weight="700" font-size="${11.5 * s}" fill="${C.charcoal}" transform="rotate(-90 ${x1 + 18 * s} ${(y0 + y1) / 2})" text-anchor="middle">Opposite</text>
</svg></div>`;
};

// ════════════════════════════ the screens ════════════════════════════
const L = { W: 1180, H: 820 }; // 11-inch iPad, landscape
const P = { W: 820, H: 1180 }; // 11-inch iPad, portrait
const out = {};
const CX = RAIL + TB.space.paneX; // content starts here, beside the rail
const TOP = TB.space.top;          // below the status bar

// ── T01 Study, landscape: the chapter beside its path ──
const studyL = (nightMode = false) => page('Study, landscape', L.W, L.H, C.fog, `
${rail('study', L.H)}
${abs(CX, TOP + 12, 400, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('73 days to the exam', C.muted)}${roundIcon('All chapters', ico.grid)}</div>`)}
${abs(CX, TOP + 76, null, null, chapterTile({ w: 400, h: 640 }))}
${abs(CX, TOP + 734, 400, 12, `<div style="display:flex;justify-content:center;">${dots(15, 0)}</div>`)}
${pathPane(CX + 400 + TB.space.paneGap + 8, TOP + 12, L.W - (CX + 400 + TB.space.paneGap + 8) - 24, L.H - TOP - 12, mathNodes, '3 of 16 cleared')}
`, { nightMode });
out['T01-study-landscape'] = studyL();
out['T01n-study-landscape-night'] = studyL(true);

// ── T01p Study, portrait: the same pairing as landscape, stacked ──
// The chapter as a band (mark beside the words), its live path below.
const PW = P.W - CX - 40; // content width beside the rail, portrait
const chapterBand = ({ w, id = 'mathematics', num = 1, weight = '8 to 12 with Stats', name = 'Mathematics', caption = '3 of 16 lessons · next: Right Triangle Trigonometry', button = 'Continue', selected = false }) => `
<div style="width:${w}px;box-sizing:border-box;padding:26px 26px 26px 26px;border-radius:36px;background:${C.cream};display:flex;gap:26px;align-items:stretch;">
<span style="flex-shrink:0;display:flex;align-items:center;justify-content:center;width:200px;height:200px;border-radius:50%;background:${C.springField};color:${C.charcoal};align-self:center;">${mark(id, 'currentColor', 120, 1.5)}</span>
<div style="flex-grow:1;display:flex;flex-direction:column;gap:10px;">
<div style="display:flex;justify-content:space-between;">${eyebrow('Chapter ' + num)}${eyebrow(weight, C.muted)}</div>
${headline(name, 48)}
<div style="font-family:${F.mono};font-size:14px;line-height:1.45;color:${C.muted};">${caption}</div>
<div style="flex-grow:1;min-height:12px;"></div>
${pill(button)}
</div>
</div>`;
out['T01p-study-portrait'] = page('Study, portrait', P.W, P.H, C.fog, `
${rail('study', P.H)}
${abs(CX, TOP + 12, PW, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('73 days to the exam', C.muted)}${roundIcon('All chapters', ico.grid)}</div>`)}
${abs(CX, TOP + 76, null, null, chapterBand({ w: PW }))}
${abs(CX, TOP + 76 + 300, PW, 12, `<div style="display:flex;justify-content:center;">${dots(15, 0)}</div>`)}
${pathPane(CX, TOP + 412, PW, P.H - TOP - 412, mathNodes, '3 of 16 cleared', { top: 64, node: 92, amp: 110, labelW: 230 })}
`);

// ── T02 Chapter map, landscape: every chapter beside the one you picked ──
out['T02-chapter-map-landscape'] = page('Chapter map, landscape', L.W, L.H, C.fog, `
${rail('study', L.H)}
${abs(CX, TOP + 12, 400, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('73 days to the exam', C.muted)}${roundIcon('One chapter', ico.single)}</div>`)}
${abs(CX, TOP + 76, null, null, gridTiles(3, 126, 124, { selected: 'statics' }))}
${abs(CX + 400 + 32, TOP + 12, 560, null, `<div style="display:flex;flex-direction:column;gap:14px;">${eyebrow('Chapter 5 · 4 to 6 on the exam', C.muted)}${headline('Statics', 44)}</div>`)}
${pathPane(CX + 400 + 32, TOP + 112, L.W - (CX + 400 + 32) - 24, L.H - TOP - 112, staticsNodes, '1 of 7 cleared', { top: 64, node: 84, amp: 100 })}
`);

// ── T02p All chapters, portrait: the grid on top, the picked chapter's path below ──
out['T02p-chapter-map-portrait'] = page('All chapters, portrait', P.W, P.H, C.fog, `
${rail('study', P.H)}
${abs(CX, TOP + 12, PW, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('73 days to the exam', C.muted)}${roundIcon('One chapter', ico.single)}</div>`)}
${abs(CX, TOP + 76, null, null, gridTiles(5, (PW - 40) / 5, 112, { selected: 'statics' }))}
${abs(CX, TOP + 76 + 3 * 112 + 20 + 34, PW, null, `<div style="display:flex;flex-direction:column;gap:12px;">${eyebrow('Chapter 5 · 4 to 6 on the exam', C.muted)}${headline('Statics', 44)}</div>`)}
${pathPane(CX, TOP + 576, PW, P.H - TOP - 576, staticsNodes, '1 of 7 cleared', { top: 64, node: 88, amp: 110, labelW: 230 })}
`);

// ── T03 Lesson sheet, landscape: the lesson takes the chapter's pane ──
const gameRow = ([n, b, s], pad = '18px 14px 18px 22px') => `
<div style="display:flex;align-items:center;gap:14px;box-sizing:border-box;padding:${pad};border-radius:24px;background:${s === 'next' ? C.spring : C.creamDark};color:${s === 'next' ? C.onAccent : C.charcoal};">
<span style="display:flex;flex-direction:column;gap:4px;flex-grow:1;"><span style="font-family:${F.display};font-weight:700;font-size:18px;letter-spacing:-0.02em;">${n}</span><span style="font-size:14px;line-height:1.35;color:${s === 'next' ? C.onAccent : C.muted};">${b}</span></span>
<span style="display:flex;align-items:center;justify-content:center;width:48px;height:48px;border-radius:24px;background:${C.charcoal};color:${s === 'next' ? C.spring : C.onCharcoal};flex-shrink:0;">${s === 'done' ? ico.check() : ico.play}</span>
</div>`;
const RTT_GAMES = [
  ['Tap the Side', 'Point at the opposite, the adjacent, the hypotenuse.', 'done'],
  ['Which Ratio', 'One side known, one wanted. Pick sin, cos or tan.', 'next'],
  ['Resolve It', 'Split a force. Angles from the vertical are in here.', 'todo'],
];
const lessonPane = (w, h) => `
<div style="width:${w}px;height:${h}px;box-sizing:border-box;padding:28px 24px 24px;border-radius:36px;background:${C.cream};display:flex;flex-direction:column;gap:22px;">
<div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;">
<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow('Lesson 3 · 1 of 3 done', C.muted)}${headline('Right Triangle Trigonometry', 40)}</div>
${creamButton('Back to the chapter', ico.close, { size: 48 }).replace(`background:${C.cream}`, `background:${C.creamDark}`)}
</div>
<div style="display:flex;flex-direction:column;gap:10px;">${RTT_GAMES.map((g) => gameRow(g)).join('')}</div>
<div style="flex-grow:1;"></div>
${outlinePill('Read the concept first')}
</div>`;
out['T03-lesson-sheet-landscape'] = page('Lesson sheet, landscape', L.W, L.H, C.fog, `
${rail('study', L.H)}
${abs(CX, TOP + 12, 400, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('73 days to the exam', C.muted)}${roundIcon('All chapters', ico.grid)}</div>`)}
${abs(CX, TOP + 76, null, null, lessonPane(400, 670))}
${pathPane(CX + 400 + TB.space.paneGap + 8, TOP + 12, L.W - (CX + 400 + TB.space.paneGap + 8) - 24, L.H - TOP - 12, mathNodes, '3 of 16 cleared', { highlight: 'Right Triangle Trigonometry' })}
`);

// ── T03p Lesson, portrait: the lesson takes the band's place, the path stays ──
const gameCol = ([n, b, st]) => `
<div style="flex:1;display:flex;flex-direction:column;gap:8px;box-sizing:border-box;padding:18px 16px 16px 18px;border-radius:24px;background:${st === 'next' ? C.spring : C.creamDark};color:${st === 'next' ? C.onAccent : C.charcoal};">
<span style="font-family:${F.display};font-weight:700;font-size:18px;letter-spacing:-0.02em;">${n}</span>
<span style="flex-grow:1;font-size:14px;line-height:1.4;color:${st === 'next' ? C.onAccent : C.muted};">${b}</span>
<span style="align-self:flex-end;display:flex;align-items:center;justify-content:center;width:48px;height:48px;border-radius:24px;background:${C.charcoal};color:${st === 'next' ? C.spring : C.onCharcoal};">${st === 'done' ? ico.check() : ico.play}</span>
</div>`;
out['T03p-lesson-sheet-portrait'] = page('Lesson, portrait', P.W, P.H, C.fog, `
${rail('study', P.H)}
${abs(CX, TOP + 12, PW, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('73 days to the exam', C.muted)}${roundIcon('All chapters', ico.grid)}</div>`)}
${abs(CX, TOP + 76, PW, null, `
<div style="box-sizing:border-box;padding:26px 24px 24px;border-radius:36px;background:${C.cream};display:flex;flex-direction:column;gap:20px;">
<div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;">
<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow('Lesson 3 · 1 of 3 done', C.muted)}${headline('Right Triangle Trigonometry', 40)}</div>
${creamButton('Back to the chapter', ico.close, { size: 48 }).replace(`background:${C.cream}`, `background:${C.creamDark}`)}
</div>
<div style="display:flex;gap:10px;height:190px;">${RTT_GAMES.map(gameCol).join('')}</div>
${outlinePill('Read the concept first')}
</div>`)}
${pathPane(CX, TOP + 500, PW, P.H - TOP - 500, mathNodes, '3 of 16 cleared', { top: 64, node: 92, amp: 110, labelW: 230, highlight: 'Right Triangle Trigonometry' })}
`);

// ── T04 Round, landscape: the drawing beside the answer ──
const FIG_L = { w: 640, h: L.H - TOP - 96 - 36 }; // full height, bottom edge shared with the pill
const roundL = ({ answered = false }) => page(`Round${answered ? ', answered' : ''}, landscape`, L.W, L.H, C.fog, `
${abs(40, TOP + 8, 1100, 48, roundHeader(1100, { done: answered ? 2 : 1, count: '2 / 8', bookDot: !answered, pipsW: 560 }))}
${abs(40, TOP + 96, null, null, triangle(FIG_L.w, FIG_L.h, 1.5, { answered }))}
${abs(720, TOP + 96, 420, L.H - TOP - 96 - 36, `
<div style="height:100%;display:flex;flex-direction:column;">
<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow('Which ratio connects them', C.ember)}
<div style="font-size:20px;line-height:1.5;color:${C.charcoal};">${ROUND_CONTEXT}</div></div>
<div style="height:24px;"></div>
${ratioButtons(answered ? 'answered' : 'chosen', 420, 88)}
${answered ? `<div style="height:16px;"></div>${feedbackPanel(420)}<div style="height:12px;"></div><div style="display:flex;justify-content:center;">${tanRule(24)}</div>` : ''}
<div style="flex-grow:1;"></div>
<div style="display:flex;align-items:center;gap:12px;justify-content:flex-end;">${creamButton('Something unclear?', ico.flag, { size: 48 })}${pill(answered ? 'Next' : 'Lock it in', { width: 360 })}</div>
</div>`)}
`);
out['T04-round-landscape'] = roundL({});
out['T05-round-answered-landscape'] = roundL({ answered: true });

// ── T06 Round with the concept sheet beside it, landscape ──
const SHEET_W = TB.pane.conceptSheet;
const conceptSheetPane = (w, h, { closeLabel = 'Close the concept', compact = true } = {}) => `
<div style="width:${w}px;height:${h}px;box-sizing:border-box;padding:${TOP + 8}px 32px 0 36px;border-radius:40px 0 0 40px;background:${C.sheet};box-shadow:-6px 0 30px rgba(44,44,44,0.10);overflow:hidden;display:flex;flex-direction:column;gap:14px;">
<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('The concept · Handbook 10.6, p. 39', C.muted)}${roundIcon(closeLabel, ico.close)}</div>
<div style="font-family:${F.display};font-weight:700;font-size:17px;color:${C.muted};letter-spacing:-0.02em;">Right Triangle Trigonometry</div>
${headline('The three ratios, and picking one', 38)}
<div style="margin-top:6px;">${ratiosPicture(w - 68, 230, 1.2)}</div>
<div style="font-family:${F.mono};font-size:12px;color:${C.muted};">pick the ratio that joins the side you know to the side you want</div>
${STEPS.slice(0, compact ? 3 : 4).map(([e, t]) => `<div style="display:flex;flex-direction:column;gap:6px;max-width:${TB.measure.body}px;">${eyebrow(e, C.charcoal)}<div style="font-size:17px;line-height:1.5;">${t}</div></div>`).join('')}
</div>`;
out['T06-round-with-concept-landscape'] = page('Round with the concept, landscape', L.W, L.H, C.fog, `
${abs(40, TOP + 8, 600, 48, roundHeader(600, { done: 1, count: '2 / 8', bookOn: true, pipsW: 330 }))}
${abs(40, TOP + 84, 600, null, `<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow('Which ratio connects them', C.ember)}<div style="font-size:18px;line-height:1.5;">${ROUND_CONTEXT}</div></div>`)}
${abs(40, TOP + 200, null, null, triangle(600, 330, 1.2))}
${abs(40, TOP + 550, null, null, ratioButtons('chosen', 600))}
${abs(40, L.H - 36 - 72, 600, 72, `<div style="display:flex;align-items:center;gap:12px;justify-content:flex-end;">${creamButton('Something unclear?', ico.flag, { size: 48 })}${pill('Lock it in', { width: 360 })}</div>`)}
${abs(L.W - SHEET_W, 0, SHEET_W, L.H, conceptSheetPane(SHEET_W, L.H))}
`);

// ── T04p Round, portrait: one column, the drawing much larger ──
out['T04p-round-portrait'] = page('Round, portrait', P.W, P.H, C.fog, `
${abs(48, TOP + 8, P.W - 96, 48, roundHeader(P.W - 96, { done: 1, count: '2 / 8', bookDot: true, pipsW: 470 }))}
${abs(48, TOP + 92, P.W - 96, null, `<div style="display:flex;flex-direction:column;gap:10px;max-width:${TB.measure.body}px;">${eyebrow('Which ratio connects them', C.ember)}<div style="font-size:20px;line-height:1.5;">${ROUND_CONTEXT}</div></div>`)}
${abs(48, TOP + 222, null, null, triangle(P.W - 96, 560, 1.6))}
${abs(48, TOP + 806, null, null, ratioButtons('chosen', P.W - 96))}
${abs(48, P.H - 40 - 72, P.W - 96, 72, `<div style="display:flex;align-items:center;gap:12px;justify-content:flex-end;">${creamButton('Something unclear?', ico.flag, { size: 48 })}${pill('Lock it in', { width: TB.size.pillMax })}</div>`)}
`);

// ── T07 Lesson brief, landscape: the picture beside the steps ──
out['T07-lesson-brief-landscape'] = page('Lesson brief, landscape', L.W, L.H, C.sheet, `
${abs(48, TOP + 8, 1084, 48, `<div style="display:flex;align-items:center;gap:16px;height:48px;">${roundIcon('Back to the lesson', ico.back)}${eyebrow('The concept · Handbook 10.6, p. 39', C.muted)}</div>`)}
${abs(48, TOP + 84, 540, null, `<div style="display:flex;flex-direction:column;gap:14px;">
<div style="font-family:${F.display};font-weight:700;font-size:18px;color:${C.muted};letter-spacing:-0.02em;">Right Triangle Trigonometry</div>
${headline('The three ratios, and picking one', 52)}
<div style="margin-top:10px;">${ratiosPicture(540, 330, 1.45)}</div>
<div style="font-family:${F.mono};font-size:13px;color:${C.muted};">pick the ratio that joins the side you know to the side you want</div>
</div>`)}
${abs(636, TOP + 84, 496, null, `<div style="display:flex;flex-direction:column;gap:20px;">
${STEPS.map(([e, t]) => `<div style="display:flex;flex-direction:column;gap:6px;">${eyebrow(e)}<div style="font-size:17px;line-height:1.5;">${t}</div></div>`).join('')}
<div style="display:flex;gap:10px;">${SPOKEN.map((s) => spokenTile(s, 158, 19)).join('')}</div>
</div>`)}
${abs(48, L.H - 36 - 72, 1084, 72, `<div style="display:flex;align-items:center;justify-content:space-between;gap:24px;"><div style="max-width:420px;font-size:14px;line-height:1.45;color:${C.muted};">Knowing this is not the same as solving with it. The full problems belong at a desk, on paper.</div>${pill('Back to the lesson', { width: TB.size.pillMax })}</div>`)}
`);

// ── T07p Lesson brief, portrait: the picture full width, the steps in two columns ──
out['T07p-lesson-brief-portrait'] = page('Lesson brief, portrait', P.W, P.H, C.sheet, `
${abs(48, TOP + 8, P.W - 96, 48, `<div style="display:flex;align-items:center;gap:16px;height:48px;">${roundIcon('Back to the lesson', ico.back)}${eyebrow('The concept · Handbook 10.6, p. 39', C.muted)}</div>`)}
${abs(48, TOP + 84, P.W - 96, null, `<div style="display:flex;flex-direction:column;gap:14px;">
<div style="font-family:${F.display};font-weight:700;font-size:18px;color:${C.muted};letter-spacing:-0.02em;">Right Triangle Trigonometry</div>
${headline('The three ratios, and picking one', 52)}
<div style="margin-top:10px;">${ratiosPicture(P.W - 96, 260, 1.35)}</div>
<div style="font-family:${F.mono};font-size:13px;color:${C.muted};">pick the ratio that joins the side you know to the side you want</div>
<div style="margin-top:12px;display:grid;grid-template-columns:1fr 1fr;column-gap:32px;row-gap:22px;">
${STEPS.map(([e, t]) => `<div style="display:flex;flex-direction:column;gap:6px;">${eyebrow(e)}<div style="font-size:16px;line-height:1.5;">${t}</div></div>`).join('')}
</div>
<div style="margin-top:10px;display:flex;gap:12px;">${SPOKEN.map((s) => spokenTile(s, (P.W - 96 - 24) / 3, 20)).join('')}</div>
</div>`)}
${abs(48, P.H - 40 - 72, P.W - 96, 72, `<div style="display:flex;align-items:center;justify-content:space-between;gap:24px;"><div style="max-width:260px;font-size:14px;line-height:1.45;color:${C.muted};">Knowing this is not the same as solving with it. The full problems belong at a desk, on paper.</div>${pill('Back to the lesson', { width: TB.size.pillMax })}</div>`)}
`);

// ── T08 Daily, landscape ──
const dailyRow = (id, name, lesson, rounds) => `
<div style="flex:1;display:flex;align-items:center;gap:20px;box-sizing:border-box;padding:20px 26px 20px 22px;border-radius:30px;background:${C.creamDark};">
<span style="display:flex;align-items:center;justify-content:center;width:92px;height:92px;border-radius:46px;background:${C.fog};flex-shrink:0;">${mark(id, C.charcoal, 52, 1.5)}</span>
<span style="display:flex;flex-direction:column;gap:3px;flex-grow:1;"><span style="font-family:${F.display};font-weight:700;font-size:18px;letter-spacing:-0.02em;">${name}</span><span style="font-size:14px;color:${C.muted};">${lesson}</span></span>
<span style="font-family:${F.mono};font-size:13px;color:${C.muted};">${rounds}</span>
</div>`;
const streakTile = (w, n, line, filled) => `
<div style="width:${w}px;box-sizing:border-box;display:flex;align-items:center;gap:22px;padding:22px 26px;border-radius:32px;background:${C.tile};color:${C.cream === 'var(--cream)' ? '#FFF9F0' : C.cream};">
<span style="font-family:${F.display};font-weight:800;font-size:68px;line-height:0.82;letter-spacing:-0.06em;color:${C.sunbeam};">${n}</span>
<span style="display:flex;flex-direction:column;gap:6px;"><span style="font-family:${F.display};font-weight:700;font-size:21px;color:#FFF9F0;">Day streak</span><span style="font-size:14px;color:${C.mutedDark};">${line}</span>
<span style="display:flex;gap:4px;margin-top:4px;">${Array.from({ length: 7 }, (_, i) => `<span style="width:22px;height:10px;border-radius:5px;background:${i < filled ? C.sunbeam : 'rgba(255,249,240,0.16)'};"></span>`).join('')}</span></span>
</div>`;
out['T08-daily-landscape'] = page('Daily, landscape', L.W, L.H, C.butter, `
${rail('daily', L.H, { dailyDot: true })}
${abs(CX, TOP + 24, 420, null, `<div style="display:flex;flex-direction:column;gap:14px;">${eyebrow('Wednesday, Oct 28')}${headline("Today's Daily", 64)}</div>`)}
${abs(CX, TOP + 196, 420, null, `<div style="display:flex;flex-direction:column;gap:22px;">
<div style="display:flex;align-items:baseline;gap:14px;"><span style="font-family:${F.display};font-weight:800;font-size:200px;line-height:0.82;letter-spacing:-0.07em;">3</span><span style="font-family:${F.display};font-weight:700;font-size:26px;letter-spacing:-0.03em;">concepts, about 3 min</span></div>
<div style="font-size:17px;line-height:1.5;max-width:380px;">Same for everyone. Play, then see how you did against everyone else today.</div>
</div>`)}
${abs(CX, L.H - 36 - 138, null, null, streakTile(420, 5, 'Play today to make it 6', 5))}
${abs(CX + 420 + 40, TOP + 24, L.W - (CX + 420 + 40) - 40, L.H - TOP - 24 - 36, `
<div style="height:100%;box-sizing:border-box;padding:30px 28px 28px;border-radius:36px 36px 64px 64px;background:${C.cream};display:flex;flex-direction:column;gap:12px;">
${eyebrow("Today's three")}
<div style="height:6px;"></div>
${dailyRow('statics', 'Which Distance Counts', 'Force Systems &amp; Resultants', '6 rounds')}
${dailyRow('mechanics-materials', 'Which Stretches More', 'Axial Stress, Strain &amp; Deformation', '6 rounds')}
${dailyRow('surveying', 'Find It on the Plan', 'Angles, Distances &amp; Bearings', '6 rounds')}
<div style="height:8px;"></div>
${pill("Play today's")}
</div>`)}
`);

// ── T08b Daily results, landscape ──
const bar = (label, n, max, me) => `<div style="display:flex;align-items:center;gap:14px;height:30px;"><span style="width:40px;font-family:${F.mono};font-size:14px;">${label}</span><span style="display:flex;align-items:center;justify-content:flex-end;box-sizing:border-box;padding-right:12px;height:26px;width:${Math.round((n / max) * 420)}px;min-width:44px;border-radius:13px;background:${me ? C.charcoal : C.creamDark};color:${me ? C.onCharcoal : C.charcoal};font-family:${F.mono};font-size:12.5px;font-weight:600;">${n}</span></div>`;
const rankRow = (place, name, score, time, me) => `<div style="display:flex;align-items:center;gap:18px;height:62px;box-sizing:border-box;padding:0 22px;border-radius:22px;background:${me ? C.charcoal : C.cream};color:${me ? C.onCharcoal : C.charcoal};"><span style="width:22px;font-family:${F.mono};font-size:14px;color:${me ? C.mutedDark : C.muted};">${place}</span><span style="flex-grow:1;font-family:${F.display};font-weight:700;font-size:18px;">${name}</span><span style="font-family:${F.mono};font-size:14px;font-weight:600;">${score}</span><span style="width:52px;text-align:right;font-family:${F.mono};font-size:14px;color:${me ? C.mutedDark : C.muted};">${time}</span></div>`;
const againRow = (id, name, lesson) => `<div style="display:flex;align-items:center;gap:14px;height:64px;box-sizing:border-box;padding:0 10px 0 12px;border-radius:22px;background:${C.cream};"><span style="display:flex;align-items:center;justify-content:center;width:44px;height:44px;border-radius:22px;background:${C.creamDark};flex-shrink:0;">${mark(id, C.charcoal, 24, 1.8)}</span><span style="display:flex;flex-direction:column;gap:2px;flex-grow:1;"><span style="font-family:${F.display};font-weight:700;font-size:16px;letter-spacing:-0.02em;">${name}</span><span style="font-size:13px;color:${C.muted};">${lesson}</span></span><span role="button" aria-label="Play again" style="display:flex;align-items:center;justify-content:center;width:44px;height:44px;border-radius:22px;background:${C.charcoal};color:${C.onCharcoal};">${ico.play}</span></div>`;
const RIGHT_X = CX + 540 + 40;
const RIGHT_W = L.W - RIGHT_X - 40;
out['T08b-daily-results-landscape'] = page('Daily results, landscape', L.W, L.H, C.butter, `
${rail('daily', L.H)}
${abs(CX, TOP + 24, 540, null, `<div style="display:flex;flex-direction:column;gap:14px;">${eyebrow("Today's Daily · 23 played")}${headline('You beat 70%<br>today', 60)}
<div style="display:flex;gap:10px;margin-top:8px;"><span style="display:flex;align-items:center;height:48px;padding:0 20px;border-radius:24px;background:${C.charcoal};color:${C.onCharcoal};font-family:${F.display};font-weight:700;font-size:16px;">Everyone</span><span style="display:flex;align-items:center;height:48px;padding:0 20px;border-radius:24px;background:${C.creamDark};color:${C.muted};font-family:${F.display};font-weight:700;font-size:16px;">BYU, at 5 players</span></div></div>`)}
${abs(CX, TOP + 270, 540, null, `<div style="box-sizing:border-box;padding:24px 28px;border-radius:36px;background:${C.cream};display:flex;flex-direction:column;gap:6px;">${eyebrow('First try, out of 18', C.muted)}<div style="height:6px;"></div>
${bar('18', 2, 6, false)}${bar('17', 4, 6, false)}${bar('16', 5, 6, true)}${bar('15', 6, 6, false)}${bar('14', 3, 6, false)}${bar('≤12', 3, 6, false)}</div>`)}
${abs(CX, L.H - 36 - 134, null, null, streakTile(540, 6, 'Come back tomorrow to make it 7', 6))}
${abs(RIGHT_X, TOP + 24, RIGHT_W, null, `<div style="display:flex;flex-direction:column;gap:10px;">
<div style="display:flex;justify-content:flex-end;height:20px;"><span style="font-size:14px;font-weight:500;color:${C.muted};text-decoration:underline;text-underline-offset:4px;">Yesterday's score</span></div>
<div style="height:10px;"></div>
${rankRow(1, 'Maria L.', 18, '1:58', false)}${rankRow(2, 'Dev P.', 18, '2:20', false)}${rankRow(7, 'You', 16, '2:41', true)}
<div style="font-size:14px;line-height:1.45;color:${C.muted};margin:2px 4px 0;">BYU's board opens once 5 students from it play the same day. 2 so far today.</div>
<div style="height:16px;"></div>
${eyebrow("Today's concepts")}
<div style="font-size:14px;line-height:1.45;color:${C.muted};margin-bottom:4px;">Play them again as practice. Your first try is the one that counts.</div>
${againRow('statics', 'Which Distance Counts', 'Force Systems &amp; Resultants')}
${againRow('mechanics-materials', 'Which Stretches More', 'Axial Stress, Strain &amp; Deformation')}
${againRow('surveying', 'Find It on the Plan', 'Angles, Distances &amp; Bearings')}
<div style="display:flex;align-items:center;justify-content:space-between;margin-top:8px;"><span style="font-size:15px;font-weight:600;text-decoration:underline;text-underline-offset:4px;">Share your result</span>${eyebrow('Next one at midnight', C.muted)}</div>
</div>`)}
`);

// ── T09 Profile, landscape: the page of type, the facts in two columns ──
const fact = (big, unit, line, trailing = '', size = 84) => `
<div style="display:flex;flex-direction:column;gap:10px;">
<div style="display:flex;align-items:baseline;gap:10px;"><span style="font-family:${F.display};font-weight:800;font-size:${size}px;line-height:0.82;letter-spacing:-0.06em;">${big}</span><span style="font-family:${F.display};font-weight:700;font-size:${Math.round(size * (size > 84 ? 0.26 : 0.29))}px;letter-spacing:-0.03em;white-space:nowrap;">${unit}</span>${trailing}</div>
<div style="font-size:16px;color:${C.muted};">${line}</div>
</div>`;
// Stand-in for LeagueCoin (league_coin.dart draws the real one).
const coin = (s = 30) => `<span aria-hidden="true" style="position:relative;display:inline-block;flex-shrink:0;width:${s}px;height:${s}px;border-radius:50%;background:${T.leagueCoin.silver.face};box-shadow:inset 0 0 0 ${Math.max(3, s / 9)}px ${T.leagueCoin.silver.rim};align-self:center;margin-left:4px;"><span style="position:absolute;inset:${s * 0.3}px;border-radius:50%;border:${Math.max(1.5, s / 20)}px solid ${T.leagueCoin.silver.ink};"></span></span>`;
const avatar = `<span role="button" aria-label="Account" style="display:flex;align-items:center;justify-content:center;width:52px;height:52px;border-radius:26px;background:${C.charcoal};color:${C.onCharcoal};font-family:${F.display};font-weight:700;font-size:18px;">J</span>`;
const progressBar = (w, f) => `<div style="width:${w}px;height:10px;border-radius:5px;background:${C.pipOff};"><div style="width:${Math.round(w * f)}px;height:10px;border-radius:5px;background:${C.charcoal};"></div></div>`;
const carryOn = (w) => `
<div style="position:relative;width:${w}px;padding-top:58px;">
<img src="${RACCOON}" alt="" style="position:absolute;left:34px;top:0;width:118px;">
<div style="position:relative;">${pill('Carry on').replace(`background:${C.charcoal}`, `background:${C.forest}`)}</div>
<div style="margin-top:12px;text-align:center;font-family:${F.mono};font-size:13px;color:${C.muted};">Mathematics · Round 1 of 20</div>
</div>`;
out['T09-profile-landscape'] = page('Profile, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${abs(CX, TOP + 16, L.W - CX - 40, 52, `<div style="display:flex;align-items:center;justify-content:space-between;height:52px;">${eyebrow('Tuesday, Nov 3', C.muted)}${avatar}</div>`)}
${abs(CX, TOP + 104, 460, null, headline('Welcome back, Jerson.', 96))}
${abs(CX, L.H - 36 - 168, 440, null, carryOn(440))}
${abs(CX + 440 + 72, TOP + 116, L.W - (CX + 440 + 72) - 40, null, `<div style="display:flex;flex-direction:column;gap:46px;">
<div style="display:flex;flex-direction:column;gap:14px;">${fact('20', 'rounds left', 'In Law of Sines &amp; Law of Cosines')}${progressBar(460, 0.05)}</div>
${fact('6', 'days studied', 'Across the app and the website')}
${fact('73', 'days to the exam', 'Friday, January 15')}
${fact('3rd', 'in Silver', 'Of 15 this week, ends Saturday', coin())}
</div>`)}
`);

// ── T09p Profile, portrait: the fact Carry on acts on leads, the others in a row ──
const stackFact = (big, unit, line, trailing = '') => `
<div style="display:flex;flex-direction:column;gap:10px;">
<div style="display:flex;align-items:center;gap:10px;"><span style="font-family:${F.display};font-weight:800;font-size:76px;line-height:0.82;letter-spacing:-0.06em;">${big}</span>${trailing}</div>
<div style="font-family:${F.display};font-weight:700;font-size:21px;letter-spacing:-0.03em;">${unit}</div>
<div style="font-size:15px;line-height:1.4;color:${C.muted};">${line}</div>
</div>`;
out['T09p-profile-portrait'] = page('Profile, portrait', P.W, P.H, C.fog, `
${rail('profile', P.H)}
${abs(CX, TOP + 16, P.W - CX - 48, 52, `<div style="display:flex;align-items:center;justify-content:space-between;height:52px;">${eyebrow('Tuesday, Nov 3', C.muted)}${avatar}</div>`)}
${abs(CX, TOP + 104, 600, null, headline('Welcome back, Jerson.', 92))}
${abs(CX, TOP + 410, PW, null, `<div style="display:flex;flex-direction:column;gap:16px;">${fact('20', 'rounds left', 'In Law of Sines &amp; Law of Cosines', '', 150)}${progressBar(PW - 8, 0.05)}</div>`)}
${abs(CX, TOP + 700, PW, null, `<div style="display:grid;grid-template-columns:1fr 1fr 1fr;column-gap:32px;">
${stackFact('6', 'days studied', 'Across the app and the website')}
${stackFact('73', 'days to the exam', 'Friday, January 15')}
${stackFact('3rd', 'in Silver', 'Of 15 this week, ends Saturday', coin(34))}
</div>`)}
${abs(P.W - 48 - TB.size.pillMax, P.H - 40 - 168, null, null, carryOn(TB.size.pillMax))}
`);

// ── T10 Welcome, landscape ──
const floatCard = (x, y, w, h, rot, bg, label, id, glyphS, shadow = false) =>
  abs(x, y, w, h, `<div style="width:${w}px;height:${h}px;box-sizing:border-box;padding:24px;border-radius:34px;background:${bg};color:${C.onAccent};display:flex;flex-direction:column;transform:rotate(${rot}deg);${shadow ? 'box-shadow:0 18px 40px rgba(44,44,44,0.16);' : ''}">${eyebrow(label, C.onAccent, 13)}<div style="flex-grow:1;display:flex;align-items:center;justify-content:center;">${mark(id, 'currentColor', glyphS, 1.15)}</div></div>`);
const conceptsCard = (x, y, w, h, size = 72) => abs(x, y, w, h, `<div style="width:${w}px;height:${h}px;box-sizing:border-box;padding:24px;border-radius:30px;background:${C.cream};display:flex;flex-direction:column;justify-content:space-between;box-shadow:0 18px 40px rgba(44,44,44,0.16);transform:rotate(-2deg);">${eyebrow('Concepts', C.charcoal, 13)}<div style="display:flex;align-items:baseline;gap:8px;"><span style="font-family:${F.display};font-weight:800;font-size:${size}px;line-height:0.82;letter-spacing:-0.06em;">375</span><span style="font-family:${F.display};font-weight:700;font-size:20px;">free</span></div></div>`);
out['T10-welcome-landscape'] = page('Welcome, landscape', L.W, L.H, C.fog, `
${abs(56, TOP + 28, null, null, eyebrow('FE for Raccoons', C.muted, 13))}
${floatCard(610, 90, 290, 340, -6, C.spring, 'Statics', 'statics', 180)}
${floatCard(890, 170, 250, 300, 8, C.peach, 'Fluids', 'fluid-mechanics', 150)}
${conceptsCard(700, 470, 290, 170, 80)}
${abs(56, L.H - 40 - 72 - 44 - 200, 560, null, headline('The FE Civil,<br>one concept<br>at a time.', 66))}
${abs(56, L.H - 40 - 72 - 40, null, null, `<div style="display:flex;align-items:center;gap:28px;">${pill("Let's go", { width: TB.size.pillMax })}<span style="font-size:16px;font-weight:500;color:${C.muted};">I already have an account</span></div>`)}
`);

// ── T10p Welcome, portrait ──
out['T10p-welcome-portrait'] = page('Welcome, portrait', P.W, P.H, C.fog, `
${abs(56, TOP + 32, null, null, eyebrow('FE for Raccoons', C.muted, 13))}
${floatCard(80, 130, 340, 400, -6, C.spring, 'Statics', 'statics', 210)}
${floatCard(450, 200, 300, 350, 8, C.peach, 'Fluids', 'fluid-mechanics', 180)}
${conceptsCard(250, 540, 320, 176, 88)}
${abs(56, 770, 620, null, headline('The FE Civil,<br>one concept<br>at a time.', 74))}
${abs(56, P.H - 40 - 40 - 72 - 30, P.W - 112, null, `<div style="display:flex;flex-direction:column;gap:22px;align-items:flex-start;">${pill("Let's go", { width: TB.size.pillMax })}<span style="font-size:16px;font-weight:500;color:${C.muted};padding-left:28px;">I already have an account</span></div>`)}
`);

// ── T11 League, landscape: the place beside the board ──
const leagueRow = (place, name, xp, me, caret = '') => `<div style="display:flex;align-items:center;gap:16px;height:52px;box-sizing:border-box;padding:0 20px;border-radius:18px;${me ? `background:${C.charcoal};color:${C.onCharcoal};` : ''}"><span style="width:24px;font-family:${F.mono};font-size:14px;color:${me ? C.mutedDark : C.muted};">${place}</span><span style="flex-grow:1;font-family:${F.display};font-weight:700;font-size:17px;">${name}</span><span style="font-family:${F.mono};font-size:11px;color:${C.forest};width:28px;">${caret}</span><span style="font-family:${F.mono};font-size:14px;font-weight:600;">${xp} XP</span></div>`;
const zone = (label, color, icon, rows) => `<div style="display:flex;flex-direction:column;gap:8px;"><div style="display:flex;align-items:center;gap:8px;color:${color};padding-left:4px;">${icon}${eyebrow(label, color)}</div><div style="box-sizing:border-box;padding:6px;border-radius:26px;background:${C.cream};">${rows.join('')}</div></div>`;
out['T11-league-landscape'] = page('League, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${abs(CX, TOP + 16, 400, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${roundIcon('Back', ico.back)}${eyebrow('Ends Saturday')}</div>`)}
${abs(CX, TOP + 104, 420, null, `<div style="display:flex;flex-direction:column;gap:22px;">
<div style="display:flex;align-items:center;gap:14px;">${coin(44)}${headline('Silver league', 44)}</div>
<div style="display:flex;align-items:baseline;gap:10px;"><span style="font-family:${F.display};font-weight:800;font-size:150px;line-height:0.82;letter-spacing:-0.07em;">3rd</span><span style="font-family:${F.display};font-weight:700;font-size:28px;letter-spacing:-0.03em;">of 15</span></div>
<div style="font-size:17px;line-height:1.5;max-width:400px;">Points from the app and the website both count. The week ends Saturday at midnight, Eastern.</div>
<div style="font-size:15px;line-height:1.5;max-width:400px;color:${C.muted};">Everyone here studied this week. A new league starts every Sunday.</div>
</div>`)}
${abs(CX + 420 + 56, TOP + 16, L.W - (CX + 420 + 56) - 40, L.H - TOP - 16, `<div style="display:flex;flex-direction:column;gap:22px;">
${zone('Moving up to Gold', C.forest, ico.up, [leagueRow(1, 'Maria L.', 1840, false), leagueRow(2, 'Dev P.', 1610, false, '▲ 2'), leagueRow(3, 'You', 1395, true, ''), leagueRow(4, 'Sam R.', 1270, false), leagueRow(5, 'Ana G.', 1105, false)])}
${zone('Staying in Silver', C.muted, '', [leagueRow(6, 'Theo K.', 980, false), leagueRow(7, 'Priya N.', 940, false), leagueRow(8, 'Luis M.', 860, false), leagueRow(9, 'Kate W.', 715, false), leagueRow(10, 'Omar H.', 640, false), leagueRow(11, 'Jess T.', 590, false), leagueRow(12, 'Ben A.', 520, false)])}
${zone('Moving down to Bronze', C.ember, ico.down, [leagueRow(13, 'Nina S.', 310, false), leagueRow(14, 'Raj P.', 150, false), leagueRow(15, 'Leo F.', 40, false)])}
</div>`, 'overflow:hidden;')}
`);

// ════════════════════ every other screen (2026-11-03, second pass) ════════════════════
// Real copy from lib/features and the phone goldens. Screens that stay
// phone-like on purpose say so in TABLET.md, section 4.

const nextBtn = (label = 'Next') => `<span role="button" aria-label="${label}" style="display:flex;align-items:center;justify-content:center;width:72px;height:72px;border-radius:36px;background:${C.charcoal};color:${C.spring};flex-shrink:0;">${arrow(30)}</span>`;
const stepDots = (n, at, color = C.charcoal) => `<div style="display:flex;gap:6px;align-items:center;">${Array.from({ length: n }, (_, i) => `<span style="width:${i === at ? 34 : 8}px;height:8px;border-radius:4px;background:${color};opacity:${i === at ? 1 : 0.3};"></span>`).join('')}</div>`;
const link = (t, color = C.charcoal, size = 16) => `<span role="link" style="font-size:${size}px;font-weight:500;color:${color};text-decoration:underline;text-underline-offset:4px;">${t}</span>`;
const field = (placeholder, caption, w, line = C.forest) => `
<div style="width:${w}px;display:flex;flex-direction:column;gap:14px;">
<div style="font-family:${F.display};font-weight:700;font-size:40px;letter-spacing:-0.03em;color:${C.muted};opacity:0.75;padding-bottom:12px;border-bottom:3px solid ${line};">${placeholder}</div>
<div style="font-size:16px;line-height:1.5;color:${C.muted};max-width:${TB.measure.body}px;">${caption}</div>
</div>`;
const twoTone = (a, b, size = 72, second = C.forest) => headline(`${a}<br><span style="color:${second};">${b}</span>`, size);
const topLine = (x, w, left, right = '') => abs(x, TOP + 12, w, 52, `<div style="display:flex;align-items:center;justify-content:space-between;height:52px;gap:20px;">${left}${right}</div>`);
const sheetBox = (w, h, inner, { radius = '40px 40px 0 0', pad = '12px 36px 32px' } = {}) => `
<div style="width:${w}px;height:${h}px;box-sizing:border-box;padding:${pad};border-radius:${radius};background:${C.sheet};display:flex;flex-direction:column;gap:18px;overflow:hidden;">
<div style="align-self:center;width:44px;height:5px;border-radius:3px;background:${C.charcoal};opacity:0.25;flex-shrink:0;"></div>
${inner}
</div>`;
const scrim = () => abs(0, 0, null, null, '', `width:100%;height:100%;background:${C.scrim};z-index:6;`);
const block = (bg, inner, pad = '28px') => `<div style="box-sizing:border-box;padding:${pad};border-radius:32px;background:${bg};">${inner}</div>`;
const darkPill = (label, w = null, h = 64) => `<span role="button" style="display:flex;align-items:center;justify-content:center;height:${h}px;${w ? `width:${w}px;` : ''}box-sizing:border-box;border-radius:${h / 2}px;background:${C.charcoal};color:${C.onCharcoal};font-family:${F.display};font-weight:700;font-size:18px;">${label}</span>`;
const lightPill = (label, w = null, h = 64) => `<span role="button" style="display:flex;align-items:center;justify-content:center;height:${h}px;${w ? `width:${w}px;` : ''}box-sizing:border-box;border-radius:${h / 2}px;border:2px solid ${C.charcoal};font-family:${F.display};font-weight:700;font-size:18px;">${label}</span>`;
const LEFT_W = 500; // the left column on screens with no rail
const RX = 620;     // where the right column starts on screens with no rail
const RW = L.W - RX - 56;

// The system keyboard, drawn as a plain stand-in (iPadOS draws the real one).
// It is on the auth mockups to prove the field and its next button clear it.
const keyboard = (W, H, h = 300) => {
  const key = (t, w = 1) => `<span style="flex:${w};display:flex;align-items:center;justify-content:center;height:58px;border-radius:9px;background:#FCFCFE;box-shadow:0 1px 0 #8E9096;font-family:-apple-system,'Inter',sans-serif;font-size:20px;color:#1C1C1E;">${t}</span>`;
  const row = (keys, pad = 0) => `<div style="display:flex;gap:9px;padding:0 ${pad}px;">${keys.map((k) => (Array.isArray(k) ? key(k[0], k[1]) : key(k))).join('')}</div>`;
  return abs(0, H - h, W, h, `<div style="height:${h}px;box-sizing:border-box;padding:12px 10px;background:#D1D3D9;display:flex;flex-direction:column;gap:11px;">
${row(['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', ['delete', 1.4]])}${row(['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ['return', 1.8]], 28)}${row([['shift', 1.3], 'z', 'x', 'c', 'v', 'b', 'n', 'm', '@', '.', ['shift', 1.3]])}${row([['.?123', 1.6], [' ', 7], ['.?123', 1.6]])}</div>`, 'z-index:4;');
};

// ── T12 Auth: one field per screen; headline left, the field right ──
const authL = (name, title, ground, dots, at, head, field_, below, { close = true, decor = '', kb = true } = {}) => {
  out[name] = page(title, L.W, L.H, ground, `
${decor}${kb ? keyboard(L.W, L.H) : ''}
${abs(56, TOP + 12, 500, 52, `<div style="display:flex;align-items:center;gap:22px;height:52px;">${roundIcon(close ? 'Close' : 'Back', close ? ico.close : ico.back)}${dots ? stepDots(dots, at) : ''}</div>`)}
${abs(56, TOP + 110, LEFT_W, null, head)}
${abs(RX, TOP + 168, RW, null, `<div style="display:flex;flex-direction:column;gap:40px;">${field_}${below}</div>`)}
`);
};
const nextRow = (left) => `<div style="display:flex;align-items:center;justify-content:space-between;">${left}${nextBtn()}</div>`;
authL('T12-create-email-landscape', 'Create account, email, landscape', C.fog, 5, 0,
  twoTone('First,', 'your email.', 84),
  field('you@school.edu', 'Completely free. Your progress follows you to the website.', RW),
  nextRow(link('Log in instead')));
authL('T12b-create-name-landscape', 'Create account, name, landscape', C.butter, 5, 1,
  headline('What should<br>we call you?', 84),
  field('Your first name', "Shown on the Daily's board and in hello. You can change it any time.", RW, C.charcoal),
  nextRow(link('Skip')));
authL('T12c-create-password-landscape', 'Create account, password, landscape', C.spring, 5, 2,
  headline('Pick a<br>password.', 84, C.onAccent),
  `<div style="width:${RW}px;display:flex;flex-direction:column;gap:14px;"><div style="display:flex;align-items:center;gap:6px;height:52px;padding-bottom:12px;border-bottom:3px solid ${C.onAccent};"><span style="width:3px;height:44px;background:${C.onAccent};"></span>${Array.from({ length: 8 }, () => `<span style="width:12px;height:12px;border-radius:6px;background:${C.onAccent};opacity:0.45;"></span>`).join('')}</div><div style="font-size:16px;line-height:1.5;color:${C.onAccent};opacity:0.75;">Eight characters or more. You can reset it by email any time.</div></div>`,
  nextRow('<span></span>'));
const gradChips = (on) => `<div style="display:flex;gap:6px;">${['Winter', 'Spring', 'Summer', 'Fall'].map((t) => `<span style="display:flex;align-items:center;justify-content:center;height:44px;padding:0 20px;border-radius:22px;${t === on ? `background:${C.charcoal};color:${C.onCharcoal};` : ''}font-family:${F.mono};font-size:13px;font-weight:600;letter-spacing:0.06em;text-transform:uppercase;">${t}</span>`).join('')}</div>`;
const yearChips = (on) => `<div style="display:flex;gap:6px;">${[2026, 2027, 2028, 2029, 2030].map((t) => `<span style="display:flex;align-items:center;justify-content:center;height:44px;padding:0 18px;border-radius:22px;${t === on ? `background:${C.charcoal};color:${C.onCharcoal};` : ''}font-family:${F.mono};font-size:14px;font-weight:600;">${t}</span>`).join('')}</div>`;
authL('T12d-create-school-landscape', 'Create account, school, landscape', C.peach, 5, 3,
  `<div style="display:flex;flex-direction:column;gap:22px;">${headline('Where do<br>you study?', 76)}<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow('Graduating', C.muted)}${gradChips('Spring')}${yearChips(2027)}</div></div>`,
  field('Your university', 'So we can show you how you compare with other students at your school.', RW, C.charcoal),
  nextRow(link('I have already graduated')));
// The phone sets big FE letters behind log in; on a tablet the keyboard covers
// that band, so they are left out.
authL('T12e-log-in-landscape', 'Log in, landscape', C.fog, 2, 0,
  twoTone('Hey again.', "What's your<br>email?", 76),
  field('you@school.edu', 'Your password comes next.', RW),
  nextRow(link('Create an account')));
authL('T12f-forgot-landscape', 'Forgot password, landscape', C.fog, 0, 0,
  twoTone('Reset your', 'password.', 84),
  field('you@school.edu', "We'll email you a reset link.", RW),
  nextRow(link('Back to log in')), { close: false });

// Check your email: the verify sheet, capped at 640 and centred, the two cards behind.
out['T12g-check-email-landscape'] = page('Check your email, landscape', L.W, L.H, C.fog, `
${abs(400, TOP + 18, null, null, stepDots(3, 2))}
${abs(250, 70, 380, 380, `<div style="width:380px;height:380px;border-radius:40px;background:${C.spring};opacity:0.5;transform:rotate(-6deg);"></div>`)}
${abs(560, 120, 360, 360, `<div style="width:360px;height:360px;border-radius:40px;background:${C.peach};opacity:0.6;transform:rotate(8deg);"></div>`)}
${abs((L.W - TB.pane.sheetMax) / 2, L.H - 320, TB.pane.sheetMax, 320, sheetBox(TB.pane.sheetMax, 320, `
${headline('Check your email.', 44)}
<div style="font-size:17px;line-height:1.5;color:${C.muted};">We sent a link to <span style="color:${C.charcoal};">you@school.edu</span>. Tap it and you're in.</div>
<div style="display:flex;gap:12px;margin-top:4px;">${darkPill('Open email app', 278)}${lightPill('Resend link', 278)}</div>
<div style="display:flex;justify-content:space-between;align-items:center;margin-top:6px;">${link('Wrong email? Go back', C.charcoal, 15)}<span style="font-size:15px;font-weight:600;color:${C.forest};">Continue to the app</span></div>`))}
`);

// Portrait: the auth flow stays the phone's column, set left. One example.
out['T12p-create-email-portrait'] = page('Create account, email, portrait', P.W, P.H, C.fog, `
${abs(56, TOP + 12, 500, 52, `<div style="display:flex;align-items:center;gap:22px;height:52px;">${roundIcon('Close', ico.close)}${stepDots(5, 0)}</div>`)}
${abs(56, TOP + 140, 600, null, twoTone('First,', 'your email.', 84))}
${abs(56, TOP + 380, 600, null, field('you@school.edu', 'Completely free. Your progress follows you to the website.', 600))}
${abs(56, TOP + 540, 600, 72, nextRow(link('Log in instead')))}
${keyboard(P.W, P.H, 320)}
`);

// ── T13 Onboarding: the words left, the object right ──
const onbTop = (n, at) => `${abs(56, TOP + 12, L.W - 112, 52, `<div style="display:flex;align-items:center;justify-content:space-between;height:52px;"><div style="display:flex;align-items:center;gap:22px;">${roundIcon('Close', ico.close)}${stepDots(n, at)}</div>${at < n - 1 ? link('Skip', C.charcoal, 15) : ''}</div>`)}`;
const body17 = (t, w = 480) => `<div style="max-width:${w}px;font-size:17px;line-height:1.6;color:${C.charcoal};opacity:0.82;">${t}</div>`;
const listCard = (bg, over, big, items, w) => `<div style="width:${w}px;box-sizing:border-box;display:flex;gap:28px;padding:30px 32px;border-radius:36px;background:${bg};">
<div style="display:flex;flex-direction:column;gap:10px;width:170px;flex-shrink:0;">${eyebrow(over, C.onAccent, 12)}<span style="font-family:${F.display};font-weight:800;font-size:40px;letter-spacing:-0.04em;color:${C.onAccent};">${big}</span></div>
<div style="display:flex;flex-direction:column;gap:12px;font-size:16px;line-height:1.4;color:${C.onAccent};">${items.map((i) => `<span>${i}</span>`).join('')}</div></div>`;
out['T13-onboarding-together-landscape'] = page('Onboarding, two parts, landscape', L.W, L.H, C.fog, `
${onbTop(3, 0)}
${abs(56, TOP + 130, 500, null, `<div style="display:flex;flex-direction:column;gap:26px;">${headline('Learn at the desk.<br>Practice<br>anywhere.', 64)}${body17('FE for Raccoons comes in two parts. The website is where you learn the material and earn your mastery. The app is for the time in between, when you are away from your desk and have a few minutes to keep concepts fresh.')}</div>`)}
${abs(RX, TOP + 110, RW, null, `<div style="display:flex;flex-direction:column;gap:0;">
${listCard(C.cream, 'fe4raccoons.com', 'Learn it', ['135 lessons with full solutions', '1,454 exam-style problems', 'The 6-hour exam simulation', 'Your mastery, chapter by chapter'], RW)}
<div style="height:70px;position:relative;"><img src="${RACCOON}" alt="" style="position:absolute;right:70px;top:14px;width:120px;"></div>
${listCard(C.spring, 'The app', 'Keep it', ['375 concepts, about a minute each', 'Any chapter, in any order', 'Keeps you sharp between desk sessions'], RW)}
</div>`)}
${abs(L.W - 56 - 72, L.H - 36 - 72, 72, 72, nextBtn())}
`);

// The sample round on step two: the shared truss, one member picked out.
const truss = (w, h) => {
  const s = w / 420, y0 = h - 70 * s, y1 = 80 * s, xs = [50, 150, 270, 370].map((v) => v * s);
  const J = { A: [xs[0], y0], B: [xs[1], y0], C: [xs[2], y0], D: [xs[3], y0], E: [xs[1], y1], F: [xs[2], y1] };
  const m = (a, b, col = C.charcoal, sw = 3.2) => `<path d="M${J[a][0]} ${J[a][1]} L${J[b][0]} ${J[b][1]}" stroke="${col}" stroke-width="${sw * s}" stroke-linecap="round"/>`;
  const members = [['A', 'B'], ['B', 'C'], ['C', 'D'], ['A', 'E'], ['E', 'B'], ['B', 'F'], ['F', 'C'], ['F', 'D']].map(([a, b]) => m(a, b)).join('') + m('E', 'F', C.ember, 5);
  const joints = Object.values(J).map(([x, y]) => `<circle cx="${x}" cy="${y}" r="${7 * s}" fill="${C.paper}" stroke="${C.charcoal}" stroke-width="${2.4 * s}"/>`).join('');
  const lab = (k, dx, dy) => `<text x="${J[k][0] + dx * s}" y="${J[k][1] + dy * s}" font-family="JetBrains Mono" font-size="${13 * s}" fill="${C.muted}">${k}</text>`;
  const pin = `<path d="M${xs[0]} ${y0 + 7 * s} l${-14 * s} ${22 * s} h${28 * s} z" fill="none" stroke="${C.charcoal}" stroke-width="${2.2 * s}"/><path d="M${xs[0] - 22 * s} ${y0 + 31 * s} h${44 * s}" stroke="${C.charcoal}" stroke-width="${2.2 * s}"/>`;
  const roller = `<circle cx="${xs[3]}" cy="${y0 + 17 * s}" r="${9 * s}" fill="none" stroke="${C.charcoal}" stroke-width="${2.2 * s}"/><path d="M${xs[3] - 22 * s} ${y0 + 28 * s} h${44 * s}" stroke="${C.charcoal}" stroke-width="${2.2 * s}"/>`;
  const load = `<path d="M${xs[2]} ${y1 - 66 * s} V${y1 - 12 * s}" stroke="${C.charcoal}" stroke-width="${2.6 * s}"/><path d="M${xs[2] - 7 * s} ${y1 - 22 * s} l${7 * s} ${10 * s} l${7 * s} ${-10 * s}" fill="none" stroke="${C.charcoal}" stroke-width="${2.6 * s}" stroke-linejoin="round"/><text x="${xs[2] + 10 * s}" y="${y1 - 52 * s}" font-family="JetBrains Mono" font-weight="700" font-size="${14 * s}" fill="${C.charcoal}">24 kN</text>`;
  return `<div style="${gridPaper(w, h, Math.round(40 * s))}"><svg width="${w}" height="${h}" style="position:absolute;inset:0;" fill="none">${members}${pin}${roller}${load}${joints}${lab('A', -20, -8)}${lab('B', -4, 32)}${lab('C', -4, 32)}${lab('D', 12, -8)}${lab('E', -24, -6)}${lab('F', 12, -8)}</svg></div>`;
};
const choiceChips = (labels, on, w, h = 56) => `<div style="display:flex;gap:10px;width:${w}px;">${labels.map((l) => `<span style="flex:1;display:flex;align-items:center;justify-content:center;height:${h}px;border-radius:${h / 2}px;background:${l === on ? C.charcoal : C.creamDark};color:${l === on ? C.onCharcoal : C.charcoal};font-family:${F.display};font-weight:700;font-size:17px;">${l}</span>`).join('')}</div>`;
out['T13b-onboarding-games-landscape'] = page('Onboarding, a minute each, landscape', L.W, L.H, C.peach, `
${onbTop(3, 1)}
${abs(56, TOP + 130, 500, null, `<div style="display:flex;flex-direction:column;gap:26px;">${headline('One concept.<br>A minute each.', 64)}${body17('Each lesson in the app is a few rounds. For each round, you read a figure, make a call, and see right away whether you were right and why. All fifteen chapters are open from the start, so you can go straight to the one you need.')}</div>`)}
${abs(RX, TOP + 90, RW, null, `<div style="box-sizing:border-box;width:${RW}px;padding:26px 28px 28px;border-radius:36px;background:${C.cream};display:flex;flex-direction:column;gap:16px;">
<div style="display:flex;align-items:center;gap:14px;">${pips(1, 6, RW - 56 - 60)}<span style="width:46px;text-align:right;">${eyebrow('2 / 6')}</span></div>
${eyebrow('Which way is it being worked', C.forest)}
<div style="font-size:17px;line-height:1.5;">Same truss, same load. This time the member picked out runs along the top, between the two apex joints.</div>
${truss(RW - 56, 300)}
${choiceChips(['Stretched', 'Squashed', 'Neither'], 'Squashed', RW - 56)}
</div>`)}
${abs(L.W - 56 - 72, L.H - 36 - 72, 72, 72, nextBtn())}
`);
const masteryCard = (w) => `<div style="width:${w}px;box-sizing:border-box;padding:26px 30px;border-radius:36px;background:${C.cream};display:flex;flex-direction:column;gap:14px;">
${eyebrow('Where mastery comes from')}
<div style="display:flex;align-items:flex-end;gap:14px;"><span style="font-family:${F.display};font-weight:800;font-size:110px;line-height:0.82;letter-spacing:-0.06em;">100<span style="font-size:44px;">%</span></span><span style="font-family:${F.display};font-weight:700;font-size:18px;line-height:1.25;padding-bottom:6px;">the problems you work<br>on the website</span></div>
<div style="display:flex;gap:6px;">${Array.from({ length: 10 }, () => `<span style="flex:1;height:14px;border-radius:7px;background:${C.charcoal};"></span>`).join('')}</div>
<div style="font-size:15px;line-height:1.5;color:${C.muted};">Practice in the app does not change this number, but it helps you have the concepts fresh for more effective study sessions.</div></div>`;
const legal = `<div style="font-size:12.5px;line-height:1.5;color:${C.muted};">By creating an account or using the app, you agree to our <u>Terms of Service</u> and <u>Privacy Policy</u>.</div>`;
out['T13c-onboarding-honest-landscape'] = page('Onboarding, honest by design, landscape', L.W, L.H, C.butter, `
${onbTop(3, 2)}
${abs(56, TOP + 130, 500, null, `<div style="display:flex;flex-direction:column;gap:26px;">${headline('Honest by<br>design.', 72)}${body17('With an account, everything you play in the app is saved, and you can see it on the website too. It does not raise your mastery score, though. Recognizing a concept is not the same as solving a problem with it, so mastery only comes from problems you work at a desk.')}</div>`)}
${abs(RX, TOP + 110, RW, null, masteryCard(RW))}
${abs(RX, L.H - 36 - 262, RW, null, `<div style="display:flex;flex-direction:column;gap:14px;">
${pill('Create my account')}
${lightPill('Try a round first')}
<div style="display:flex;justify-content:center;font-size:16px;font-weight:500;margin-top:4px;">I already have an account</div>
<div style="margin-top:6px;">${legal}</div></div>`)}
`);
out['T13p-onboarding-honest-portrait'] = page('Onboarding, honest by design, portrait', P.W, P.H, C.butter, `
${abs(56, TOP + 12, P.W - 112, 52, `<div style="display:flex;align-items:center;gap:22px;height:52px;">${roundIcon('Close', ico.close)}${stepDots(3, 2)}</div>`)}
${abs(56, TOP + 120, P.W - 112, null, `<div style="display:grid;grid-template-columns:300px 1fr;column-gap:36px;align-items:start;">${headline('Honest by<br>design.', 64)}${body17('With an account, everything you play in the app is saved, and you can see it on the website too. It does not raise your mastery score, though. Recognizing a concept is not the same as solving a problem with it, so mastery only comes from problems you work at a desk.', 400)}</div>`)}
${abs(56, TOP + 470, P.W - 112, null, masteryCard(P.W - 112))}
${abs(56, P.H - 40 - 300, P.W - 112, null, `<div style="display:flex;flex-direction:column;gap:14px;">${pill('Create my account')}${lightPill('Try a round first')}<div style="display:flex;justify-content:center;font-size:16px;font-weight:500;margin-top:4px;">I already have an account</div><div style="margin-top:6px;">${legal}</div></div>`)}
`);

// Titles and splash: posters, phone-like on purpose.
out['T14-titles-landscape'] = page('Titles, landscape', L.W, L.H, C.paper, `
${abs(0, 0, L.W, L.H, '', `${gridPaper(L.W, L.H, 48)}border-radius:0;`)}
${abs(0, 250, L.W, null, `<div style="display:flex;flex-direction:column;align-items:center;gap:26px;">${headline('Welcome to', 56)}<div style="display:flex;flex-direction:column;align-items:center;padding:14px 22px;border-radius:14px;background:${C.white};box-shadow:0 4px 0 ${C.plinth};"><span style="font-family:${F.display};font-weight:800;font-size:96px;line-height:0.85;letter-spacing:-0.05em;">FE<span style="color:${C.ember};">4</span></span><span style="font-family:${F.display};font-weight:700;font-size:22px;letter-spacing:0.32em;">RACCOONS</span></div>${headline('the mobile app', 56, C.ember)}</div>`)}
`);
out['T14b-splash-landscape'] = page('Splash, landscape', L.W, L.H, C.fog, `
${abs(0, 330, L.W, null, `<div style="display:flex;flex-direction:column;align-items:center;"><span style="font-family:${F.display};font-weight:800;font-size:112px;line-height:0.85;letter-spacing:-0.05em;">FE<span style="color:${C.ember};">4</span></span><span style="font-family:${F.display};font-weight:600;font-size:26px;letter-spacing:0.36em;margin-top:8px;">RACCOONS</span></div>`)}
`);

// ── T15 Exam date: the date left, the picker right, two weeks at a glance ──
const monthChips = (months, on, dark = false) => `<div style="display:flex;gap:6px;flex-wrap:wrap;">${months.map((m) => `<span style="display:flex;align-items:center;justify-content:center;height:44px;padding:0 18px;border-radius:22px;${m === on ? `background:${C.charcoal};color:${dark ? C.spring : C.onCharcoal};` : `color:${C.onAccent};`}font-family:${F.mono};font-size:13px;font-weight:600;letter-spacing:0.06em;text-transform:uppercase;">${m}</span>`).join('')}</div>`;
const dayCell = (dow, d, on, size = 66) => `<span style="display:flex;flex-direction:column;align-items:center;justify-content:center;gap:6px;width:${size}px;height:${size * 1.45}px;border-radius:${size / 2}px;${on ? `background:${C.charcoal};color:${C.spring};` : `color:${C.onAccent};`}"><span style="font-family:${F.mono};font-size:11px;font-weight:600;letter-spacing:0.06em;">${dow}</span><span style="font-family:${F.display};font-weight:700;font-size:28px;">${d}</span></span>`;
const DOW = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
out['T15-exam-date-landscape'] = page('Exam date, landscape', L.W, L.H, C.spring, `
${abs(56, TOP + 12, 52, 52, roundIcon('Back', ico.back))}
${abs(56, TOP + 110, 520, null, `<div style="display:flex;flex-direction:column;gap:40px;">${headline("When's the<br>big day?", 76, C.onAccent)}
<div style="display:flex;flex-direction:column;gap:18px;"><span style="font-family:${F.display};font-weight:800;font-size:150px;line-height:0.82;letter-spacing:-0.07em;color:${C.onAccent};">Jan 15</span>
<div style="display:flex;align-items:center;gap:14px;">${eyebrow('Friday', C.onAccent, 14)}<span style="display:flex;align-items:center;height:40px;padding:0 16px;border-radius:20px;background:${C.charcoal};color:${C.spring};font-family:${F.mono};font-size:14px;font-weight:600;">73 days out</span></div></div></div>`)}
${abs(RX + 20, TOP + 150, RW - 20, null, `<div style="display:flex;flex-direction:column;gap:30px;">${monthChips(['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr'], 'Jan', true)}
<div style="display:grid;grid-template-columns:repeat(7,66px);column-gap:8px;row-gap:14px;">${[11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24].map((d, i) => dayCell(DOW[i % 7], d, d === 15)).join('')}</div></div>`)}
${abs(RX + 20, L.H - 36 - 72, RW - 20, 72, `<div style="display:flex;align-items:center;justify-content:space-between;height:72px;">${link('Clear the date', C.onAccent)}${nextBtn('Save the date')}</div>`)}
`);

// ── T16 Days studied: the count left, two months right ──
const monthGrid = (name, first, days, studied, today, w) => {
  const cell = Math.min(42, Math.floor((w - 6 * 10) / 7));
  const cells = Array.from({ length: first }, () => '<span></span>').concat(Array.from({ length: days }, (_, i) => {
    const d = i + 1, on = studied.includes(d), now = d === today, future = today && d > today;
    return `<span style="display:flex;align-items:center;justify-content:center;width:${cell}px;height:${cell}px;border-radius:50%;${on ? `background:${C.charcoal};color:${C.onCharcoal};` : now ? `background:${C.cream};` : ''}font-family:${F.mono};font-size:15px;font-weight:600;${!on && !now ? `color:${C.muted};${future ? 'opacity:0.5;' : ''}` : ''}">${d}</span>`;
  }));
  return `<div style="display:flex;flex-direction:column;gap:12px;"><div style="display:flex;align-items:baseline;justify-content:space-between;">${headline(name, 34)}${eyebrow(`${studied.length} of ${today || days} days`, C.muted)}</div>
<div style="display:grid;grid-template-columns:repeat(7,${cell}px);column-gap:${Math.floor((w - 7 * cell) / 6)}px;row-gap:6px;">${DOW.map((d) => `<span style="text-align:center;font-family:${F.mono};font-size:11px;font-weight:600;color:${C.muted};">${d}</span>`).join('')}${cells.join('')}</div></div>`;
};
out['T16-days-studied-landscape'] = page('Days studied, landscape', L.W, L.H, C.butter, `
${rail('profile', L.H)}
${topLine(CX, 420, roundIcon('Back', ico.back), eyebrow('Days studied', C.muted))}
${abs(CX, TOP + 130, 420, null, `<div style="display:flex;flex-direction:column;gap:26px;"><div style="display:flex;align-items:baseline;gap:14px;"><span style="font-family:${F.display};font-weight:800;font-size:170px;line-height:0.82;letter-spacing:-0.07em;">27</span><span style="font-family:${F.display};font-weight:700;font-size:34px;">days</span></div>
<div style="font-size:17px;line-height:1.6;opacity:0.82;">Since Aug 3. Every day you finish a round or open a lesson counts once, and the number only ever goes up.</div>
${monthChips(['Nov', 'Oct', 'Sep', 'Aug'], 'Nov')}</div>`)}
${abs(CX + 420 + 64, TOP + 40, L.W - (CX + 420 + 64) - 48, null, `<div style="display:flex;flex-direction:column;gap:36px;">
${monthGrid('November', 6, 30, [1, 2], 3, L.W - (CX + 420 + 64) - 48)}
${monthGrid('October', 3, 31, [3, 4, 10, 11, 17, 18, 24, 31], 0, L.W - (CX + 420 + 64) - 48)}</div>`)}
`);

// ── T17 Mastery: the total and where effort pays, beside the chapters ──
const WEIGHTS = { mathematics: '8-12', statistics: '8-12', ethics: '4-6', economics: '5-8', statics: '8-12', dynamics: '4-6', 'mechanics-materials': '7-11', materials: '5-8', 'fluid-mechanics': '6-9', surveying: '6-9', 'water-resources': '10-15', structural: '10-15', geotechnical: '10-15', transportation: '9-14', construction: '8-12' };
const MASTERY = { mathematics: 62, statistics: 40, ethics: 55, economics: 48, statics: 70, dynamics: 15, 'mechanics-materials': 22, materials: 10, 'fluid-mechanics': 30, surveying: 5, 'water-resources': 8, structural: 12, geotechnical: 0, transportation: 4, construction: 6 };
const scatter = (w, h) => {
  const px = (q) => 40 + ((q - 3) / 11) * (w - 60), py = (m) => h - 30 - (m / 100) * (h - 50);
  const mid = (r) => { const [a, b] = r.split('-').map(Number); return (a + b) / 2; };
  const dots = chapters.map(([id]) => { const x = px(mid(WEIGHTS[id])), y = py(MASTERY[id]); const sel = id === 'geotechnical'; const low = MASTERY[id] < 25 && mid(WEIGHTS[id]) > 8; return `<circle cx="${x}" cy="${y}" r="${sel ? 10 : 7}" fill="${sel || low ? C.ember : C.charcoal}"${sel ? ` stroke="${C.fog}" stroke-width="3"` : ''}/>`; }).join('');
  return `<svg width="${w}" height="${h}" fill="none">
<rect x="${px(8.5)}" y="${py(30)}" width="${px(14) - px(8.5)}" height="${py(0) - py(30)}" rx="10" fill="${C.ember}" opacity="0.14"/>
<text x="${px(14) - 8}" y="${py(30) + 18}" text-anchor="end" font-family="JetBrains Mono" font-size="11" fill="${C.ember}">work here first</text>
${[0, 25, 50, 75, 100].map((m) => `<text x="0" y="${py(m) + 4}" font-family="JetBrains Mono" font-size="10" fill="${C.muted}">${m}</text><path d="M30 ${py(m)} H${w}" stroke="${C.line}"/>`).join('')}
${[4, 8, 12].map((q) => `<text x="${px(q)}" y="${h - 8}" text-anchor="middle" font-family="JetBrains Mono" font-size="10" fill="${C.muted}">${q} Q</text>`).join('')}
${dots}</svg>`;
};
const masteryTile = ([id, name]) => {
  const sel = id === 'geotechnical';
  return `<div style="display:flex;align-items:center;justify-content:space-between;gap:8px;height:52px;box-sizing:border-box;padding:0 14px;border-radius:18px;background:${sel ? C.charcoal : C.cream};color:${sel ? C.onCharcoal : C.charcoal};">${mark(id, sel ? C.spring : C.charcoal, 22, 1.7)}<span style="font-family:${F.mono};font-size:13px;font-weight:600;">${MASTERY[id]}%</span><span style="font-family:${F.mono};font-size:11px;color:${sel ? C.mutedDark : C.muted};">${WEIGHTS[id]} Q</span></div>`;
};
out['T17-mastery-landscape'] = page('Mastery, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${topLine(CX, 470, roundIcon('Back', ico.back), eyebrow('Total concept mastery', C.muted))}
${abs(CX, TOP + 92, 470, null, `<div style="display:flex;flex-direction:column;gap:16px;"><span style="font-family:${F.display};font-weight:800;font-size:130px;line-height:0.82;letter-spacing:-0.07em;color:${C.ember};">21<span style="font-size:60px;">%</span></span>
<div style="font-size:15px;line-height:1.55;color:${C.charcoal};opacity:0.82;">Of the concepts the FE Civil tests, weighted by how many questions each chapter gets. Earned at the desk on the website. What you do in this app does not count toward it. Not a probability of passing.</div>
<div style="margin-top:6px;">${eyebrow('Where effort pays', C.muted)}</div>${scatter(470, 270)}</div>`)}
${abs(CX + 470 + 48, TOP + 92, L.W - (CX + 470 + 48) - 40, null, `<div style="display:flex;flex-direction:column;gap:14px;">
${block(C.cream, `<div style="display:flex;flex-direction:column;gap:14px;">${headline('Geotechnical Engineering', 28)}
<div style="display:flex;gap:10px;"><div style="flex:1;box-sizing:border-box;padding:14px 16px;border-radius:18px;background:${C.creamDark};">${eyebrow('Mastery', C.muted, 11)}<div style="font-family:${F.display};font-weight:800;font-size:40px;color:${C.ember};margin-top:6px;">0%</div><div style="font-family:${F.mono};font-size:11px;color:${C.muted};">earned on the website</div></div>
<div style="flex:1;box-sizing:border-box;padding:14px 16px;border-radius:18px;background:${C.creamDark};">${eyebrow('Progress', C.muted, 11)}<div style="font-family:${F.display};font-weight:800;font-size:40px;color:${C.forest};margin-top:6px;">0</div><div style="font-family:${F.mono};font-size:11px;color:${C.muted};">done in this app</div></div></div>
<div style="font-size:15px;line-height:1.5;color:${C.muted};">Worth 10-15 Q of the exam. Finishing it would move your total by about 10.0 points, which puts it 1st of 15 for where effort pays.</div></div>`, '24px 26px')}
<div style="margin-top:6px;">${eyebrow('Every chapter', C.muted)}</div>
<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;">${chapters.map(masteryTile).join('')}</div></div>`)}
`);

// ── T18 Account sheet and its pages: sheets capped at 640, phone-like on purpose ──
const profileBehind = `${rail('profile', L.H)}
${topLine(CX, L.W - CX - 40, eyebrow('Tuesday, Nov 3', C.muted), avatar)}
${abs(CX, TOP + 104, 460, null, headline('Welcome back, Jerson.', 96))}`;
const stat = (label, n) => `<div style="flex:1;box-sizing:border-box;padding:16px 18px;border-radius:20px;background:${C.creamDark};display:flex;flex-direction:column;gap:8px;">${eyebrow(label, C.muted, 11)}<span style="font-family:${F.display};font-weight:800;font-size:34px;letter-spacing:-0.04em;">${n}</span></div>`;
const seg = (opts, on) => `<div style="display:flex;gap:4px;">${opts.map((o) => `<span style="display:flex;align-items:center;height:40px;padding:0 16px;border-radius:20px;${o === on ? `background:${C.charcoal};color:${C.spring};` : `color:${C.muted};`}font-family:${F.mono};font-size:12px;font-weight:600;letter-spacing:0.06em;text-transform:uppercase;">${o}</span>`).join('')}</div>`;
const toggle = (on) => `<span style="display:inline-block;position:relative;width:52px;height:30px;border-radius:15px;background:${on ? C.forest : C.creamDark};"><span style="position:absolute;top:4px;left:${on ? 26 : 4}px;width:22px;height:22px;border-radius:11px;background:${on ? C.white : C.muted};"></span></span>`;
const SH = 640, SX = RAIL + (L.W - RAIL - SH) / 2;
out['T18-account-sheet-landscape'] = page('Account sheet, landscape', L.W, L.H, C.fog, `
${profileBehind}${scrim()}
${abs(SX, L.H - 600, SH, 600, sheetBox(SH, 600, `
<div style="display:flex;align-items:center;gap:16px;"><span style="display:flex;align-items:center;justify-content:center;width:52px;height:52px;border-radius:26px;background:${C.charcoal};color:${C.onCharcoal};font-family:${F.display};font-weight:700;font-size:18px;">J</span><span style="flex-grow:1;font-family:${F.display};font-weight:700;font-size:24px;">j@x.edu</span>${creamButton('Edit profile', `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h4L19 9l-4-4L4 16z"/></svg>`).replace(`background:${C.cream}`, `background:${C.creamDark}`)}${creamButton('More', `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>`).replace(`background:${C.cream}`, `background:${C.creamDark}`)}</div>
<div style="display:flex;gap:10px;">${stat('Total XP', '1,240')}${stat('Badges', '2')}${stat('Concepts', '9')}</div>
<div style="display:flex;align-items:center;justify-content:space-between;height:56px;"><span style="font-size:17px;font-weight:500;">Appearance</span>${seg(['Auto', 'Light', 'Dark'], 'Auto')}</div>
<div style="display:flex;align-items:center;justify-content:space-between;height:44px;"><span style="font-size:17px;font-weight:500;">Study reminders</span>${toggle(false)}</div>
<div style="flex-grow:1;"></div>
${darkPill('Open the website')}
<div style="display:flex;gap:12px;">${lightPill('How it works', 278)}${lightPill('Sign out', 278)}</div>
<div style="text-align:center;font-family:${F.mono};font-size:12px;color:${C.muted};">Version 1.3.0</div>`), 'z-index:7;')}
`);
const ABOUT = ["I'm Jerson, a recent graduate. I finished my master's in Civil Engineering at BYU in May 2025.", 'Some engineering concepts were really hard for me. Not all of them, but some took a lot of work, and I wished I had something to learn from other than the books. There is only so much teaching assistants and professors can do, and a lot of the time I was on my own. I wished I had one place where I could study all my courses and find what I needed.', 'I needed that most when I was preparing for the FE exam. The exam covers so many courses and chapters that I had to pull resources together from many different places, and almost none of them explained things in simple terms. I believe a lot of civil engineering concepts are really hard, but explained well, they make sense.', "With what I studied, and what I learned building websites and mobile apps, I thought I could make an impact and give other students the resource I wish I'd had."];
out['T18b-about-landscape'] = page('About, landscape', L.W, L.H, C.fog, `
${profileBehind}${scrim()}
${abs(SX, L.H - 640, SH, 640, sheetBox(SH, 640, `
<div style="display:flex;align-items:center;gap:8px;color:${C.charcoal};">${ico.back}<span style="font-family:${F.display};font-weight:700;font-size:16px;">Account</span></div>
${headline('Why this exists', 40)}
${ABOUT.map((p) => `<div style="font-size:16px;line-height:1.6;color:${C.charcoal};opacity:0.85;max-width:${TB.measure.body - 40}px;">${p}</div>`).join('')}`), 'z-index:7;')}
`);
const editRow = (k, v) => `<div style="display:flex;align-items:center;justify-content:space-between;height:60px;border-bottom:1px solid ${C.line};"><span style="font-size:17px;font-weight:500;">${k}</span><span style="display:flex;align-items:center;gap:12px;font-size:16px;color:${C.muted};">${v}<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h4L19 9l-4-4L4 16z"/></svg></span></div>`;
out['T18c-edit-profile-landscape'] = page('Edit profile, landscape', L.W, L.H, C.fog, `
${profileBehind}${scrim()}
${abs(SX, L.H - 370, SH, 370, sheetBox(SH, 370, `
<div style="display:flex;align-items:center;gap:8px;">${ico.back}<span style="font-family:${F.display};font-weight:700;font-size:16px;">Account</span></div>
${headline('Edit profile', 40)}
<div>${editRow('Name', 'Jerson')}${editRow('Email', 'j@x.edu')}${editRow('School', 'BYU, graduated 2025')}</div>`), 'z-index:7;')}
`);
// Contact: a pushed page; the words left, the two fields right.
const boxField = (label, value, h, caption) => `<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow(label, C.muted)}<div style="height:${h}px;box-sizing:border-box;padding:18px 20px;border-radius:22px;background:${C.cream};font-size:17px;line-height:1.5;color:${C.muted};">${value}</div>${caption ? `<div style="font-size:14px;color:${C.muted};">${caption}</div>` : ''}</div>`;
out['T18d-contact-landscape'] = page('Contact us, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${topLine(CX, 400, `<div style="display:flex;align-items:center;gap:14px;">${roundIcon('Back to the account', ico.back)}${eyebrow('Account', C.muted)}</div>`)}
${abs(CX, TOP + 120, 400, null, `<div style="display:flex;flex-direction:column;gap:22px;">${headline('Contact us', 72)}${body17('A question, a round that looks wrong, something you wish the app did. A person reads every one and writes back to that email.', 400)}</div>`)}
${abs(CX + 400 + 64, TOP + 40, L.W - (CX + 400 + 64) - 48, null, `<div style="display:flex;flex-direction:column;gap:24px;">${boxField('Your email', 'j@x.edu', 64, 'Where we write back. You do not need an account.')}${boxField('Your message', 'Your message', 300)}</div>`)}
${abs(L.W - 48 - TB.size.pillMax, L.H - 36 - 72, TB.size.pillMax, 72, pill('Send it'))}
`);

// ── T19 Round extras: the feedback sheet docks like the concept sheet ──
const PERP_Q = 'A property boundary runs from P(2, 3) to Q(8, 7). A utility easement must be laid perpendicular to it through Q.';
const perpFigure = (w, h) => {
  const s = w / 600, ox = 70 * s, oy = h - 60 * s, u = 52 * s;
  const P = [ox + 2 * u, oy - 3 * u], Q = [ox + 8 * u, oy - 7 * u];
  return `<div style="${gridPaper(w, h, Math.round(u))}"><svg width="${w}" height="${h}" style="position:absolute;inset:0;" fill="none">
<path d="M${ox} ${oy} H${w - 30 * s}" stroke="${C.muted}" stroke-width="${1.6 * s}"/><path d="M${ox} ${oy} V${30 * s}" stroke="${C.muted}" stroke-width="${1.6 * s}"/>
<path d="M${P[0] - 1.5 * u} ${P[1] + 1 * u} L${Q[0] + 1.5 * u} ${Q[1] - 1 * u}" stroke="${C.charcoal}" stroke-width="${3.4 * s}" stroke-linecap="round"/>
<circle cx="${P[0]}" cy="${P[1]}" r="${7 * s}" fill="${C.paper}" stroke="${C.charcoal}" stroke-width="${2.6 * s}"/><circle cx="${Q[0]}" cy="${Q[1]}" r="${7 * s}" fill="${C.paper}" stroke="${C.charcoal}" stroke-width="${2.6 * s}"/>
<text x="${P[0] + 12 * s}" y="${P[1] + 22 * s}" font-family="JetBrains Mono" font-weight="700" font-size="${14 * s}" fill="${C.charcoal}">P(2, 3)</text><text x="${Q[0] + 12 * s}" y="${Q[1] + 24 * s}" font-family="JetBrains Mono" font-weight="700" font-size="${14 * s}" fill="${C.charcoal}">Q(8, 7)</text></svg></div>`;
};
const sheetChips = (labels, on) => `<div style="display:flex;flex-wrap:wrap;gap:8px;">${labels.map((l) => `<span style="display:flex;align-items:center;height:46px;padding:0 20px;border-radius:23px;background:${l === on ? C.charcoal : C.creamDark};color:${l === on ? C.onCharcoal : C.charcoal};font-family:${F.display};font-weight:700;font-size:16px;">${l}</span>`).join('')}</div>`;
out['T19-feedback-sheet-landscape'] = page('Feedback sheet, landscape', L.W, L.H, C.fog, `
${abs(40, TOP + 8, 600, 48, roundHeader(600, { done: 0, count: '0 / 8', pipsW: 330 }))}
${abs(40, TOP + 84, 600, null, `<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow('Lay it perpendicular', C.ember)}<div style="font-size:18px;line-height:1.5;">${PERP_Q}</div></div>`)}
${abs(40, TOP + 200, null, null, perpFigure(600, 520))}
${abs(L.W - SHEET_W, 0, SHEET_W, L.H, `<div style="width:${SHEET_W}px;height:${L.H}px;box-sizing:border-box;padding:${TOP + 8}px 32px 36px 36px;border-radius:40px 0 0 40px;background:${C.sheet};box-shadow:-6px 0 30px rgba(44,44,44,0.10);display:flex;flex-direction:column;gap:18px;">
<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('Perpendicular Flip · Round 1', C.muted)}${roundIcon('Close', ico.close)}</div>
${headline('Something unclear?', 40)}
${sheetChips(['The question', 'The drawing', 'How to play', 'The concept'], 'The question')}
<div style="margin-top:8px;font-family:${F.display};font-weight:700;font-size:24px;color:${C.muted};opacity:0.75;padding-bottom:12px;border-bottom:3px solid ${C.forest};">What tripped you up?</div>
<div style="font-size:15px;line-height:1.5;color:${C.muted};">We read every one. The round you were on comes along, so you can keep it short.</div>
<div style="flex-grow:1;"></div>${pill('Send it')}</div>`)}
`);
out['T19b-round-done-landscape'] = page('Round done, landscape', L.W, L.H, C.fog, `
${abs(40, TOP + 8, 48, 48, roundIcon('Close', ico.close))}
${abs(40, TOP + 96, 560, null, `<div style="display:flex;flex-direction:column;gap:12px;">
<div style="box-sizing:border-box;height:400px;padding:30px 32px;border-radius:40px;background:${C.spring};color:${C.onAccent};display:flex;flex-direction:column;justify-content:space-between;"><div style="display:flex;justify-content:space-between;">${eyebrow('All done', C.onAccent)}${eyebrow('Perpendicular Flip', C.onAccent)}</div>
<div style="display:flex;align-items:baseline;gap:14px;"><span style="font-family:${F.display};font-weight:800;font-size:200px;line-height:0.8;letter-spacing:-0.07em;">8</span><span style="font-family:${F.display};font-weight:700;font-size:30px;">of 8</span></div>
<div style="font-size:17px;line-height:1.5;">6 on the first try. The 2 you missed came back and you got them.</div></div>
<div style="display:flex;gap:12px;"><div style="flex:1;height:180px;box-sizing:border-box;padding:24px;border-radius:32px;background:${C.cream};display:flex;flex-direction:column;justify-content:space-between;">${eyebrow('First try')}<span style="font-family:${F.display};font-weight:800;font-size:76px;line-height:0.82;letter-spacing:-0.06em;">6 <span style="font-size:20px;letter-spacing:0;">of 8</span></span></div>
<div style="flex:1;height:180px;box-sizing:border-box;padding:24px;border-radius:32px;background:${C.butter};display:flex;flex-direction:column;justify-content:space-between;">${eyebrow('Lesson')}<span style="font-family:${F.display};font-weight:800;font-size:76px;line-height:0.82;letter-spacing:-0.06em;">1 <span style="font-size:20px;letter-spacing:0;">of 3 done</span></span></div></div></div>`)}
${abs(660, TOP + 96, 480, null, `<div style="display:flex;flex-direction:column;gap:16px;">${headline('You can build the perpendicular by hand.', 52)}${body17('Knowing the rule is not the same as solving with it. The full problems belong at a desk, on paper.', 440)}</div>`)}
${abs(660, L.H - 36 - 72, 480, 72, `<div style="display:flex;align-items:center;justify-content:space-between;">${link('Start over')}${pill('Done', { width: 360 })}</div>`)}
`);

// ── T20 Badges: the page, and the moment ──
const BADGE_CH = chapters.map(([id, name]) => [id, { mathematics: 'Math', statistics: 'Statistics', ethics: 'Ethics', economics: 'Economics', 'mechanics-materials': 'Mechanics', 'fluid-mechanics': 'Fluids', 'water-resources': 'Water', geotechnical: 'Geotech', transportation: 'Transport', structural: 'Structural', construction: 'Construction' }[id] || name]);
const badgeCoin = (id, earned, s = 96) => `<span style="display:flex;align-items:center;justify-content:center;width:${s}px;height:${s}px;border-radius:50%;${earned ? `background:${C.spring};box-shadow:inset 0 0 0 ${s / 16}px ${C.forest}, 0 5px 0 ${C.plinth};` : `background:${C.creamDark};box-shadow:inset 0 0 0 2px ${C.line};`}color:${earned ? C.onAccent : C.muted};">${mark(id, 'currentColor', s * 0.5, 1.6)}</span>`;
const milestoneCoin = (glyphSvg, earned, s = 96) => `<span style="display:flex;align-items:center;justify-content:center;width:${s}px;height:${s}px;border-radius:50%;${earned ? `background:${C.sunbeam};box-shadow:inset 0 0 0 ${s / 16}px #C98E14, 0 5px 0 ${C.plinth};` : `background:${C.creamDark};box-shadow:inset 0 0 0 2px ${C.line};`}color:${earned ? C.onAccent : C.muted};">${glyphSvg}</span>`;
const badgeCell = (coinHtml, name) => `<div style="display:flex;flex-direction:column;align-items:center;gap:10px;width:112px;">${coinHtml}<span style="font-family:${F.display};font-weight:700;font-size:14px;text-align:center;">${name}</span></div>`;
const mg = { flawless: `<svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3l2.6 5.6 6 .7-4.5 4.1 1.2 6L12 16.5 6.7 19.4l1.2-6L3.4 9.3l6-.7z"/></svg>`, daily: `<svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="4"/><path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5.3 5.3l1.4 1.4M17.3 17.3l1.4 1.4M5.3 18.7l1.4-1.4M17.3 6.7l1.4-1.4"/></svg>`, seven: `<svg width="44" height="44" viewBox="0 0 24 24" fill="none"><text x="12" y="17" text-anchor="middle" font-family="DM Sans" font-weight="800" font-size="15" fill="currentColor">7</text></svg>`, all: `<svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><rect x="3.5" y="3.5" width="7" height="7" rx="2"/><rect x="13.5" y="3.5" width="7" height="7" rx="2"/><rect x="3.5" y="13.5" width="7" height="7" rx="2"/><rect x="13.5" y="13.5" width="7" height="7" rx="2"/></svg>` };
out['T20-badges-landscape'] = page('Badges, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${topLine(CX, 300, roundIcon('Back', ico.back))}
${abs(CX, TOP + 120, 300, null, `<div style="display:flex;flex-direction:column;gap:18px;">${headline('Badges', 72)}<div style="font-size:17px;color:${C.muted};">2 of 19 earned.</div></div>`)}
${abs(CX + 300 + 40, TOP + 24, L.W - (CX + 300 + 40) - 40, null, `<div style="display:flex;flex-direction:column;gap:14px;">
<div style="display:flex;align-items:baseline;justify-content:space-between;">${eyebrow('Chapters')}<span style="font-size:14px;color:${C.muted};">A chapter's drawing, for its first lesson done.</span></div>
<div style="display:grid;grid-template-columns:repeat(5,112px);column-gap:16px;row-gap:18px;">${BADGE_CH.map(([id, n]) => badgeCell(badgeCoin(id, id === 'mathematics', 84), n)).join('')}</div>
<div style="height:8px;"></div>${eyebrow('Milestones')}
<div style="display:grid;grid-template-columns:repeat(5,112px);column-gap:16px;">${badgeCell(milestoneCoin(mg.flawless, false, 84), 'Flawless')}${badgeCell(milestoneCoin(mg.daily, true, 84), 'First Daily')}${badgeCell(milestoneCoin(mg.seven, false, 84), 'Seven in a row')}${badgeCell(milestoneCoin(mg.all, false, 84), 'All chapters')}</div></div>`)}
`);
const momentCard = (w, coinHtml, over, overColor, title, line) => `<div style="width:${w}px;box-sizing:border-box;padding:44px 40px 40px;border-radius:44px;background:${C.cream};display:flex;flex-direction:column;align-items:center;gap:16px;text-align:center;">${coinHtml}<div style="height:6px;"></div>${eyebrow(over, overColor)}${headline(title, 44, C.charcoal, 'text-align:center;')}<div style="font-size:17px;line-height:1.5;color:${C.muted};max-width:420px;">${line}</div></div>`;
out['T20b-badge-moment-landscape'] = page('Badge moment, landscape', L.W, L.H, C.fog, `
${abs((L.W - 560) / 2, 70, 560, null, momentCard(560, badgeCoin('mathematics', true, 180), 'New badge', C.forest, 'Mathematics', 'Your first lesson in Mathematics, done.'))}
${abs((L.W - 720) / 2, L.H - 36 - 72, 720, 72, `<div style="display:flex;align-items:center;justify-content:space-between;">${link('All badges')}${pill('Carry on', { width: TB.size.pillMax })}</div>`)}
`);

// ── T21 The Daily's steps, done, yesterday, share ──
const daySteps = (at) => `<div style="display:flex;flex-direction:column;gap:10px;">${[['statics', 'Which Distance Counts', 'Force Systems &amp; Resultants', '5 of 6'], ['mechanics-materials', 'Which Stretches More', 'Axial Stress, Strain &amp; Deformation', 'Now'], ['surveying', 'Find It on the Plan', 'Angles, Distances &amp; Bearings', 'Next']].map(([id, n, l, st], i) => `<div style="display:flex;align-items:center;gap:16px;box-sizing:border-box;padding:16px 20px 16px 16px;border-radius:26px;background:${i === at ? C.charcoal : C.cream};color:${i === at ? C.onCharcoal : C.charcoal};${i > at ? 'opacity:0.6;' : ''}"><span style="display:flex;align-items:center;justify-content:center;width:56px;height:56px;border-radius:28px;background:${i === at ? C.spring : C.creamDark};color:${C.onAccent};">${i < at ? ico.check(22) : mark(id, 'currentColor', 30, 1.7)}</span><span style="display:flex;flex-direction:column;gap:3px;flex-grow:1;"><span style="font-family:${F.display};font-weight:700;font-size:17px;">${n}</span><span style="font-size:13px;color:${i === at ? C.mutedDark : C.muted};">${l}</span></span><span style="font-family:${F.mono};font-size:12px;color:${i === at ? C.spring : C.muted};">${st}</span></div>`).join('')}</div>`;
out['T21-daily-step-landscape'] = page('Daily step, landscape', L.W, L.H, C.fog, `
${abs(56, TOP + 12, 48, 48, roundIcon('Close', ico.close))}
${abs(56, TOP + 100, 460, null, `<div style="display:flex;flex-direction:column;gap:18px;"><div style="display:flex;justify-content:space-between;">${eyebrow("Today's Daily")}${eyebrow('Concept 2 of 3', C.muted)}</div>${daySteps(1)}</div>`)}
${abs(RX - 40, TOP + 12, L.W - (RX - 40) - 56, L.H - TOP - 12 - 36 - 72 - 24, `<div style="height:100%;box-sizing:border-box;padding:32px 36px;border-radius:40px;background:${C.cream};display:flex;flex-direction:column;gap:14px;">
${eyebrow('Mechanics of Materials', C.muted)}
<div style="flex-grow:1;display:flex;align-items:center;justify-content:center;"><span style="display:flex;align-items:center;justify-content:center;width:200px;height:200px;border-radius:50%;background:${C.springField};color:${C.charcoal};">${mark('mechanics-materials', 'currentColor', 120, 1.4)}</span></div>
<div style="font-family:${F.display};font-weight:700;font-size:17px;color:${C.muted};">Axial Stress, Strain &amp; Deformation</div>
${headline('Which Stretches More', 52)}
<div style="display:flex;align-items:flex-end;justify-content:space-between;gap:20px;"><div style="font-size:17px;line-height:1.5;color:${C.muted};">Two bars, one scale. Which one moves further?</div><span style="white-space:nowrap;">${link('Read the concept first', C.charcoal, 15)}</span></div></div>`)}
${abs(L.W - 56 - TB.size.pillMax, L.H - 36 - 72, TB.size.pillMax, 72, pill('Play concept 2'))}
`);
const pipGrid = (w, missed) => `<div style="display:grid;grid-template-columns:repeat(6,1fr);gap:8px;width:${w}px;">${Array.from({ length: 18 }, (_, i) => `<span style="height:16px;border-radius:8px;background:${missed.includes(i) ? C.cream : C.charcoal};"></span>`).join('')}</div>`;
out['T21b-daily-done-landscape'] = page('Daily done, landscape', L.W, L.H, C.fog, `
${abs(56, TOP + 12, 48, 48, roundIcon('Close', ico.close))}
${abs(56, TOP + 96, 600, null, `<div style="box-sizing:border-box;height:${L.H - TOP - 96 - 36}px;padding:34px 36px;border-radius:44px;background:${C.spring};color:${C.onAccent};display:flex;flex-direction:column;justify-content:space-between;">
<div style="display:flex;justify-content:space-between;">${eyebrow("Today's Daily", C.onAccent)}${eyebrow('Done', C.onAccent)}</div>
<div style="display:flex;align-items:baseline;gap:16px;"><span style="font-family:${F.display};font-weight:800;font-size:200px;line-height:0.8;letter-spacing:-0.07em;">16</span><span style="font-family:${F.display};font-weight:700;font-size:32px;">of 18</span></div>
${pipGrid(528, [7, 10])}
<div style="font-size:18px;line-height:1.5;">On the first try. You missed one in Mechanics of Materials and one in Surveying, and they all came back.</div></div>`)}
${abs(696, TOP + 96, L.W - 696 - 56, null, `<div style="display:flex;flex-direction:column;gap:12px;">
<div style="height:180px;box-sizing:border-box;padding:24px 28px;border-radius:32px;background:${C.cream};display:flex;flex-direction:column;justify-content:space-between;">${eyebrow('Time')}<span style="font-family:${F.display};font-weight:800;font-size:84px;line-height:0.82;letter-spacing:-0.05em;">2:41</span></div>
<div style="height:180px;box-sizing:border-box;padding:24px 28px;border-radius:32px;background:${C.butter};display:flex;flex-direction:column;justify-content:space-between;">${eyebrow('Streak', C.forest)}<span style="font-family:${F.display};font-weight:800;font-size:84px;line-height:0.82;letter-spacing:-0.05em;">6 <span style="font-size:22px;letter-spacing:0;">days</span></span></div></div>`)}
${abs(696, L.H - 36 - 72, L.W - 696 - 56, 72, `<div style="display:flex;align-items:center;justify-content:space-between;">${link('Share')}${pill('How others did', { width: 330 })}</div>`)}
`);
out['T21c-daily-yesterday-landscape'] = page("Yesterday's score, landscape", L.W, L.H, C.butter, `
${rail('daily', L.H)}
${topLine(CX, 520, roundIcon('Back', ico.back))}
${abs(CX, TOP + 100, 520, null, `<div style="display:flex;flex-direction:column;gap:18px;">${eyebrow('Monday, Nov 2 · Final · 23 played')}${headline('4th of 23<br>yesterday', 72)}
<div style="box-sizing:border-box;margin-top:10px;padding:24px 28px;border-radius:36px;background:${C.cream};display:flex;flex-direction:column;gap:6px;">${eyebrow('First try, out of 18', C.muted)}<div style="height:6px;"></div>${bar('18', 3, 7, false)}${bar('17', 5, 7, true)}${bar('16', 7, 7, false)}${bar('15', 5, 7, false)}${bar('14', 3, 7, false)}</div></div>`)}
${abs(RIGHT_X, TOP + 100, RIGHT_W, null, `<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow('The board', C.muted)}<div style="height:4px;"></div>
${rankRow(1, 'Maria L.', 18, '1:58', false)}${rankRow(2, 'Dev P.', 18, '2:20', false)}${rankRow(3, 'Ana R.', 17, '2:05', false)}${rankRow(4, 'You', 17, '2:41', true)}${rankRow(5, 'Sam K.', 17, '3:02', false)}${rankRow(6, 'Priya N.', 16, '2:12', false)}${rankRow(7, 'Luis M.', 16, '2:47', false)}</div>`)}
`);
const shareCard = (w) => `<div style="width:${w}px;box-sizing:border-box;padding:28px 30px 24px;border-radius:30px;background:${C.white};box-shadow:0 18px 40px rgba(44,44,44,0.16);transform:rotate(-2deg);display:flex;flex-direction:column;gap:14px;">
<div style="display:flex;justify-content:space-between;">${eyebrow('FE for Raccoons')}${eyebrow('Nov 3', C.muted)}</div>${headline('The Daily', 34)}
<div style="display:flex;align-items:baseline;gap:10px;"><span style="font-family:${F.display};font-weight:800;font-size:86px;line-height:0.82;letter-spacing:-0.06em;">16</span><span style="font-family:${F.display};font-weight:700;font-size:22px;">of 18</span><span style="font-family:${F.mono};font-size:18px;font-weight:600;margin-left:8px;">2:41</span></div>
<div style="display:grid;grid-template-columns:repeat(6,1fr);gap:7px;">${Array.from({ length: 18 }, (_, i) => `<span style="height:14px;border-radius:7px;background:${[7, 10].includes(i) ? C.peach : C.charcoal};"></span>`).join('')}</div>
<div style="font-family:${F.mono};font-size:12px;color:${C.muted};">fe4raccoons.com</div></div>`;
out['T21d-daily-share-landscape'] = page('Share your result, landscape', L.W, L.H, C.butter, `
${rail('daily', L.H)}${scrim()}
${abs(SX, L.H - 400, SH, 400, sheetBox(SH, 400, `<div style="display:flex;gap:32px;align-items:center;flex-grow:1;">${shareCard(320)}<div style="flex-grow:1;display:flex;flex-direction:column;gap:12px;">${darkPill('Share the picture')}${lightPill('Copy as text')}</div></div>`), 'z-index:7;')}
`);

// ── T22 League moment: a moment, phone-like on purpose ──
const bigCoin = (letter, s = 180) => `<span style="display:flex;align-items:center;justify-content:center;width:${s}px;height:${s}px;border-radius:50%;background:${T.leagueCoin.silver.face};box-shadow:inset 0 0 0 ${s / 14}px ${T.leagueCoin.silver.rim}, 0 8px 0 ${C.plinth};"><span style="display:flex;align-items:center;justify-content:center;width:${s * 0.68}px;height:${s * 0.68}px;border-radius:50%;border:${s / 40}px solid ${T.leagueCoin.silver.ink};font-family:${F.display};font-weight:800;font-size:${s * 0.36}px;color:${T.leagueCoin.silver.ink};">${letter}</span></span>`;
out['T22-league-moment-landscape'] = page('League moment, landscape', L.W, L.H, C.fog, `
${abs((L.W - 560) / 2, 70, 560, null, momentCard(560, bigCoin('S'), 'Moved up', C.forest, 'You moved up to Silver', '3rd of 15 in Bronze last week. A new week starts now, and everyone is back at zero.'))}
${abs((L.W - TB.size.pillMax) / 2, L.H - 36 - 72, TB.size.pillMax, 72, pill('Carry on'))}
`);

// ── T23 XP and Concepts: the number left, where it came from right ──
const half = (label, n) => `<div style="flex:1;box-sizing:border-box;padding:22px 24px;border-radius:28px;background:${C.cream};display:flex;flex-direction:column;gap:10px;">${eyebrow(label, C.muted)}<span style="font-family:${F.display};font-weight:800;font-size:54px;letter-spacing:-0.05em;">${n}</span></div>`;
const how = (where, what) => `<div style="display:flex;gap:20px;padding:16px 0;border-bottom:1px solid ${C.line};"><span style="width:150px;flex-shrink:0;font-family:${F.display};font-weight:700;font-size:17px;">${where}</span><span style="font-size:16px;line-height:1.5;color:${C.muted};">${what}</span></div>`;
out['T23-xp-landscape'] = page('XP, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${topLine(CX, 420, roundIcon('Back', ico.back), eyebrow('Total XP', C.muted))}
${abs(CX, TOP + 190, 420, null, `<div style="display:flex;flex-direction:column;gap:22px;"><div style="display:flex;align-items:baseline;gap:12px;"><span style="font-family:${F.display};font-weight:800;font-size:150px;line-height:0.82;letter-spacing:-0.07em;">1,240</span><span style="font-family:${F.display};font-weight:700;font-size:26px;">XP</span></div>${body17('Points for practice, in the app and on the website. They rank the leaderboard. They are not mastery.', 420)}
<div style="display:flex;gap:10px;margin-top:8px;">${half('In the app', '410')}${half('On the website', '830')}</div></div>`)}
${abs(CX + 420 + 64, TOP + 190, L.W - (CX + 420 + 64) - 48, null, `<div style="display:flex;flex-direction:column;gap:8px;">${eyebrow('How it is earned')}
${how('In the app', '5 for each round right, 2 for a miss, up to 60 a day.')}${how('On the website', '10 for each problem right, 5 for a miss, and 25 more for finishing a practice session.')}
<div style="height:30px;"></div>${eyebrow('Today in the app')}
<div style="display:flex;align-items:baseline;justify-content:space-between;margin-top:6px;"><span style="font-family:${F.display};font-weight:800;font-size:44px;letter-spacing:-0.04em;">35 <span style="font-size:20px;letter-spacing:0;">of 60</span></span></div>
${progressBar(L.W - (CX + 420 + 64) - 48, 35 / 60)}
<div style="font-size:15px;line-height:1.5;color:${C.muted};margin-top:6px;">The app gives up to 60 a day, so a phone never outscores the desk.</div></div>`)}
`);
const conceptRow = (title, lesson) => `<div style="display:flex;align-items:center;gap:14px;height:60px;box-sizing:border-box;padding:0 16px 0 20px;border-radius:20px;background:${C.cream};"><span style="display:flex;flex-direction:column;gap:2px;flex-grow:1;"><span style="font-family:${F.display};font-weight:700;font-size:16px;">${title}</span><span style="font-size:13px;color:${C.muted};">${lesson}</span></span><span style="color:${C.muted};">${ico.book}</span></div>`;
const conceptGroup = (id, name, rows) => `<div style="display:flex;flex-direction:column;gap:8px;"><div style="display:flex;align-items:center;gap:10px;">${mark(id, C.charcoal, 20, 1.8)}${eyebrow(name)}<span style="font-family:${F.mono};font-size:12px;color:${C.muted};">${rows.length}</span></div>${rows.map(([t, l]) => conceptRow(t, l)).join('')}</div>`;
out['T23b-concepts-landscape'] = page('Concepts, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${topLine(CX, 380, roundIcon('Back', ico.back), eyebrow('Concepts', C.muted))}
${abs(CX, TOP + 120, 380, null, `<div style="display:flex;flex-direction:column;gap:22px;"><div style="display:flex;align-items:baseline;gap:12px;"><span style="font-family:${F.display};font-weight:800;font-size:170px;line-height:0.82;letter-spacing:-0.07em;">9</span><span style="font-family:${F.display};font-weight:700;font-size:28px;">concepts</span></div>${body17('Each one finished here on the phone, every round cleared. The website counts its own practice.', 380)}</div>`)}
${abs(CX + 380 + 56, TOP + 24, L.W - (CX + 380 + 56) - 40, null, `<div style="display:grid;grid-template-columns:1fr 1fr;column-gap:16px;row-gap:22px;align-items:start;">
${conceptGroup('mathematics', 'Mathematics', [['Parallel and perpendicular', 'Straight Lines &amp; Quadratics'], ['The part under the square root', 'Straight Lines &amp; Quadratics'], ['Grade, rise and run', 'Straight Lines &amp; Quadratics'], ['What a log is, and the rule that does not exist', 'Logarithms'], ['Getting the unknown down from the exponent', 'Logarithms'], ['Squeeze the logs into one first', 'Logarithms'], ['Opposite, adjacent, hypotenuse', 'Right Triangle Trigonometry']])}
${conceptGroup('statics', 'Statics', [['The arm is the shortest distance to the line', 'Force Systems &amp; Resultants'], ['Which part gets the cosine', 'Force Systems &amp; Resultants']])}</div>`)}
`);

// ── T24 Exam outcome and the pass card ──
out['T24-exam-outcome-landscape'] = page('Exam outcome, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${topLine(CX, L.W - CX - 40, eyebrow('Saturday, Jan 16', C.muted), avatar)}
${abs(CX, TOP + 120, 460, null, `<div style="display:flex;flex-direction:column;gap:20px;">${eyebrow('How did it go?', C.ember)}${headline('Your exam has been and gone.', 64)}</div>`)}
${abs(CX + 460 + 64, TOP + 136, L.W - (CX + 460 + 64) - 48, null, `<div style="display:flex;flex-direction:column;gap:14px;">${body17('Telling us is how we learn which study patterns actually lead to a pass, which makes this better for everyone sitting it after you.', 460)}
<div style="height:18px;"></div>${pill('I passed')}${lightPill('Not this time')}<div style="display:flex;justify-content:center;margin-top:6px;">${link('I did not sit it', C.charcoal, 15)}</div></div>`)}
`);
const passCardArt = (w, h) => `<div style="width:${w}px;height:${h}px;box-sizing:border-box;padding:${w * 0.05}px;border-radius:14px;background:${C.white};box-shadow:0 18px 40px rgba(44,44,44,0.16);display:flex;gap:${w * 0.04}px;position:relative;overflow:hidden;">
<div style="flex:1;display:flex;flex-direction:column;"><span style="font-family:${F.mono};font-size:${w * 0.016}px;color:${C.ember};letter-spacing:0.08em;">FUNDAMENTALS OF ENGINEERING</span><span style="font-family:${F.display};font-weight:800;font-size:${w * 0.075}px;line-height:0.95;letter-spacing:-0.04em;margin-top:${w * 0.02}px;">FE Civil<br>passed.</span><span style="font-family:${F.display};font-weight:700;font-size:${w * 0.03}px;margin-top:${w * 0.02}px;">Jerson Garcia, EIT</span><span style="flex-grow:1;"></span><div style="display:flex;gap:${w * 0.04}px;border-top:1px solid ${C.line};padding-top:${w * 0.015}px;font-family:${F.mono};font-size:${w * 0.014}px;color:${C.muted};"><span>Civil Engineering</span><span>Pass</span><span>January 2027</span></div></div>
<div style="width:48%;display:flex;flex-direction:column;justify-content:flex-end;gap:${w * 0.006}px;">${chapters.slice().reverse().map(([, n], i) => `<span style="height:${h * 0.042}px;border-radius:3px;background:${i === 0 ? C.ember : i % 3 === 1 ? C.creamDark : C.charcoal};margin-left:${(i * 7) % 18}px;font-family:${F.mono};font-size:${w * 0.011}px;color:${i % 3 === 1 ? C.charcoal : C.onCharcoal};padding-left:6px;line-height:${h * 0.042}px;overflow:hidden;white-space:nowrap;">${n.toUpperCase()}</span>`).join('')}</div>
<img src="${RACCOON}" alt="" style="position:absolute;right:${w * 0.06}px;top:${h * 0.03}px;width:${w * 0.08}px;"></div>`;
out['T24b-pass-card-landscape'] = page('Pass card, landscape', L.W, L.H, C.fog, `
${abs(56, TOP + 12, 48, 48, roundIcon('Close', ico.close))}
${abs(56, TOP + 120, 660, null, passCardArt(660, 440))}
${abs(780, TOP + 150, L.W - 780 - 56, null, `<div style="display:flex;flex-direction:column;gap:18px;">${headline('It is yours.', 64)}${body17('Post it, print it, or keep it. It stays on your profile, so you can find it again.', 340)}</div>`)}
${abs(780, L.H - 36 - 72 - 76, L.W - 780 - 56, null, `<div style="display:flex;flex-direction:column;gap:12px;">${pill('Save or share')}<div style="display:flex;justify-content:center;">${link('Change the name', C.charcoal, 15)}</div></div>`)}
`);

// ── T25 Edge states, and the guest's tabs ──
out['T25-update-needed-landscape'] = page('Update needed, landscape', L.W, L.H, C.fog, `
${abs(56, TOP + 12, 48, 48, roundIcon('Back', ico.back))}
${abs(56, TOP + 140, 600, null, `<div style="display:flex;flex-direction:column;gap:22px;">${eyebrow('A new kind of round', C.muted)}${headline(`Update the app<br>to play <span style="color:${C.forest};">this lesson.</span>`, 76)}</div>`)}
${abs(RX + 60, TOP + 300, L.W - RX - 60 - 56, null, body17('It teaches with something your version does not have yet. Every other lesson works as it is, and nothing you have done is lost.', 440))}
${abs(L.W - 56 - TB.size.pillMax, L.H - 36 - 72, TB.size.pillMax, 72, pill('Update the app'))}
`);
const adds = ['Your mastery across all 15 chapters', 'The Daily, your streak and badges', 'Lessons and practice on fe4raccoons.com, in sync with this phone', 'Your exam date and countdown'];
const addList = `<div style="display:flex;flex-direction:column;gap:14px;">${adds.map((a) => `<div style="display:flex;gap:14px;align-items:flex-start;font-size:17px;line-height:1.45;"><span style="flex-shrink:0;margin-top:3px;width:18px;height:18px;border-radius:6px;border:2.5px solid ${C.forest};"></span>${a}</div>`).join('')}</div>`;
const greenPill = (label, w = null) => pill(label, { width: w }).replace(`background:${C.charcoal}`, `background:${C.forest}`);
out['T25b-guest-profile-landscape'] = page('Guest profile, landscape', L.W, L.H, C.fog, `
${rail('profile', L.H)}
${topLine(CX, L.W - CX - 40, eyebrow('Tuesday, Nov 3', C.muted), avatar.replace('>J<', '>?<'))}
${abs(CX, TOP + 104, 470, null, `<div style="display:flex;flex-direction:column;gap:40px;">${headline('Your progress lives on this phone for now.', 64)}${fact('4', 'rounds', 'Finished on this phone', '', 110)}</div>`)}
${abs(CX + 470 + 72, TOP + 140, L.W - (CX + 470 + 72) - 40, null, `<div style="display:flex;flex-direction:column;gap:18px;">${headline('A free account adds', 28)}${addList}</div>`)}
${abs(CX + 470 + 72, L.H - 36 - 72 - 40, L.W - (CX + 470 + 72) - 40, null, `<div style="display:flex;flex-direction:column;gap:12px;">${greenPill('Create an account')}<div style="font-size:15px;color:${C.muted};">The 4 rounds come with you. Have one? <u style="color:${C.charcoal};">Sign in</u></div></div>`)}
`);
out['T25c-guest-daily-landscape'] = page('Guest Daily, landscape', L.W, L.H, C.butter, `
${rail('daily', L.H)}
${abs(CX, TOP + 24, 500, null, `<div style="display:flex;flex-direction:column;gap:16px;">${eyebrow('Tuesday, Nov 3')}${headline("Today's Daily", 64)}
${eyebrow('Same for everyone', C.muted)}<div style="font-size:17px;line-height:1.5;opacity:0.82;">Play, then see how you did against everyone else today.</div>
<div style="display:flex;align-items:baseline;gap:14px;margin-top:20px;"><span style="font-family:${F.display};font-weight:800;font-size:200px;line-height:0.8;letter-spacing:-0.07em;">3</span><span style="font-family:${F.display};font-weight:700;font-size:26px;">concepts, about 3 min</span></div></div>`)}
${abs(CX, L.H - 36 - 110, 500, null, `<div style="font-size:15px;line-height:1.5;color:${C.muted};">The Daily ranks you against everyone who played today and keeps your streak, so it needs an account. These concepts are in your lessons too.</div>`)}
${abs(RIGHT_X, TOP + 24, RIGHT_W, L.H - TOP - 24 - 36, `<div style="height:100%;box-sizing:border-box;padding:26px;border-radius:40px;background:${C.cream};display:flex;flex-direction:column;gap:12px;">
${dailyRow('fluid-mechanics', 'Which Property Is That', 'Fluid Properties', '6')}${dailyRow('structural', 'Z or S', 'Steel Beams', '6')}${dailyRow('mathematics', 'One Log', 'Logarithms', '6')}
<div style="height:6px;"></div>${pill('Sign up to play')}<div style="text-align:center;font-size:15px;color:${C.muted};">Already have one? <u style="color:${C.charcoal};">Sign in</u></div></div>`)}
`);


// ── write ──
const dir = new URL('./tablet-screens/html/', import.meta.url);
mkdirSync(dir, { recursive: true });
for (const [name, html] of Object.entries(out)) {
  writeFileSync(new URL(`${name}.html`, dir), html);
  console.log('wrote', name);
}

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
  gridFine: 'rgba(100,160,140,0.05)',
};
// Night values from lib/core/theme/app_colors.dart (ADR 0025, "Warm night").
const night = {
  ...day, fog: '#1B1A18', charcoal: '#F2ECE2', tile: '#34312C', tile2: '#403C36',
  cream: '#272522', creamDark: '#3A3732', springField: '#1C4532', ember: '#F27A4C',
  peach: '#3A2219', butter: '#2B2418', forest: '#5FD69A', muted: '#A89F93',
  mutedDark: '#A89F93', pipOff: 'rgba(242,236,226,0.2)', onCharcoal: '#1B1A18',
  paper: '#24221F', plinth: '#5A544C', sheet: '#2E2B27', line: 'rgba(242,236,226,0.14)',
  emberBg: '#3A2219', forestBg: '#1C3328', white: '#24221F', scrim: 'rgba(0,0,0,0.78)',
  grid: 'rgba(120,190,160,0.10)', gridFine: 'rgba(120,190,160,0.05)',
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
const path = ({ width, top, nodes, node = 92, step = 136, amp = 110, highlight = null, labelW = 210, center = 0.42 }) => {
  const cx0 = Math.round(width * center);
  let y = top;
  const placed = [];
  const sections = [];
  nodes.forEach((n, i) => {
    if (n.section) { sections.push({ y, text: n.section }); y += 54; }
    const x = cx0 + (i % 2 === 0 ? -amp : amp);
    placed.push({ ...n, x, y: y + node / 2 });
    y += step;
  });
  const h = y + 40;
  let road = '';
  let walked = '';
  for (let i = 0; i < placed.length - 1; i++) {
    const a = placed[i], b = placed[i + 1];
    const d = `M${a.x} ${a.y} C ${a.x} ${a.y + (b.y - a.y) * 0.55}, ${b.x} ${b.y - (b.y - a.y) * 0.55}, ${b.x} ${b.y}`;
    road += `<path d="${d}" stroke="${C.charcoal}" stroke-width="16" stroke-linecap="round"/>`;
    if (a.state === 'done') walked += `<path d="${d}" stroke="${C.spring}" stroke-width="6" stroke-linecap="round" stroke-dasharray="16 13"/>`;
  }
  const disc = (n) => {
    const r = node / 2;
    const on = highlight === n.name;
    if (n.state === 'done') return `<span style="display:flex;align-items:center;justify-content:center;width:${node}px;height:${node}px;border-radius:${r}px;background:${C.charcoal};color:${C.spring};box-shadow:0 7px 0 ${C.plinth};">${ico.check(36, 3)}</span>`;
    if (n.state === 'now') {
      const pct = Math.round((n.frac ?? 0.33) * 100);
      return `<span style="position:relative;display:block;width:${node}px;height:${node}px;border-radius:${r}px;background:conic-gradient(${C.spring} 0 ${pct}%, ${C.charcoal} ${pct}% 100%);box-shadow:0 7px 0 ${C.plinth}${on ? `, 0 0 0 8px ${C.fog}, 0 0 0 12px ${C.charcoal}` : ''};"><span style="position:absolute;inset:11px;border-radius:50%;background:${C.cream};"></span></span>`;
    }
    return `<span style="display:block;width:${node}px;height:${node}px;border-radius:${r}px;background:${C.cream};box-shadow:0 7px 0 ${C.plinth}${on ? `, 0 0 0 8px ${C.fog}, 0 0 0 12px ${C.charcoal}` : ''};"></span>`;
  };
  const label = (n, i) => {
    const right = i % 2 === 0; // node on the left, label to its right
    const tileOn = n.state === 'now';
    const subColor = n.state === 'done' ? C.forest : tileOn ? C.onAccent : C.muted;
    const inner = `<span style="display:flex;flex-direction:column;gap:4px;${right ? '' : 'align-items:flex-end;text-align:right;'}"><span style="font-family:${F.display};font-weight:700;font-size:16px;line-height:1.15;letter-spacing:-0.02em;color:${tileOn ? C.onAccent : C.charcoal};">${n.name}</span><span style="font-family:${F.mono};font-size:11.5px;color:${subColor};">${n.sub}</span></span>`;
    const box = tileOn
      ? `<span style="display:inline-block;padding:12px 16px;border-radius:20px;background:${C.spring};">${inner}</span>`
      : inner;
    const gap = node / 2 + 18;
    const pos = right ? `left:${n.x + gap}px;` : `right:${width - n.x + gap}px;`;
    return `<div style="position:absolute;top:${n.y}px;${pos}width:${labelW}px;transform:translateY(-50%);display:flex;${right ? '' : 'justify-content:flex-end;'}">${box}</div>`;
  };
  return {
    height: h,
    html: `<svg aria-hidden="true" width="${width}" height="${h}" style="position:absolute;left:0;top:0;" fill="none">${road}${walked}</svg>
${sections.map((s) => `<div style="position:absolute;left:0;top:${s.y}px;padding:6px 14px 6px 0;background:${C.fog};">${eyebrow(s.text, C.muted)}</div>`).join('')}
${placed.map((n) => `<div style="position:absolute;left:${n.x - node / 2}px;top:${n.y - node / 2}px;">${disc(n)}</div>`).join('')}
${placed.map(label).join('')}`,
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
${pathPane(CX, TOP + 412, PW, P.H - TOP - 412, mathNodes, '3 of 16 cleared', { top: 64, node: 92, step: 128, amp: 150, labelW: 230 })}
`);

// ── T02 Chapter map, landscape: every chapter beside the one you picked ──
out['T02-chapter-map-landscape'] = page('Chapter map, landscape', L.W, L.H, C.fog, `
${rail('study', L.H)}
${abs(CX, TOP + 12, 400, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('73 days to the exam', C.muted)}${roundIcon('One chapter', ico.single)}</div>`)}
${abs(CX, TOP + 76, null, null, gridTiles(3, 126, 124, { selected: 'statics' }))}
${abs(CX + 400 + 32, TOP + 12, 560, null, `<div style="display:flex;flex-direction:column;gap:14px;">${eyebrow('Chapter 5 · 4 to 6 on the exam', C.muted)}${headline('Statics', 44)}</div>`)}
${pathPane(CX + 400 + 32, TOP + 112, L.W - (CX + 400 + 32) - 24, L.H - TOP - 112, staticsNodes, '1 of 7 cleared', { top: 64, step: 124, node: 84, amp: 100 })}
`);

// ── T02p All chapters, portrait: the grid on top, the picked chapter's path below ──
out['T02p-chapter-map-portrait'] = page('All chapters, portrait', P.W, P.H, C.fog, `
${rail('study', P.H)}
${abs(CX, TOP + 12, PW, 48, `<div style="display:flex;align-items:center;justify-content:space-between;height:48px;">${eyebrow('73 days to the exam', C.muted)}${roundIcon('One chapter', ico.single)}</div>`)}
${abs(CX, TOP + 76, null, null, gridTiles(5, (PW - 40) / 5, 112, { selected: 'statics' }))}
${abs(CX, TOP + 76 + 3 * 112 + 20 + 34, PW, null, `<div style="display:flex;flex-direction:column;gap:12px;">${eyebrow('Chapter 5 · 4 to 6 on the exam', C.muted)}${headline('Statics', 44)}</div>`)}
${pathPane(CX, TOP + 576, PW, P.H - TOP - 576, staticsNodes, '1 of 7 cleared', { top: 64, step: 124, node: 88, amp: 150, labelW: 230 })}
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
${pathPane(CX, TOP + 500, PW, P.H - TOP - 500, mathNodes, '3 of 16 cleared', { top: 64, node: 92, step: 128, amp: 150, labelW: 230, highlight: 'Right Triangle Trigonometry' })}
`);

// ── T04 Round, landscape: the drawing beside the answer ──
const FIG_L = { w: 640, h: L.H - TOP - 96 - 36 }; // full height, bottom edge shared with the pill
const roundL = ({ answered = false }) => page(`Round${answered ? ', answered' : ''}, landscape`, L.W, L.H, C.fog, `
${abs(40, TOP + 8, 1100, 48, roundHeader(1100, { done: answered ? 2 : 1, count: '2 / 8', bookDot: !answered, pipsW: 560 }))}
${abs(40, TOP + 96, null, null, triangle(FIG_L.w, FIG_L.h, 1.5, { answered }))}
${abs(720, TOP + 96, 420, L.H - TOP - 96 - 36, `
<div style="height:100%;display:flex;flex-direction:column;">
<div style="flex-grow:1;"></div>
<div style="display:flex;flex-direction:column;gap:10px;">${eyebrow('Which ratio connects them', C.ember)}
<div style="font-size:20px;line-height:1.5;color:${C.charcoal};">${ROUND_CONTEXT}</div></div>
<div style="height:24px;"></div>
${ratioButtons(answered ? 'answered' : 'chosen', 420, answered ? 72 : 112)}
${answered ? `<div style="height:16px;"></div>${feedbackPanel(420)}<div style="height:12px;"></div><div style="display:flex;justify-content:center;">${tanRule(24)}</div>` : ''}
<div style="height:28px;"></div>
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

// ── write ──
const dir = new URL('./tablet-screens/html/', import.meta.url);
mkdirSync(dir, { recursive: true });
for (const [name, html] of Object.entries(out)) {
  writeFileSync(new URL(`${name}.html`, dir), html);
  console.log('wrote', name);
}

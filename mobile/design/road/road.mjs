// The road between lesson nodes, drawn the way ROAD.md says the app should
// draw it, in the isometric-style view the owner chose (2026-11-03): the
// ground is tilted about 30 degrees (depth squashed to half), each node is a
// raised elliptical platform, and the road is a raised slab between them,
// lower than the platforms. One segment per pair of nodes, each with its own
// progress, on the app's own curve rule (road_segment.dart) laid out on the
// ground and then projected.
//
// Shared by build-road.mjs (phone, storyboard, close-up) and
// build-tablet-screens.mjs (every tablet path), so the two never drift.

// Road colours by role. Each value is a token from tokens.json (day) or
// app_colors.dart (night). The road and the nodes are one material system:
// a top colour over the plinth tan. The walked road is charcoal on tan, as a
// finished node is; the road ahead is creamDark on tan, as an untouched node
// is cream on tan.
export const roadDay = {
  roadOn: '#2C2C2C', // charcoal: the walked top
  roadEdge: '#47453F', // tile2: the lit rim along both edges of the walked top
  roadWall: '#CDBFA8', // plinth: the walked side wall
  roadLine: '#FFF9F0', // cream: the dashed centre line
  roadOff: '#F5EDE0', // creamDark: the top of the road not walked yet
  roadOffEdge: '#FFF9F0', // cream: its lit rim
  roadOffWall: '#CDBFA8', // plinth: its side wall
  roadShadow: 'rgba(44,44,44,0.22)', // pipOff: the shadow on the ground
  roadPulse: '#63F0A8', // spring: the pulse that runs ahead
};
export const roadNight = {
  roadOn: '#34312C', // tile (night): the walked top, lighter than the ground
  roadEdge: '#4A463F', // lineOnDark (night): its lit rim
  roadWall: '#5A544C', // plinth (night): the side wall, as under a node
  roadLine: '#F2ECE2', // the night ink (the charcoal role at night)
  roadOff: '#272522', // cream (night): the untouched node's face
  roadOffEdge: '#3A3732', // creamDark (night): its rim
  roadOffWall: '#5A544C', // plinth (night)
  roadShadow: 'rgba(0,0,0,0.5)',
  roadPulse: '#63F0A8', // spring, the same in both themes
};

// Sizes, in ground units for widths and screen units for heights.
// node: platform height (its plinth), road: slab height. The road is a
// little over half the platform's height, so the nodes stand taller.
export const roadSize = {
  phone: { width: 20, rim: 2, line: 2, dash: 7, gap: 9, node: 14, road: 8, blur: 3, shadowY: 4 },
  tablet: { width: 24, rim: 2, line: 2.5, dash: 9, gap: 10, node: 16, road: 9, blur: 3.5, shadowY: 5 },
};
export const K = 0.5; // ground depth on screen: a tilt of about 30 degrees

const lerp = (a, b, t) => ({ x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t });
const quad = (a, c, b, t) => lerp(lerp(a, c, t), lerp(c, b, t), t);

// The app's rule (RoadPainter._road): leave the node, lean 80% of the way
// toward the next node's column, arrive. Trimmed by arc length at each end.
// Works in ground units; `at(f)` gives a ground point and its ground angle.
export function segmentCurve(from, to, r, { startReach = r - 3, endReach = r - 3 } = {}) {
  const dx = to.x - from.x;
  const lean = Math.abs(dx) > 4 ? from.x + dx * 0.8 : from.x + r * 0.55;
  const c = { x: lean, y: from.y + (to.y - from.y) * 0.52 };
  let t0 = 0, t1 = 1;
  for (let t = 0; t <= 1; t += 0.001) {
    const p = quad(from, c, to, t);
    if (Math.hypot(p.x - from.x, p.y - from.y) >= startReach) { t0 = t; break; }
  }
  for (let t = 1; t >= t0; t -= 0.001) {
    const p = quad(from, c, to, t);
    if (Math.hypot(p.x - to.x, p.y - to.y) >= endReach) { t1 = t; break; }
  }
  // The sub-curve between t0 and t1 is itself a quadratic (blossoming).
  const p0 = quad(from, c, to, t0);
  const p2 = quad(from, c, to, t1);
  const k = (u, v) => ({
    x: (1 - u) * (1 - v) * from.x + ((1 - u) * v + u * (1 - v)) * c.x + u * v * to.x,
    y: (1 - u) * (1 - v) * from.y + ((1 - u) * v + u * (1 - v)) * c.y + u * v * to.y,
  });
  const p1 = k(t0, t1);
  const d = `M${p0.x.toFixed(1)} ${p0.y.toFixed(1)} Q ${p1.x.toFixed(1)} ${p1.y.toFixed(1)}, ${p2.x.toFixed(1)} ${p2.y.toFixed(1)}`;
  // Points by arc length, for the pulse and the marker.
  const pts = [];
  let len = 0, prev = p0;
  for (let i = 0; i <= 400; i++) {
    const p = quad(p0, p1, p2, i / 400);
    len += Math.hypot(p.x - prev.x, p.y - prev.y);
    pts.push({ ...p, s: len });
    prev = p;
  }
  const at = (f) => {
    const s = f * len;
    const i = pts.findIndex((p) => p.s >= s);
    const p = pts[Math.max(0, i)];
    const q = pts[Math.min(pts.length - 1, Math.max(1, i))];
    const o = pts[Math.max(0, Math.max(1, i) - 1)];
    return { x: p.x, y: p.y, angle: Math.atan2(q.y - o.y, q.x - o.x) };
  };
  return { d, length: len, at };
}

let uid = 0;
const BIG = 'x="-3000" y="-3000" width="9000" height="12000"';

// A whole path in the isometric view. Nodes are placed down the screen
// `row` apart, alternating `amp` either side of the centre line; section
// names take `sectionGap`. Returns the SVG content (no wrapper), the
// placed nodes, section rows, the curves, label obstacles and the marker.
//
//   seg(i)    -> { fill, line, pulse } for the segment from node i to i+1
//   nodeFx(i) -> { scale, lift } for the arrival moment
export function isoPath({
  nodes, width, r, size, col, row, amp, top = 26, sectionGap = 48,
  seg = () => ({}), nodeFx = () => ({}), ring = null, markerAt = null,
  peek = null, markerD = 32,
}) {
  const HN = size.node, HR = size.road, w = size.width;
  const placed = [], sections = [];
  let y = top;
  nodes.forEach((n, i) => {
    if (n.section) { sections.push({ y, text: n.section }); y += sectionGap; }
    const Y = y + r * K + HN + 4; // the platform's footprint centre on screen
    placed.push({ ...n, x: Math.round(width / 2 + (i % 2 === 0 ? -amp : amp)), Y, T: Y - HN });
    y += row;
  });
  const height = y + 40;
  // Screen point of a ground point at a height above the ground.
  const scr = (p, h = 0) => ({ x: p.x, y: p.y * K - h });
  const proj = (dy) => `translate(0 ${dy}) scale(1 ${K})`;

  const nodeSvg = (n, i) => {
    const { scale = 1, lift = 0 } = nodeFx(i) || {};
    const X = n.x, Y = n.Y, T = n.T, ry = r * K;
    let face;
    if (n.state === 'done') {
      const s = r / 42;
      face = `<ellipse cx="${X}" cy="${T}" rx="${r}" ry="${ry}" fill="${col.charcoal}"/><g transform="translate(${X} ${T}) scale(${s} ${s * K})"><path d="M-15 1l9 9 20-20" stroke="${col.spring}" stroke-width="6.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/></g>`;
    } else if (n.state === 'now') {
      const t = r * 0.22;
      face = `<g transform="translate(${X} ${T}) scale(1 ${K})"><circle r="${r - t / 2}" stroke="${col.spring}" stroke-width="${t}" fill="none"/><circle r="${r - t / 2}" stroke="${col.charcoal}" stroke-width="${t}" fill="none" pathLength="1" stroke-dasharray="${n.frac ?? 0} 1" transform="rotate(-90)"/><circle r="${r - t}" fill="${col.cream}"/></g>`;
    } else face = `<ellipse cx="${X}" cy="${T}" rx="${r}" ry="${ry}" fill="${col.cream}"/>`;
    const body = `<ellipse cx="${X}" cy="${Y}" rx="${r}" ry="${ry}" fill="${col.plinth}"/><rect x="${X - r}" y="${T}" width="${2 * r}" height="${HN}" fill="${col.plinth}"/>${face}`;
    const cy = Y - HN / 2;
    const ringSvg = ring === i ? `<ellipse cx="${X}" cy="${Y}" rx="${r + 10}" ry="${(r + 10) * K}" stroke="${col.charcoal}" stroke-width="3.5" fill="none"/>` : '';
    return `${ringSvg}<g transform="translate(0 ${-lift}) translate(${X} ${cy}) scale(${scale}) translate(${-X} ${-cy})">${body}</g>`;
  };

  const curves = [];
  const obstacles = []; // screen points the labels must stay clear of
  const segSvg = (i) => {
    const a = placed[i], b = placed[i + 1];
    const ga = { x: a.x, y: a.Y / K }, gb = { x: b.x, y: b.Y / K };
    const curve = segmentCurve(ga, gb, r, { startReach: r - 2, endReach: r - 4 });
    curves.push(curve);
    for (let f = 0; f <= 1.0001; f += 0.025) {
      const q = curve.at(Math.min(1, f));
      const nx = Math.cos(q.angle + Math.PI / 2), ny = Math.sin(q.angle + Math.PI / 2);
      for (const sgn of [-1, 1]) {
        const e = { x: q.x + sgn * nx * w / 2, y: q.y + sgn * ny * w / 2 };
        obstacles.push(scr(e, HR), scr(e, 0));
      }
    }
    const walked = a.state === 'done';
    const { fill = walked ? 1 : 0, line = fill, pulse = null } = seg(i) || {};
    const id = `iso${uid++}`;
    const cut = fill > 0 ? `pathLength="1" stroke-dasharray="${fill.toFixed(4)} 2"` : null;
    const band = (stroke, width, extra = '') => `<path d="${curve.d}" stroke="${stroke}" stroke-width="${width}" stroke-linecap="round" fill="none" ${extra}/>`;
    const layer = (dy, inner, mask) => `<g mask="url(#${id}${mask})"><g transform="${proj(dy)}">${inner}</g></g>`;
    // The joint: each layer is cut by the platform's outline at its own
    // height, so the road butts against the side of the node it leaves.
    const X = a.x, Y = a.Y;
    const ell = (cy, m) => `<mask id="${id}${m}" maskUnits="userSpaceOnUse" ${BIG}><rect ${BIG} fill="#fff"/><ellipse cx="${X}" cy="${cy}" rx="${r}" ry="${r * K}" fill="#000"/></mask>`;
    let defs = `<filter id="${id}b" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="${size.blur}"/></filter>`
      + ell(Y, 'g') + ell(Y - HR / 2, 'h') + ell(Y - HR, 't');
    // Ground: the shadow. Side wall: the band at the ground and half way up,
    // which fills the slab's side under its near edge.
    let s = layer(size.shadowY, band(col.roadShadow, w, `stroke-opacity="0.5" filter="url(#${id}b)"`), 'g');
    s += layer(0, band(col.roadOffWall, w), 'g') + layer(-HR / 2, band(col.roadOffWall, w), 'h');
    if (cut) {
      s += layer(size.shadowY, band(col.roadShadow, w, `filter="url(#${id}b)" ${cut}`), 'g');
      s += layer(0, band(col.roadWall, w, cut), 'g') + layer(-HR / 2, band(col.roadWall, w, cut), 'h');
    }
    // Top: the pale road with its lit rim, then the walked top with its own
    // lit rim of the same width, then the centre line.
    let top = band(col.roadOffEdge, w) + band(col.roadOff, w - 2 * size.rim);
    if (cut) top += band(col.roadEdge, w, cut) + band(col.roadOn, w - 2 * size.rim, cut);
    // The centre line is revealed up to `line`, never ahead of the fill.
    let dashes = '';
    if (line > 0) {
      defs += `<mask id="${id}m" maskUnits="userSpaceOnUse" ${BIG}><g transform="${proj(-HR)}"><path d="${curve.d}" stroke="#fff" stroke-width="${w + 8}" fill="none" pathLength="1" stroke-dasharray="${Math.min(line, fill).toFixed(4)} 2"/></g></mask>`;
      dashes = `<g mask="url(#${id}m)"><g transform="${proj(-HR)}"><path d="${curve.d}" stroke="${col.roadLine}" stroke-width="${size.line}" stroke-linecap="round" fill="none" stroke-dasharray="${size.dash} ${size.gap}" stroke-dashoffset="${-size.gap / 2}"/></g></g>`;
    }
    s += `<g mask="url(#${id}t)"><g transform="${proj(-HR)}">${top}</g>${dashes}</g>`;
    // A thin lip where the top meets the platform's side, so the joint
    // reads as built.
    defs += `<mask id="${id}j" maskUnits="userSpaceOnUse" ${BIG}><g transform="${proj(-HR)}"><path d="${curve.d}" stroke="#fff" stroke-width="${w}" fill="none"/></g></mask>`;
    s += `<ellipse cx="${X}" cy="${Y - HR}" rx="${r + 0.7}" ry="${(r + 0.7) * K}" stroke="${cut ? col.roadWall : col.roadOffEdge}" stroke-width="1.2" fill="none" mask="url(#${id}j)"/>`;
    if (pulse != null) {
      const q = curve.at(pulse), p = scr(q, HR);
      defs += `<radialGradient id="${id}p"><stop offset="0" stop-color="${col.roadPulse}" stop-opacity="0.95"/><stop offset="0.45" stop-color="${col.roadPulse}" stop-opacity="0.45"/><stop offset="1" stop-color="${col.roadPulse}" stop-opacity="0"/></radialGradient>`;
      const ang = Math.atan2(Math.sin(q.angle) * K, Math.cos(q.angle)) * 180 / Math.PI;
      s += `<ellipse cx="${p.x.toFixed(1)}" cy="${p.y.toFixed(1)}" rx="${w * 0.95}" ry="${w * 0.4}" transform="rotate(${ang.toFixed(1)} ${p.x.toFixed(1)} ${p.y.toFixed(1)})" fill="url(#${id}p)"/>`;
    }
    return `<defs>${defs}</defs>${s}`;
  };

  // Depth order: each node, then the segment that leaves it (in front of
  // it), then the next node (which hides that segment's end).
  let svg = '';
  placed.forEach((n, i) => {
    svg += nodeSvg(n, i);
    if (i < placed.length - 1) svg += segSvg(i);
  });
  placed.forEach((n) => obstacles.push(
    { x: n.x - r, y: n.T - r * K }, { x: n.x + r, y: n.T - r * K },
    { x: n.x - r, y: n.Y + r * K }, { x: n.x + r, y: n.Y + r * K }, { x: n.x, y: n.Y + r * K }, { x: n.x, y: n.T - r * K },
  ));

  // The marker: its centre on the road's centre line, on the top surface.
  let markerHtml = '', markerPt = null;
  if (markerAt) {
    markerPt = markerAt.seg != null
      ? scr(curves[markerAt.seg].at(markerAt.f), HR)
      : { x: placed[0].x, y: placed[0].T }; // the centre of the first face, where the centre line starts
    if (peek) markerHtml = marker(markerPt.x, markerPt.y, peek, markerD, { ring: col.fog });
  }
  // Named points for the zoomed checks (road/checks.py): every joint, the
  // middle of every segment, and the marker. Invisible; a small script
  // reports their page positions when the page is dumped.
  const pts = [];
  curves.forEach((c, i) => {
    const kind = placed[i].state === 'done' ? 'walked' : 'pale';
    pts.push([`seg${i}-leave-${kind}`, scr(c.at(0), HR)], [`seg${i}-arrive-${kind}`, scr(c.at(1), HR)], [`seg${i}-middle-${kind}`, scr(c.at(0.5), HR)]);
  });
  if (markerPt) {
    // The road's screen direction at the marker, for the dash-line check.
    const a = markerAt.seg != null ? curves[markerAt.seg].at(markerAt.f).angle : null;
    pts.push(['marker', markerPt, a == null ? '' : Math.atan2(Math.sin(a) * K, Math.cos(a)).toFixed(5)]);
  }
  const checkHtml = pts.map(([n, q, a = '']) => `<i data-check="${n}" data-a="${a}" style="position:absolute;left:${q.x.toFixed(2)}px;top:${q.y.toFixed(2)}px;width:0;height:0;"></i>`).join('')
    + `<script>window.addEventListener('load',()=>{if(window.__c)return;window.__c=1;const o=[];document.querySelectorAll('[data-check]').forEach(e=>{const b=e.getBoundingClientRect();o.push([e.dataset.check,b.left,b.top,e.dataset.a]);});const p=document.createElement('pre');p.id='checks';p.style.display='none';p.textContent=JSON.stringify(o);document.body.appendChild(p);});</script>`;
  return { height, placed, sections, curves, obstacles, svg, markerHtml, markerPt, scr, HR, checkHtml };
}

// Puts a label beside its node: centred on the node's face if that is
// clear of the road and the platforms, otherwise moved up or down by the
// smallest amount that is. Returns the label's centre y.
export function placeLabel({ x0, x1, cy, h, obstacles, margin = 6 }) {
  const hit = (c) => obstacles.some((p) => p.x >= x0 - margin && p.x <= x1 + margin && p.y >= c - h / 2 - margin && p.y <= c + h / 2 + margin);
  for (let d = 0; d <= 90; d += 2) {
    if (!hit(cy - d)) return cy - d;
    if (!hit(cy + d)) return cy + d;
  }
  return cy;
}

// The position marker: the brand's raccoon peek on a small charcoal coin,
// centred on (x, y), with a fog ring that lifts it off the road.
export const marker = (x, y, src, d = 34, { ring = '#E3DFD7' } = {}) =>
  `<div aria-hidden="true" style="position:absolute;left:${x - d / 2}px;top:${y - d / 2}px;width:${d}px;height:${d}px;border-radius:50%;background:#2C2C2C;box-shadow:0 0 0 3px ${ring};display:flex;align-items:flex-end;justify-content:center;overflow:hidden;z-index:200;"><img src="${src}" alt="" style="width:${Math.round(d * 0.78)}px;margin-bottom:${Math.round(d * 0.18)}px;"></div>`;

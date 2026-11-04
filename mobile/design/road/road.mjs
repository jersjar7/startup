// The road between lesson nodes, drawn the way ROAD.md says the app should
// draw it: one segment per pair of nodes, each with its own progress, on the
// same curve rule the app's RoadPainter already uses (road_segment.dart).
//
// Shared by build-road.mjs (phone, storyboard, close-up) and
// build-tablet-screens.mjs (every tablet path), so the two never drift.

// Road colours by role. Each value is a token from tokens.json (day) or
// app_colors.dart (night). ROAD.md, "Colour", explains the choices.
//
// The road is a raised slab: a top surface with a thin lighter rim, a side
// wall under its downward-facing edge, and a soft shadow on the ground. The
// wall is shorter than a node's plinth, so the nodes stand taller.
export const roadDay = {
  roadOn: '#3A3936', // tile: the walked surface, dark charcoal grey
  roadEdge: '#47453F', // tile2: the lighter rim along its top edges
  roadWall: '#2C2C2C', // charcoal: its side wall, darker than the surface
  roadLine: '#FFF9F0', // cream: the dashed centre line
  roadOff: '#F5EDE0', // creamDark: the road not walked yet
  roadOffEdge: '#FFF9F0', // cream: its rim
  roadOffWall: '#CDBFA8', // plinth: its wall, the untouched node's plinth
  roadShadow: 'rgba(44,44,44,0.22)', // pipOff: the shadow on the ground
  roadPulse: '#63F0A8', // spring: the pulse that runs ahead
};
export const roadNight = {
  roadOn: '#4A463F', // lineOnDark (night): lighter than the ground, so walked reads as defined
  roadEdge: '#5A544C', // plinth (night): the rim, a touch lighter again
  roadWall: '#34312C', // tile (night): the wall, darker than the surface
  roadLine: '#F2ECE2', // the night ink (the charcoal role at night)
  roadOff: '#272522', // cream (night): the untouched node's face
  roadOffEdge: '#3A3732', // creamDark (night): its rim
  roadOffWall: '#5A544C', // plinth (night): its wall, as under an untouched node
  roadShadow: 'rgba(0,0,0,0.5)',
  roadPulse: '#63F0A8', // spring, the same in both themes
};

// Sizes. Phone nodes are 84 at 390 wide; tablet nodes are 100 (92 in the
// tablet mockups). The mockups' node plinth is 7 deep, so the wall is 4:
// 0.6 of the plinth, which ROAD.md sets as the rule.
export const roadSize = {
  phone: { width: 20, edge: 2, line: 2, dash: 7, gap: 9, depth: 4, shadowY: 7, blur: 3 },
  tablet: { width: 24, edge: 2, line: 2.5, dash: 9, gap: 10, depth: 4, shadowY: 7, blur: 3.5 },
};

const lerp = (a, b, t) => ({ x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t });
const quad = (a, c, b, t) => lerp(lerp(a, c, t), lerp(c, b, t), t);

// The app's rule (RoadPainter._road): leave the node, lean 80% of the way
// toward the next node's column, arrive. Then trim by arc length where the
// curve enters each node, tucked 3 under the face so there is no seam.
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

// The road meets each node at the node's side wall, at road height
// (ROAD.md, "Where the road meets a node"). Node centres are the centres of
// their top faces; `plinth` is the node's plinth depth. The road's surface
// sits (plinth - depth) lower than the node's top face, so its curve runs
// between the centres moved down by that much. It leaves the upper node from
// that node's near (viewer-facing) side, in front of it, and ends under the
// lower node's far side, where the node hides it.
export function joinedSegment(a, b, r, size, plinth) {
  const drop = plinth - size.depth;
  const from = { x: a.x, y: a.y + drop }, to = { x: b.x, y: b.y + drop };
  const curve = segmentCurve(from, to, r, { startReach: r - 2, endReach: r - 4 });
  return { curve, near: { x: a.x, y: a.y + drop, r } };
}

let uid = 0;
// One segment. `fill` is how far the charcoal has run (0..1), `line` how far
// the centre line has been revealed (0..1, never ahead of fill), `pulse` is
// where the pulse is (null for none). Colours come in as CSS values.
export function segmentSvg(curve, { fill = 0, line = fill, pulse = null, size, col, near = null }) {
  const id = `r${uid++}`;
  const { width: w, edge, line: lw, dash, gap, depth, shadowY, blur } = size;
  const dash1 = (f) => `pathLength="1" stroke-dasharray="${Math.max(0, f).toFixed(4)} 2"`;
  const band = (stroke, width, extra = '') => `<path d="${curve.d}" stroke="${stroke}" stroke-width="${width}" stroke-linecap="round" ${extra}/>`;
  // A slab. On the ground: its soft shadow and its side wall (the same band
  // moved down by the wall's depth, so it shows only under the downward-
  // facing edge, lit from above like the node plinths). On top: the rim and
  // the surface. The pale road is drawn whole; the walked part is laid over
  // it, cut at `fill`, so its wall darkens with it.
  const walked = fill > 0 ? dash1(fill) : null;
  let ground = band(col.roadShadow, w, `stroke-opacity="0.5" transform="translate(0 ${shadowY})" filter="url(#${id}b)"`)
    + band(col.roadOffWall, w, `transform="translate(0 ${depth})"`);
  let top = band(col.roadOffEdge, w) + band(col.roadOff, w - 2 * edge);
  if (walked) {
    ground += band(col.roadShadow, w, `transform="translate(0 ${shadowY})" filter="url(#${id}b)" ${walked}`)
      + band(col.roadWall, w, `transform="translate(0 ${depth})" ${walked}`);
    top += band(col.roadEdge, w, walked) + band(col.roadOn, w - 2 * edge, walked);
  }
  let defs = `<filter id="${id}b" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="${blur}"/></filter>`;
  if (line > 0) {
    defs += `<mask id="${id}m" maskUnits="userSpaceOnUse" x="-2000" y="-2000" width="6000" height="8000"><path d="${curve.d}" stroke="#fff" stroke-width="${w + 8}" stroke-linecap="butt" ${dash1(Math.min(line, fill))}/></mask>`;
    top += `<path d="${curve.d}" stroke="${col.roadLine}" stroke-width="${lw}" stroke-linecap="round" stroke-dasharray="${dash} ${gap}" stroke-dashoffset="${-gap / 2}" mask="url(#${id}m)"/>`;
  }
  if (pulse != null) {
    const p = curve.at(pulse);
    defs += `<radialGradient id="${id}g"><stop offset="0" stop-color="${col.roadPulse}" stop-opacity="0.95"/><stop offset="0.45" stop-color="${col.roadPulse}" stop-opacity="0.45"/><stop offset="1" stop-color="${col.roadPulse}" stop-opacity="0"/></radialGradient>`;
    top += `<ellipse cx="${p.x.toFixed(1)}" cy="${p.y.toFixed(1)}" rx="${w * 0.95}" ry="${w * 0.5}" transform="rotate(${(p.angle * 180 / Math.PI).toFixed(1)} ${p.x.toFixed(1)} ${p.y.toFixed(1)})" fill="url(#${id}g)"/>`;
  }
  if (!near) return `<defs>${defs}</defs>${ground}${top}`;
  // The joint (ROAD.md, "Where the road meets a node"). The node is a
  // cylinder. The road's top is cut by the cylinder's outline at road height;
  // its wall and shadow by the outline at the ground, the wall's depth lower.
  // So the road butts against the node's side instead of passing under it,
  // and a thin lit rim runs along the cut where the surface meets the wall.
  const { x, y, r } = near;
  const big = 'x="-2000" y="-2000" width="6000" height="8000"';
  const cut = (cy, mid) => `<mask id="${id}${mid}" maskUnits="userSpaceOnUse" ${big}><rect ${big} fill="#fff"/><circle cx="${x}" cy="${cy}" r="${r}" fill="#000"/></mask>`;
  defs += cut(y, 't') + cut(y + depth, 'g')
    + `<mask id="${id}j" maskUnits="userSpaceOnUse" ${big}><path d="${curve.d}" stroke="#fff" stroke-width="${w}" stroke-linecap="butt"/></mask>`;
  const lip = `<circle cx="${x}" cy="${y}" r="${r + 0.8}" stroke="${walked ? col.roadEdge : col.roadOffEdge}" stroke-width="1.6" mask="url(#${id}j)"/>`;
  return `<defs>${defs}</defs><g mask="url(#${id}g)">${ground}</g><g mask="url(#${id}t)">${top}${lip}</g>`;
}

// The position marker: the brand's raccoon peek on a small charcoal coin with
// the node's plinth under it, parked on the road. `src` is the peek PNG.
export const marker = (x, y, src, d = 34, { ring = '#E3DFD7' } = {}) =>
  `<div aria-hidden="true" style="position:absolute;left:${x - d / 2}px;top:${y - d / 2}px;width:${d}px;height:${d}px;border-radius:50%;background:#2C2C2C;box-shadow:0 0 0 3px ${ring};display:flex;align-items:flex-end;justify-content:center;overflow:hidden;z-index:200;"><img src="${src}" alt="" style="width:${Math.round(d * 0.78)}px;margin-bottom:${Math.round(d * 0.18)}px;"></div>`;

// Where the top edge of a segment's road is at screen column `x`, or null
// when the road does not reach that column. Labels use it to stay clear of
// the road that leaves their node (ROAD.md, "Labels").
export function roadTopAt(curve, x, halfWidth) {
  for (let f = 0; f <= 1; f += 0.005) {
    const a = curve.at(f), b = curve.at(Math.min(1, f + 0.005));
    if ((a.x - x) * (b.x - x) <= 0) return a.y - halfWidth / Math.max(0.2, Math.abs(Math.cos(a.angle)));
  }
  return null;
}

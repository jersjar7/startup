import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan sketch of a level loop BM 40 -> P -> Q -> BM 40, legs drawn to scale
 * from their lengths, with arrows in the direction the run was leveled.
 */
export function CtSurveyingBLevelLoop({ d1 = 18000, d2 = 24000, d3 = 16000 }) {
  // BM at origin, P along +x, Q from the law of cosines (engineering y up)
  const qx = (d1 * d1 + d3 * d3 - d2 * d2) / (2 * d1);
  const qy = Math.sqrt(Math.max(d3 * d3 - qx * qx, 0));
  const s = 300 / d1;
  const ox = 60;
  const oy = 34 + qy * s;
  const P = (x, y) => ({ x: ox + x * s, y: oy - y * s });
  const bm = P(0, 0);
  const p = P(d1, 0);
  const q = P(qx, qy);
  const W = Math.ceil(p.x + 60);
  const H = Math.ceil(oy + 34);
  const fmt = (v) => `${v.toLocaleString('en-US')} ft`;
  const arrow = (a, b, id) => {
    const mx = (a.x + b.x) / 2;
    const my = (a.y + b.y) / 2;
    const L = Math.hypot(b.x - a.x, b.y - a.y);
    const ux = (b.x - a.x) / L;
    const uy = (b.y - a.y) / L;
    return <path key={id} d={`M ${mx + ux * 7},${my + uy * 7} L ${mx - ux * 5 - uy * 5},${my - uy * 5 + ux * 5} L ${mx - ux * 5 + uy * 5},${my - uy * 5 - ux * 5} Z`} fill="var(--charcoal)" />;
  };
  // label outward from the triangle's centroid
  const g = { x: (bm.x + p.x + q.x) / 3, y: (bm.y + p.y + q.y) / 3 };
  const lab = (a, b, d) => {
    const mx = (a.x + b.x) / 2;
    const my = (a.y + b.y) / 2;
    const L = Math.hypot(b.x - a.x, b.y - a.y);
    let nx = -(b.y - a.y) / L;
    let ny = (b.x - a.x) / L;
    if (nx * (mx - g.x) + ny * (my - g.y) < 0) { nx = -nx; ny = -ny; }
    return { x: mx + nx * d, y: my + ny * d, nx };
  };
  const l1 = lab(bm, p, 15);
  const l2 = lab(p, q, 14);
  const l3 = lab(q, bm, 14);
  const anchorOf = (l) => (l.nx > 0.3 ? 'start' : l.nx < -0.3 ? 'end' : 'middle');

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Level loop from BM 40 to P (${fmt(d1)}), P to Q (${fmt(d2)}), Q back to BM 40 (${fmt(d3)})`}
      style={{ width: '100%', height: 'auto' }}>
      <polygon points={`${bm.x},${bm.y} ${p.x},${p.y} ${q.x},${q.y}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.8} strokeLinejoin="round" />
      {arrow(bm, p, 'a1')}{arrow(p, q, 'a2')}{arrow(q, bm, 'a3')}
      <path d={`M ${bm.x},${bm.y - 7} L ${bm.x - 7},${bm.y + 5} L ${bm.x + 7},${bm.y + 5} Z`} fill="var(--charcoal)" />
      <circle cx={p.x} cy={p.y} r={4} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <circle cx={q.x} cy={q.y} r={4} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <Label x={bm.x - 12} y={bm.y} anchor="end" color="var(--charcoal)" fontSize={13} bold>BM 40</Label>
      <Label x={p.x + 10} y={p.y} anchor="start" color="var(--charcoal)" fontSize={13} bold>P</Label>
      <Label x={q.x} y={q.y - 15} color="var(--charcoal)" fontSize={13} bold>Q</Label>
      <Label x={l1.x} y={l1.y} anchor={anchorOf(l1)} color="var(--gray-500)" fontSize={12}>{fmt(d1)}</Label>
      <Label x={l2.x} y={l2.y} anchor={anchorOf(l2)} color="var(--gray-500)" fontSize={12}>{fmt(d2)}</Label>
      <Label x={l3.x} y={l3.y} anchor={anchorOf(l3)} color="var(--gray-500)" fontSize={12}>{fmt(d3)}</Label>
    </svg>
  );
}

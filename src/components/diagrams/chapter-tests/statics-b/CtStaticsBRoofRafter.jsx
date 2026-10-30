import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * A rafter on a rise:run slope with a vertical gravity load and a wind load
 * normal to the roof, pushing into it.
 * Shows: the slope triangle, both loads.
 * Does NOT show: components of either load.
 */
export function CtStaticsBRoofRafter({ rise = 6, run = 12, gravity = '1,200 lb', wind = '400 lb' }) {
  const len = Math.hypot(rise, run);
  const u = { x: run / len, y: -rise / len }; // up the rafter (svg)
  const n = { x: -rise / len, y: -run / len }; // outward normal, up and to the left
  const A = { x: 40, y: 206 };
  const Lp = 300;
  const B = { x: A.x + u.x * Lp, y: A.y + u.y * Lp };
  const th = 7; // half depth of the rafter
  const corner = (p, s) => ({ x: p.x + n.x * th * s, y: p.y + n.y * th * s });
  const pts = [corner(A, 1), corner(B, 1), corner(B, -1), corner(A, -1)];
  const at = (f) => ({ x: A.x + u.x * Lp * f, y: A.y + u.y * Lp * f });
  const G = at(0.38); // gravity load point (top face)
  const Gt = { x: G.x + n.x * th, y: G.y + n.y * th };
  const Wp = at(0.74);
  const Wt = { x: Wp.x + n.x * (th + 2), y: Wp.y + n.y * (th + 2) };
  const Wtail = { x: Wt.x + n.x * 66, y: Wt.y + n.y * 66 };
  // slope triangle below the rafter, toward the right end
  const s = 7;
  const P0 = at(0.62);
  const p = { x: P0.x - n.x * 22, y: P0.y - n.y * 22 };
  const q = { x: p.x + run * s, y: p.y };
  const r = { x: q.x, y: q.y - rise * s };
  const gray = 'var(--gray-500)';

  return (
    <svg viewBox="0 0 370 226" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Rafter at ${rise} in ${run} slope with a vertical ${gravity} load and a ${wind} wind load normal to the roof`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBRafterArrow" color="var(--ember)" size={9} />

      <polygon points={pts.map((c) => `${c.x},${c.y}`).join(' ')} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <Label x={A.x + 46} y={A.y + 6} color="var(--charcoal)" anchor="start">rafter</Label>

      {/* Gravity load, vertical */}
      <line x1={Gt.x} y1={Gt.y - 78} x2={Gt.x} y2={Gt.y - 2} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBRafterArrow)" />
      <Label x={Gt.x - 8} y={Gt.y - 64} color="var(--ember)" bold anchor="end">{gravity}</Label>
      <Label x={Gt.x - 8} y={Gt.y - 49} color="var(--charcoal)" anchor="end">gravity</Label>

      {/* Wind load, normal to the roof */}
      <line x1={Wtail.x} y1={Wtail.y} x2={Wt.x} y2={Wt.y} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBRafterArrow)" />
      <Label x={Wtail.x - 6} y={Wtail.y - 8} color="var(--ember)" bold anchor="end">{`wind ${wind}`}</Label>
      <Label x={Wtail.x - 6} y={Wtail.y + 7} color="var(--charcoal)" anchor="end">normal to roof</Label>

      {/* Slope triangle */}
      <polygon points={`${p.x},${p.y} ${q.x},${q.y} ${r.x},${r.y}`} fill="none" stroke={gray} strokeWidth={1.2} />
      <Label x={(p.x + q.x) / 2} y={p.y + 11}>{run}</Label>
      <Label x={q.x + 9} y={(q.y + r.y) / 2}>{rise}</Label>
    </svg>
  );
}

import React from 'react';
import { T, Arrow, Dim, Ext, Leader } from './CtFluidMechanicsBParts';

/**
 * Water line running downhill through a reducer, elevation view. Pipe
 * diameters and the drop between points 1 and 2 share one scale.
 * Shows: diameters, flow, pressure at 1, drop from 1 to 2.
 * Does NOT show: the pressure at 2 (student solves).
 */
export function CtFluidMechanicsBReducer({ d1 = 12, d2 = 8, dz = 10, p1 = 30, q = 6 }) {
  const W = 460;
  const s = 14; // px per ft
  const P1 = { x: 120, y: 74 };
  const P2 = { x: 412, y: P1.y + dz * s };
  const L = Math.hypot(P2.x - P1.x, P2.y - P1.y);
  const u = { x: (P2.x - P1.x) / L, y: (P2.y - P1.y) / L };
  const n = { x: -u.y, y: u.x }; // points down and left of the flow
  const at = (t, off = 0) => ({ x: P1.x + u.x * t + n.x * off, y: P1.y + u.y * t + n.y * off });
  const r1 = (d1 / 12) * s / 2;
  const r2 = (d2 / 12) * s / 2;
  const ta = -36;
  const tr0 = L * 0.48;
  const tr1 = tr0 + 22;
  const tb = L + 30;
  const edge = (sg) => [at(ta, sg * r1), at(tr0, sg * r1), at(tr1, sg * r2), at(tb, sg * r2)]
    .map((p, i) => `${i ? 'L' : 'M'} ${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' ');
  const body = `${edge(-1)} ${[at(tb, r2), at(tr1, r2), at(tr0, r1), at(ta, r1)].map((p) => `L ${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' ')} Z`;
  const g1 = at(0, -r1);
  const gy = 30;
  const a1 = at(30, -24);
  const a2 = at(96, -24);
  const ql = at(58, -42);
  const l1 = at(84, 30);
  const l2 = at(L * 0.70, 24);
  const H = P2.y + 30;
  const dx = 66;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Water line dropping ${dz} ft from a ${d1}-in. pipe at point 1 to an ${d2}-in. pipe at point 2; ${p1} psi at point 1`}
      style={{ width: '100%', height: 'auto' }}>
      <path d={body} fill="var(--info)" fillOpacity={0.3} />
      <path d={edge(-1)} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <path d={edge(1)} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={P1.x} cy={P1.y} r={2.4} fill="var(--charcoal)" />
      <circle cx={P2.x} cy={P2.y} r={2.4} fill="var(--charcoal)" />
      <T x={at(0, 22).x - 4} y={at(0, 22).y} bold>1</T>
      <T x={P2.x - 4} y={P2.y + 20} bold>2</T>

      {/* gauge at 1 */}
      <line x1={g1.x} y1={g1.y} x2={g1.x} y2={gy + 13} stroke="var(--charcoal)" strokeWidth={3} />
      <circle cx={g1.x} cy={gy} r={13} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={g1.x} y1={gy} x2={g1.x + 6} y2={gy - 8} stroke="var(--charcoal)" strokeWidth={1.6} />
      <circle cx={g1.x} cy={gy} r={1.6} fill="var(--charcoal)" />
      <T x={g1.x + 20} y={gy} anchor="start" color="var(--ember)" bold>{`${p1} psi`}</T>

      {/* flow */}
      <Arrow x1={a1.x} y1={a1.y} x2={a2.x} y2={a2.y} color="var(--info)" width={2.2} />
      <T x={ql.x + 6} y={ql.y} anchor="start" color="var(--info)">{`Q = ${q} cfs`}</T>

      {/* diameters */}
      <T x={l1.x - 6} y={l1.y + 6} anchor="end" color="var(--gray-500)">{`${d1} in.`}</T>
      <Leader x1={l1.x - 4} y1={l1.y + 2} x2={at(84, r1 + 1).x} y2={at(84, r1 + 1).y} />
      <T x={l2.x - 6} y={l2.y + 6} anchor="end" color="var(--gray-500)">{`${d2} in.`}</T>
      <Leader x1={l2.x - 4} y1={l2.y + 2} x2={at(L * 0.70, r2 + 1).x} y2={at(L * 0.70, r2 + 1).y} />

      {/* drop from 1 to 2 */}
      <Ext x1={P1.x - 21} y1={P1.y} x2={dx - 6} y2={P1.y} />
      <Ext x1={P2.x - 16} y1={P2.y} x2={dx - 6} y2={P2.y} />
      <Dim x1={dx} y1={P1.y} x2={dx} y2={P2.y} label={`${dz} ft`} lx={dx - 8} ly={(P1.y + P2.y) / 2} anchor="end" />
    </svg>
  );
}

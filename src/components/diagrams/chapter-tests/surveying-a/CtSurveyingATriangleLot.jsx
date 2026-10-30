import React from 'react';
import { arcPath } from '../../geo';
import { Label } from '../../primitives';

/**
 * Triangular lot ABC in plan, drawn to scale from its three taped sides.
 * Shows the side lengths and marks the angle at B without its value.
 */
export function CtSurveyingATriangleLot({ ab = 412.5, bc = 365.2, ac = 598.4 }) {
  // Engineering coordinates (ft, y up): A at origin, C on the x axis.
  const bx = (ab * ab - bc * bc + ac * ac) / (2 * ac);
  const by = Math.sqrt(Math.max(ab * ab - bx * bx, 0));
  const s = 320 / ac;
  const ox = 40;
  const oy = 30 + by * s;
  const P = (x, y) => ({ x: ox + x * s, y: oy - y * s });
  const A = P(0, 0);
  const B = P(bx, by);
  const C = P(ac, 0);
  const W = 400;
  const H = oy + 32;
  const fmt = (v) => `${v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} ft`;

  // Angle at B (math convention, y up) from BA to BC.
  const angA = (Math.atan2(-(A.y - B.y), A.x - B.x) * 180) / Math.PI;
  const angC = (Math.atan2(-(C.y - B.y), C.x - B.x) * 180) / Math.PI;
  const a1 = (angA + 360) % 360;
  const a2 = (angC + 360) % 360;

  // Side label positions: midpoint pushed outward along the side normal.
  const out = (p, q, d) => {
    const dx = q.x - p.x;
    const dy = q.y - p.y;
    const L = Math.hypot(dx, dy);
    // outward = away from the triangle interior (interior lies below AB and BC)
    return { x: (p.x + q.x) / 2 + (dy / L) * d, y: (p.y + q.y) / 2 - (dx / L) * d };
  };
  const labAB = out(A, B, 12);
  const labBC = out(B, C, 12);

  return (
    <svg viewBox={`0 0 ${W} ${H.toFixed(1)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Triangular lot ABC with sides AB ${fmt(ab)}, BC ${fmt(bc)}, AC ${fmt(ac)}`}
      style={{ width: '100%', height: 'auto' }}>
      <polygon points={`${A.x},${A.y} ${B.x},${B.y} ${C.x},${C.y}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <path d={arcPath(B.x, B.y, 22, a1, a2)} fill="none" stroke="var(--ember)" strokeWidth={1.5} />
      {[A, B, C].map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={3} fill="var(--charcoal)" />)}

      <Label x={A.x - 10} y={A.y} anchor="end" color="var(--charcoal)" fontSize={13} bold>A</Label>
      <Label x={B.x} y={B.y - 14} color="var(--charcoal)" fontSize={13} bold>B</Label>
      <Label x={C.x + 10} y={C.y} anchor="start" color="var(--charcoal)" fontSize={13} bold>C</Label>

      <Label x={labAB.x} y={labAB.y} anchor="end" color="var(--gray-500)" fontSize={12}>{fmt(ab)}</Label>
      <Label x={labBC.x} y={labBC.y} anchor="start" color="var(--gray-500)" fontSize={12}>{fmt(bc)}</Label>
      <Label x={(A.x + C.x) / 2} y={A.y + 16} color="var(--gray-500)" fontSize={12}>{fmt(ac)}</Label>
    </svg>
  );
}

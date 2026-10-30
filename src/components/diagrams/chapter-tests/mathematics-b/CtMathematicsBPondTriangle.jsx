import React from 'react';
import { Label } from '../../primitives';
import { arcPath } from '../../geo';

/**
 * Taping across a pond: from station P the surveyor tapes PA and PB and turns
 * the angle APB. AB crosses the water and cannot be taped.
 * Shows: PA, PB, the angle at P, the pond, line AB dashed.
 * Does NOT show: the length AB.
 */
export function CtMathematicsBPondTriangle({ pa = 318.4, pb = 402.7, angleDeg = 73.3, angleLabel = "73°18′", unit = 'ft' }) {
  const s = 230 / Math.max(pa, pb);
  const half = angleDeg / 2;
  const dirA = 90 + half;
  const dirB = 90 - half;
  const LA = pa * s;
  const LB = pb * s;
  // Raw coordinates with P at the origin, y up.
  const A0 = { x: LA * Math.cos((dirA * Math.PI) / 180), y: LA * Math.sin((dirA * Math.PI) / 180) };
  const B0 = { x: LB * Math.cos((dirB * Math.PI) / 180), y: LB * Math.sin((dirB * Math.PI) / 180) };
  const minX = Math.min(0, A0.x, B0.x);
  const maxX = Math.max(0, A0.x, B0.x);
  const maxY = Math.max(A0.y, B0.y);
  const padL = 44;
  const padR = 44;
  const padT = 24;
  const padB = 28;
  const W = Math.round(maxX - minX + padL + padR);
  const H = Math.round(maxY + padT + padB);
  const px = padL - minX;
  const py = padT + maxY;
  const P = { x: px, y: py };
  const A = { x: px + A0.x, y: py - A0.y };
  const B = { x: px + B0.x, y: py - B0.y };

  // Pond: an ellipse centred on AB, long axis along AB.
  const mx = (A.x + B.x) / 2;
  const my = (A.y + B.y) / 2;
  const abAng = (Math.atan2(B.y - A.y, B.x - A.x) * 180) / Math.PI;
  const abLen = Math.hypot(B.x - A.x, B.y - A.y);

  // Side labels: midpoint pushed outward, perpendicular to the side.
  const sideLabel = (Q, sign) => {
    const dx = Q.x - P.x;
    const dy = Q.y - P.y;
    const len = Math.hypot(dx, dy);
    const nx = (sign * -dy) / len;
    const ny = (sign * dx) / len;
    return { x: (P.x + Q.x) / 2 + nx * 16, y: (P.y + Q.y) / 2 + ny * 16, rot: (Math.atan2(dy, dx) * 180) / Math.PI };
  };
  const upright = (r) => { let v = ((r % 360) + 360) % 360; if (v > 90 && v < 270) v -= 180; return v; };
  const la = sideLabel(A, -1);
  const lb = sideLabel(B, 1);
  const rotA = upright(la.rot);
  const rotB = upright(lb.rot);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Station P with tapes PA = ${pa} ${unit} and PB = ${pb} ${unit}, angle APB ${angleLabel}; line AB crosses a pond`}
      style={{ width: '100%', height: 'auto' }}>
      <ellipse cx={mx} cy={my} rx={abLen * 0.3} ry={30} transform={`rotate(${abAng}, ${mx}, ${my})`}
        fill="var(--info)" fillOpacity={0.14} stroke="var(--info)" strokeWidth={1.5} />
      <Label x={mx} y={my + 18} color="var(--info)" fontSize={11} italic>pond</Label>

      <line x1={A.x} y1={A.y} x2={B.x} y2={B.y} stroke="var(--charcoal)" strokeWidth={1.5} strokeDasharray="6,4" />
      <line x1={P.x} y1={P.y} x2={A.x} y2={A.y} stroke="var(--charcoal)" strokeWidth={2.2} />
      <line x1={P.x} y1={P.y} x2={B.x} y2={B.y} stroke="var(--charcoal)" strokeWidth={2.2} />

      <path d={arcPath(P.x, P.y, 34, dirB, dirA)} fill="none" stroke="var(--ember)" strokeWidth={1.6} />
      <Label x={P.x} y={P.y - 50} color="var(--ember)" fontSize={12} bold>{angleLabel}</Label>

      <Label x={la.x} y={la.y} rotate={rotA} color="var(--charcoal)" fontSize={12}>{`${pa} ${unit}`}</Label>
      <Label x={lb.x} y={lb.y} rotate={rotB} color="var(--charcoal)" fontSize={12}>{`${pb} ${unit}`}</Label>

      {[['P', P, 0, 16], ['A', A, -12, -10], ['B', B, 12, -10]].map(([n, Q, dx, dy]) => (
        <g key={n}>
          <circle cx={Q.x} cy={Q.y} r={3.5} fill="var(--charcoal)" />
          <Label x={Q.x + dx} y={Q.y + dy} color="var(--charcoal)" fontSize={13} bold>{n}</Label>
        </g>
      ))}
    </svg>
  );
}

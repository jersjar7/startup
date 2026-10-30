import React from 'react';
import { Label } from '../../primitives';
import { arcPath } from '../../geo';

/**
 * Triangular lot ABC drawn to scale, with the obtuse corner at C.
 * Shows: AB, BC, the angle at A, and the asked angle at C marked theta.
 * Does NOT show: AC, the angle at B, or the value of theta.
 */
export function CtMathematicsBLotTriangle({ ab = 520.0, bc = 410.0, angleA = 42, unit = 'ft' }) {
  // Solve the drawing (the obtuse case: C is the vertex nearer A).
  const A_ = (angleA * Math.PI) / 180;
  const sinC = (ab * Math.sin(A_)) / bc;
  const C_ = Math.PI - Math.asin(Math.min(1, sinC));
  const B_ = Math.PI - A_ - C_;
  const ac = (bc * Math.sin(B_)) / Math.sin(A_);

  const s = 360 / ab;
  const padL = 26;
  const padT = 34;
  const cyUp = ac * Math.sin(A_) * s;
  const A = { x: padL, y: padT + cyUp };
  const B = { x: padL + ab * s, y: padT + cyUp };
  const C = { x: padL + ac * Math.cos(A_) * s, y: padT };
  const W = Math.round(B.x + 26);
  const H = Math.round(A.y + 40);

  const dirCA = (Math.atan2(-(A.y - C.y), A.x - C.x) * 180) / Math.PI; // math convention
  const dirCB = (Math.atan2(-(B.y - C.y), B.x - C.x) * 180) / Math.PI;
  const cStart = dirCA < 0 ? dirCA + 360 : dirCA;
  const cEnd = dirCB < 0 ? dirCB + 360 : dirCB;
  const cMid = ((cStart + cEnd) / 2) * (Math.PI / 180);

  // BC label: outside the triangle, perpendicular to BC.
  const bdx = B.x - C.x;
  const bdy = B.y - C.y;
  const blen = Math.hypot(bdx, bdy);
  const bcRot = (Math.atan2(bdy, bdx) * 180) / Math.PI;
  const bcLab = { x: (B.x + C.x) / 2 + (bdy / blen) * 14, y: (B.y + C.y) / 2 - (bdx / blen) * 14 };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Triangular lot: AB = ${ab} ${unit}, BC = ${bc} ${unit}, angle A = ${angleA} degrees, obtuse angle at C marked theta`}
      style={{ width: '100%', height: 'auto' }}>
      <polygon points={`${A.x},${A.y} ${B.x},${B.y} ${C.x},${C.y}`} fill="var(--gray-400)" fillOpacity={0.08}
        stroke="var(--charcoal)" strokeWidth={2.2} strokeLinejoin="round" />

      <path d={arcPath(A.x, A.y, 46, 0, angleA)} fill="none" stroke="var(--gray-500)" strokeWidth={1.4} />
      <Label x={A.x + 70} y={A.y - 14} color="var(--charcoal)" fontSize={12}>{`${angleA}°`}</Label>

      <path d={arcPath(C.x, C.y, 18, cStart, cEnd)} fill="none" stroke="var(--ember)" strokeWidth={1.8} />
      <Label x={C.x + 32 * Math.cos(cMid)} y={C.y - 32 * Math.sin(cMid)} color="var(--ember)" fontSize={14} bold italic>
        {'θ'}
      </Label>

      <Label x={(A.x + B.x) / 2} y={A.y + 16} color="var(--charcoal)" fontSize={12}>{`${ab.toFixed(1)} ${unit}`}</Label>
      <Label x={bcLab.x} y={bcLab.y} rotate={bcRot} color="var(--charcoal)" fontSize={12}>{`${bc.toFixed(1)} ${unit}`}</Label>

      {[['A', A, -12, 6], ['B', B, 12, 6], ['C', C, 0, -14]].map(([n, Q, dx, dy]) => (
        <g key={n}>
          <circle cx={Q.x} cy={Q.y} r={3.5} fill="var(--charcoal)" />
          <Label x={Q.x + dx} y={Q.y + dy} color="var(--charcoal)" fontSize={13} bold>{n}</Label>
        </g>
      ))}
    </svg>
  );
}

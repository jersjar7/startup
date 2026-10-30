import React from 'react';
import { PinSupport, DimensionLine, Label } from '../../primitives';

/**
 * Parabolic arch between two pinned springings.
 * Shows: span, rise at the crown, a point P a given distance from the left
 * springing and its unknown height h. Does NOT show the value of h.
 */
export function CtMathematicsAParabolicArch({ span = 80, rise = 20, offset = 10 }) {
  const s = 300 / span;                 // px per ft, arch always 300 wide
  const x0 = 28;
  const yS = 24 + rise * s;             // springing line
  const half = span / 2;
  const X = (u) => x0 + u * s;          // u in ft from the left springing
  const Y = (u) => yS - rise * (1 - ((u - half) / half) ** 2) * s;
  const pts = [];
  for (let i = 0; i <= 80; i++) { const u = (span * i) / 80; pts.push(`${X(u).toFixed(1)},${Y(u).toFixed(1)}`); }
  const px = X(offset), py = Y(offset);
  const xr = X(span) + 22;              // rise dimension, right of the arch
  const W = xr + 40;
  const H = yS + 82;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Parabolic arch, span ${span} ft, rise ${rise} ft, point P ${offset} ft from the left springing`}
      style={{ width: '100%', height: 'auto' }}>
      {/* springing line */}
      <line x1={X(0)} y1={yS} x2={X(span)} y2={yS} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="5,4" />
      {/* arch */}
      <polyline points={pts.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={3} strokeLinejoin="round" />
      <PinSupport x={X(0)} y={yS} size={14} />
      <PinSupport x={X(span)} y={yS} size={14} />

      {/* crown extension to the rise dimension */}
      <line x1={X(half) + 6} y1={Y(half)} x2={xr + 6} y2={Y(half)} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={X(span) + 14} y1={yS} x2={xr + 6} y2={yS} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={xr} y1={yS} x2={xr} y2={Y(half)} />
      <Label x={xr + 9} y={(yS + Y(half)) / 2} anchor="start" fontSize={12}>{rise} ft</Label>

      {/* point P and its unknown height h */}
      <line x1={px} y1={yS} x2={px} y2={py} stroke="var(--ember)" strokeWidth={1.5} strokeDasharray="4,3" />
      <circle cx={px} cy={py} r={3.5} fill="var(--ember)" />
      <Label x={px - 8} y={py - 10} anchor="end" bold color="var(--charcoal)" fontSize={12}>P</Label>
      <Label x={px + 7} y={(yS + py) / 2} anchor="start" italic bold color="var(--ember)" fontSize={13}>h</Label>

      {/* offset and span dimensions below */}
      <line x1={px} y1={yS + 4} x2={px} y2={yS + 36} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={X(0)} y1={yS + 32} x2={px} y2={yS + 32} />
      <Label x={(X(0) + px) / 2} y={yS + 44} fontSize={12}>{offset} ft</Label>
      <DimensionLine x1={X(0)} y1={yS + 60} x2={X(span)} y2={yS + 60} />
      <Label x={X(half)} y={yS + 72} fontSize={12}>{span} ft</Label>
      <line x1={X(0)} y1={yS + 22} x2={X(0)} y2={yS + 64} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={X(span)} y1={yS + 22} x2={X(span)} y2={yS + 64} stroke="var(--gray-400)" strokeWidth={1} />
    </svg>
  );
}

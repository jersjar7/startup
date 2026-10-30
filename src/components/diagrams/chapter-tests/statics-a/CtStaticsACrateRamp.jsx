import React from 'react';
import { basis, along } from '../../geo';
import { ArrowMarkerDefs, AngleArc, Label } from '../../primitives';

/**
 * Crate on a rough ramp pushed by a horizontal force P.
 * Shows: ramp angle, crate weight, the horizontal push, the friction
 * coefficient.
 * Does NOT show: normal force, friction force or components.
 */
export function CtStaticsACrateRamp({ angle = 20, weight = 900, mu = 0.3, unit = 'N' }) {
  const b = basis(angle);
  const sx = 24;
  const sy = 200;
  const len = 300;
  const end = along(sx, sy, b.uphill, len);
  const c = along(sx, sy, b.uphill, 170);
  const hw = 30;
  const bh = 44;
  const bl = along(c.x, c.y, b.downhill, hw);
  const br = along(c.x, c.y, b.uphill, hw);
  const tr = along(br.x, br.y, b.outward, bh);
  const tl = along(bl.x, bl.y, b.outward, bh);
  // Horizontal push applied at the middle of the downhill face
  const face = along(bl.x, bl.y, b.outward, bh / 2);
  const pLen = 70;
  // Just uphill of the crate's lower right corner, on the contact surface
  const muBase = along(br.x, br.y, b.uphill, 8);
  const muAt = along(muBase.x, muBase.y, b.outward, 5);
  const top = Math.floor(Math.min(tl.y, tr.y) - 30);

  return (
    <svg viewBox={`0 0 ${Math.round(end.x + 16)} ${sy + 14 - top}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Crate of weight ${weight} ${unit} on a ${angle} degree ramp pushed horizontally by P`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStACrateP" color="var(--ember)" size={9} />
      <g transform={`translate(0,${-top})`}>

      {/* Ramp body */}
      <polygon points={`${sx},${sy} ${end.x},${end.y} ${end.x},${sy}`} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <AngleArc cx={sx} cy={sy} radius={56} startAngle={0} endAngle={angle} color="var(--charcoal)" />
      <Label x={sx + 74} y={sy - 10} color="var(--charcoal)">{`${angle}°`}</Label>

      {/* Crate */}
      <polygon points={`${bl.x},${bl.y} ${br.x},${br.y} ${tr.x},${tr.y} ${tl.x},${tl.y}`} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Weight, written above the crate */}
      <Label x={(tl.x + tr.x) / 2} y={Math.min(tl.y, tr.y) - 14} color="var(--charcoal)">{`W = ${weight} ${unit}`}</Label>

      {/* Horizontal push */}
      <line x1={face.x - pLen} y1={face.y} x2={face.x - 2} y2={face.y} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStACrateP)" />
      <Label x={face.x - pLen - 6} y={face.y} color="var(--ember)" bold italic anchor="end">P</Label>

      {/* Friction */}
      <text x={muAt.x} y={muAt.y} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={12} textAnchor="start"
        transform={`rotate(${-angle}, ${muAt.x}, ${muAt.y})`}>
        <tspan fontStyle="italic">μ</tspan><tspan fontSize={9} dy={3}>s</tspan><tspan dy={-3}>{` = ${mu.toFixed(2)}`}</tspan>
      </text>
      </g>
    </svg>
  );
}

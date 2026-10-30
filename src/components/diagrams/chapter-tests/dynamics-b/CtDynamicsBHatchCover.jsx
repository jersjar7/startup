import React from 'react';
import { DimensionLine, Label } from '../../primitives';

/**
 * Plan view of a thin circular access hatch hinged along a line tangent to
 * its rim, in the plane of the plate.
 * Shows: diameter, weight, the hinge line.
 * Does NOT show: the mass, the radius used in the parallel-axis step, or I.
 */
export function CtDynamicsBHatchCover({ diameter = 0.8, weight = 1177 }) {
  const r = 140; // px, plate radius
  const cx = 46 + r;
  const cy = 32 + r;
  const hx = cx - r; // hinge line, tangent to the rim
  const top = 30;
  const bot = cy + r + 8;
  const dimY = cy + r + 26;
  const w = weight.toLocaleString('en-US');

  return (
    <svg viewBox={`0 0 ${cx + r + 18} ${dimY + 26}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Plan view of a thin uniform circular hatch ${diameter} m in diameter weighing ${w} N, hinged along a line tangent to its rim`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Plate */}
      <circle cx={cx} cy={cy} r={r} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={cx - 6} y1={cy} x2={cx + 6} y2={cy} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={cx} y1={cy - 6} x2={cx} y2={cy + 6} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={cx} y={cy - 26} color="var(--charcoal)" fontSize={12}>thin uniform plate</Label>
      <Label x={cx} y={cy + 26} color="var(--charcoal)" fontSize={12}>{`W = ${w} N`}</Label>

      {/* Hinge line (dash-dot axis) and hinge knuckles */}
      <line x1={hx} y1={top} x2={hx} y2={bot} stroke="var(--ember)" strokeWidth={1.6} strokeDasharray="12,4,2,4" />
      <rect x={hx - 5} y={cy - 34} width={10} height={20} rx={2} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      <rect x={hx - 5} y={cy + 14} width={10} height={20} rx={2} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      <Label x={hx} y={top - 12} color="var(--ember)" fontSize={12}>hinge line</Label>

      {/* Diameter */}
      <line x1={cx + r} y1={cy + 6} x2={cx + r} y2={dimY + 6} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={hx} y1={bot + 2} x2={hx} y2={dimY + 6} stroke="var(--gray-300)" strokeWidth={1} />
      <DimensionLine x1={hx} y1={dimY} x2={cx + r} y2={dimY} label="" />
      <Label x={cx} y={dimY + 14} color="var(--gray-500)" fontSize={12}>{`${diameter.toFixed(2)} m diameter`}</Label>
    </svg>
  );
}

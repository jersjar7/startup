import React from 'react';
import { Label } from '../../primitives';

/**
 * Trapezoidal cross section with a vertical back face, the x-axis along
 * its base.
 * Shows: top width, bottom width, height, the base axis.
 * Does NOT show: any moment of inertia or the centroid.
 */
export function CtStaticsATrapezoid({ top = 0.3, bottom = 0.6, height = 0.9, unit = 'm' }) {
  const S = 230;
  const W = 360;
  // Labels reach about 74 px left of the back face and 70 px right of the
  // base corner; center that whole span in the width.
  const x0 = Math.round((W - (bottom * S + 144)) / 2 + 74);
  const y0 = 40;
  const h = height * S;
  const yb = y0 + h;
  const xt = x0 + top * S;
  const xb = x0 + bottom * S;
  const gray = 'var(--gray-500)';

  return (
    <svg viewBox={`0 0 ${W} ${yb + 44}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Trapezoid, top ${top} ${unit}, bottom ${bottom} ${unit}, height ${height} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>
      <polygon points={`${x0},${y0} ${xt},${y0} ${xb},${yb} ${x0},${yb}`} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.2} strokeLinejoin="round" />

      {/* Base axis */}
      <line x1={xb} y1={yb} x2={xb + 56} y2={yb} stroke="var(--charcoal)" strokeWidth={1.2} strokeDasharray="6,3" />
      <Label x={xb + 62} y={yb} italic color="var(--charcoal)" anchor="start">x</Label>

      {/* Top width */}
      <line x1={x0} y1={y0 - 16} x2={xt} y2={y0 - 16} stroke={gray} strokeWidth={1} />
      <line x1={x0} y1={y0 - 22} x2={x0} y2={y0 - 4} stroke={gray} strokeWidth={1} />
      <line x1={xt} y1={y0 - 22} x2={xt} y2={y0 - 4} stroke={gray} strokeWidth={1} />
      <line x1={x0 - 4} y1={y0 - 12} x2={x0 + 4} y2={y0 - 20} stroke={gray} strokeWidth={1.4} />
      <line x1={xt - 4} y1={y0 - 12} x2={xt + 4} y2={y0 - 20} stroke={gray} strokeWidth={1.4} />
      <Label x={(x0 + xt) / 2} y={y0 - 27}>{`${top} ${unit}`}</Label>

      {/* Bottom width */}
      <line x1={x0} y1={yb + 6} x2={x0} y2={yb + 26} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={xb} y1={yb + 6} x2={xb} y2={yb + 26} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x0} y1={yb + 20} x2={xb} y2={yb + 20} stroke={gray} strokeWidth={1} />
      <line x1={x0 - 4} y1={yb + 24} x2={x0 + 4} y2={yb + 16} stroke={gray} strokeWidth={1.4} />
      <line x1={xb - 4} y1={yb + 24} x2={xb + 4} y2={yb + 16} stroke={gray} strokeWidth={1.4} />
      <Label x={(x0 + xb) / 2} y={yb + 32}>{`${bottom} ${unit}`}</Label>

      {/* Height */}
      <line x1={x0 - 6} y1={y0} x2={x0 - 34} y2={y0} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x0 - 26} y1={y0} x2={x0 - 26} y2={yb} stroke={gray} strokeWidth={1} />
      <line x1={x0 - 30} y1={yb + 4} x2={x0 - 22} y2={yb - 4} stroke={gray} strokeWidth={1.4} />
      <line x1={x0 - 6} y1={yb} x2={x0 - 34} y2={yb} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x0 - 30} y1={y0 + 4} x2={x0 - 22} y2={y0 - 4} stroke={gray} strokeWidth={1.4} />
      <Label x={x0 - 34} y={(y0 + yb) / 2} anchor="end">{`${height} ${unit}`}</Label>
    </svg>
  );
}

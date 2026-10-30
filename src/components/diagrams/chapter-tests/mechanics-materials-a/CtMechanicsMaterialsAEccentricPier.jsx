import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Plan of a short rectangular pedestal with an eccentric axial load.
export function CtMechanicsMaterialsAEccentricPier({ b = 24, d = 16, e = 4, P = 120 }) {
  const s = 8;
  const x0 = 70;
  const y0 = 46;
  const W = b * s;
  const H = d * s;
  const cx = x0 + W / 2;
  const cy = y0 + H / 2;
  const lx = cx + e * s;

  return (
    <svg viewBox="0 0 360 232" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Plan of a ${b} by ${d} in. pedestal with a ${P} kip load ${e} in. off center along the ${b} in. direction`}
      style={{ width: '100%', height: 'auto' }}>
      <rect x={x0} y={y0} width={W} height={H} fill="var(--gray-400)" fillOpacity={0.12} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={x0 - 10} y1={cy} x2={x0 + W + 10} y2={cy} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="8,3,2,3" />
      <line x1={cx} y1={y0 - 10} x2={cx} y2={y0 + H + 10} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="8,3,2,3" />
      {/* Load */}
      <circle cx={lx} cy={cy} r={6} fill="none" stroke="var(--ember)" strokeWidth={2} />
      <circle cx={lx} cy={cy} r={2} fill="var(--ember)" />
      <Label x={lx + 10} y={cy - 26} bold color="var(--ember)">{`P = ${P} kips`}</Label>
      {/* Eccentricity */}
      <line x1={lx} y1={cy + 8} x2={lx} y2={cy + 30} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={cx} y1={cy + 26} x2={lx} y2={cy + 26} fontSize={12} tickSize={4} />
      <Label x={lx + 10} y={cy + 26} anchor="start" color="var(--gray-500)">{`e = ${e} in.`}</Label>
      {/* Overall */}
      <DimensionLine x1={x0} y1={y0 - 18} x2={x0 + W} y2={y0 - 18} label={`${b} in.`} offset={-11} fontSize={12} />
      <DimensionLine x1={x0 + W + 18} y1={y0} x2={x0 + W + 18} y2={y0 + H} label={`${d} in.`} offset={-22} fontSize={12} />
      <Label x={cx} y={y0 + H + 24} color="var(--gray-500)" bold>PLAN</Label>
    </svg>
  );
}

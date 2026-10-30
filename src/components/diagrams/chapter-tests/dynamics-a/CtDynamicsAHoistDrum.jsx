import React from 'react';
import { Label } from '../../primitives';

/**
 * Hoist drum on a fixed axle with a load hanging from a rope wrapped on it.
 * Shows: drum radius, the drum's mass moment of inertia, the load's mass.
 * Does NOT show: tension, angular or linear acceleration.
 */
export function CtDynamicsAHoistDrum({ radius = 0.25, inertia = 12, mass = 50 }) {
  const cx = 150;
  const cy = 78;
  const R = 52; // drawn radius
  const ropeX = cx + R;
  const loadTop = cy + 112;
  const lw = 52;
  const lh = 40;

  return (
    <svg viewBox={`0 0 350 ${loadTop + lh + 14}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Hoist drum of radius ${radius} m and moment of inertia ${inertia} kg m^2 with a ${mass} kg load on its rope`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Bearing support: frame from the axle up to a hatched ceiling beam */}
      <line x1={cx - 40} y1={12} x2={cx + 40} y2={12} stroke="var(--charcoal)" strokeWidth={2.2} />
      {Array.from({ length: 7 }, (_, i) => (
        <line key={i} x1={cx - 36 + i * 12} y1={12} x2={cx - 44 + i * 12} y2={4}
          stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Drum */}
      <circle cx={cx} cy={cy} r={R} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.2} />
      <circle cx={cx} cy={cy} r={R - 7} fill="none" stroke="var(--gray-300)" strokeWidth={1} />
      {/* Hanger from beam to axle, drawn over the drum */}
      <line x1={cx} y1={12} x2={cx} y2={cy} stroke="var(--charcoal)" strokeWidth={3} />
      <circle cx={cx} cy={cy} r={5} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Radius */}
      <line x1={cx} y1={cy} x2={cx - R * 0.71} y2={cy + R * 0.71} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={cx - R * 0.71 - 8} y={cy + R * 0.71 + 6} color="var(--gray-500)" fontSize={12} anchor="end">{`r = ${radius.toFixed(2)} m`}</Label>

      {/* Drum inertia label */}
      <Label x={cx + R + 22} y={cy - 22} color="var(--charcoal)" fontSize={12} anchor="start">drum</Label>
      <text x={cx + R + 22} y={cy - 2} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={12} textAnchor="start">
        <tspan fontFamily="'Times New Roman', 'KaTeX_Main', serif" fontStyle="italic" fontSize={14}>I</tspan>
        <tspan fontSize={9} dy={3}>O</tspan>
        <tspan dy={-3}>{` = ${inertia} kg·m²`}</tspan>
      </text>
      <Label x={cx + R + 22} y={cy + 10} color="var(--gray-500)" fontSize={11} anchor="start">about the axle</Label>

      {/* Rope and load */}
      <line x1={ropeX} y1={cy} x2={ropeX} y2={loadTop} stroke="var(--charcoal)" strokeWidth={1.6} />
      <rect x={ropeX - lw / 2} y={loadTop} width={lw} height={lh} rx={3}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={ropeX} y={loadTop + lh / 2} color="var(--charcoal)" fontSize={12}>{`${mass} kg`}</Label>
    </svg>
  );
}

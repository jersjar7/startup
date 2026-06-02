import React from 'react';
import { Label } from './primitives';

/**
 * Proctor compaction curve: dry unit weight vs. moisture content.
 * Shows: the curve, its peak (maximum dry density at optimum moisture),
 * dashed lines dropping the peak to both axes, axis titles.
 * Does NOT show: numeric density/moisture values (kept schematic).
 */
export function ProctorCurve() {
  const W = 360, H = 230, pad = 40;
  const x0 = pad, x1 = W - 16;
  const yBase = H - pad, yTop = 24;

  // Schematic inverted parabola peaking at the optimum
  const peakT = 0.5;                 // peak at mid-range of moisture axis
  const peakY = yTop + 18;
  const k = (yBase - peakY) / (0.42 * 0.42);
  const toX = (t) => x0 + t * (x1 - x0);
  const yOf = (t) => peakY + k * Math.pow(t - peakT, 2);

  const pts = [];
  for (let i = 0; i <= 60; i++) {
    const t = 0.12 + (i / 60) * 0.76;     // moisture range
    pts.push(`${toX(t).toFixed(1)},${Math.min(yBase, yOf(t)).toFixed(1)}`);
  }
  const peakX = toX(peakT);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Proctor compaction curve: dry unit weight versus moisture content"
      style={{ width: '100%', height: 'auto' }}>

      {/* Axes */}
      <line x1={x0} y1={yTop} x2={x0} y2={yBase} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={x0} y1={yBase} x2={x1} y2={yBase} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Curve */}
      <polyline points={pts.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Peak drop-lines */}
      <line x1={peakX} y1={peakY} x2={peakX} y2={yBase} stroke="var(--ember)" strokeWidth={1.2} strokeDasharray="4,3" />
      <line x1={x0} y1={peakY} x2={peakX} y2={peakY} stroke="var(--ember)" strokeWidth={1.2} strokeDasharray="4,3" />
      <circle cx={peakX} cy={peakY} r={3.5} fill="var(--ember)" />

      {/* Peak labels */}
      <Label x={x0 + 5} y={peakY - 9} color="var(--ember)" bold fontSize={10} anchor="start">{'γ'}d,max</Label>
      <Label x={peakX} y={yBase + 14} color="var(--ember)" bold fontSize={10}>OMC</Label>

      {/* Axis titles */}
      <Label x={(x0 + x1) / 2} y={H - 8} color="var(--gray-500)" fontSize={10}>Moisture content</Label>
      <Label x={14} y={(yTop + yBase) / 2} color="var(--gray-500)" fontSize={10} rotate={-90}>Dry unit weight</Label>
    </svg>
  );
}

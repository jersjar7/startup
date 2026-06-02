import React from 'react';
import { basis, along } from './geo';
import { AngleArc, Label } from './primitives';

/**
 * Infinite slope: a long slope of constant angle with a failure plane
 * parallel to the surface at depth, and one representative slice.
 * Shows: slope surface, parallel slip plane, a slice element, slope angle β.
 * Does NOT show: the factor of safety or force resolution.
 */
export function InfiniteSlope({ beta = 25 }) {
  const b = basis(beta);
  const start = { x: 55, y: 170 };
  const len = 250;
  const end = along(start.x, start.y, b.uphill, len);

  const depth = 40;                 // perpendicular depth to slip plane
  const sStart = along(start.x, start.y, b.outward, -depth);
  const sEnd = along(end.x, end.y, b.outward, -depth);

  // representative slice (two vertical lines) at mid-slope
  const surf1 = along(start.x, start.y, b.uphill, 120);
  const surf2 = along(start.x, start.y, b.uphill, 160);
  const slip1 = along(sStart.x, sStart.y, b.uphill, 120);
  const slip2 = along(sStart.x, sStart.y, b.uphill, 160);

  return (
    <svg viewBox="0 0 360 230" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Infinite slope at ${beta} degrees with a slip plane parallel to the surface`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Soil slab between surface and slip plane */}
      <polygon points={`${start.x},${start.y} ${end.x},${end.y} ${sEnd.x},${sEnd.y} ${sStart.x},${sStart.y}`}
        fill="rgba(180,160,130,0.16)" stroke="none" />

      {/* Horizontal ground at the base */}
      <line x1={25} y1={start.y} x2={start.x + 30} y2={start.y} stroke="var(--charcoal)" strokeWidth={2} />

      {/* Slope surface */}
      <line x1={start.x} y1={start.y} x2={end.x} y2={end.y} stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Slip plane (parallel, dashed) */}
      <line x1={sStart.x} y1={sStart.y} x2={sEnd.x} y2={sEnd.y}
        stroke="var(--error)" strokeWidth={2} strokeDasharray="6,4" />

      {/* Representative slice */}
      <line x1={surf1.x} y1={surf1.y} x2={slip1.x} y2={slip1.y} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={surf2.x} y1={surf2.y} x2={slip2.x} y2={slip2.y} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="3,3" />

      {/* Angle β at base */}
      <AngleArc cx={start.x} cy={start.y} radius={38} startAngle={0} endAngle={beta} label={`${beta}°`} />

      {/* Labels */}
      <Label x={end.x - 40} y={end.y - 12} color="var(--gray-500)" italic fontSize={10} anchor="end">slope surface</Label>
      <Label x={sEnd.x - 26} y={sEnd.y + 14} color="var(--error)" italic fontSize={10} anchor="end">slip plane</Label>
    </svg>
  );
}

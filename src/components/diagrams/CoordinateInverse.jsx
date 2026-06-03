import React from 'react';
import { Label } from './primitives';

/**
 * Inverse computation between two survey points.
 * Shows: points A and B on an E–N grid, the line between them, and the
 * coordinate differences ΔE and ΔN forming a right triangle with the
 * distance L.
 * Does NOT show: the computed distance or azimuth (those are the answers).
 */
export function CoordinateInverse() {
  const ox = 50, oy = 200;                 // origin (axes corner)
  const A = { x: 95, y: 185 };
  const B = { x: 270, y: 70 };

  return (
    <svg viewBox="0 0 320 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Inverse computation: distance and azimuth between two coordinate points"
      style={{ width: '100%', height: 'auto' }}>

      {/* Axes (E, N) */}
      <line x1={ox} y1={28} x2={ox} y2={oy} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={ox} y1={oy} x2={300} y2={oy} stroke="var(--gray-400)" strokeWidth={1} />
      <Label x={304} y={oy} color="var(--gray-400)" italic fontSize={11} anchor="start">E</Label>
      <Label x={ox} y={20} color="var(--gray-400)" italic fontSize={11}>N</Label>

      {/* Right-triangle legs: ΔE (horizontal), ΔN (vertical) */}
      <line x1={A.x} y1={A.y} x2={B.x} y2={A.y} stroke="var(--gray-500)" strokeWidth={1.2} strokeDasharray="5,3" />
      <line x1={B.x} y1={A.y} x2={B.x} y2={B.y} stroke="var(--gray-500)" strokeWidth={1.2} strokeDasharray="5,3" />
      <Label x={(A.x + B.x) / 2} y={A.y + 14} color="var(--gray-500)" italic fontSize={10}>ΔE</Label>
      <Label x={B.x + 8} y={(A.y + B.y) / 2} color="var(--gray-500)" italic fontSize={10} anchor="start">ΔN</Label>

      {/* Line A–B (distance L) */}
      <line x1={A.x} y1={A.y} x2={B.x} y2={B.y} stroke="var(--charcoal)" strokeWidth={2.5} />
      {(() => {
        const dx = B.x - A.x, dy = B.y - A.y, len = Math.hypot(dx, dy);
        const ang = (Math.atan2(dy, dx) * 180) / Math.PI;
        const lx = (A.x + B.x) / 2 + (dy / len) * 13;       // above the line
        const ly = (A.y + B.y) / 2 + (-dx / len) * 13;
        return <Label x={lx} y={ly} rotate={ang} color="var(--charcoal)" bold fontSize={11}>L</Label>;
      })()}

      {/* Points */}
      <circle cx={A.x} cy={A.y} r={4} fill="var(--charcoal)" />
      <circle cx={B.x} cy={B.y} r={4} fill="var(--charcoal)" />
      <Label x={A.x - 6} y={A.y + 12} color="var(--charcoal)" bold fontSize={11} anchor="end">A</Label>
      <Label x={B.x + 8} y={B.y - 8} color="var(--charcoal)" bold fontSize={11} anchor="start">B</Label>
    </svg>
  );
}

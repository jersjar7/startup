import React from 'react';
import { DimensionLine, Label } from './primitives';

/**
 * Rectangular open-channel cross-section (end-on view).
 *
 * Shows: channel walls, water fill, wetted perimeter highlight,
 *        width b, depth y, water surface line.
 *
 * Does NOT show: computed Q, velocity, or R_H (student solves).
 */
export function RectangularChannel({
  b = 4,
  y = 2,
  unit = 'ft',
}) {
  const W = 360;
  const H = 260;

  // Layout
  const chW = 160;                       // channel width in px
  const chH = (y / b) * chW;            // proportional depth
  const maxChH = 130;
  const drawH = Math.min(chH, maxChH);
  const wallH = drawH + 30;             // walls extend above water

  const cx = W / 2;
  const botY = 190;
  const topY = botY - wallH;
  const waterY = botY - drawH;

  const left = cx - chW / 2;
  const right = cx + chW / 2;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Rectangular channel cross-section, width ${b} ${unit}, depth ${y} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Water fill */}
      <rect x={left} y={waterY} width={chW} height={botY - waterY}
        fill="rgba(160,210,240,0.25)" />

      {/* 2. Channel walls (charcoal) */}
      <path d={`M ${left},${topY} L ${left},${botY} L ${right},${botY} L ${right},${topY}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} />

      {/* 3. Wetted perimeter highlight (info blue, bold) */}
      <path d={`M ${left},${waterY} L ${left},${botY} L ${right},${botY} L ${right},${waterY}`}
        fill="none" stroke="var(--info)" strokeWidth={2.5} />

      {/* 4. Water surface */}
      <line x1={left} y1={waterY} x2={right} y2={waterY}
        stroke="var(--info)" strokeWidth={1.5} />
      {/* Wave ticks */}
      {[0.2, 0.4, 0.6, 0.8].map((f, i) => (
        <path key={i}
          d={`M ${left + chW * f - 4},${waterY} q 4,-3 8,0`}
          fill="none" stroke="var(--info)" strokeWidth={1} />
      ))}

      {/* 5. Dimension: width b (below channel) */}
      <DimensionLine x1={left} y1={botY + 20} x2={right} y2={botY + 20}
        label={`b = ${b} ${unit}`} offset={12} />

      {/* 6. Dimension: depth y (right side) */}
      <DimensionLine x1={right + 20} y1={botY} x2={right + 20} y2={waterY}
        label={`y = ${y} ${unit}`} offset={29} />
    </svg>
  );
}

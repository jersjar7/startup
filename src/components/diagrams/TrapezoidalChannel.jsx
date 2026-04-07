import React from 'react';
import { DimensionLine, Label } from './primitives';

/**
 * Trapezoidal open-channel cross-section (end-on view).
 *
 * Shows: channel walls with side slopes, water fill, wetted perimeter,
 *        bottom width b, depth y, side slope ratio z:1.
 *
 * Does NOT show: computed Q, velocity, or R_H (student solves).
 */
export function TrapezoidalChannel({
  b = 3,
  y = 1.5,
  z = 2,
  unit = 'm',
}) {
  const W = 400;
  const H = 280;

  // Layout — scale so the channel fills nicely
  const botPx = 120;                           // bottom width in px
  const depthPx = Math.min((y / b) * botPx, 110); // proportional depth
  const slopePx = z * depthPx;                 // horizontal run of side slope

  const cx = W / 2;
  const botY = 200;
  const waterY = botY - depthPx;
  const wallTopY = waterY - 20;                // walls extend above water

  // Channel corners (bottom)
  const bLeft = cx - botPx / 2;
  const bRight = cx + botPx / 2;

  // Top of walls (at water level + extension)
  const extraH = botY - wallTopY;
  const tLeft = bLeft - (extraH / depthPx) * slopePx;
  const tRight = bRight + (extraH / depthPx) * slopePx;

  // Water surface corners
  const wLeft = bLeft - slopePx;
  const wRight = bRight + slopePx;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Trapezoidal channel, bottom width ${b} ${unit}, depth ${y} ${unit}, side slopes ${z}:1`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Water fill (trapezoid) */}
      <path d={`M ${wLeft},${waterY} L ${bLeft},${botY} L ${bRight},${botY} L ${wRight},${waterY} Z`}
        fill="rgba(160,210,240,0.25)" />

      {/* 2. Channel walls */}
      <path d={`M ${tLeft},${wallTopY} L ${bLeft},${botY} L ${bRight},${botY} L ${tRight},${wallTopY}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} />

      {/* 3. Wetted perimeter highlight */}
      <path d={`M ${wLeft},${waterY} L ${bLeft},${botY} L ${bRight},${botY} L ${wRight},${waterY}`}
        fill="none" stroke="var(--info)" strokeWidth={2.5} />

      {/* 4. Water surface */}
      <line x1={wLeft} y1={waterY} x2={wRight} y2={waterY}
        stroke="var(--info)" strokeWidth={1.5} />
      {/* Wave ticks */}
      {[0.25, 0.5, 0.75].map((f, i) => {
        const sx = wLeft + (wRight - wLeft) * f;
        return (
          <path key={i}
            d={`M ${sx - 4},${waterY} q 4,-3 8,0`}
            fill="none" stroke="var(--info)" strokeWidth={1} />
        );
      })}

      {/* 5. Dimension: bottom width b */}
      <DimensionLine x1={bLeft} y1={botY + 20} x2={bRight} y2={botY + 20}
        label={`b = ${b} ${unit}`} offset={12} />

      {/* 6. Dimension: depth y (right side, vertical) */}
      <DimensionLine x1={wRight + 24} y1={botY} x2={wRight + 24} y2={waterY}
        label={`y = ${y} ${unit}`} offset={18} />

      {/* 7. Side slope triangle (right side, mirrored to match bank slope) */}
      {(() => {
        const triH = 25;
        const triW = z * triH;
        const triRight = Math.min(wRight - 4, W - 20);
        const triBot = botY - 20;
        return (
          <g>
            <path d={`M ${triRight},${triBot} L ${triRight - triW},${triBot} L ${triRight},${triBot - triH} Z`}
              fill="none" stroke="var(--gray-400)" strokeWidth={1} />
            <Label x={triRight - triW / 2} y={triBot + 12}
              fontSize={8} color="var(--gray-500)">
              {z}
            </Label>
            <Label x={triRight + 8} y={triBot - triH / 2}
              fontSize={8} color="var(--gray-500)">
              1
            </Label>
          </g>
        );
      })()}
    </svg>
  );
}

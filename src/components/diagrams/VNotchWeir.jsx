import React from 'react';
import { AngleArc, DimensionLine, Label } from './primitives';

/**
 * V-notch weir — front view showing the triangular notch and head.
 *
 * Shows: flat plate, 90° V-notch cut (vertex at bottom, opening upward),
 *        water level through the notch, head H from vertex to water surface,
 *        angle marker at vertex.
 *
 * Does NOT show: computed Q (student solves).
 */
export function VNotchWeir({
  H: head = 2.0,
  angle = 90,
  unit = 'ft',
}) {
  const W = 340;
  const HH = 260;

  // Layout
  const plateW = 240;
  const plateH = 160;
  const plateX = (W - plateW) / 2;
  const plateY = 40;
  const plateBotY = plateY + plateH;

  const cx = W / 2;

  // V-notch geometry — vertex at BOTTOM, opens upward
  const halfAngle = (angle / 2) * Math.PI / 180;
  const notchDepth = 80;
  const notchHalfW = notchDepth * Math.tan(halfAngle);
  const vertexY = plateBotY - 20;          // vertex near bottom of plate
  const notchTopY = vertexY - notchDepth;  // top of notch opening

  // Scale head relative to notch depth
  const headPx = Math.min((head / 3) * notchDepth, notchDepth - 5);
  const waterY = vertexY - headPx;         // water surface (above vertex)

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${angle}-degree V-notch weir, head H = ${head} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Plate background */}
      <rect x={plateX} y={plateY} width={plateW} height={plateH}
        fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} rx={2} />

      {/* 2. V-notch cut (cream to show opening) — vertex at bottom */}
      <path d={`M ${cx},${vertexY}
        L ${cx - notchHalfW},${notchTopY}
        L ${cx + notchHalfW},${notchTopY} Z`}
        fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* 3. Water fill in the notch (triangle from vertex up to water surface) */}
      {headPx > 0 && (() => {
        const wHalfW = headPx * Math.tan(halfAngle);
        return (
          <path d={`M ${cx},${vertexY}
            L ${cx - wHalfW},${waterY}
            L ${cx + wHalfW},${waterY} Z`}
            fill="rgba(160,210,240,0.30)" />
        );
      })()}

      {/* 4. Water surface line */}
      {headPx > 0 && (() => {
        const wHalfW = headPx * Math.tan(halfAngle);
        return (
          <line x1={cx - wHalfW} y1={waterY} x2={cx + wHalfW} y2={waterY}
            stroke="var(--info)" strokeWidth={1.5} />
        );
      })()}

      {/* 5. Angle arc at vertex (bottom) */}
      <AngleArc cx={cx} cy={vertexY} radius={20}
        startAngle={90 - angle / 2} endAngle={90 + angle / 2}
        label={`${angle}\u00b0`}
        color="var(--ember)" />

      {/* 6. Head H dimension */}
      <DimensionLine x1={cx + notchHalfW + 20} y1={vertexY} x2={cx + notchHalfW + 20} y2={waterY}
        label={`H = ${head} ${unit}`} offset={20} fontSize={9} />

    </svg>
  );
}

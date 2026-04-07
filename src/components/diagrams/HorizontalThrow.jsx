import React from 'react';
import { ArrowMarkerDefs, ForceArrow, DimensionLine, Label } from './primitives';

/**
 * Ball thrown horizontally from the top of a building/cliff.
 * Shows: building edge, ball on top, horizontal velocity arrow, building height.
 * Does NOT show: landing distance, trajectory path (student solves for these).
 */
export function HorizontalThrow({
  height = 45, velocity = 12,
}) {
  const W = 340;
  const H = 230;

  // Building
  const bldgW = 60;
  const bldgX = 90;
  const topY = 44;
  const groundY = 195;

  // Ball centered on top of building
  const ballX = bldgX + bldgW / 2;
  const ballY = topY - 6;

  // Velocity arrow
  const vArrowLen = 60;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Ball thrown horizontally at ${velocity} m/s from top of ${height} m building`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowV" color="var(--ember)" size={8} />

      {/* Ground */}
      <line x1={20} y1={groundY} x2={W - 20} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Building */}
      <rect x={bldgX} y={topY} width={bldgW} height={groundY - topY}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Ball on top of building */}
      <circle cx={ballX} cy={ballY} r={5}
        fill="var(--charcoal)" />

      {/* Velocity arrow (horizontal, rightward from ball) */}
      <ForceArrow
        x1={ballX + 8} y1={ballY}
        x2={ballX + 8 + vArrowLen} y2={ballY}
        color="var(--ember)" strokeWidth={2.5} markerId="arrowV" />
      <Label x={ballX + 8 + vArrowLen / 2} y={ballY - 14}
        fontSize={11} color="var(--ember)" bold>
        {velocity} m/s
      </Label>

      {/* Height dimension (left side of building) */}
      <DimensionLine
        x1={bldgX - 20} y1={groundY} x2={bldgX - 20} y2={topY}
        label={`${height} m`} offset={-24} fontSize={10} />
    </svg>
  );
}

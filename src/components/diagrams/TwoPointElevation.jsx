import React from 'react';
import { polar, K, rad2deg } from './geo';
import { ArrowMarkerDefs, DashedLine, AngleArc, DimensionLine, Label } from './primitives';

/**
 * Double-triangle tower problem — two observation points measuring angles to tower top.
 * Shows: vertical tower, ground with points A and B, dashed sight lines, angle arcs, 30 m dimension.
 * Does NOT show: tower height or distance from B to base (both unknowns).
 */
export function TwoPointElevation({ dist: separation = 30, angleA = 25, angleB = 42 }) {
  const W = 380;
  const H = 260;
  const groundY = 220;
  const towerBaseX = 300;
  const towerTopY = 50;

  // Points A and B on the ground
  const bx = towerBaseX - 50;   // B is closer to tower
  const ax = bx - 120;          // A is farther (visual spacing)

  // Compute actual visual angles of sight lines (so arcs match the dashed lines)
  const visAngleA = rad2deg(Math.atan2(groundY - towerTopY, towerBaseX - ax));
  const visAngleB = rad2deg(Math.atan2(groundY - towerTopY, towerBaseX - bx));

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Tower with observation angles ${angleA} degrees from A and ${angleB} degrees from B, ${separation} m apart`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowTower" />

      {/* Ground line */}
      <line x1={20} y1={groundY} x2={W - 20} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Tower (thick vertical line) */}
      <line x1={towerBaseX} y1={groundY} x2={towerBaseX} y2={towerTopY}
        stroke="var(--charcoal)" strokeWidth={3} />

      {/* Tower top marker */}
      <circle cx={towerBaseX} cy={towerTopY} r={3} fill="var(--charcoal)" />

      {/* Dashed sight lines */}
      <DashedLine x1={ax} y1={groundY} x2={towerBaseX} y2={towerTopY}
        color="var(--gray-400)" strokeWidth={1.5} dasharray="6,4" />
      <DashedLine x1={bx} y1={groundY} x2={towerBaseX} y2={towerTopY}
        color="var(--gray-400)" strokeWidth={1.5} dasharray="6,4" />

      {/* Angle arcs — sweep to visual angle of sight line, label with given angle */}
      <AngleArc cx={ax} cy={groundY} radius={28}
        startAngle={0} endAngle={visAngleA}
        label={`${angleA}\u00b0`} />
      <AngleArc cx={bx} cy={groundY} radius={24}
        startAngle={0} endAngle={visAngleB}
        label={`${angleB}\u00b0`} />

      {/* Distance dimension A to B */}
      <DimensionLine x1={ax} y1={groundY + 20} x2={bx} y2={groundY + 20}
        label={`${separation} m`} offset={12} />

      {/* Point labels */}
      <Label x={ax} y={groundY - 12} fontSize={12} color="var(--charcoal)" bold>
        A
      </Label>
      <Label x={bx} y={groundY - 12} fontSize={12} color="var(--charcoal)" bold>
        B
      </Label>

      {/* Height label (unknown) */}
      <Label x={towerBaseX + 12} y={(groundY + towerTopY) / 2} fontSize={12}
        color="var(--gray-500)" italic anchor="start">
        h
      </Label>

      {/* Point dots */}
      <circle cx={ax} cy={groundY} r={3} fill="var(--charcoal)" />
      <circle cx={bx} cy={groundY} r={3} fill="var(--charcoal)" />
    </svg>
  );
}

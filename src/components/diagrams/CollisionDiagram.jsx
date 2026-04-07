import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

/**
 * Two objects approaching each other (or same direction) before a collision.
 * Shows: two blocks/circles with masses, velocity arrows with magnitudes.
 * Does NOT show: post-collision velocities, coefficient of restitution (student solves).
 */
export function CollisionDiagram({
  massA = 3, massB = 5,
  velA = 10, velB = -4,
  labelA = '', labelB = '',
}) {
  const W = 380;
  const H = 130;

  const groundY = 95;
  const blockH = 40;
  const blockW = 56;
  const blockY = groundY - blockH;

  // Positions
  const ax = 80;
  const bx = 240;
  const aCx = ax + blockW / 2;
  const bCx = bx + blockW / 2;

  // Arrow config
  const arrowLen = 50;
  const arrowY = blockY - 18;

  // velA > 0 = rightward, velB < 0 = leftward
  const aDir = velA >= 0 ? 1 : -1;
  const bDir = velB >= 0 ? 1 : -1;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Collision: ${massA} kg at ${velA} m/s and ${massB} kg at ${velB} m/s`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowVa" color="var(--ember)" size={7} />
      <ArrowMarkerDefs id="arrowVb" color="var(--charcoal)" size={7} />

      {/* Ground */}
      <line x1={20} y1={groundY} x2={W - 20} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Block A */}
      <rect x={ax} y={blockY} width={blockW} height={blockH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={3} />
      <Label x={aCx} y={blockY + blockH / 2} fontSize={10} color="var(--charcoal)" bold>
        {massA} kg
      </Label>
      {labelA && (
        <Label x={aCx} y={groundY + 14} fontSize={9} color="var(--gray-500)">
          {labelA}
        </Label>
      )}

      {/* Block B */}
      <rect x={bx} y={blockY} width={blockW} height={blockH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={3} />
      <Label x={bCx} y={blockY + blockH / 2} fontSize={10} color="var(--charcoal)" bold>
        {massB} kg
      </Label>
      {labelB && (
        <Label x={bCx} y={groundY + 14} fontSize={9} color="var(--gray-500)">
          {labelB}
        </Label>
      )}

      {/* Velocity arrow A */}
      <ForceArrow
        x1={aCx - aDir * arrowLen / 2} y1={arrowY}
        x2={aCx + aDir * arrowLen / 2} y2={arrowY}
        color="var(--ember)" strokeWidth={2} markerId="arrowVa" />
      <Label x={aCx} y={arrowY - 14} fontSize={10} color="var(--ember)" bold>
        {Math.abs(velA)} m/s
      </Label>

      {/* Velocity arrow B */}
      <ForceArrow
        x1={bCx - bDir * arrowLen / 2} y1={arrowY}
        x2={bCx + bDir * arrowLen / 2} y2={arrowY}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowVb" />
      <Label x={bCx} y={arrowY - 14} fontSize={10} color="var(--charcoal)" bold>
        {Math.abs(velB)} m/s
      </Label>
    </svg>
  );
}

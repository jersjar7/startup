import React from 'react';
import {
  DashedLine, DimensionLine, Label,
} from './primitives';

/**
 * Block at top of a frictionless ramp, dropping height h.
 * Shows: ramp surface, block sitting on ramp, height h, "frictionless" label.
 * Does NOT show: velocity, acceleration, mass value on diagram.
 */
export function RampDrop({ height = 3, mass = 5 }) {
  const groundY = 190;
  const topY = 55;
  const leftX = 80;
  const rightX = 290;

  const dx = rightX - leftX;
  const dy = groundY - topY;
  const rampAngleRad = Math.atan2(dy, dx);
  const rampAngleDeg = rampAngleRad * 180 / Math.PI;

  const blockW = 28;
  const blockH = 22;

  // Contact point: 20% down the ramp from top
  const t = 0.2;
  const contactX = leftX + dx * t;
  const contactY = topY + dy * t;

  // Surface normal pointing ABOVE the ramp in SVG (y-down) coords:
  // Tangent = (cos θ, sin θ). Normal above = (cos(θ+90), sin(θ+90)) = (-sin θ, cos θ).
  // But in SVG y-down, "above" means smaller y, so we negate the y:
  // normal = (-sin θ, -cos θ)  ... no, let's verify:
  //   θ ≈ 32° for this ramp. -sin(32°) ≈ -0.53 (left), -cos(32°) ≈ -0.85 (up in SVG). That's up-left. Correct!
  const normX = Math.sin(rampAngleRad);
  const normY = -Math.cos(rampAngleRad);

  // Block center = contact point offset by half blockH along outward normal
  const blockCX = contactX + normX * (blockH / 2);
  const blockCY = contactY + normY * (blockH / 2);

  return (
    <svg viewBox="0 0 380 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${mass} kg block at top of frictionless ramp, height ${height} m`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Ground line */}
      <line x1={40} y1={groundY} x2={340} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 2. Vertical wall at left */}
      <line x1={leftX} y1={topY} x2={leftX} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 3. Ramp surface */}
      <line x1={leftX} y1={topY} x2={rightX} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 4. Block sitting on ramp surface, rotated to match slope */}
      <rect x={-blockW / 2} y={-blockH / 2} width={blockW} height={blockH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2}
        transform={`translate(${blockCX}, ${blockCY}) rotate(${rampAngleDeg})`} />

      {/* 5. Dashed horizontal from top to dimension line */}
      <DashedLine x1={leftX} y1={topY} x2={rightX + 20} y2={topY}
        color="var(--gray-400)" strokeWidth={1} />

      {/* 6. Height dimension (right side, bottom-to-top for label on right) */}
      <DimensionLine x1={rightX + 20} y1={groundY} x2={rightX + 20} y2={topY}
        label={`h = ${height} m`} offset={24} />

      {/* 7. "Frictionless" label centered on ramp */}
      <Label x={(leftX + rightX) / 2 + 20} y={(topY + groundY) / 2 - 14}
        color="var(--gray-400)" italic fontSize={9}>
        frictionless
      </Label>

    </svg>
  );
}

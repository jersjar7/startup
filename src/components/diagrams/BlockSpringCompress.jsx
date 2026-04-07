import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

/**
 * Block sliding on a smooth surface into a spring against a wall.
 * Shows: block with mass and velocity, spring with stiffness, wall.
 * Does NOT show: compression distance x (that's the answer).
 */
export function BlockSpringCompress({
  mass = 4, velocity = 6, stiffness = 800,
}) {
  const W = 360;
  const H = 150;

  // Ground
  const groundY = 105;

  // Block
  const blockW = 50;
  const blockH = 40;
  const blockX = 60;
  const blockY = groundY - blockH;

  // Wall and spring
  const wallX = W - 40;
  const springStartX = 210;
  const springEndX = wallX - 4;

  // Coil zigzag
  const coilCount = 8;
  const segW = (springEndX - springStartX) / (coilCount * 2);
  const coilY = groundY - blockH / 2;
  const coilAmp = 14;

  const coilPoints = [`${springStartX},${coilY}`];
  for (let i = 0; i < coilCount * 2; i++) {
    const x = springStartX + (i + 1) * segW;
    const y = i % 2 === 0 ? coilY - coilAmp : coilY + coilAmp;
    coilPoints.push(`${x},${y}`);
  }
  coilPoints.push(`${springEndX},${coilY}`);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${mass} kg block at ${velocity} m/s sliding into spring (k = ${stiffness} N/m) against wall`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowV" color="var(--ember)" size={8} />

      {/* Wall */}
      <line x1={wallX} y1={groundY - 56} x2={wallX} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={3} />
      {Array.from({ length: 5 }, (_, i) => {
        const hy = groundY - 52 + i * 12;
        return (
          <line key={i} x1={wallX} y1={hy} x2={wallX + 10} y2={hy + 8}
            stroke="var(--gray-400)" strokeWidth={1.5} />
        );
      })}

      {/* Ground */}
      <line x1={20} y1={groundY} x2={wallX} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Block */}
      <rect x={blockX} y={blockY} width={blockW} height={blockH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={3} />
      <Label x={blockX + blockW / 2} y={blockY + blockH / 2} fontSize={11} color="var(--charcoal)" bold>
        {mass} kg
      </Label>

      {/* Motion lines (left of block) */}
      {[0, 1, 2].map((i) => (
        <line key={i}
          x1={blockX - 10 - i * 6} y1={blockY + 12 + i * 8}
          x2={blockX - 22 - i * 6} y2={blockY + 12 + i * 8}
          stroke="var(--gray-400)" strokeWidth={1.5} />
      ))}

      {/* Velocity arrow (above block, pointing right) */}
      <ForceArrow
        x1={blockX + blockW / 2 - 18} y1={blockY - 16}
        x2={blockX + blockW / 2 + 32} y2={blockY - 16}
        color="var(--ember)" strokeWidth={2} markerId="arrowV" />
      <Label x={blockX + blockW / 2 + 8} y={blockY - 30} fontSize={11} color="var(--ember)" bold>
        {velocity} m/s
      </Label>

      {/* Spring (zigzag coil) */}
      <polyline
        points={coilPoints.join(' ')}
        fill="none"
        stroke="var(--charcoal)"
        strokeWidth={2}
        strokeLinejoin="round"
      />

      {/* k label below spring */}
      <Label x={(springStartX + springEndX) / 2} y={groundY + 16} fontSize={10} color="var(--gray-500)">
        k = {stiffness.toLocaleString()} N/m
      </Label>
    </svg>
  );
}

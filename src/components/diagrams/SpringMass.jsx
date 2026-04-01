import React from 'react';
import {
  Label,
} from './primitives';

/**
 * Spring-mass system: spring attached to wall, mass block at end.
 * Shows: fixed wall, spring zigzag, mass block, k label, m label, equilibrium position.
 * Does NOT show: displacement x, velocity, natural frequency (student calculates).
 */
export function SpringMass({ mass = 50, stiffness = 800 }) {
  const wallX = 50;
  const wallTop = 70;
  const wallBot = 170;
  const springStartX = wallX;
  const springEndX = 200;
  const springY = (wallTop + wallBot) / 2;
  const blockW = 50;
  const blockH = 60;
  const blockX = springEndX;
  const blockY = springY - blockH / 2;

  // Spring zigzag path
  const coils = 8;
  const springLen = springEndX - springStartX;
  const coilWidth = springLen / coils;
  const amplitude = 12;
  let springPath = `M ${springStartX},${springY}`;
  for (let i = 0; i < coils; i++) {
    const x1 = springStartX + i * coilWidth + coilWidth * 0.25;
    const x2 = springStartX + i * coilWidth + coilWidth * 0.75;
    const x3 = springStartX + (i + 1) * coilWidth;
    const yUp = springY - amplitude;
    const yDown = springY + amplitude;
    springPath += ` L ${x1},${i % 2 === 0 ? yUp : yDown}`;
    springPath += ` L ${x2},${i % 2 === 0 ? yDown : yUp}`;
    if (i === coils - 1) {
      springPath += ` L ${x3},${springY}`;
    }
  }

  return (
    <svg viewBox="0 0 360 220" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Spring-mass system: k=${stiffness} N/m, m=${mass} kg`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Fixed wall (hatched) */}
      <line x1={wallX} y1={wallTop} x2={wallX} y2={wallBot}
        stroke="var(--charcoal)" strokeWidth={2.5} />
      {Array.from({ length: 6 }, (_, i) => {
        const hy = wallTop + ((wallBot - wallTop) / 7) * (i + 1);
        return (
          <line key={i}
            x1={wallX} y1={hy}
            x2={wallX - 10} y2={hy + 6}
            stroke="var(--charcoal)" strokeWidth={1.5} />
        );
      })}

      {/* 2. Spring */}
      <path d={springPath} fill="none" stroke="var(--charcoal)" strokeWidth={2} />

      {/* 3. Mass block */}
      <rect x={blockX} y={blockY} width={blockW} height={blockH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 4. Mass label (inside block) */}
      <Label x={blockX + blockW / 2} y={springY} color="var(--charcoal)" bold fontSize={12}>
        m
      </Label>

      {/* 5. Spring stiffness label */}
      <Label x={(springStartX + springEndX) / 2} y={springY - amplitude - 16}
        color="var(--gray-500)" fontSize={11}>
        k = {stiffness} N/m
      </Label>

      {/* 6. Mass value label */}
      <Label x={blockX + blockW / 2} y={blockY + blockH + 18}
        color="var(--gray-500)" fontSize={11}>
        {mass} kg
      </Label>

      {/* 7. Equilibrium indicator */}
      <line x1={blockX + blockW + 10} y1={wallTop + 10} x2={blockX + blockW + 10} y2={wallBot - 10}
        stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <Label x={blockX + blockW + 12} y={wallTop + 4}
        color="var(--gray-400)" italic fontSize={9} anchor="start">
        equilibrium
      </Label>

    </svg>
  );
}

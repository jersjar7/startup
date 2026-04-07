import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

/**
 * Two stacked blocks on a frictionless surface with a horizontal force on the lower block.
 * Shows: both blocks with masses, frictionless floor, applied force F.
 * Does NOT show: μs value, friction arrows, acceleration (student derives these).
 */
export function StackedBlocks({
  massTop = 4, massBot = 12,
}) {
  const W = 320;
  const H = 170;

  // Bottom block
  const botW = 100;
  const botH = 44;
  const botX = 110;
  const botY = 95;

  // Top block (centered on bottom)
  const topW = 64;
  const topH = 36;
  const topX = botX + (botW - topW) / 2;
  const topY = botY - topH;

  // Floor
  const floorY = botY + botH;

  // Force arrow
  const fArrowLen = 65;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${massTop} kg block on ${massBot} kg block, frictionless floor, horizontal force F on lower block`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowF" color="var(--ember)" size={8} />

      {/* Floor */}
      <line x1={30} y1={floorY} x2={W - 30} y2={floorY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Smooth floor indicator (rollers) */}
      {[0, 1, 2, 3].map((i) => {
        const rx = botX + 10 + i * 28;
        return (
          <circle key={i} cx={rx} cy={floorY + 6} r={4}
            fill="none" stroke="var(--gray-400)" strokeWidth={1} />
        );
      })}

      {/* Bottom block */}
      <rect x={botX} y={botY} width={botW} height={botH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={3} />
      <Label x={botX + botW / 2} y={botY + botH / 2} fontSize={11} color="var(--charcoal)" bold>
        {massBot} kg
      </Label>

      {/* Top block */}
      <rect x={topX} y={topY} width={topW} height={topH}
        fill="white" stroke="var(--charcoal)" strokeWidth={2} rx={3} />
      <Label x={topX + topW / 2} y={topY + topH / 2} fontSize={11} color="var(--charcoal)" bold>
        {massTop} kg
      </Label>

      {/* Applied force F (rightward on lower block) */}
      <ForceArrow
        x1={botX - fArrowLen - 6} y1={botY + botH / 2}
        x2={botX - 6} y2={botY + botH / 2}
        color="var(--ember)" strokeWidth={2.5} markerId="arrowF" />
      <Label x={botX - fArrowLen / 2 - 6} y={botY + botH / 2 - 14}
        fontSize={12} color="var(--ember)" bold>
        F
      </Label>
    </svg>
  );
}

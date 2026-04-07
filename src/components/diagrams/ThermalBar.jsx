import React from 'react';
import { DimensionLine, Label } from './primitives';

/**
 * Bar fixed between two rigid walls, optionally with a gap at one end.
 * Shows: bar, rigid walls (hatched), length dimension, gap if present.
 * Does NOT show: stress, temperature values, material properties (in problem text).
 */
export function ThermalBar({
  length = 1.0, lengthUnit = 'm', gap = 0, gapUnit = 'mm',
}) {
  const W = 360;
  const H = 140;

  const wallH = 70;
  const barH = 30;
  const midY = H / 2;
  const barY = midY - barH / 2;

  const leftWallX = 60;
  const rightWallX = 300;
  const barStartX = leftWallX;
  const barEndX = gap > 0 ? rightWallX - 12 : rightWallX;

  const hatchLen = 10;
  const hatchCount = 6;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Bar between rigid walls, length ${length} ${lengthUnit}${gap > 0 ? `, gap ${gap} ${gapUnit}` : ''}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Left wall */}
      <line x1={leftWallX} y1={midY - wallH / 2} x2={leftWallX} y2={midY + wallH / 2}
        stroke="var(--charcoal)" strokeWidth={3} />
      {Array.from({ length: hatchCount }, (_, i) => {
        const hy = midY - wallH / 2 + 6 + i * (wallH - 12) / (hatchCount - 1);
        return (
          <line key={`lh${i}`} x1={leftWallX} y1={hy} x2={leftWallX - hatchLen} y2={hy + 6}
            stroke="var(--gray-400)" strokeWidth={1.5} />
        );
      })}

      {/* Right wall */}
      <line x1={rightWallX} y1={midY - wallH / 2} x2={rightWallX} y2={midY + wallH / 2}
        stroke="var(--charcoal)" strokeWidth={3} />
      {Array.from({ length: hatchCount }, (_, i) => {
        const hy = midY - wallH / 2 + 6 + i * (wallH - 12) / (hatchCount - 1);
        return (
          <line key={`rh${i}`} x1={rightWallX} y1={hy} x2={rightWallX + hatchLen} y2={hy + 6}
            stroke="var(--gray-400)" strokeWidth={1.5} />
        );
      })}

      {/* Bar */}
      <rect x={barStartX} y={barY} width={barEndX - barStartX} height={barH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={2} />

      {/* Gap indicator */}
      {gap > 0 && (
        <g>
          {/* Gap bracket */}
          <line x1={barEndX + 1} y1={midY - 6} x2={rightWallX - 1} y2={midY - 6}
            stroke="var(--ember)" strokeWidth={1.5} />
          <line x1={barEndX + 1} y1={midY - 10} x2={barEndX + 1} y2={midY - 2}
            stroke="var(--ember)" strokeWidth={1.5} />
          <line x1={rightWallX - 1} y1={midY - 10} x2={rightWallX - 1} y2={midY - 2}
            stroke="var(--ember)" strokeWidth={1.5} />
          <Label x={(barEndX + rightWallX) / 2} y={midY - 20}
            fontSize={9} color="var(--ember)" bold>
            {gap} {gapUnit}
          </Label>
        </g>
      )}

      {/* Length dimension below */}
      <DimensionLine
        x1={leftWallX} y1={midY + wallH / 2 + 16}
        x2={gap > 0 ? barEndX : rightWallX} y2={midY + wallH / 2 + 16}
        label={`${length} ${lengthUnit}`} offset={14} fontSize={10} />
    </svg>
  );
}

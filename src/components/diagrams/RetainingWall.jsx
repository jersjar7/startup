import React from 'react';
import { DimensionLine, Label, ArrowMarkerDefs, DistributedLoadArrows } from './primitives';

/**
 * Retaining wall cross-section for lateral earth pressure problems.
 *
 * Shows: wall, backfill soil, height dimension, optional surcharge.
 * Student computes active force on the wall from given soil properties.
 */
export function RetainingWall({
  height = 15,
  surcharge = 0,
  unit = 'ft',
}) {
  const wallW = 28;
  const wallLeft = 100;
  const wallRight = wallLeft + wallW;
  const soilRight = 370;

  const topPad = surcharge > 0 ? 56 : 24;
  const wallScale = Math.min(10, 150 / height);
  const wallH = height * wallScale;

  const wallTop = topPad;
  const wallBot = wallTop + wallH;
  const groundY = wallBot;
  const pressureUnit = unit === 'ft' ? 'psf' : 'kPa';

  const W = 420;
  const HH = groundY + 36;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Retaining wall, H = ${height} ${unit}${surcharge ? `, q = ${surcharge} ${pressureUnit}` : ''}`}
      style={{ width: '100%', height: 'auto' }}>

      {surcharge > 0 && <ArrowMarkerDefs id="arrowSurch" color="var(--charcoal)" size={7} />}

      {/* Backfill soil fill */}
      <rect x={wallRight} y={wallTop} width={soilRight - wallRight} height={wallH}
        fill="rgba(180,160,130,0.12)" />

      {/* Soil surface line */}
      <line x1={wallRight} y1={wallTop} x2={soilRight} y2={wallTop}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Wall */}
      <rect x={wallLeft} y={wallTop} width={wallW} height={wallH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={1} />

      {/* Ground line (full width at base) */}
      <line x1={wallLeft - 30} y1={groundY} x2={soilRight} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Ground hatching — left of wall */}
      {[-24, -12].map(dx => (
        <line key={dx}
          x1={wallLeft + dx} y1={groundY}
          x2={wallLeft + dx - 5} y2={groundY + 7}
          stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}

      {/* Ground hatching — right of wall (under backfill) */}
      {Array.from({ length: 10 }, (_, i) => (
        <line key={i}
          x1={wallRight + 10 + i * 24} y1={groundY}
          x2={wallRight + 4 + i * 24} y2={groundY + 7}
          stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}

      {/* Backfill label */}
      <Label x={(wallRight + soilRight) / 2} y={wallTop + wallH * 0.45}
        fontSize={10} color="var(--gray-400)" italic>
        Backfill
      </Label>

      {/* Height dimension (left of wall) */}
      <DimensionLine
        x1={wallLeft - 16} y1={groundY}
        x2={wallLeft - 16} y2={wallTop}
        label={`H = ${height} ${unit}`}
        offset={-32} fontSize={10} />

      {/* Surcharge distributed arrows */}
      {surcharge > 0 && (
        <g>
          <DistributedLoadArrows
            x={wallRight + 20} y={wallTop - 32}
            width={soilRight - wallRight - 40} arrowLen={28}
            count={4} color="var(--charcoal)" markerId="arrowSurch" />
          <Label x={(wallRight + soilRight) / 2} y={wallTop - 42}
            fontSize={9} color="var(--charcoal)" bold>
            q = {surcharge} {pressureUnit}
          </Label>
        </g>
      )}
    </svg>
  );
}

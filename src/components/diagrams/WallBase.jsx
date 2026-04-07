import React from 'react';
import { DimensionLine, Label, ArrowMarkerDefs, ForceArrow } from './primitives';

/**
 * Retaining wall base cross-section for stability / eccentricity problems.
 *
 * Shows: gravity wall (stem + base slab), base width B, toe/heel labels.
 * When resultantPos is given, shows the resultant arrow at that distance from toe.
 * Student computes eccentricity and/or maximum toe pressure.
 */
export function WallBase({
  baseWidth = 8,
  resultantPos = null,
  unit = 'ft',
}) {
  const W = 420;
  const baseW = 180;
  const stemW = 24;
  const stemH = 105;
  const baseH = 16;
  const topPad = 28;

  const centerX = W / 2;
  const baseLeft = centerX - baseW / 2;
  const baseRight = centerX + baseW / 2;
  const stemRight = baseRight - 12;
  const stemLeft = stemRight - stemW;

  const stemTop = topPad;
  const stemBot = stemTop + stemH;
  const baseTop = stemBot;
  const baseBot = baseTop + baseH;
  const baseScale = baseW / baseWidth;

  const showArrow = resultantPos != null;
  const arrowX = showArrow ? baseLeft + resultantPos * baseScale : null;

  const HH = baseBot + (showArrow ? 65 : 52);

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Gravity retaining wall, base B = ${baseWidth} ${unit}${showArrow ? `, resultant at ${resultantPos} ${unit} from toe` : ''}`}
      style={{ width: '100%', height: 'auto' }}>

      {showArrow && <ArrowMarkerDefs id="arrowResultant" />}

      {/* Backfill soil (behind stem, above base heel side) */}
      <rect x={stemRight} y={stemTop} width={baseRight - stemRight} height={stemH}
        fill="rgba(180,160,130,0.12)" />

      {/* Soil surface on heel side */}
      <line x1={stemRight} y1={stemTop} x2={baseRight + 20} y2={stemTop}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Ground on toe side */}
      <line x1={baseLeft - 30} y1={stemBot} x2={baseLeft} y2={stemBot}
        stroke="var(--charcoal)" strokeWidth={1.5} />
      {[-24, -12].map(dx => (
        <line key={dx}
          x1={baseLeft + dx} y1={stemBot}
          x2={baseLeft + dx - 4} y2={stemBot + 6}
          stroke="var(--charcoal)" strokeWidth={1} />
      ))}

      {/* Stem */}
      <rect x={stemLeft} y={stemTop} width={stemW} height={stemH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={1} />

      {/* Base slab */}
      <rect x={baseLeft} y={baseTop} width={baseW} height={baseH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={1} />

      {/* Ground below base */}
      <line x1={baseLeft - 30} y1={baseBot} x2={baseRight + 30} y2={baseBot}
        stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 10 }, (_, i) => (
        <line key={i}
          x1={baseLeft - 24 + i * 24} y1={baseBot}
          x2={baseLeft - 30 + i * 24} y2={baseBot + 7}
          stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}

      {/* Toe label */}
      <Label x={baseLeft} y={baseBot + 16} fontSize={9}
        color="var(--charcoal)" bold>
        Toe
      </Label>

      {/* Heel label */}
      <Label x={baseRight} y={baseBot + 16} fontSize={9}
        color="var(--charcoal)" bold>
        Heel
      </Label>

      {/* Base width B dimension */}
      <DimensionLine
        x1={baseLeft} y1={baseBot + (showArrow ? 46 : 32)}
        x2={baseRight} y2={baseBot + (showArrow ? 46 : 32)}
        label={`B = ${baseWidth} ${unit}`}
        offset={14} fontSize={10} />

      {/* Resultant arrow + position dimension */}
      {showArrow && (
        <g>
          <ForceArrow
            x1={arrowX} y1={baseTop - 28}
            x2={arrowX} y2={baseTop - 2}
            markerId="arrowResultant" strokeWidth={2} />
          <Label x={arrowX} y={baseTop - 36} fontSize={8}
            color="var(--charcoal)" bold>
            {'\u03A3'}V
          </Label>

          {/* Distance from toe dimension */}
          <DimensionLine
            x1={baseLeft} y1={baseBot + 30}
            x2={arrowX} y2={baseBot + 30}
            label={`${resultantPos} ${unit}`}
            offset={-12} fontSize={9} />
        </g>
      )}
    </svg>
  );
}

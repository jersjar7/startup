import React from 'react';
import {
  ArrowMarkerDefs, FixedSupport, RollerSupport, DistributedLoadArrows,
  DimensionLine, Label,
} from './primitives';

/**
 * Propped cantilever: fixed at one end, roller (prop) at the other,
 * optionally carrying a uniformly distributed load.
 * Shows: fixed support, beam, roller prop, UDL (if w > 0), span.
 * Does NOT show: reactions, fixed-end moment, deflected shape.
 */
export function ProppedCantilever({ length = 8, w = 12, unit = 'kN/m' }) {
  const wallX = 70;
  const by = 115;
  const scale = 35;
  const beamW = length * scale;
  const tipX = wallX + beamW;

  return (
    <svg viewBox="0 0 400 210" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Propped cantilever ${length} m${w > 0 ? `, ${w} ${unit} distributed load` : ''}`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowEmber" color="var(--ember)" size={6} />

      {/* Fixed support (wall) at left */}
      <FixedSupport x={wallX} y={by - 30} height={60} side="left" />

      {/* Beam */}
      <line x1={wallX} y1={by} x2={tipX} y2={by}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Roller prop at right end */}
      <RollerSupport x={tipX} y={by} />

      {/* Distributed load */}
      {w > 0 && (
        <>
          <DistributedLoadArrows x={wallX} y={by - 58} width={beamW}
            arrowLen={24} count={8} markerId="arrowEmber" />
          <Label x={wallX + beamW / 2} y={by - 70} color="var(--ember)" bold fontSize={11}>
            {w} {unit}
          </Label>
        </>
      )}

      {/* Span dimension */}
      <DimensionLine x1={wallX} y1={by + 40} x2={tipX} y2={by + 40}
        label={`${length} m`} offset={14} />
    </svg>
  );
}

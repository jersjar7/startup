import React from 'react';
import {
  ArrowMarkerDefs, ForceArrow, FixedSupport, DimensionLine, Label,
} from './primitives';

/**
 * Cantilever beam with a concentrated load at the free end.
 * Shows: fixed (wall) support, beam, downward point load P at the tip, span.
 * Does NOT show: reactions, deflection, moment diagram.
 */
export function CantileverEndLoad({ length = 3, load = 10, unit = 'kN' }) {
  const wallX = 70;
  const by = 110;
  const scale = 70;
  const beamW = length * scale;
  const tipX = wallX + beamW;

  return (
    <svg viewBox="0 0 380 200" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Cantilever beam ${length} m with ${load} ${unit} point load at the free end`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Fixed support (wall) at left */}
      <FixedSupport x={wallX} y={by - 30} height={60} side="left" />

      {/* Beam */}
      <line x1={wallX} y1={by} x2={tipX} y2={by}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Point load at free end */}
      <ForceArrow x1={tipX} y1={by - 70} x2={tipX} y2={by - 4}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={tipX} y={by - 80} color="var(--charcoal)" bold>
        {load} {unit}
      </Label>

      {/* Span dimension */}
      <DimensionLine x1={wallX} y1={by + 36} x2={tipX} y2={by + 36}
        label={`${length} m`} offset={14} />
    </svg>
  );
}

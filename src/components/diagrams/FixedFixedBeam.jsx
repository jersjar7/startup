import React from 'react';
import {
  ArrowMarkerDefs, FixedSupport, DistributedLoadArrows,
  DimensionLine, Label,
} from './primitives';

/**
 * Beam fixed (built in) at both ends carrying a uniformly distributed load.
 * Shows: fixed supports at both ends, beam, UDL, span.
 * Does NOT show: reactions, fixed-end moments, deflected shape.
 */
export function FixedFixedBeam({ span = 6, w = 10, unit = 'kN/m' }) {
  const lx = 70;
  const by = 115;
  const scale = 40;
  const beamW = span * scale;
  const rx = lx + beamW;

  return (
    <svg viewBox="0 0 400 210" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Fixed-fixed beam ${span} m with ${w} ${unit} distributed load`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowEmber" color="var(--ember)" size={6} />

      {/* Fixed supports (walls) at both ends */}
      <FixedSupport x={lx} y={by - 30} height={60} side="left" />
      <FixedSupport x={rx} y={by - 30} height={60} side="right" />

      {/* Beam */}
      <line x1={lx} y1={by} x2={rx} y2={by}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Distributed load */}
      <DistributedLoadArrows x={lx} y={by - 58} width={beamW}
        arrowLen={24} count={7} markerId="arrowEmber" />
      <Label x={lx + beamW / 2} y={by - 70} color="var(--ember)" bold fontSize={11}>
        {w} {unit}
      </Label>

      {/* Span dimension */}
      <DimensionLine x1={lx} y1={by + 40} x2={rx} y2={by + 40}
        label={`${span} m`} offset={14} />
    </svg>
  );
}

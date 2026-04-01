import React from 'react';
import {
  ArrowMarkerDefs, PinSupport, RollerSupport,
  DistributedLoadArrows, DimensionLine, Label,
} from './primitives';

export function SSBeamUDL({ span = 8, w = 5 }) {
  const lx = 60;
  const by = 120;
  const scale = span <= 6 ? 40 : span <= 8 ? 30 : 24;
  const beamW = span * scale;
  const rx = lx + beamW;

  return (
    <svg viewBox="0 0 380 210" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Simply supported beam, ${span} m span, ${w} kN/m uniform load`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowEmber" color="var(--ember)" size={6} />

      {/* Beam */}
      <line x1={lx} y1={by} x2={rx} y2={by}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Pin at A */}
      <PinSupport x={lx} y={by} />
      <Label x={lx - 18} y={by + 10} bold>A</Label>

      {/* Roller at B */}
      <RollerSupport x={rx} y={by} />
      <Label x={rx + 18} y={by + 10} bold>B</Label>

      {/* Distributed load */}
      <DistributedLoadArrows x={lx} y={by - 60} width={beamW}
        arrowLen={24} count={7} markerId="arrowEmber" />
      <Label x={lx + beamW / 2} y={by - 72} color="var(--ember)" bold fontSize={11}>
        {w} kN/m
      </Label>

      {/* Span dimension */}
      <DimensionLine x1={lx} y1={by + 56} x2={rx} y2={by + 56}
        label={`${span} m`} offset={12} />
    </svg>
  );
}

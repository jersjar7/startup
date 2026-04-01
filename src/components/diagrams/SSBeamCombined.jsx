import React from 'react';
import {
  ArrowMarkerDefs, ForceArrow, PinSupport, RollerSupport,
  DistributedLoadArrows, DimensionLine, Label,
} from './primitives';

export function SSBeamCombined({ span = 6, P = 24, w = 4 }) {
  const lx = 60;
  const by = 130;
  const scale = span <= 6 ? 40 : span <= 8 ? 30 : 24;
  const beamW = span * scale;
  const rx = lx + beamW;
  const midX = lx + beamW / 2;

  return (
    <svg viewBox="0 0 380 230" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Simply supported beam, ${span} m span, ${P} kN midpoint load and ${w} kN/m uniform load`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />
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

      {/* Distributed load (below the point load arrow) */}
      <DistributedLoadArrows x={lx} y={by - 50} width={beamW}
        arrowLen={20} count={7} markerId="arrowEmber" />
      <Label x={lx + beamW / 2 + 50} y={by - 60} color="var(--ember)" bold fontSize={11}>
        {w} kN/m
      </Label>

      {/* Point load at midspan */}
      <ForceArrow x1={midX} y1={by - 100} x2={midX} y2={by - 54}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={midX} y={by - 108} color="var(--charcoal)" bold>
        {P} kN
      </Label>

      {/* Span dimension */}
      <DimensionLine x1={lx} y1={by + 56} x2={rx} y2={by + 56}
        label={`${span} m`} offset={12} />
    </svg>
  );
}

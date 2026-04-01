import React from 'react';
import {
  ArrowMarkerDefs, ForceArrow, PinSupport, RollerSupport,
  DimensionLine, Label,
} from './primitives';

export function SimplySupportedBeam({ span = 8, loadPos = 3, load = 12 }) {
  const lx = 60;
  const by = 120;
  const scale = 30;
  const beamW = span * scale;
  const loadX = lx + loadPos * scale;
  const rx = lx + beamW;

  return (
    <svg viewBox="0 0 380 210" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Simply supported beam, ${span} m span, ${load} kN load at ${loadPos} m`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Beam */}
      <line x1={lx} y1={by} x2={rx} y2={by}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Pin at A */}
      <PinSupport x={lx} y={by} />
      <Label x={lx - 18} y={by + 10} bold>A</Label>

      {/* Roller at B */}
      <RollerSupport x={rx} y={by} />
      <Label x={rx + 18} y={by + 10} bold>B</Label>

      {/* Point load */}
      <ForceArrow x1={loadX} y1={by - 70} x2={loadX} y2={by - 4}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={loadX} y={by - 78} color="var(--charcoal)" bold>
        {load} kN
      </Label>

      {/* Dimensions */}
      <DimensionLine x1={lx} y1={by + 56} x2={loadX} y2={by + 56}
        label={`${loadPos} m`} offset={12} />
      <DimensionLine x1={loadX} y1={by + 56} x2={rx} y2={by + 56}
        label={`${span - loadPos} m`} offset={12} />
    </svg>
  );
}

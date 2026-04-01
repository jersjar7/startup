import React from 'react';
import {
  ArrowMarkerDefs, ForceArrow, PinSupport, RollerSupport,
  CoupleArrow, DimensionLine, Label,
} from './primitives';

export function BeamWithCouple({ span = 10, loadPos = 4, load = 20, couplePos = 7, couple = 10 }) {
  const lx = 50;
  const by = 120;
  const scale = 26;
  const beamW = span * scale;
  const loadX = lx + loadPos * scale;
  const coupleX = lx + couplePos * scale;
  const rx = lx + beamW;

  return (
    <svg viewBox="0 0 380 220" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Beam with ${load} kN load and ${couple} kN·m couple`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />
      <ArrowMarkerDefs id="arrowEmber" color="var(--ember)" size={6} />

      {/* Beam */}
      <line x1={lx} y1={by} x2={rx} y2={by}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Pin at A */}
      <PinSupport x={lx} y={by} />
      <Label x={lx} y={by + 40} bold>A</Label>

      {/* Roller at B */}
      <RollerSupport x={rx} y={by} />
      <Label x={rx} y={by + 40} bold>B</Label>

      {/* Point load */}
      <ForceArrow x1={loadX} y1={by - 70} x2={loadX} y2={by - 4}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={loadX} y={by - 78} color="var(--charcoal)" bold fontSize={11}>
        {load} kN
      </Label>

      {/* Couple (CCW) */}
      <CoupleArrow cx={coupleX} cy={by - 6} radius={18} ccw={true}
        markerId="arrowEmber" label={`${couple} kN\u00b7m`} />

      {/* Dimensions */}
      <DimensionLine x1={lx} y1={by + 56} x2={loadX} y2={by + 56}
        label={`${loadPos} m`} offset={12} />
      <DimensionLine x1={loadX} y1={by + 56} x2={coupleX} y2={by + 56}
        label={`${couplePos - loadPos} m`} offset={12} />
      <DimensionLine x1={coupleX} y1={by + 56} x2={rx} y2={by + 56}
        label={`${span - couplePos} m`} offset={12} />
    </svg>
  );
}

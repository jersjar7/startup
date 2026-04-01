import React from 'react';
import {
  ArrowMarkerDefs, FixedSupport, DistributedLoadArrows,
  DimensionLine, Label,
} from './primitives';

export function CantileverBeam({ length = 4, loadIntensity = 3 }) {
  const wallX = 60;
  const by = 120;
  const scale = 50;
  const beamW = length * scale;
  const tipX = wallX + beamW;

  return (
    <svg viewBox="0 0 380 220" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Cantilever beam, ${length} m, ${loadIntensity} kN/m distributed load`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowEmber" color="var(--ember)" size={6} />

      {/* Fixed support at left */}
      <FixedSupport x={wallX} y={by - 30} height={60} side="left" />

      {/* Beam */}
      <line x1={wallX} y1={by} x2={tipX} y2={by}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Distributed load */}
      <DistributedLoadArrows x={wallX} y={by - 60} width={beamW}
        arrowLen={24} count={7} markerId="arrowEmber" />
      <Label x={wallX + beamW / 2} y={by - 72} color="var(--ember)" bold fontSize={11}>
        {loadIntensity} kN/m
      </Label>

      {/* Dimension */}
      <DimensionLine x1={wallX} y1={by + 36} x2={tipX} y2={by + 36}
        label={`${length} m`} offset={14} />
    </svg>
  );
}

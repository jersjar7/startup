import React from 'react';
import { ArrowMarkerDefs, ForceArrow, PinSupport, DimensionLine, Label } from './primitives';

/**
 * A lever (simple machine) balancing an effort against a load about a pivot.
 * Shows: the lever, the fulcrum, the effort and load forces, and the two
 * moment arms.
 * Does NOT show: the resulting force or mechanical advantage (the answer).
 */
export function LeverMachine() {
  const beamY = 110;
  const left = 55, right = 320;
  const fulcrum = 235;
  const effortX = 70, loadX = 300;

  return (
    <svg viewBox="0 0 370 200" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Lever balancing effort and load about a fulcrum"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Lever beam */}
      <line x1={left} y1={beamY} x2={right} y2={beamY}
        stroke="var(--charcoal)" strokeWidth={4} strokeLinecap="round" />

      {/* Fulcrum (pivot) */}
      <PinSupport x={fulcrum} y={beamY + 2} size={18} />
      <Label x={fulcrum} y={beamY + 40} color="var(--gray-500)" fontSize={10}>fulcrum</Label>

      {/* Effort (down) on the long arm */}
      <ForceArrow x1={effortX} y1={beamY - 56} x2={effortX} y2={beamY - 6}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowMain" />
      <Label x={effortX} y={beamY - 64} color="var(--charcoal)" bold fontSize={11}>effort</Label>

      {/* Load (down) on the short arm */}
      <ForceArrow x1={loadX} y1={beamY - 56} x2={loadX} y2={beamY - 6}
        color="var(--ember)" strokeWidth={2.5} markerId="arrowMain" />
      <Label x={loadX} y={beamY - 64} color="var(--ember)" bold fontSize={11}>load</Label>

      {/* Moment arms */}
      <DimensionLine x1={effortX} y1={beamY + 22} x2={fulcrum} y2={beamY + 22} label="aᵢₙ" offset={12} />
      <DimensionLine x1={fulcrum} y1={beamY + 22} x2={loadX} y2={beamY + 22} label="aₒᵤₜ" offset={12} />
    </svg>
  );
}

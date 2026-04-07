import React from 'react';
import { ArrowMarkerDefs, ForceArrow, DimensionLine, Label, PinSupport, RollerSupport } from './primitives';

/**
 * Simply supported beam with two concentrated point loads at different positions.
 * Shows: beam, pin + roller supports, two downward force arrows with magnitudes, positions.
 * Does NOT show: reactions, moment values (student solves for these).
 */
export function SSBeamTwoLoads({
  span = 8, pos1 = 2, load1 = 20, pos2 = 6, load2 = 40,
}) {
  const W = 400;
  const H = 200;

  const padL = 50;
  const padR = 30;
  const beamY = 110;
  const beamLen = W - padL - padR;
  const scale = beamLen / span;

  const xAt = (pos) => padL + pos * scale;
  const supportSize = 14;
  const arrowLen = 50;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Simply supported beam, span ${span} m, ${load1} kN at ${pos1} m and ${load2} kN at ${pos2} m`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowLoad" color="var(--ember)" size={7} />

      {/* Beam */}
      <line x1={xAt(0)} y1={beamY} x2={xAt(span)} y2={beamY}
        stroke="var(--charcoal)" strokeWidth={3} />

      {/* Pin support (left) */}
      <PinSupport x={xAt(0)} y={beamY} size={supportSize} />

      {/* Roller support (right) */}
      <RollerSupport x={xAt(span)} y={beamY} size={supportSize} />

      {/* Load 1 */}
      <ForceArrow
        x1={xAt(pos1)} y1={beamY - arrowLen - 4}
        x2={xAt(pos1)} y2={beamY - 4}
        color="var(--ember)" strokeWidth={2} markerId="arrowLoad" />
      <Label x={xAt(pos1)} y={beamY - arrowLen - 14}
        fontSize={11} color="var(--ember)" bold>
        {load1} kN
      </Label>

      {/* Load 2 */}
      <ForceArrow
        x1={xAt(pos2)} y1={beamY - arrowLen - 4}
        x2={xAt(pos2)} y2={beamY - 4}
        color="var(--ember)" strokeWidth={2} markerId="arrowLoad" />
      <Label x={xAt(pos2)} y={beamY - arrowLen - 14}
        fontSize={11} color="var(--ember)" bold>
        {load2} kN
      </Label>

      {/* Span dimension */}
      <DimensionLine
        x1={xAt(0)} y1={beamY + 46}
        x2={xAt(span)} y2={beamY + 46}
        label={`${span} m`} offset={14} fontSize={10} />

      {/* Position dimensions */}
      <DimensionLine
        x1={xAt(0)} y1={beamY + 28}
        x2={xAt(pos1)} y2={beamY + 28}
        label={`${pos1} m`} offset={12} fontSize={9} />
      <DimensionLine
        x1={xAt(0)} y1={beamY + 28}
        x2={xAt(pos2)} y2={beamY + 28}
        label={`${pos2} m`} offset={12} fontSize={9} />
    </svg>
  );
}

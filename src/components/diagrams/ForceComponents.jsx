import React from 'react';
import { polar, K } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, DashedLine, AngleArc, Label,
} from './primitives';

/**
 * Force vector decomposition on x/y axes.
 * Shows: axes, force vector at angle, angle arc, dashed projection lines forming right triangle.
 * Different from ForceAtAngle — this one shows the decomposition triangle with Fx/Fy labels.
 * Does NOT show: actual Fx/Fy numeric values.
 */
export function ForceComponents({ force = 12, angle = 40, unit = 'kN' }) {
  const ox = 80;
  const oy = 180;
  const fLen = 140;

  const tip = polar(ox, oy, fLen, angle);
  const fx = tip.x;  // projection onto x-axis (same y as origin)
  const fy = tip.y;  // projection onto y-axis (same x as origin)

  return (
    <svg viewBox="0 0 360 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${force} ${unit} force at ${angle} degrees decomposed into x and y components`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowFC" />
      <ArrowMarkerDefs id="arrowFCAxis" color="var(--gray-400)" />

      {/* x-axis */}
      <ForceArrow x1={ox - 10} y1={oy} x2={ox + fLen + 40} y2={oy}
        color="var(--gray-400)" strokeWidth={1.5} markerId="arrowFCAxis" />
      <Label x={ox + fLen + 48} y={oy} fontSize={12} color="var(--gray-500)" italic anchor="start">
        x
      </Label>

      {/* y-axis */}
      <ForceArrow x1={ox} y1={oy + 10} x2={ox} y2={oy - fLen - 20}
        color="var(--gray-400)" strokeWidth={1.5} markerId="arrowFCAxis" />
      <Label x={ox} y={oy - fLen - 30} fontSize={12} color="var(--gray-500)" italic>
        y
      </Label>

      {/* Dashed projection lines forming right triangle */}
      <DashedLine x1={tip.x} y1={tip.y} x2={fx} y2={oy}
        color="var(--gray-400)" strokeWidth={1.5} dasharray="4,3" />
      <DashedLine x1={tip.x} y1={tip.y} x2={ox} y2={fy}
        color="var(--gray-400)" strokeWidth={1.5} dasharray="4,3" />

      {/* Force vector (bold) */}
      <ForceArrow x1={ox} y1={oy} x2={tip.x} y2={tip.y}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowFC" />

      {/* Force label */}
      <Label x={tip.x + 8} y={tip.y - 10} color="var(--charcoal)" bold fontSize={12} anchor="start">
        {force} {unit}
      </Label>

      {/* Angle arc */}
      <AngleArc cx={ox} cy={oy} radius={K.ARC_RADIUS + 4}
        startAngle={0} endAngle={angle}
        label={`${angle}\u00b0`} />

      {/* Component labels */}
      <Label x={(ox + fx) / 2} y={oy + 16} fontSize={12} color="var(--ember)" italic>
        Fx
      </Label>
      <Label x={ox - 16} y={(oy + fy) / 2} fontSize={12} color="var(--ember)" italic>
        Fy
      </Label>

      {/* Origin dot */}
      <circle cx={ox} cy={oy} r={3} fill="var(--charcoal)" />
    </svg>
  );
}

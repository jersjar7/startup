import React from 'react';
import { polar, K } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, DashedLine, AngleArc, Label,
} from './primitives';

export function ForceAtAngle({ force = 500, angle = 35 }) {
  const ox = 80;
  const oy = 180;
  const fLen = 140;

  const tip = polar(ox, oy, fLen, angle);

  return (
    <svg viewBox="0 0 360 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Force of ${force} N at ${angle} degrees above horizontal`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Anchor point */}
      <circle cx={ox} cy={oy} r={4} fill="var(--charcoal)" />

      {/* Horizontal reference */}
      <DashedLine x1={ox} y1={oy} x2={ox + fLen + 20} y2={oy} />

      {/* Force vector */}
      <ForceArrow x1={ox} y1={oy} x2={tip.x} y2={tip.y}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowMain" />
      <Label x={tip.x + 8} y={tip.y - 10} color="var(--charcoal)" bold>
        {force} N
      </Label>

      {/* Angle arc */}
      <AngleArc cx={ox} cy={oy} radius={K.ARC_RADIUS + 4}
        startAngle={0} endAngle={angle}
        label={`${angle}\u00b0`} />
    </svg>
  );
}

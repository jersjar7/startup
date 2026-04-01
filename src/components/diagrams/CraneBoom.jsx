import React from 'react';
import { polar, K } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, DashedLine, AngleArc, Label,
} from './primitives';


export function CraneBoom({ length = 10, angle = 40, load = 5000 }) {
  const pivotX = 60;
  const pivotY = 220;
  const boomLen = 180; // boom length in px

  // Boom tip via polar (angle from horizontal)
  const tip = polar(pivotX, pivotY, boomLen, angle);


  return (
    <svg viewBox="0 0 360 280" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Crane boom at ${angle} degrees with ${load} N load`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Ground line */}
      <line x1={20} y1={pivotY + 16} x2={pivotX + 60} y2={pivotY + 16}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Pivot base */}
      <rect x={pivotX - 12} y={pivotY} width={24} height={16}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} rx={2} />
      <circle cx={pivotX} cy={pivotY} r={4} fill="var(--charcoal)" />

      {/* Boom line */}
      <line x1={pivotX} y1={pivotY} x2={tip.x} y2={tip.y}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Boom length label */}
      <Label x={(pivotX + tip.x) / 2 - 14} y={(pivotY + tip.y) / 2 - 10}
        color="var(--gray-500)" italic fontSize={11}>
        {length} m
      </Label>

      {/* Horizontal reference */}
      <DashedLine x1={pivotX} y1={pivotY} x2={pivotX + boomLen + 20} y2={pivotY} />

      {/* Angle arc */}
      <AngleArc cx={pivotX} cy={pivotY} radius={36}
        startAngle={0} endAngle={angle}
        label={`${angle}\u00b0`} />

      {/* Load arrow hanging from boom tip (vertical downward) */}
      <ForceArrow x1={tip.x} y1={tip.y + K.ARROW_GAP} x2={tip.x} y2={tip.y + 60}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={tip.x + 8} y={tip.y + 40} color="var(--charcoal)" bold fontSize={11} anchor="start">
        {(load / 1000).toFixed(0)} kN
      </Label>

    </svg>
  );
}

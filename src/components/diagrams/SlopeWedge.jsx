import React from 'react';
import { ArrowMarkerDefs, ForceArrow, AngleArc, Label } from './primitives';

/**
 * Slope failure on a planar slip surface (wedge method).
 * Shows: cut slope, planar slip surface from the toe, the sliding wedge
 * (shaded), its weight W, and the slip-surface angle α.
 * Does NOT show: the factor of safety or the resisting/driving forces.
 */
export function SlopeWedge({ alpha = 25 }) {
  const toe = { x: 95, y: 200 };
  const upperY = 110;                       // upper ground surface level
  const crest = { x: 185, y: upperY };
  const run = (toe.y - upperY) / Math.tan((alpha * Math.PI) / 180);
  const slipEnd = { x: toe.x + run, y: upperY };

  return (
    <svg viewBox="0 0 360 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Slope failing along a planar slip surface at ${alpha} degrees`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Sliding wedge (shaded): toe -> slip surface -> back along upper ground -> down slope face */}
      <polygon points={`${toe.x},${toe.y} ${slipEnd.x},${slipEnd.y} ${crest.x},${crest.y}`}
        fill="rgba(180,160,130,0.18)" stroke="none" />

      {/* Lower ground (in front of toe) */}
      <line x1={20} y1={toe.y} x2={toe.x} y2={toe.y} stroke="var(--charcoal)" strokeWidth={2} />
      {/* Upper ground surface */}
      <line x1={crest.x} y1={upperY} x2={340} y2={upperY} stroke="var(--charcoal)" strokeWidth={2} />
      {/* Slope face (crest down to toe) */}
      <line x1={crest.x} y1={crest.y} x2={toe.x} y2={toe.y} stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Planar slip surface */}
      <line x1={toe.x} y1={toe.y} x2={slipEnd.x} y2={slipEnd.y}
        stroke="var(--error)" strokeWidth={2} strokeDasharray="6,4" />
      {(() => {
        const dx = slipEnd.x - toe.x, dy = slipEnd.y - toe.y;
        const len = Math.hypot(dx, dy);
        const ang = (Math.atan2(dy, dx) * 180) / Math.PI;
        const lx = toe.x + dx * 0.82 + (-dy / len) * 12;   // upper part, below the line, clear of W
        const ly = toe.y + dy * 0.82 + (dx / len) * 12;
        return <Label x={lx} y={ly} rotate={ang} color="var(--error)" italic fontSize={10}>slip surface</Label>;
      })()}

      {/* Weight of the wedge */}
      <ForceArrow x1={(toe.x + slipEnd.x + crest.x) / 3} y1={150} x2={(toe.x + slipEnd.x + crest.x) / 3} y2={188}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowMain" />
      <Label x={(toe.x + slipEnd.x + crest.x) / 3 + 12} y={166} color="var(--charcoal)" bold anchor="start">W</Label>

      {/* Slip angle α at the toe */}
      <AngleArc cx={toe.x} cy={toe.y} radius={36} startAngle={0} endAngle={alpha} label={`${alpha}°`} />
    </svg>
  );
}

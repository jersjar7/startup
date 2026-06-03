import React from 'react';
import { polar } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, AngleArc, Label,
} from './primitives';

/**
 * Free-body of a single truss joint: a horizontal member, a diagonal member
 * at a given angle, and a vertical applied load at the joint.
 * Shows: joint A, members AB (horizontal) and AC (diagonal), load, the angle.
 * Does NOT show: member forces, components, or the solution.
 */
export function TrussJointFBD({ load = 500, angle = 45, unit = 'lb' }) {
  const A = { x: 95, y: 185 };
  const B = { x: 305, y: 185 };          // horizontal member end
  const C = polar(A.x, A.y, 150, angle);  // diagonal member end (up-right)

  return (
    <svg viewBox="0 0 360 270" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Truss joint with a horizontal member, a diagonal at ${angle} degrees, and a ${load} ${unit} downward load`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Members */}
      <line x1={A.x} y1={A.y} x2={B.x} y2={B.y}
        stroke="var(--charcoal)" strokeWidth={2.5} strokeLinecap="round" />
      <line x1={A.x} y1={A.y} x2={C.x} y2={C.y}
        stroke="var(--charcoal)" strokeWidth={2.5} strokeLinecap="round" />

      {/* Member labels */}
      <Label x={(A.x + B.x) / 2} y={A.y + 16} color="var(--gray-500)" italic fontSize={11}>AB</Label>
      {(() => {
        const dx = C.x - A.x, dy = C.y - A.y, len = Math.hypot(dx, dy);
        const ang = (Math.atan2(dy, dx) * 180) / Math.PI;
        const lx = (A.x + C.x) / 2 + (dy / len) * 13;       // above-left of the diagonal
        const ly = (A.y + C.y) / 2 + (-dx / len) * 13;
        return <Label x={lx} y={ly} rotate={ang} color="var(--gray-500)" italic fontSize={11}>AC</Label>;
      })()}

      {/* Angle arc between the two members */}
      <AngleArc cx={A.x} cy={A.y} radius={40} startAngle={0} endAngle={angle} label={`${angle}°`} />

      {/* Applied load (downward into the joint) */}
      <ForceArrow x1={A.x} y1={A.y - 78} x2={A.x} y2={A.y - 6}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={A.x - 10} y={A.y - 86} color="var(--charcoal)" bold anchor="end">
        {load} {unit}
      </Label>

      {/* Joint + joint labels */}
      <circle cx={A.x} cy={A.y} r={4.5} fill="var(--charcoal)" />
      <Label x={A.x - 14} y={A.y + 14} color="var(--charcoal)" bold>A</Label>
      <Label x={B.x + 14} y={B.y} color="var(--charcoal)" bold>B</Label>
      <Label x={C.x + 4} y={C.y - 10} color="var(--charcoal)" bold>C</Label>
    </svg>
  );
}

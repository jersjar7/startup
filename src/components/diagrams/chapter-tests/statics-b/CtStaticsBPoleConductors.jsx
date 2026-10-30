import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';
import { polar, arcPath } from '../../geo';

/**
 * Plan view of a utility pole at a line angle. Conductor 1 pulls due west,
 * conductor 2 pulls at `angle` degrees north of east.
 * Shows: both pulls with magnitudes, the angle from east, a north arrow.
 * Does NOT show: components or the resultant.
 */
export function CtStaticsBPoleConductors({ t1 = 3.5, t2 = 4.2, angle = 40, unit = 'kips' }) {
  const O = { x: 196, y: 150 };
  const L = 118;
  const r0 = 9;
  const tip1 = { x: O.x - L, y: O.y };
  const tip2 = polar(O.x, O.y, L, angle);
  const wire2 = polar(O.x, O.y, L + 34, angle);
  const s2 = polar(O.x, O.y, r0, angle);
  const arcR = 52;
  const lab = polar(O.x, O.y, arcR + 15, angle / 2);
  const gray = 'var(--gray-500)';

  return (
    <svg viewBox="0 0 376 196" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Plan view of a pole: ${t1} ${unit} due west, ${t2} ${unit} at ${angle} degrees north of east`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBPoleArrow" color="var(--ember)" size={9} />
      <ArrowMarkerDefs id="ctStBPoleNorth" color="var(--charcoal)" size={8} />

      {/* Conductors (the wires themselves), thin gray beyond the force arrows */}
      <line x1={O.x} y1={O.y} x2={18} y2={O.y} stroke="var(--gray-400)" strokeWidth={1.2} />
      <line x1={O.x} y1={O.y} x2={wire2.x} y2={wire2.y} stroke="var(--gray-400)" strokeWidth={1.2} />

      {/* Reference line due east */}
      <line x1={O.x + r0} y1={O.y} x2={O.x + 150} y2={O.y} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="5,4" />
      <Label x={O.x + 150} y={O.y + 14} anchor="end">east</Label>

      {/* Angle */}
      <path d={arcPath(O.x, O.y, arcR, 0, angle)} fill="none" stroke={gray} strokeWidth={1.2} />
      <Label x={lab.x} y={lab.y} color="var(--charcoal)">{`${angle}°`}</Label>

      {/* Forces */}
      <line x1={O.x - r0} y1={O.y} x2={tip1.x} y2={tip1.y} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBPoleArrow)" />
      <line x1={s2.x} y1={s2.y} x2={tip2.x} y2={tip2.y} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBPoleArrow)" />
      <Label x={(O.x + tip1.x) / 2 - 6} y={O.y - 14} color="var(--ember)" bold>{`${t1} ${unit}`}</Label>
      <Label x={(O.x + tip1.x) / 2 - 6} y={O.y + 16} color="var(--charcoal)">conductor 1</Label>
      <Label x={tip2.x - 20} y={tip2.y - 4} color="var(--ember)" bold anchor="end">{`${t2} ${unit}`}</Label>
      <Label x={tip2.x - 28} y={tip2.y + 12} color="var(--charcoal)" anchor="end">conductor 2</Label>

      {/* Pole (plan) */}
      <circle cx={O.x} cy={O.y} r={r0} fill="#fff" stroke="var(--charcoal)" strokeWidth={2.4} />
      <Label x={O.x} y={O.y + 24} color="var(--charcoal)">pole</Label>

      {/* North arrow */}
      <line x1={34} y1={66} x2={34} y2={24} stroke="var(--charcoal)" strokeWidth={1.6} markerEnd="url(#ctStBPoleNorth)" />
      <Label x={34} y={12} color="var(--charcoal)" bold>N</Label>
      <Label x={48} y={58} anchor="start">plan view</Label>
    </svg>
  );
}

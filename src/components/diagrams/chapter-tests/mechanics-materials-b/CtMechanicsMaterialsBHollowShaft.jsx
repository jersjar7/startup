import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Cross section of a hollow circular shaft with the applied torque shown
// as a curved arrow around it. Outer and inner diameters dimensioned.
export function CtMechanicsMaterialsBHollowShaft({ od = 3.0, id = 2.0, T = 30, unit = 'kip·in.' }) {
  const cx = 150;
  const cy = 128;
  const ro = 66;
  const ri = ro * id / od;
  const ra = ro + 22;
  // Torque arrow: an arc over the top from lower left to lower right.
  const a1 = (215 * Math.PI) / 180;
  const a2 = (-35 * Math.PI) / 180;
  const p1 = { x: cx + ra * Math.cos(a1), y: cy - ra * Math.sin(a1) };
  const p2 = { x: cx + ra * Math.cos(a2), y: cy - ra * Math.sin(a2) };
  const ring = `M ${cx - ro},${cy} a ${ro},${ro} 0 1,0 ${2 * ro},0 a ${ro},${ro} 0 1,0 ${-2 * ro},0 Z `
    + `M ${cx - ri},${cy} a ${ri},${ri} 0 1,1 ${2 * ri},0 a ${ri},${ri} 0 1,1 ${-2 * ri},0 Z`;
  const dimY = cy + ro + 30;

  return (
    <svg viewBox="0 0 300 262" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Hollow shaft section, outside diameter ${od} in., inside diameter ${id} in., torque ${T} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMmBShaftHead" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>
      <path d={ring} fillRule="evenodd" fill="var(--gray-400)" fillOpacity={0.3} stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={cx} cy={cy} r={2} fill="var(--charcoal)" />

      {/* Torque */}
      <path d={`M ${p1.x},${p1.y} A ${ra},${ra} 0 1,1 ${p2.x},${p2.y}`} fill="none" stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctMmBShaftHead)" />
      <Label x={cx} y={cy - ra - 14} bold color="var(--ember)">{`T = ${T} ${unit}`}</Label>

      {/* Inner diameter, across the hole */}
      <DimensionLine x1={cx - ri} y1={cy} x2={cx + ri} y2={cy} label={`ID = ${id.toFixed(1)} in.`} offset={-13} fontSize={12} />

      {/* Outer diameter, below */}
      <line x1={cx - ro} y1={cy + 6} x2={cx - ro} y2={dimY + 6} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={cx + ro} y1={cy + 6} x2={cx + ro} y2={dimY + 6} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={cx - ro} y1={dimY} x2={cx + ro} y2={dimY} label={`OD = ${od.toFixed(1)} in.`} offset={14} fontSize={12} />
    </svg>
  );
}

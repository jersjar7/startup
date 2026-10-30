import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Closed-end pipe with internal pressure and equal, opposite end torques.
export function CtMechanicsMaterialsAPressurizedPipe({ D = 600, t = 8, p = 1.6, T = 60 }) {
  const x1 = 84;
  const x2 = 316;
  const cy = 112;
  const r = 44;
  const cap = 16;
  const ry = r + 12;
  const rx = 9;
  const xl = x1 - cap - 20;
  const xr = x2 + cap + 20;

  return (
    <svg viewBox="0 0 400 174" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Closed-end pipe, mean diameter ${D} mm, wall ${t} mm, internal pressure ${p} MPa, end torques ${T} kN m`}
      style={{ width: '100%', height: 'auto' }}>
      <g transform="translate(0,-24)">
      <defs>
        <marker id="ctMmAPipeHead" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* Pipe with end caps */}
      <path d={`M ${x1},${cy - r} L ${x2},${cy - r} A ${cap},${r} 0 0 1 ${x2},${cy + r} L ${x1},${cy + r} A ${cap},${r} 0 0 1 ${x1},${cy - r} Z`}
        fill="var(--gray-400)" fillOpacity={0.12} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={xl - 14} y1={cy} x2={xr + 14} y2={cy} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="8,3,2,3" />
      {/* End torques, opposite senses */}
      <path d={`M ${xl},${cy + ry} A ${rx},${ry} 0 0 0 ${xl},${cy - ry}`} fill="none" stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctMmAPipeHead)" />
      <path d={`M ${xr},${cy - ry} A ${rx},${ry} 0 0 1 ${xr},${cy + ry}`} fill="none" stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctMmAPipeHead)" />
      <Label x={xl + 6} y={cy - ry - 14} bold color="var(--ember)">{`T = ${T} kN·m`}</Label>
      <Label x={xr - 6} y={cy - ry - 14} bold color="var(--ember)">{`T = ${T} kN·m`}</Label>
      {/* Pressure */}
      <Label x={(x1 + x2) / 2 + 30} y={cy + 20} bold color="var(--charcoal)">{`p = ${p} MPa (internal)`}</Label>
      {/* Mean diameter */}
      <DimensionLine x1={x1 + 44} y1={cy - r + 3} x2={x1 + 44} y2={cy + r - 3} fontSize={12} tickSize={4} />
      <Label x={x1 + 52} y={cy - 20} anchor="start" color="var(--charcoal)">{`D = ${D} mm (mean)`}</Label>
      {/* Wall thickness */}
      <Label x={(x1 + x2) / 2 + 60} y={cy + r + 28} anchor="start" color="var(--charcoal)">{`wall t = ${t} mm`}</Label>
      <line x1={(x1 + x2) / 2 + 56} y1={cy + r + 24} x2={(x1 + x2) / 2 + 40} y2={cy + r + 3} stroke="var(--gray-500)" strokeWidth={1} />
    </g>
    </svg>
  );
}

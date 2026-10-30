import React from 'react';
import { DimensionLine, FixedSupport, Label } from '../../primitives';

// Solid shaft fixed at A with opposite torques at B and at the free end C.
export function CtMechanicsMaterialsATwistShaft({ lAB = 600, lBC = 400, d = 50, TB = 3.0, TC = 1.2 }) {
  const xA = 50;
  const s = 0.3;
  const xB = xA + lAB * s;
  const xC = xB + lBC * s;
  const cy = 100;
  const half = Math.max(8, (d * s) / 2);
  const ry = 26;
  const rx = 8;

  // front-half elliptical arcs; up = front surface moves up, down = moves down
  const arcUp = (x) => `M ${x},${cy + ry} A ${rx},${ry} 0 0 0 ${x},${cy - ry}`;
  const arcDown = (x) => `M ${x},${cy - ry} A ${rx},${ry} 0 0 1 ${x},${cy + ry}`;

  return (
    <svg viewBox="0 0 420 150" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Shaft ${d} mm diameter fixed at A; torque ${TB} kN m at B and ${TC} kN m in the opposite direction at C`}
      style={{ width: '100%', height: 'auto' }}>
      <g transform="translate(0,-40)">
      <defs>
        <marker id="ctMmATwistHead" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>
      <FixedSupport x={xA} y={cy - 44} height={88} side="left" />
      <rect x={xA} y={cy - half} width={xC - xA} height={2 * half} fill="var(--gray-400)" fillOpacity={0.2} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={xA - 6} y1={cy} x2={xC + 14} y2={cy} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="8,3,2,3" />

      <path d={arcUp(xB)} fill="none" stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctMmATwistHead)" />
      <path d={arcDown(xC)} fill="none" stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctMmATwistHead)" />
      <Label x={xB} y={cy - ry - 14} bold color="var(--ember)">{`${TB.toFixed(1)} kN·m`}</Label>
      <Label x={xC} y={cy - ry - 14} bold color="var(--ember)">{`${TC.toFixed(1)} kN·m`}</Label>

      <Label x={xA + 14} y={cy - 40} bold color="var(--charcoal)">A</Label>
      <Label x={xB - 16} y={cy + 22} bold color="var(--charcoal)">B</Label>
      <Label x={xC + 22} y={cy + 20} bold color="var(--charcoal)">C</Label>
      <Label x={(xA + xB) / 2} y={cy - half - 12} color="var(--charcoal)">{`d = ${d} mm`}</Label>

      <line x1={xB} y1={cy + ry + 4} x2={xB} y2={cy + 66} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={xC} y1={cy + ry + 4} x2={xC} y2={cy + 66} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={xA} y1={cy + 62} x2={xB} y2={cy + 62} label={`${lAB} mm`} offset={13} fontSize={12} />
      <DimensionLine x1={xB} y1={cy + 62} x2={xC} y2={cy + 62} label={`${lBC} mm`} offset={13} fontSize={12} />
    </g>
    </svg>
  );
}

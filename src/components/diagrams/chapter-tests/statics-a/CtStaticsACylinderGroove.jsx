import React from 'react';
import { ArrowMarkerDefs, AngleArc, Label } from '../../primitives';

/**
 * Smooth cylinder resting in a V-groove formed by two inclined faces.
 * Shows: the weight and the two face angles from horizontal.
 * Does NOT show: the contact (normal) forces.
 */
export function CtStaticsACylinderGroove({ leftAngle = 30, rightAngle = 45, weight = 800, unit = 'N' }) {
  const r = 62;
  const vx = 170;
  const vy = 214;
  const d = (a) => (a * Math.PI) / 180;
  // Upward normals of the faces (svg coords)
  const n1 = { x: Math.sin(d(leftAngle)), y: -Math.cos(d(leftAngle)) };
  const n2 = { x: -Math.sin(d(rightAngle)), y: -Math.cos(d(rightAngle)) };
  // Solve n1.t = r, n2.t = r for t = centre - V
  const det = n1.x * n2.y - n1.y * n2.x;
  const tx = (r * n2.y - n1.y * r) / det;
  const ty = (n1.x * r - r * n2.x) / det;
  const c = { x: vx + tx, y: vy + ty };
  const L1 = 170;
  const L2 = 150;
  const lTop = { x: vx - L1 * Math.cos(d(leftAngle)), y: vy - L1 * Math.sin(d(leftAngle)) };
  const rTop = { x: vx + L2 * Math.cos(d(rightAngle)), y: vy - L2 * Math.sin(d(rightAngle)) };
  const minX = Math.floor(lTop.x) - 12;
  const W = Math.ceil(rTop.x) + 12 - minX;
  const minY = Math.floor(Math.min(c.y - r - 26, lTop.y, rTop.y)) - 4;

  return (
    <svg viewBox={`0 0 ${W} ${vy + 14 - minY}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Smooth cylinder of weight ${weight} ${unit} in a groove with faces at ${leftAngle} and ${rightAngle} degrees`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStAGrooveArrow" color="var(--ember)" size={9} />
      <g transform={`translate(${-minX},${-minY})`}>
        {/* Wedges */}
        <polygon points={`${vx},${vy} ${lTop.x},${lTop.y} ${lTop.x},${vy}`} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
        <polygon points={`${vx},${vy} ${rTop.x},${rTop.y} ${rTop.x},${vy}`} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />

        {/* Angles at the groove bottom, measured from horizontal */}
        <AngleArc cx={vx} cy={vy} radius={58} startAngle={180 - leftAngle} endAngle={180} color="var(--charcoal)" />
        <AngleArc cx={vx} cy={vy} radius={44} startAngle={0} endAngle={rightAngle} color="var(--charcoal)" />
        <Label x={vx - 86} y={vy - 14} color="var(--charcoal)">{`${leftAngle}°`}</Label>
        <Label x={vx + 64} y={vy - 22} color="var(--charcoal)">{`${rightAngle}°`}</Label>

        {/* Cylinder */}
        <circle cx={c.x} cy={c.y} r={r} fill="#fff" stroke="var(--charcoal)" strokeWidth={2.2} />
        <circle cx={c.x} cy={c.y} r={2.5} fill="var(--charcoal)" />

        {/* Weight */}
        <line x1={c.x} y1={c.y + 3} x2={c.x} y2={c.y + 40} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStAGrooveArrow)" />
        <Label x={c.x + 7} y={c.y + 22} color="var(--ember)" bold anchor="start">{`${weight} ${unit}`}</Label>
        <Label x={c.x} y={c.y - r - 12} color="var(--charcoal)">smooth</Label>
      </g>
    </svg>
  );
}

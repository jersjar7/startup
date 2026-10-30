import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan view of three observation wells in a confined aquifer, B due east of
 * A and C due north of A, with the measured piezometric (groundwater)
 * elevation written at each well. Drawn to scale.
 * Shows: well positions, distances, heads, north arrow.
 * Does NOT show: the gradient, its direction or contours.
 */
export function CtWaterResourcesAThreeWells({ dAB = 800, dAC = 500, hA = 100.0, hB = 96.0, hC = 98.0 }) {
  const s = 0.32; // px per ft
  const ax = 70;
  const ay = 40 + dAC * s;
  const bx = ax + dAB * s;
  const cy = 40;
  const well = (x, y, name) => (
    <g>
      <circle cx={x} cy={y} r={7} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={x} cy={y} r={2} fill="var(--charcoal)" />
    </g>
  );

  return (
    <svg viewBox={`0 0 ${bx + 64} ${ay + 50}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Wells: A head ${hA} ft; B ${dAB} ft east of A, head ${hB} ft; C ${dAC} ft north of A, head ${hC} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Triangle sides */}
      <line x1={ax} y1={ay} x2={bx} y2={ay} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="5,4" />
      <line x1={ax} y1={ay} x2={ax} y2={cy} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="5,4" />
      <line x1={ax} y1={cy} x2={bx} y2={ay} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="5,4" />
      <polyline points={`${ax + 12},${ay} ${ax + 12},${ay - 12} ${ax},${ay - 12}`} fill="none" stroke="var(--gray-400)" strokeWidth={1.2} />

      {well(ax, ay)}
      {well(bx, ay)}
      {well(ax, cy)}

      {/* Well names and heads */}
      <Label x={ax - 14} y={ay - 2} color="var(--charcoal)" fontSize={13} bold anchor="end">A</Label>
      <Label x={ax - 2} y={ay + 22} color="var(--charcoal)" fontSize={12} anchor="middle">{`El. ${hA.toFixed(1)} ft`}</Label>
      <Label x={bx + 14} y={ay - 2} color="var(--charcoal)" fontSize={13} bold anchor="start">B</Label>
      <Label x={bx} y={ay + 22} color="var(--charcoal)" fontSize={12} anchor="middle">{`El. ${hB.toFixed(1)} ft`}</Label>
      <Label x={ax - 14} y={cy} color="var(--charcoal)" fontSize={13} bold anchor="end">C</Label>
      <Label x={ax + 14} y={cy} color="var(--charcoal)" fontSize={12} anchor="start">{`El. ${hC.toFixed(1)} ft`}</Label>

      {/* Distances */}
      <Label x={(ax + bx) / 2} y={ay - 12} color="var(--gray-500)" fontSize={12}>{`${dAB.toLocaleString('en-US')} ft`}</Label>
      <Label x={ax - 10} y={(ay + cy) / 2} color="var(--gray-500)" fontSize={12} anchor="end">{`${dAC} ft`}</Label>

      {/* North arrow */}
      <g transform={`translate(${bx + 26}, ${cy + 6})`}>
        <polygon points="0,-18 7,6 0,1 -7,6" fill="var(--charcoal)" />
        <Label x={0} y={-28} color="var(--charcoal)" fontSize={12} bold>N</Label>
      </g>
    </svg>
  );
}

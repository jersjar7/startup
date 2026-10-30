import React from 'react';
import { T, Arrow, Dim } from './CtFluidMechanicsBParts';

/**
 * Horizontal venturi meter with a pressure gauge at the inlet and at the
 * throat. Diameters drawn to scale.
 * Does NOT show: the flow rate (student solves).
 */
export function CtFluidMechanicsBVenturi({ d1 = 8, d2 = 6, p1 = 38.0, p2 = 35.5 }) {
  const W = 420;
  const s = 10; // px per in.
  const cy = 128;
  const r1 = (d1 * s) / 2;
  const r2 = (d2 * s) / 2;
  const xs = [14, 112, 162, 206, 330, W - 14];
  const H = cy + r1 + 16;
  const prof = (sg) => `M ${xs[0]},${cy + sg * r1} L ${xs[1]},${cy + sg * r1} L ${xs[2]},${cy + sg * r2} L ${xs[3]},${cy + sg * r2} L ${xs[4]},${cy + sg * r1} L ${xs[5]},${cy + sg * r1}`;
  const fill = `${prof(-1)} L ${xs[5]},${cy + r1} L ${xs[4]},${cy + r1} L ${xs[3]},${cy + r2} L ${xs[2]},${cy + r2} L ${xs[1]},${cy + r1} L ${xs[0]},${cy + r1} Z`;
  const g1 = 64;
  const g2 = (xs[2] + xs[3]) / 2;
  const gy = 30;
  const gauge = (x, yWall, p) => (
    <g>
      <line x1={x} y1={yWall} x2={x} y2={gy + 15} stroke="var(--charcoal)" strokeWidth={3} />
      <circle cx={x} cy={gy} r={15} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={x} y1={gy} x2={x + 7} y2={gy - 9} stroke="var(--charcoal)" strokeWidth={1.6} />
      <circle cx={x} cy={gy} r={1.8} fill="var(--charcoal)" />
      <T x={x + 22} y={gy} anchor="start" color="var(--ember)" bold>{`${p.toFixed(1)} psi`}</T>
    </g>
  );
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Venturi meter, ${d1}-in. inlet and ${d2}-in. throat; gauges read ${p1} psi and ${p2} psi`}
      style={{ width: '100%', height: 'auto' }}>
      <path d={fill} fill="var(--info)" fillOpacity={0.14} />
      <path d={prof(-1)} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <path d={prof(1)} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      {gauge(g1, cy - r1, p1)}
      {gauge(g2, cy - r2, p2)}

      <Dim x1={34} y1={cy - r1} x2={34} y2={cy + r1} label={`${d1} in.`} lx={42} ly={cy - 16} anchor="start" />
      <Dim x1={g2} y1={cy - r2} x2={g2} y2={cy + r2} label={`${d2} in.`} lx={g2 + 7} ly={cy + 14} anchor="start" />
      <Arrow x1={350} y1={cy} x2={396} y2={cy} color="var(--info)" width={2.2} />
      <T x={373} y={cy - 14} color="var(--info)">flow</T>
    </svg>
  );
}

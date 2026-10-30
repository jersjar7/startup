import React from 'react';
import { T, Arrow, Dim, Ext, Leader } from './CtFluidMechanicsBParts';

/**
 * Horizontal nozzle bolted by a flange to the end of a pipe, discharging a
 * free jet. Diameters drawn to scale.
 * Does NOT show: the inlet pressure or the bolt force (student solves).
 */
export function CtFluidMechanicsBNozzle({ d1 = 100, d2 = 40, q = 0.02 }) {
  const W = 460;
  const s = 1.2; // px per mm
  const cy = 96;
  const r1 = (d1 * s) / 2;
  const r2 = (d2 * s) / 2;
  const xf = 170; // flange face
  const xc = 296; // nozzle tip
  const xj = 392; // end of drawn jet
  const H = cy + r1 + 58;
  const fl = 12;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Pipe of ${d1} mm with a flanged nozzle to a ${d2} mm free jet, Q = ${q} cubic meters per second`}
      style={{ width: '100%', height: 'auto' }}>
      {/* water */}
      <path d={`M 14,${cy - r1} L ${xf + fl},${cy - r1} L ${xc - 12},${cy - r2} L ${xc},${cy - r2} L ${xc},${cy + r2} L ${xc - 12},${cy + r2} L ${xf + fl},${cy + r1} L 14,${cy + r1} Z`}
        fill="var(--info)" fillOpacity={0.14} />
      <rect x={xc} y={cy - r2} width={xj - xc} height={2 * r2} fill="var(--info)" fillOpacity={0.3} />
      {/* pipe */}
      <line x1={14} y1={cy - r1} x2={xf - fl} y2={cy - r1} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={14} y1={cy + r1} x2={xf - fl} y2={cy + r1} stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* flanges and bolts */}
      <rect x={xf - fl} y={cy - r1 - 14} width={fl} height={2 * r1 + 28} fill="var(--gray-200)" stroke="var(--charcoal)" strokeWidth={2} />
      <rect x={xf} y={cy - r1 - 14} width={fl} height={2 * r1 + 28} fill="var(--gray-200)" stroke="var(--charcoal)" strokeWidth={2} />
      {[-1, 1].map((k) => (
        <g key={k}>
          <line x1={xf - fl - 6} y1={cy + k * (r1 + 7)} x2={xf + fl + 6} y2={cy + k * (r1 + 7)} stroke="var(--charcoal)" strokeWidth={3} />
          <rect x={xf - fl - 9} y={cy + k * (r1 + 7) - 4} width={4} height={8} fill="var(--charcoal)" />
          <rect x={xf + fl + 5} y={cy + k * (r1 + 7) - 4} width={4} height={8} fill="var(--charcoal)" />
        </g>
      ))}
      {/* nozzle */}
      <path d={`M ${xf + fl},${cy - r1} L ${xc - 12},${cy - r2} L ${xc},${cy - r2}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <path d={`M ${xf + fl},${cy + r1} L ${xc - 12},${cy + r2} L ${xc},${cy + r2}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      <Arrow x1={40} y1={cy + 18} x2={110} y2={cy + 18} color="var(--info)" width={2.2} />
      <T x={75} y={cy + 36} color="var(--info)">{`Q = ${q.toFixed(3)} m³/s`}</T>
      <Dim x1={128} y1={cy - r1} x2={128} y2={cy + r1} label={`${d1} mm`} lx={122} ly={cy - 22} anchor="end" />
      <T x={(xc + xj) / 2} y={cy - r2 - 14} color="var(--gray-500)">free jet</T>

      <Ext x1={xj + 3} y1={cy - r2} x2={xj + 26} y2={cy - r2} />
      <Ext x1={xj + 3} y1={cy + r2} x2={xj + 26} y2={cy + r2} />
      <Dim x1={xj + 18} y1={cy - r2} x2={xj + 18} y2={cy + r2} label={`${d2} mm`} lx={xj + 24} ly={cy + r2 + 14} anchor="start" />

      <T x={xf} y={cy + r1 + 40} color="var(--gray-500)">bolted flange</T>
      <Leader x1={xf} y1={cy + r1 + 32} x2={xf} y2={cy + r1 + 16} />
    </svg>
  );
}

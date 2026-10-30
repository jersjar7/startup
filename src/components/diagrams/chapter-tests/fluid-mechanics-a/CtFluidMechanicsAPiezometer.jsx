import React from 'react';
import { T, Arrow, Dim, Ext, Leader } from './CtFluidMechanicsAParts';

/**
 * Glass piezometer tube tapped into the crown of a water main.
 * Shows: main, small tube, water column with a concave meniscus, the
 * reading measured from the tap centerline, the tube bore.
 * Does NOT show: capillary rise or the corrected head (student solves).
 */
export function CtFluidMechanicsAPiezometer({ reading = 850, bore = 3 }) {
  const W = 380;
  const H = 286;
  const pipeTop = 214;
  const pipeBot = 264;
  const cl = (pipeTop + pipeBot) / 2;
  const colTop = 44; // top of the water column (meniscus edge)
  const tx = 170; // tube centerline
  const r = 4; // tube bore half-width, drawn larger than true scale
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Piezometer tube of ${bore} mm bore on a water main, water ${reading} mm above the tap centerline`}
      style={{ width: '100%', height: 'auto' }}>
      {/* water main */}
      <rect x={24} y={pipeTop} width={332} height={pipeBot - pipeTop} fill="var(--info)" fillOpacity={0.14} />
      <line x1={24} y1={pipeTop} x2={356} y2={pipeTop} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={24} y1={pipeBot} x2={356} y2={pipeBot} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={24} y1={cl} x2={356} y2={cl} stroke="var(--gray-400)" strokeWidth={0.8} strokeDasharray="10,3,2,3" />
      <Arrow x1={40} y1={cl} x2={92} y2={cl} color="var(--info)" width={2} />
      <T x={300} y={pipeBot + 13} color="var(--gray-500)">water main</T>

      {/* water column in the tube, with a concave meniscus */}
      <path d={`M ${tx - r},${pipeTop} L ${tx - r},${colTop} Q ${tx},${colTop + 7} ${tx + r},${colTop} L ${tx + r},${pipeTop} Z`}
        fill="var(--info)" fillOpacity={0.45} />
      {/* tube walls, open at the top */}
      <line x1={tx - r} y1={14} x2={tx - r} y2={pipeTop} stroke="var(--charcoal)" strokeWidth={1.6} />
      <line x1={tx + r} y1={14} x2={tx + r} y2={pipeTop} stroke="var(--charcoal)" strokeWidth={1.6} />

      {/* reading from tap centerline to the water in the tube */}
      <Ext x1={tx + r + 4} y1={colTop} x2={234} y2={colTop} />
      <Dim x1={226} y1={colTop} x2={226} y2={cl} label={`${reading} mm`} lx={234} ly={(colTop + cl) / 2} anchor="start" />

      {/* tube label */}
      <T x={146} y={104} anchor="end" color="var(--gray-500)">glass tube</T>
      <T x={146} y={121} anchor="end" color="var(--gray-500)">{`bore ${bore} mm`}</T>
      <Leader x1={150} y1={112} x2={tx - r - 1} y2={112} />
    </svg>
  );
}

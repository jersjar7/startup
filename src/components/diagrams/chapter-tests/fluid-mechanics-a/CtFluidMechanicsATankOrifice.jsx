import React from 'react';
import { T, Dim, Ext, WaterSym, Ground, Leader } from './CtFluidMechanicsAParts';

/**
 * Open tank draining through a sharp-edged orifice in its side wall.
 * Shows: water surface, head to the orifice center, orifice size, free jet.
 * Does NOT show: the discharge (student solves).
 */
export function CtFluidMechanicsATankOrifice({ head = 4.5, d = 50 }) {
  const W = 400;
  const s = 180 / head; // px per m
  const surf = 40;
  const oy = surf + head * s;
  const bottom = oy + 30;
  const tl = 70;
  const tr = 250;
  const H = bottom + 24;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Open tank, orifice ${d} mm, center ${head} m below the water surface`}
      style={{ width: '100%', height: 'auto' }}>
      {/* water */}
      <rect x={tl} y={surf} width={tr - tl} height={bottom - surf} fill="var(--info)" fillOpacity={0.15} />
      <line x1={tl} y1={surf} x2={tr} y2={surf} stroke="var(--info)" strokeWidth={1.6} />
      <WaterSym x={110} y={surf} />
      {/* tank walls, open top */}
      <path d={`M ${tl},${surf - 26} L ${tl},${bottom} L ${tr},${bottom} L ${tr},${oy + 5}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={tr} y1={oy - 5} x2={tr} y2={surf - 26} stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* free jet */}
      <path d={`M ${tr},${oy} Q ${tr + 62},${oy + 2} ${tr + 104},${bottom + 22}`} fill="none" stroke="var(--info)" strokeWidth={6} strokeLinecap="butt" strokeOpacity={0.7} />
      <Ground x1={tl - 20} x2={W - 16} y={bottom + 22} />
      {/* tank legs */}
      <line x1={tl + 10} y1={bottom} x2={tl + 10} y2={bottom + 22} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={tr - 10} y1={bottom} x2={tr - 10} y2={bottom + 22} stroke="var(--charcoal)" strokeWidth={2} />

      <T x={tr + 30} y={oy - 30} anchor="start">{`orifice, d = ${d} mm`}</T>
      <T x={tr + 30} y={oy - 46} anchor="start">sharp-edged</T>
      <Leader x1={tr + 28} y1={oy - 30} x2={tr + 2} y2={oy - 6} />

      {/* head to orifice center */}
      <Ext x1={tr - 4} y1={oy} x2={196} y2={oy} />
      <Dim x1={204} y1={surf} x2={204} y2={oy} label={`${head} m`} lx={196} ly={(surf + oy) / 2} anchor="end" />
    </svg>
  );
}

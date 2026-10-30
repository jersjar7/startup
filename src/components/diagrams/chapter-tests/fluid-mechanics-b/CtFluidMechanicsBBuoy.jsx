import React from 'react';
import { T, Arrow, Dim, Ext, WaterSym } from './CtFluidMechanicsBParts';

/**
 * Upright cylindrical buoy floating in seawater, held down by its mooring
 * chain. The waterline is a sketch position: the draft is what the
 * student solves, so it is not dimensioned.
 */
export function CtFluidMechanicsBBuoy({ d = 1.2, h = 2.0, mass = 900, chain = 2.0, rho = 1025 }) {
  const W = 420;
  const s = 90; // px per m
  const bw = d * s;
  const bh = h * s;
  const x0 = 160;
  const x1 = x0 + bw;
  const top = 44;
  const bot = top + bh;
  const wl = bot - 0.62 * bh; // sketch waterline
  const cx = (x0 + x1) / 2;
  const H = bot + 90;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Cylindrical buoy ${d} m in diameter and ${h} m tall, mass ${mass} kg, chain pull ${chain} kN, floating in seawater`}
      style={{ width: '100%', height: 'auto' }}>
      {/* sea */}
      <rect x={14} y={wl} width={W - 28} height={H - wl - 10} fill="var(--info)" fillOpacity={0.14} />
      <line x1={14} y1={wl} x2={W - 14} y2={wl} stroke="var(--info)" strokeWidth={1.6} />
      <WaterSym x={W - 60} y={wl} />
      {/* buoy */}
      <rect x={x0} y={top} width={bw} height={bh} rx={6} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={2.5} />
      <T x={cx} y={top + 40}>{`${mass} kg`}</T>
      {/* chain pull */}
      <line x1={cx} y1={bot} x2={cx} y2={bot + 8} stroke="var(--charcoal)" strokeWidth={2} />
      <Arrow x1={cx} y1={bot + 8} x2={cx} y2={bot + 58} color="var(--ember)" width={2.6} size={11} />
      <T x={cx + 12} y={bot + 30} anchor="start" color="var(--ember)" bold>{`chain, ${chain.toFixed(1)} kN`}</T>

      <T x={W - 60} y={wl + 34} color="var(--info)">seawater</T>
      <T x={W - 60} y={wl + 50} color="var(--info)">{`ρ = ${rho.toLocaleString('en-US')} kg/m³`}</T>

      <T x={cx} y={H - 4} color="var(--gray-500)" size={11}>waterline not to scale</T>

      {/* size */}
      <Ext x1={x0} y1={top - 3} x2={x0} y2={top - 24} />
      <Ext x1={x1} y1={top - 3} x2={x1} y2={top - 24} />
      <Dim x1={x0} y1={top - 16} x2={x1} y2={top - 16} label={`${d.toFixed(1)} m`} lx={x1 + 10} ly={top - 16} anchor="start" />
      <Ext x1={x0 - 3} y1={top} x2={x0 - 34} y2={top} />
      <Ext x1={x0 - 3} y1={bot} x2={x0 - 34} y2={bot} />
      <Dim x1={x0 - 26} y1={top} x2={x0 - 26} y2={bot} label={`${h.toFixed(1)} m`} lx={x0 - 32} ly={top + 0.25 * bh} anchor="end" />
    </svg>
  );
}

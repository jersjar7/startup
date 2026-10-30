import React from 'react';
import { T, Dim, Ext, WaterSym } from './CtFluidMechanicsBParts';

/**
 * Closed tank: air over a layer of oil floating on water, with a pressure
 * gauge at the bottom.
 * Shows: layer depths, oil SG, bottom gauge reading.
 * Does NOT show: the air pressure (student solves).
 */
export function CtFluidMechanicsBTank({ oil = 1.5, water = 2.0, sg = 0.85, gauge = 45.0 }) {
  const W = 400;
  const s = 50; // px per m
  const tl = 90;
  const tr = 270;
  const top = 22;
  const oilTop = top + 42;
  const iface = oilTop + oil * s;
  const bot = iface + water * s;
  const H = bot + 22;
  const gy = bot - 8;
  const cx = (tl + tr) / 2;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Closed tank with air over ${oil} m of oil of SG ${sg} over ${water} m of water; bottom gauge reads ${gauge} kPa`}
      style={{ width: '100%', height: 'auto' }}>
      {/* liquids */}
      <rect x={tl} y={oilTop} width={tr - tl} height={iface - oilTop} fill="var(--gray-400)" fillOpacity={0.3} />
      <rect x={tl} y={iface} width={tr - tl} height={bot - iface} fill="var(--info)" fillOpacity={0.16} />
      <line x1={tl} y1={oilTop} x2={tr} y2={oilTop} stroke="var(--gray-500)" strokeWidth={1.4} />
      <WaterSym x={tl + 30} y={oilTop} color="var(--gray-500)" />
      <line x1={tl} y1={iface} x2={tr} y2={iface} stroke="var(--info)" strokeWidth={1.4} />
      {/* closed tank */}
      <rect x={tl} y={top} width={tr - tl} height={bot - top} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      <T x={cx} y={(top + oilTop) / 2}>air</T>
      <T x={cx + 14} y={(oilTop + iface) / 2}>{`oil, SG = ${sg.toFixed(2)}`}</T>
      <T x={cx} y={(iface + bot) / 2}>water</T>

      {/* depths */}
      <Ext x1={tl - 3} y1={oilTop} x2={tl - 30} y2={oilTop} />
      <Ext x1={tl - 3} y1={iface} x2={tl - 30} y2={iface} />
      <Ext x1={tl - 3} y1={bot} x2={tl - 30} y2={bot} />
      <Dim x1={tl - 22} y1={oilTop} x2={tl - 22} y2={iface} label={`${oil.toFixed(1)} m`} lx={tl - 30} ly={(oilTop + iface) / 2} anchor="end" />
      <Dim x1={tl - 22} y1={iface} x2={tl - 22} y2={bot} label={`${water.toFixed(1)} m`} lx={tl - 30} ly={(iface + bot) / 2} anchor="end" />

      {/* gauge at the bottom */}
      <line x1={tr + 1} y1={gy} x2={tr + 30} y2={gy} stroke="var(--charcoal)" strokeWidth={3} />
      <circle cx={tr + 44} cy={gy} r={14} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={tr + 44} y1={gy} x2={tr + 51} y2={gy - 8} stroke="var(--charcoal)" strokeWidth={1.6} />
      <circle cx={tr + 44} cy={gy} r={1.8} fill="var(--charcoal)" />
      <T x={tr + 44} y={gy - 30} anchor="middle" color="var(--ember)" bold>{`${gauge.toFixed(1)} kPa`}</T>
      <T x={tr + 44} y={gy - 46} anchor="middle" color="var(--gray-500)">gauge</T>
    </svg>
  );
}

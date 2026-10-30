import React from 'react';
import { T, Arrow, Dim, Ext, WaterSym } from './CtFluidMechanicsAParts';

/**
 * Solid timber work float, side view, with a centered load.
 * The block is drawn to the length : depth ratio of the props. The draft is
 * marked d and drawn at a fixed generic level, so it cannot be read off.
 */
export function CtFluidMechanicsAFloat({ length = 10, width = 6, depth = 1.5, load = 600 }) {
  const W = 440;
  const s = 270 / length; // px per ft
  const bx = 80;
  const bw = length * s;
  const bh = depth * s;
  const top = 96;
  const bot = top + bh;
  const surf = bot - 0.6 * bh;
  const wBot = bot + 46;
  const cx = bx + bw / 2;
  const H = wBot + 8;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Timber float ${length} ft long, ${width} ft wide, ${depth} ft deep, carrying ${load} lb`}
      style={{ width: '100%', height: 'auto' }}>
      {/* water */}
      <rect x={14} y={surf} width={W - 28} height={wBot - surf} fill="var(--info)" fillOpacity={0.13} />
      <line x1={14} y1={surf} x2={W - 14} y2={surf} stroke="var(--info)" strokeWidth={1.6} />
      <WaterSym x={405} y={surf} />

      {/* timber block */}
      <rect x={bx} y={top} width={bw} height={bh} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={1} />
      {[0.22, 0.5, 0.78].map((f) => (
        <line key={f} x1={bx + 8} y1={top + bh * f} x2={bx + bw - 8} y2={top + bh * f}
          stroke="var(--gray-400)" strokeWidth={0.7} />
      ))}
      <T x={bx + bw} y={top - 12} anchor="end" color="var(--gray-500)">{`timber float, ${width} ft wide`}</T>

      {/* load */}
      <Arrow x1={cx} y1={30} x2={cx} y2={top - 2} color="var(--ember)" width={2.2} />
      <T x={cx + 8} y={42} anchor="start" color="var(--ember)" bold>{`${load.toLocaleString('en-US')} lb`}</T>

      {/* block depth, left */}
      <Ext x1={bx - 4} y1={top} x2={bx - 24} y2={top} />
      <Ext x1={bx - 4} y1={bot} x2={bx - 24} y2={bot} />
      <Dim x1={bx - 18} y1={top} x2={bx - 18} y2={bot} label={`${depth} ft`} lx={bx - 18} ly={top - 14} />

      {/* draft, right */}
      <Ext x1={bx + bw + 4} y1={bot} x2={bx + bw + 30} y2={bot} />
      <Dim x1={bx + bw + 22} y1={surf} x2={bx + bw + 22} y2={bot} label="d" lx={bx + bw + 32} ly={(surf + bot) / 2} anchor="start" />

      {/* length, below */}
      <Ext x1={bx} y1={bot + 4} x2={bx} y2={bot + 28} />
      <Ext x1={bx + bw} y1={bot + 4} x2={bx + bw} y2={bot + 28} />
      <Dim x1={bx} y1={bot + 22} x2={bx + bw} y2={bot + 22} label={`${length} ft`} lx={cx} ly={bot + 36} />
    </svg>
  );
}

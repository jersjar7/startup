import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan of a chlorine contact clearwell showing how it is baffled: a
 * perforated baffle across the inlet end, serpentine baffle walls that turn
 * the flow back and forth through three passes, and an outlet weir at the
 * end of the last pass.
 * Shows: the baffling arrangement and flow path.
 * Does NOT show: the baffling factor, t10 or CT.
 */
export function CtWaterResourcesAClearwell() {
  const x0 = 26;
  const y0 = 34;
  const W = 290;
  const H = 156;
  const xr = x0 + W;
  const lane = H / 3;
  const w1 = y0 + lane; // wall between pass 1 and pass 2 (attached left, opening at right)
  const w2 = y0 + 2 * lane; // wall between pass 2 and pass 3 (attached right, opening at left)
  const gap = 40;
  const baffleX = x0 + 30;
  const weirX = xr - 26;
  const c1 = y0 + lane / 2;
  const c2 = y0 + 1.5 * lane;
  const c3 = y0 + 2.5 * lane;
  const pieces = 5;
  const seg = lane / pieces;

  return (
    <svg viewBox={`0 0 410 ${y0 + H + 36}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Clearwell plan with a perforated inlet baffle, serpentine baffle walls and an outlet weir"
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctWraAClearArrow" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L8,4 L0,8 Z" fill="var(--info)" />
        </marker>
      </defs>
      {/* Water */}
      <rect x={x0} y={y0} width={W} height={H} fill="var(--info)" fillOpacity={0.12} />

      {/* Flow path: through the inlet baffle, three passes, over the weir */}
      <polyline points={`${x0 + 8},${c1} ${xr - gap / 2},${c1} ${xr - gap / 2},${c2} ${x0 + gap / 2},${c2} ${x0 + gap / 2},${c3} ${weirX - 8},${c3}`}
        fill="none" stroke="var(--info)" strokeWidth={1.5} strokeDasharray="5,4" markerEnd="url(#ctWraAClearArrow)" />

      {/* Tank walls */}
      <rect x={x0} y={y0} width={W} height={H} fill="none" stroke="var(--charcoal)" strokeWidth={3} />
      {/* Serpentine baffle walls */}
      <line x1={x0} y1={w1} x2={xr - gap} y2={w1} stroke="var(--charcoal)" strokeWidth={3} />
      <line x1={x0 + gap} y1={w2} x2={xr} y2={w2} stroke="var(--charcoal)" strokeWidth={3} />

      {/* Inlet pipe into pass 1 and the perforated inlet baffle across pass 1 */}
      <line x1={x0 - 18} y1={c1} x2={x0} y2={c1} stroke="var(--charcoal)" strokeWidth={6} />
      {Array.from({ length: pieces }, (_, i) => (
        <line key={i} x1={baffleX} y1={y0 + i * seg + 2} x2={baffleX} y2={y0 + (i + 1) * seg - 4} stroke="var(--charcoal)" strokeWidth={3} />
      ))}

      {/* Outlet weir across the end of pass 3, outlet pipe beyond it */}
      <line x1={weirX} y1={w2} x2={weirX} y2={y0 + H} stroke="var(--charcoal)" strokeWidth={3} />
      <line x1={xr} y1={c3} x2={xr + 18} y2={c3} stroke="var(--charcoal)" strokeWidth={6} />

      {/* Labels with short leaders, all outside the tank */}
      <line x1={baffleX} y1={y0 - 2} x2={baffleX + 12} y2={y0 - 14} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={baffleX + 16} y={y0 - 20} color="var(--charcoal)" fontSize={12} anchor="start">perforated inlet baffle</Label>
      <line x1={xr + 2} y1={w2} x2={xr + 22} y2={w2 - 22} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={xr + 26} y={w2 - 40} color="var(--charcoal)" fontSize={12} anchor="start">serpentine</Label>
      <Label x={xr + 26} y={w2 - 25} color="var(--charcoal)" fontSize={12} anchor="start">baffle walls</Label>
      <line x1={weirX} y1={y0 + H + 2} x2={weirX - 12} y2={y0 + H + 14} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={weirX - 16} y={y0 + H + 20} color="var(--charcoal)" fontSize={12} anchor="end">outlet weir</Label>
      <Label x={x0 - 16} y={c1 - 14} color="var(--gray-500)" fontSize={11} anchor="start">in</Label>
      <Label x={xr + 4} y={c3 + 16} color="var(--gray-500)" fontSize={11} anchor="start">out</Label>
    </svg>
  );
}

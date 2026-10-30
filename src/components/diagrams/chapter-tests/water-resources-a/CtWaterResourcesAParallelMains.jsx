import React from 'react';
import { Label } from '../../primitives';

/**
 * Two water mains in parallel between junctions A and B, with the pipe data
 * written beside each pipe. Path lengths are drawn in proportion.
 * Shows: total flow in and out, each pipe's diameter, length and
 * Hazen-Williams C.
 * Does NOT show: the flow in either pipe or the head loss.
 */
export function CtWaterResourcesAParallelMains({ Q = 4.0, p1 = { d: 12, L: 2000, C: 130 }, p2 = { d: 8, L: 3000, C: 100 } }) {
  const ax = 70;
  const bx = 330;
  const yTop = 50;
  const straight = bx - ax; // drawn length of pipe 1
  const extra = (straight * (p2.L / p1.L) - straight) / 2; // pipe 2 dips down so its path is longer
  const yLow = yTop + extra;
  const fmt = (n) => n.toLocaleString('en-US');

  return (
    <svg viewBox={`0 0 400 ${yLow + 36}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Two parallel mains from A to B carrying ${Q} cfs in total`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctWraAParallelArrow" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L8,4 L0,8 Z" fill="var(--info)" />
        </marker>
      </defs>

      {/* Pipe 1: straight */}
      <line x1={ax} y1={yTop} x2={bx} y2={yTop} stroke="var(--charcoal)" strokeWidth={5} />
      {/* Pipe 2: longer path below */}
      <polyline points={`${ax},${yTop} ${ax},${yLow} ${bx},${yLow} ${bx},${yTop}`} fill="none" stroke="var(--charcoal)" strokeWidth={3.4} strokeLinejoin="round" />

      {/* Flow in and out */}
      <line x1={14} y1={yTop} x2={ax - 10} y2={yTop} stroke="var(--info)" strokeWidth={2} markerEnd="url(#ctWraAParallelArrow)" />
      <line x1={bx + 10} y1={yTop} x2={388} y2={yTop} stroke="var(--info)" strokeWidth={2} markerEnd="url(#ctWraAParallelArrow)" />
      <Label x={34} y={yTop - 16} color="var(--info)" fontSize={12} bold>{`${Q.toFixed(1)} cfs`}</Label>
      <Label x={366} y={yTop - 16} color="var(--info)" fontSize={12} bold>{`${Q.toFixed(1)} cfs`}</Label>

      {/* Junctions */}
      <circle cx={ax} cy={yTop} r={6} fill="var(--charcoal)" />
      <circle cx={bx} cy={yTop} r={6} fill="var(--charcoal)" />
      <Label x={ax + 4} y={yTop - 20} color="var(--charcoal)" fontSize={13} bold anchor="start">A</Label>
      <Label x={bx - 4} y={yTop - 20} color="var(--charcoal)" fontSize={13} bold anchor="end">B</Label>

      {/* Pipe data */}
      <Label x={(ax + bx) / 2} y={yTop - 30} color="var(--charcoal)" fontSize={12} bold>Pipe 1</Label>
      <Label x={(ax + bx) / 2} y={yTop - 14} color="var(--charcoal)" fontSize={12}>{`${p1.d} in. · ${fmt(p1.L)} ft · C = ${p1.C}`}</Label>
      <Label x={(ax + bx) / 2} y={yLow - 30} color="var(--charcoal)" fontSize={12} bold>Pipe 2</Label>
      <Label x={(ax + bx) / 2} y={yLow - 14} color="var(--charcoal)" fontSize={12}>{`${p2.d} in. · ${fmt(p2.L)} ft · C = ${p2.C}`}</Label>
      <Label x={(ax + bx) / 2} y={yLow + 22} color="var(--gray-500)" fontSize={11}>pipe lengths are along each pipe</Label>
    </svg>
  );
}

import React from 'react';
import { Arrowhead, T, Dim, Ext, INK, LOAD, DIM } from './CtStructuralBParts';

/**
 * Plan of the end of a flat-bar brace bolted to a gusset plate: two lines of
 * bolts along the bar, with end distance, pitch, edge distance and gage.
 * Drawn to scale (inches).
 */
export function CtStructuralBBlockShear({ width = 6, nPerLine = 3, end = 1.5, pitch = 3, edge = 1.5, gage = 3, boltDia = 0.75, plate = 'PL 1/2 × 6' }) {
  const s = 21;
  const x0 = 104; // bar end
  const y0 = 60; // bar top edge
  const yB = y0 + width * s;
  const lastX = x0 + (end + (nPerLine - 1) * pitch) * s;
  const gussetR = lastX + 1.6 * s;
  const barR = gussetR + 3.6 * s;
  const mk = 'ctStrBBlockArrow';
  const rows = [y0 + edge * s, y0 + (edge + gage) * s];
  const cols = Array.from({ length: nPerLine }, (_, i) => x0 + (end + i * pitch) * s);
  const r = (boltDia / 2) * s;
  const dimY = y0 - 22;
  const vDimX = x0 - 36;
  const W = barR + 62;
  const H = yB + 42;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Flat bar ${plate} with ${2 * nPerLine} bolts in two lines bolted to a gusset plate`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={9} /></defs>

      {/* gusset behind the bar */}
      <rect x={x0 - 92} y={y0 - 46} width={gussetR - (x0 - 92)} height={width * s + 62} fill="var(--gray-100)" stroke={INK} strokeWidth={1.4} />
      <T x={x0 - 88} y={yB + 30} anchor="start" size={11} color={DIM}>gusset</T>
      {/* bar */}
      <rect x={x0} y={y0} width={barR - x0} height={width * s} fill="#fff" stroke={INK} strokeWidth={2} />
      {rows.map((y) => cols.map((x) => (
        <g key={`${x}-${y}`}>
          <circle cx={x} cy={y} r={r} fill="#fff" stroke={INK} strokeWidth={1.6} />
          <line x1={x - r * 0.6} y1={y} x2={x + r * 0.6} y2={y} stroke={INK} strokeWidth={1} />
          <line x1={x} y1={y - r * 0.6} x2={x} y2={y + r * 0.6} stroke={INK} strokeWidth={1} />
        </g>
      )))}
      <T x={(gussetR + barR) / 2} y={y0 + width * s * 0.5} size={11.5} bold>{plate}</T>

      <line x1={barR + 4} y1={(y0 + yB) / 2} x2={barR + 50} y2={(y0 + yB) / 2} stroke={LOAD} strokeWidth={2.6} markerEnd={`url(#${mk})`} />
      <T x={barR + 26} y={(y0 + yB) / 2 - 14} color={LOAD} bold>P</T>

      {/* end distance and pitch, along the top */}
      {[x0, ...cols].map((x, i) => <Ext key={i} x1={x} y1={y0 - 4} x2={x} y2={dimY - 5} />)}
      <Dim x1={x0} y1={dimY} x2={cols[0]} y2={dimY} label={`${end} in.`} side="above" />
      {cols.slice(1).map((x, i) => (
        <Dim key={i} x1={cols[i]} y1={dimY} x2={x} y2={dimY} label={`${pitch} in.`} side="above" />
      ))}

      {/* edge distances and gage, at the left */}
      {[y0, rows[0], rows[1], yB].map((y, i) => (
        <Ext key={i} x1={x0 - 4} y1={y} x2={vDimX - 5} y2={y} />
      ))}
      <Dim x1={vDimX} y1={y0} x2={vDimX} y2={rows[0]} label={`${edge} in.`} side="left" />
      <Dim x1={vDimX} y1={rows[0]} x2={vDimX} y2={rows[1]} label={`${gage} in.`} side="left" />
      <Dim x1={vDimX} y1={rows[1]} x2={vDimX} y2={yB} label={`${edge} in.`} side="left" />

      <line x1={cols[1] + r * 0.7} y1={rows[1] + r * 0.7} x2={cols[1] + 26} y2={yB + 24} stroke={DIM} strokeWidth={1} />
      <T x={cols[1] + 30} y={yB + 28} anchor="start" size={11} color={DIM}>{`${boltDia === 0.75 ? '3/4' : boltDia}-in. bolts`}</T>
    </svg>
  );
}

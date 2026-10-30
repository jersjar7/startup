import React from 'react';
import { T, Pin, Roller, Dim, Ext, INK } from './CtStructuralBParts';

/**
 * Parallel-chord truss with verticals at every panel point. `diagonals`
 * lists, per panel, which diagonals exist: 'up' (from the lower-left joint
 * to the upper-right), 'down' (upper-left to lower-right), 'x' (both) or
 * '' (none). Pin at L0, roller at the right end. Drawn to scale.
 */
export function CtStructuralBTrussPanels({ panelFt = 12, heightFt = 9, diagonals = ['x', '', 'down'] }) {
  const n = diagonals.length;
  const s = 300 / (n * panelFt);
  const ox = 44;
  const ty = 30;
  const by = ty + heightFt * s;
  const X = (i) => ox + i * panelFt * s;
  const xR = X(n);
  const dimY = by + 50;
  const hDimX = xR + 48;
  const W = hDimX + 44;
  const H = dimY + 22;

  const lines = [];
  for (let i = 0; i < n; i++) {
    lines.push([X(i), by, X(i + 1), by], [X(i), ty, X(i + 1), ty]);
    const d = diagonals[i];
    if (d === 'up' || d === 'x') lines.push([X(i), by, X(i + 1), ty]);
    if (d === 'down' || d === 'x') lines.push([X(i), ty, X(i + 1), by]);
  }
  for (let i = 0; i <= n; i++) lines.push([X(i), ty, X(i), by]);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Truss with ${n} panels of ${panelFt} ft, height ${heightFt} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {lines.map(([x1, y1, x2, y2], i) => (
        <line key={i} x1={x1} y1={y1} x2={x2} y2={y2} stroke={INK} strokeWidth={2} strokeLinecap="round" />
      ))}
      {Array.from({ length: n + 1 }, (_, i) => (
        <g key={i}>
          <circle cx={X(i)} cy={ty} r={2.8} fill={INK} />
          <circle cx={X(i)} cy={by} r={2.8} fill={INK} />
          <T x={X(i)} y={ty - 13} size={11.5} bold>{`U${i}`}</T>
        </g>
      ))}
      {Array.from({ length: n - 1 }, (_, i) => (
        <T key={i} x={X(i + 1)} y={by + 15} size={11.5} bold>{`L${i + 1}`}</T>
      ))}
      <T x={X(0) - 12} y={by + 2} anchor="end" size={11.5} bold>L0</T>
      <T x={xR + 12} y={by + 2} anchor="start" size={11.5} bold>{`L${n}`}</T>

      <Pin x={X(0)} y={by + 1} />
      <Roller x={xR} y={by + 1} />

      <Ext x1={X(0)} y1={by + 30} x2={X(0)} y2={dimY + 5} />
      <Ext x1={xR} y1={by + 32} x2={xR} y2={dimY + 5} />
      <Dim x1={X(0)} y1={dimY} x2={xR} y2={dimY} label={`${n} panels at ${panelFt} ft = ${n * panelFt} ft`} />

      <Ext x1={xR + 6} y1={ty} x2={hDimX + 5} y2={ty} />
      <Ext x1={xR + 36} y1={by} x2={hDimX + 5} y2={by} />
      <Dim x1={hDimX} y1={ty} x2={hDimX} y2={by} label={`${heightFt} ft`} side="right" />
    </svg>
  );
}

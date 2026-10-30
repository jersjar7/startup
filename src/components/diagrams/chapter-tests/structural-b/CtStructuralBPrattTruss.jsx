import React from 'react';
import { Arrowhead, T, Pin, Roller, Dim, Ext, INK, LOAD } from './CtStructuralBParts';

/**
 * Pratt truss with inclined end posts: bottom joints L0..Ln, top joints
 * U1..U(n-1), verticals at every interior panel point, diagonals sloping
 * down toward midspan. Equal loads hang from the interior bottom joints.
 * Pin at L0, roller at Ln. Drawn to scale.
 */
export function CtStructuralBPrattTruss({ panels = 6, panelFt = 12, heightFt = 9, load = 15 }) {
  const span = panels * panelFt;
  const s = 360 / span;
  const ox = 34;
  const ty = 30;
  const by = ty + heightFt * s;
  const X = (i) => ox + i * panelFt * s;
  const xR = X(panels);
  const half = panels / 2;
  const mk = 'ctStrBPrattArrow';
  const arrowLen = 30;
  const loadLabelY = by + arrowLen + 14;
  const dimY = loadLabelY + 26;
  const hDimX = xR + 30;
  const W = hDimX + 44;
  const H = dimY + 22;

  const members = [];
  for (let i = 0; i < panels; i++) members.push([X(i), by, X(i + 1), by]);
  for (let i = 1; i < panels - 1; i++) members.push([X(i), ty, X(i + 1), ty]);
  for (let i = 1; i < panels; i++) members.push([X(i), ty, X(i), by]);
  members.push([X(0), by, X(1), ty]);
  members.push([X(panels - 1), ty, X(panels), by]);
  for (let i = 1; i < panels - 1; i++) {
    if (i < half) members.push([X(i), ty, X(i + 1), by]);
    else members.push([X(i + 1), ty, X(i), by]);
  }

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Pratt truss, ${panels} panels at ${panelFt} ft, height ${heightFt} ft, ${load} kips at each interior bottom joint`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={7} /></defs>

      {members.map(([x1, y1, x2, y2], i) => (
        <line key={i} x1={x1} y1={y1} x2={x2} y2={y2} stroke={INK} strokeWidth={2} strokeLinecap="round" />
      ))}
      {Array.from({ length: panels + 1 }, (_, i) => <circle key={`l${i}`} cx={X(i)} cy={by} r={2.6} fill={INK} />)}
      {Array.from({ length: panels - 1 }, (_, i) => <circle key={`u${i}`} cx={X(i + 1)} cy={ty} r={2.6} fill={INK} />)}

      <Pin x={X(0)} y={by + 1} />
      <Roller x={xR} y={by + 1} />

      {/* loads at the interior bottom joints */}
      {Array.from({ length: panels - 1 }, (_, i) => (
        <g key={`p${i}`}>
          <line x1={X(i + 1)} y1={by + 4} x2={X(i + 1)} y2={by + arrowLen} stroke={LOAD} strokeWidth={1.8} markerEnd={`url(#${mk})`} />
          <T x={X(i + 1)} y={loadLabelY} size={11} color={LOAD} bold>{`${load} kips`}</T>
        </g>
      ))}

      {/* joint labels */}
      {Array.from({ length: panels - 1 }, (_, i) => (
        <T key={`ul${i}`} x={X(i + 1)} y={ty - 12} size={11.5} bold>{`U${i + 1}`}</T>
      ))}
      <T x={X(0) - 8} y={by - 10} anchor="end" size={11.5} bold>L0</T>
      <T x={xR + 8} y={by - 10} anchor="start" size={11.5} bold>{`L${panels}`}</T>
      {Array.from({ length: panels - 1 }, (_, i) => (
        <T key={`ll${i}`} x={X(i + 1) + 5} y={by + 12} anchor="start" size={11.5} bold>{`L${i + 1}`}</T>
      ))}

      {/* span */}
      <Ext x1={X(0)} y1={by + 30} x2={X(0)} y2={dimY + 5} />
      <Ext x1={xR} y1={by + 30} x2={xR} y2={dimY + 5} />
      <Dim x1={X(0)} y1={dimY} x2={xR} y2={dimY} label={`${panels} panels at ${panelFt} ft = ${span} ft`} />

      {/* height */}
      <Ext x1={X(panels - 1) + 6} y1={ty} x2={hDimX + 5} y2={ty} />
      <Ext x1={xR + 16} y1={by} x2={hDimX + 5} y2={by} />
      <Dim x1={hDimX} y1={ty} x2={hDimX} y2={by} label={`${heightFt} ft`} side="right" />
    </svg>
  );
}

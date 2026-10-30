import React from 'react';
import { T, Dim, Ext, Ground, INK, DIM } from './CtStructuralBParts';

/**
 * One column shown in its two buckling planes: pinned top and bottom in
 * both; in the weak-axis view, lateral braces at the given heights.
 */
export function CtStructuralBBracedColumn({ heightFt = 30, bracesFt = [10, 20], shape = 'W12×58' }) {
  const s = 6.4;
  const topY = 60;
  const baseY = topY + heightFt * s;
  const xL = 110;
  const xRc = 270;
  const W = 380;
  const H = baseY + 34;
  const yAt = (ft) => baseY - ft * s;
  const marks = [0, ...bracesFt, heightFt];

  const pinBase = (x) => (
    <g>
      <polygon points={`${x},${baseY} ${x - 8},${baseY + 14} ${x + 8},${baseY + 14}`} fill="none" stroke={INK} strokeWidth={1.8} strokeLinejoin="round" />
      <Ground x1={x - 14} x2={x + 14} y={baseY + 14} />
    </g>
  );
  const pinTop = (x) => (
    <g>
      <polygon points={`${x},${topY} ${x - 8},${topY - 14} ${x + 8},${topY - 14}`} fill="none" stroke={INK} strokeWidth={1.8} strokeLinejoin="round" />
      <line x1={x - 14} y1={topY - 14} x2={x + 14} y2={topY - 14} stroke={INK} strokeWidth={1.5} />
      {Array.from({ length: 4 }, (_, i) => (
        <line key={i} x1={x - 12 + i * 7} y1={topY - 14} x2={x - 7 + i * 7} y2={topY - 20} stroke={INK} strokeWidth={1} />
      ))}
    </g>
  );

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`${shape} column ${heightFt} ft tall, pinned at both ends, weak-axis braces at ${bracesFt.join(' and ')} ft`}
      style={{ width: '100%', height: 'auto' }}>
      <T x={xL} y={14} size={11.5} color={DIM}>Buckling about x-x</T>
      <T x={xRc} y={14} size={11.5} color={DIM}>Buckling about y-y</T>

      {/* x-x view */}
      <line x1={xL} y1={topY} x2={xL} y2={baseY} stroke={INK} strokeWidth={4} />
      {pinTop(xL)}
      {pinBase(xL)}
      <Ext x1={xL - 12} y1={topY} x2={xL - 50} y2={topY} />
      <Ext x1={xL - 16} y1={baseY} x2={xL - 50} y2={baseY} />
      <Dim x1={xL - 44} y1={topY} x2={xL - 44} y2={baseY} label={`${heightFt} ft`} side="left" />

      {/* y-y view */}
      <line x1={xRc} y1={topY} x2={xRc} y2={baseY} stroke={INK} strokeWidth={4} />
      {pinTop(xRc)}
      {pinBase(xRc)}
      {bracesFt.map((ft, i) => (
        <g key={i}>
          <line x1={xRc} y1={yAt(ft)} x2={xRc - 34} y2={yAt(ft)} stroke={INK} strokeWidth={1.8} />
          <line x1={xRc - 34} y1={yAt(ft) - 9} x2={xRc - 34} y2={yAt(ft) + 9} stroke={INK} strokeWidth={1.5} />
          {Array.from({ length: 3 }, (_, k) => (
            <line key={k} x1={xRc - 34} y1={yAt(ft) - 6 + k * 6} x2={xRc - 40} y2={yAt(ft) - 1 + k * 6} stroke={INK} strokeWidth={1} />
          ))}
          <circle cx={xRc} cy={yAt(ft)} r={2.6} fill={INK} />
        </g>
      ))}
      <T x={xRc - 44} y={yAt(bracesFt[bracesFt.length - 1]) - 18} anchor="end" size={11} color={DIM}>brace</T>
      <T x={xRc - 44} y={yAt(bracesFt[0]) - 18} anchor="end" size={11} color={DIM}>brace</T>
      {marks.map((ft, i) => (
        <Ext key={i} x1={xRc + (i === 0 || i === marks.length - 1 ? 16 : 6)} y1={yAt(ft)} x2={xRc + 46} y2={yAt(ft)} />
      ))}
      {marks.slice(1).map((ft, i) => (
        <Dim key={i} x1={xRc + 40} y1={yAt(marks[i])} x2={xRc + 40} y2={yAt(ft)} label={`${ft - marks[i]} ft`} side="right" />
      ))}
      <T x={(xL + xRc) / 2} y={baseY + 8} size={12} bold>{shape}</T>
    </svg>
  );
}

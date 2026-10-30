import React from 'react';
import { Arrowhead, T, Pin, Roller, Dim, Ext, INK, LOAD, DIM } from './CtStructuralAParts';

/**
 * Three-member triangular truss A-B-C: pin at A, roller at C, apex B at
 * midspan with a vertical load. Member areas are written along each member.
 * Drawn to scale.
 */
export function CtStructuralATriangleTruss({ span = 24, height = 9, load = 30, aSlope = 4.0, aChord = 2.0 }) {
  const s = 300 / span;
  const ox = 48;
  const by = 172;
  const xC = ox + span * s;
  const xB = (ox + xC) / 2;
  const yB = by - height * s;
  const ang = (Math.atan2(height, span / 2) * 180) / Math.PI;
  const dimX = xC + 40;
  const dimY = by + 46;
  const W = dimX + 44;
  const H = dimY + 24;
  const mk = 'ctStrATriTrussArrow';
  const mAB = { x: (ox + xB) / 2, y: (by + yB) / 2 };
  const mBC = { x: (xB + xC) / 2, y: (by + yB) / 2 };
  const n = 11;
  const rad = (ang * Math.PI) / 180;
  const fmt = (a) => a.toFixed(1);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Triangular truss, span ${span} ft, height ${height} ft, ${load} kip load at the apex`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} /></defs>

      <polygon points={`${ox},${by} ${xB},${yB} ${xC},${by}`} fill="none" stroke={INK} strokeWidth={2.4} strokeLinejoin="round" />
      {[[ox, by], [xB, yB], [xC, by]].map(([x, y], i) => <circle key={i} cx={x} cy={y} r={3} fill={INK} />)}

      <Pin x={ox} y={by + 1} />
      <Roller x={xC} y={by + 1} />

      <line x1={xB} y1={yB - 50} x2={xB} y2={yB - 5} stroke={LOAD} strokeWidth={2.2} markerEnd={`url(#${mk})`} />
      <T x={xB + 9} y={yB - 34} anchor="start" color={LOAD} bold>{`${load} kips`}</T>

      <T x={ox - 12} y={by - 12} anchor="end" bold>A</T>
      <T x={xB - 12} y={yB - 12} anchor="end" bold>B</T>
      <T x={xC + 12} y={by - 12} anchor="start" bold>C</T>

      {/* member areas, written along each member, outside the triangle */}
      <g transform={`translate(${mAB.x - n * Math.sin(rad)}, ${mAB.y - n * Math.cos(rad)}) rotate(${-ang})`}>
        <T x={0} y={0} size={11.5} color={DIM}>{`${fmt(aSlope)} in.²`}</T>
      </g>
      <g transform={`translate(${mBC.x + n * Math.sin(rad)}, ${mBC.y - n * Math.cos(rad)}) rotate(${ang})`}>
        <T x={0} y={0} size={11.5} color={DIM}>{`${fmt(aSlope)} in.²`}</T>
      </g>
      <T x={xB} y={by - 12} size={11.5} color={DIM}>{`${fmt(aChord)} in.²`}</T>

      {/* span */}
      <Ext x1={ox} y1={by + 28} x2={ox} y2={dimY + 5} />
      <Ext x1={xC} y1={by + 28} x2={xC} y2={dimY + 5} />
      <Dim x1={ox} y1={dimY} x2={xC} y2={dimY} label={`${span} ft`} />

      {/* height */}
      <Ext x1={xB + 6} y1={yB} x2={dimX + 5} y2={yB} />
      <Ext x1={xC + 16} y1={by} x2={dimX + 5} y2={by} />
      <Dim x1={dimX} y1={yB} x2={dimX} y2={by} label={`${height} ft`} side="right" />
    </svg>
  );
}

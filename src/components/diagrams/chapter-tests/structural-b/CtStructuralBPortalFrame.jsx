import React from 'react';
import { Arrowhead, T, Pin, Roller, Dim, Ext, Udl, INK, LOAD } from './CtStructuralBParts';

/**
 * Portal frame A-B-C-D: pin at A, roller at D, rigid knees at B and C.
 * Uniform load on the girder B-C and a horizontal load at B. Drawn to scale.
 */
export function CtStructuralBPortalFrame({ span = 16, height = 12, w = 1.5, h = 6 }) {
  const s = 13;
  const ox = 92;
  const ty = 62;
  const by = ty + height * s;
  const xR = ox + span * s;
  const mk = 'ctStrBPortalArrow';
  const dimY = by + 46;
  const hDimX = xR + 40;
  const W = hDimX + 44;
  const H = dimY + 22;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Portal frame, span ${span} ft, height ${height} ft, ${w} kips/ft on the girder and ${h} kips horizontal at B`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={7} /></defs>

      <polyline points={`${ox},${by} ${ox},${ty} ${xR},${ty} ${xR},${by}`} fill="none" stroke={INK} strokeWidth={3} strokeLinejoin="miter" />

      <Udl x1={ox} x2={xR} y={ty - 30} len={26} markerId={mk} />
      <T x={(ox + xR) / 2} y={ty - 43} color={LOAD} bold>{`${w} kips/ft`}</T>

      <line x1={ox - 62} y1={ty} x2={ox - 5} y2={ty} stroke={LOAD} strokeWidth={2.2} markerEnd={`url(#${mk})`} />
      <T x={ox - 36} y={ty + 14} color={LOAD} bold>{`${h} kips`}</T>

      <Pin x={ox} y={by + 1} />
      <Roller x={xR} y={by + 1} />

      <T x={ox - 12} y={by - 8} anchor="end" bold>A</T>
      <T x={ox - 8} y={ty - 13} anchor="end" bold>B</T>
      <T x={xR + 8} y={ty - 13} anchor="start" bold>C</T>
      <T x={xR + 12} y={by - 8} anchor="start" bold>D</T>

      <Ext x1={ox} y1={by + 30} x2={ox} y2={dimY + 5} />
      <Ext x1={xR} y1={by + 30} x2={xR} y2={dimY + 5} />
      <Dim x1={ox} y1={dimY} x2={xR} y2={dimY} label={`${span} ft`} />

      <Ext x1={xR + 6} y1={ty} x2={hDimX + 5} y2={ty} />
      <Ext x1={xR + 18} y1={by} x2={hDimX + 5} y2={by} />
      <Dim x1={hDimX} y1={ty} x2={hDimX} y2={by} label={`${height} ft`} side="right" />
    </svg>
  );
}

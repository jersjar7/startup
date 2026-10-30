import React from 'react';
import { Arrowhead, T, Pin, Hinge, Dim, Ext, Udl, INK, LOAD } from './CtStructuralAParts';

/**
 * Three-hinged portal frame: pinned bases A and E, rigid knees B and D, an
 * internal hinge C at midspan of the girder, uniform load on the girder.
 * Drawn to scale.
 */
export function CtStructuralAThreeHingedFrame({ span = 30, height = 12, w = 2 }) {
  const s = 300 / span;
  const ox = 44;
  const ty = 72;
  const by = ty + height * s;
  const xR = ox + span * s;
  const xC = (ox + xR) / 2;
  const dimX = xR + 42;
  const dimY = by + 44;
  const W = dimX + 46;
  const H = dimY + 24;
  const mk = 'ctStrAThreeHingeArrow';

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Three-hinged frame, span ${span} ft, height ${height} ft, ${w} kip/ft on the girder`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={7} /></defs>

      <Udl x1={ox} x2={xR} y={ty - 40} len={26} markerId={mk} count={11} />
      <T x={xC} y={ty - 53} color={LOAD} bold>{`w = ${w} kips/ft`}</T>

      {/* frame */}
      <polyline points={`${ox},${by} ${ox},${ty} ${xC - 4.5},${ty}`} fill="none" stroke={INK} strokeWidth={3} strokeLinejoin="miter" />
      <polyline points={`${xC + 4.5},${ty} ${xR},${ty} ${xR},${by}`} fill="none" stroke={INK} strokeWidth={3} strokeLinejoin="miter" />
      <Hinge x={xC} y={ty} />

      <Pin x={ox} y={by + 1} />
      <Pin x={xR} y={by + 1} />

      <T x={ox - 12} y={by - 14} anchor="end" bold>A</T>
      <T x={ox + 10} y={ty + 15} anchor="start" bold>B</T>
      <T x={xC} y={ty + 18} bold>C</T>
      <T x={xR - 10} y={ty + 15} anchor="end" bold>D</T>
      <T x={xR + 12} y={by - 14} anchor="start" bold>E</T>

      {/* span */}
      <Ext x1={ox} y1={by + 20} x2={ox} y2={dimY + 5} />
      <Ext x1={xR} y1={by + 20} x2={xR} y2={dimY + 5} />
      <Dim x1={ox} y1={dimY} x2={xR} y2={dimY} label={`${span} ft`} />

      {/* height */}
      <Ext x1={xR + 5} y1={ty} x2={dimX + 5} y2={ty} />
      <Ext x1={xR + 16} y1={by} x2={dimX + 5} y2={by} />
      <Dim x1={dimX} y1={ty} x2={dimX} y2={by} label={`${height} ft`} side="right" />
    </svg>
  );
}

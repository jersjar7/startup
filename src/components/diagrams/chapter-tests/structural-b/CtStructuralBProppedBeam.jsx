import React from 'react';
import { Arrowhead, T, Roller, Dim, Ext, Wall, INK, LOAD } from './CtStructuralBParts';

/**
 * Propped cantilever: fixed into a wall at A, roller at B, one point load at
 * distance `a` from A. Drawn to scale.
 */
export function CtStructuralBProppedBeam({ span = 20, a = 10, p = 24 }) {
  const s = 300 / span;
  const ox = 40;
  const by = 74;
  const xB = ox + span * s;
  const xP = ox + a * s;
  const mk = 'ctStrBProppedArrow';
  const dimY = by + 48;
  const W = xB + 40;
  const H = dimY + 22;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Propped cantilever, span ${span} ft, ${p} kips at ${a} ft from the fixed end`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={8} /></defs>

      <Wall x={ox} y1={by - 26} y2={by + 26} side="left" />
      <line x1={ox} y1={by} x2={xB} y2={by} stroke={INK} strokeWidth={3.5} />
      <Roller x={xB} y={by + 2} />

      <line x1={xP} y1={by - 52} x2={xP} y2={by - 4} stroke={LOAD} strokeWidth={2.4} markerEnd={`url(#${mk})`} />
      <T x={xP + 9} y={by - 42} anchor="start" color={LOAD} bold>{`${p} kips`}</T>

      <T x={ox + 10} y={by - 14} anchor="start" bold>A</T>
      <T x={xB + 12} y={by - 2} anchor="start" bold>B</T>

      <Ext x1={ox} y1={by + 30} x2={ox} y2={dimY + 5} />
      <Ext x1={xP} y1={by + 6} x2={xP} y2={dimY + 5} />
      <Ext x1={xB} y1={by + 32} x2={xB} y2={dimY + 5} />
      <Dim x1={ox} y1={dimY} x2={xP} y2={dimY} label={`${a} ft`} />
      <Dim x1={xP} y1={dimY} x2={xB} y2={dimY} label={`${span - a} ft`} />
    </svg>
  );
}

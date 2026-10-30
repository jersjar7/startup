import React from 'react';
import { Arrowhead, T, Dim, Ext, Udl, Wall, INK, LOAD } from './CtStructuralBParts';

/** Beam built in at both ends with a uniform load over the full span. */
export function CtStructuralBFixedBeam({ span = 30, w = 2.4 }) {
  const ox = 36;
  const len = 300;
  const by = 72;
  const xB = ox + len;
  const mk = 'ctStrBFixedArrow';
  const dimY = by + 46;
  const W = xB + 36;
  const H = dimY + 22;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Fixed-fixed beam, span ${span} ft, ${w} kips/ft`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={7} /></defs>

      <Wall x={ox} y1={by - 28} y2={by + 28} side="left" />
      <Wall x={xB} y1={by - 28} y2={by + 28} side="right" />
      <line x1={ox} y1={by} x2={xB} y2={by} stroke={INK} strokeWidth={3.5} />

      <Udl x1={ox + 8} x2={xB - 8} y={by - 30} len={26} markerId={mk} />
      <T x={(ox + xB) / 2} y={by - 43} color={LOAD} bold>{`w = ${w} kips/ft`}</T>

      <T x={ox + 10} y={by + 14} anchor="start" bold>A</T>
      <T x={xB - 10} y={by + 14} anchor="end" bold>B</T>

      <Ext x1={ox} y1={by + 32} x2={ox} y2={dimY + 5} />
      <Ext x1={xB} y1={by + 32} x2={xB} y2={dimY + 5} />
      <Dim x1={ox} y1={dimY} x2={xB} y2={dimY} label={`${span} ft`} />
    </svg>
  );
}

import React from 'react';
import { Arrowhead, T, Pin, Roller, Dim, Ext, Udl, INK, LOAD } from './CtStructuralAParts';

/**
 * Two-span continuous beam on three supports (pin at A, rollers at B and C)
 * with a uniform load over its whole length. Drawn to scale.
 */
export function CtStructuralATwoSpanBeam({ span1 = 20, span2 = 20, w = 3 }) {
  const s = 340 / (span1 + span2);
  const ox = 32;
  const by = 74;
  const xB = ox + span1 * s;
  const xC = xB + span2 * s;
  const dimY = by + 46;
  const W = xC + 32;
  const H = dimY + 24;
  const mk = 'ctStrATwoSpanArrow';

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Two-span continuous beam, spans ${span1} ft and ${span2} ft, ${w} kip/ft uniform load`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={7} /></defs>
      <Udl x1={ox} x2={xC} y={by - 30} len={25} markerId={mk} count={17} />
      <T x={(ox + xC) / 2} y={by - 43} color={LOAD} bold>{`w = ${w} kips/ft`}</T>

      <line x1={ox} y1={by} x2={xC} y2={by} stroke={INK} strokeWidth={3.5} />
      <Pin x={ox} y={by + 2} />
      <Roller x={xB} y={by + 2} />
      <Roller x={xC} y={by + 2} />

      <T x={ox - 11} y={by} anchor="end" bold>A</T>
      <T x={xB + 16} y={by + 12} anchor="start" bold>B</T>
      <T x={xC + 11} y={by} anchor="start" bold>C</T>

      {[ox, xB, xC].map((x, i) => <Ext key={i} x1={x} y1={by + 28} x2={x} y2={dimY + 5} />)}
      <Dim x1={ox} y1={dimY} x2={xB} y2={dimY} label={`${span1} ft`} />
      <Dim x1={xB} y1={dimY} x2={xC} y2={dimY} label={`${span2} ft`} />
    </svg>
  );
}

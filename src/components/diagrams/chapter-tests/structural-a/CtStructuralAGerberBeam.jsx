import React from 'react';
import { Arrowhead, T, Pin, Roller, Hinge, Dim, Ext, Udl, INK, LOAD } from './CtStructuralAParts';

/**
 * Beam with an internal hinge (Gerber beam): pin at A, roller at B, the
 * beam overhangs B to a hinge at C, and a drop-in span C-D ends on a roller
 * at D. Uniform load on C-D only. Drawn to scale.
 */
export function CtStructuralAGerberBeam({ ab = 20, bc = 5, cd = 15, w = 2 }) {
  const total = ab + bc + cd;
  const s = 340 / total;
  const ox = 30;
  const by = 72;
  const xA = ox;
  const xB = ox + ab * s;
  const xC = xB + bc * s;
  const xD = xC + cd * s;
  const dimY = by + 46;
  const W = xD + 30;
  const H = dimY + 24;
  const mk = 'ctStrAGerberArrow';

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Beam with internal hinge: spans ${ab}, ${bc}, ${cd} ft, ${w} kip/ft on the drop-in span`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={7} /></defs>

      {/* load on C-D */}
      <Udl x1={xC + 6} x2={xD} y={by - 30} len={24} markerId={mk} />
      <T x={(xC + xD) / 2} y={by - 42} color={LOAD} bold>{`w = ${w} kips/ft`}</T>

      {/* beam */}
      <line x1={xA} y1={by} x2={xC - 4.5} y2={by} stroke={INK} strokeWidth={3.5} />
      <line x1={xC + 4.5} y1={by} x2={xD} y2={by} stroke={INK} strokeWidth={3.5} />
      <Hinge x={xC} y={by} />

      {/* supports */}
      <Pin x={xA} y={by + 2} />
      <Roller x={xB} y={by + 2} />
      <Roller x={xD} y={by + 2} />

      {/* labels */}
      <T x={xA - 10} y={by} anchor="end" bold>A</T>
      <T x={xB} y={by - 14} bold>B</T>
      <T x={xC} y={by + 17} bold>C</T>
      <T x={xD + 10} y={by} anchor="start" bold>D</T>

      {/* dimensions */}
      {[xA, xB, xD].map((x, i) => <Ext key={i} x1={x} y1={by + 28} x2={x} y2={dimY + 5} />)}
      <Ext x1={xC} y1={by + 27} x2={xC} y2={dimY + 5} />
      <Dim x1={xA} y1={dimY} x2={xB} y2={dimY} label={`${ab} ft`} />
      <Dim x1={xB} y1={dimY} x2={xC} y2={dimY} label={`${bc} ft`} />
      <Dim x1={xC} y1={dimY} x2={xD} y2={dimY} label={`${cd} ft`} />
    </svg>
  );
}

import React from 'react';
import { Arrowhead, T, Pin, Roller, Dim, Ext, Udl, INK, LOAD } from './CtStructuralBParts';

/**
 * Beam on a pin at A and a roller at B with an overhang to the free end C.
 * Optional uniform load over the full length (omit `w` to show geometry
 * only, when the loads are described in the statement). Drawn to scale.
 */
export function CtStructuralBOverhangBeam({ ab = 20, bc = 6, w = null, wLabel = null }) {
  const total = ab + bc;
  const s = 340 / total;
  const ox = 30;
  const top = w ? 50 : 22;
  const by = top + 20;
  const xA = ox;
  const xB = ox + ab * s;
  const xC = xB + bc * s;
  const dimY = by + 48;
  const W = xC + 30;
  const H = dimY + 22;
  const mk = 'ctStrBOverhangArrow';

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Beam with overhang: ${ab} ft between supports, ${bc} ft overhang${w ? `, ${w} kips/ft full length` : ''}`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={7} /></defs>

      {w && (
        <g>
          <Udl x1={xA} x2={xC} y={by - 30} len={26} markerId={mk} />
          <T x={(xA + xC) / 2} y={by - 42} color={LOAD} bold>{wLabel || `${w} kips/ft`}</T>
        </g>
      )}

      <line x1={xA} y1={by} x2={xC} y2={by} stroke={INK} strokeWidth={3.5} />
      <Pin x={xA} y={by + 2} />
      <Roller x={xB} y={by + 2} />

      <T x={xA - 10} y={by} anchor="end" bold>A</T>
      <T x={xB + 13} y={by + 14} anchor="start" bold>B</T>
      <T x={xC + 9} y={by} anchor="start" bold>C</T>

      <Ext x1={xA} y1={by + 30} x2={xA} y2={dimY + 5} />
      <Ext x1={xB} y1={by + 32} x2={xB} y2={dimY + 5} />
      <Ext x1={xC} y1={by + 5} x2={xC} y2={dimY + 5} />
      <Dim x1={xA} y1={dimY} x2={xB} y2={dimY} label={`${ab} ft`} />
      <Dim x1={xB} y1={dimY} x2={xC} y2={dimY} label={`${bc} ft`} />
    </svg>
  );
}

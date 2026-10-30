import React from 'react';
import { T, Pin, Ground, Hinge, INK } from './CtStructuralAParts';

/**
 * Portal frame for a determinacy question: column AB fixed at its base A,
 * column CD pinned at its base D, rigid knees at B and C, and an internal
 * hinge E in the girder. Proportions only; no loads or dimensions needed.
 */
export function CtStructuralAHingedPortal({ span = 28, height = 16, hingeAt = 0.5 }) {
  const s = 10;
  const ox = 52;
  const ty = 34;
  const by = ty + height * s;
  const xR = ox + span * s;
  const xE = ox + hingeAt * span * s;
  const W = xR + 52;
  const H = by + 22;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Portal frame with a fixed base, a pinned base and an internal hinge in the girder"
      style={{ width: '100%', height: 'auto' }}>
      <polyline points={`${ox},${by} ${ox},${ty} ${xE - 5},${ty}`} fill="none" stroke={INK} strokeWidth={3} />
      <polyline points={`${xE + 5},${ty} ${xR},${ty} ${xR},${by - 16}`} fill="none" stroke={INK} strokeWidth={3} />
      <Hinge x={xE} y={ty} r={5} />

      {/* fixed base at A: column built into hatched ground */}
      <Ground x1={ox - 22} x2={ox + 22} y={by} />
      <line x1={ox - 22} y1={by + 0.5} x2={ox + 22} y2={by + 0.5} stroke={INK} strokeWidth={2.4} />
      {/* pinned base at D */}
      <Pin x={xR} y={by - 16} s={16} />

      <T x={ox - 12} y={by - 16} anchor="end" bold>A</T>
      <T x={ox - 12} y={ty} anchor="end" bold>B</T>
      <T x={xE} y={ty - 15} bold>E</T>
      <T x={xR + 12} y={ty} anchor="start" bold>C</T>
      <T x={xR + 14} y={by - 16} anchor="start" bold>D</T>

      <T x={ox + 28} y={by - 9} anchor="start" size={11} color="var(--gray-500)">fixed</T>
      <T x={xR - 18} y={by - 9} anchor="end" size={11} color="var(--gray-500)">pin</T>
      <T x={xE} y={ty + 18} size={11} color="var(--gray-500)">hinge</T>
    </svg>
  );
}

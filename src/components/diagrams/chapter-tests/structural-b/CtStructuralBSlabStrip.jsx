import React from 'react';
import { T, Dim, Ext, INK, DIM } from './CtStructuralBParts';

/**
 * Section through a one-way slab, cut parallel to the supports, showing the
 * bottom bars at their spacing and a 12-in. design strip. Drawn to scale.
 */
export function CtStructuralBSlabStrip({ h = 7, spacing = 10, bar = '#5', db = 0.625, cover = 0.75, lengthIn = 36 }) {
  const s = 8.5;
  const ox = 66;
  const oy = 46;
  const xR = ox + lengthIn * s;
  const yB = oy + h * s;
  const barY = yB - (cover + db / 2) * s;
  const first = (lengthIn - 2 * spacing) / 2;
  const bars = [0, 1, 2].map((i) => ox + (first + i * spacing) * s);
  const stripL = bars[1] - 6 * s;
  const stripR = bars[1] + 6 * s;
  const zig = (x, dir) => `M ${x},${oy - 4} L ${x + 5 * dir},${oy + h * s * 0.3} L ${x - 5 * dir},${oy + h * s * 0.6} L ${x},${yB + 4}`;
  const W = Math.max(xR + 30, bars[2] + 160);
  const H = yB + 54;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`One-way slab ${h} in. thick with ${bar} bars at ${spacing} in., ${cover} in. clear cover`}
      style={{ width: '100%', height: 'auto' }}>
      <rect x={ox} y={oy} width={xR - ox} height={yB - oy} fill="var(--gray-100)" />
      <line x1={ox} y1={oy} x2={xR} y2={oy} stroke={INK} strokeWidth={2} />
      <line x1={ox} y1={yB} x2={xR} y2={yB} stroke={INK} strokeWidth={2} />
      <path d={zig(ox, 1)} fill="none" stroke={INK} strokeWidth={1.4} />
      <path d={zig(xR, -1)} fill="none" stroke={INK} strokeWidth={1.4} />
      {bars.map((x, i) => <circle key={i} cx={x} cy={barY} r={(db / 2) * s + 0.5} fill={INK} />)}

      {/* 12-in. design strip */}
      <line x1={stripL} y1={oy - 2} x2={stripL} y2={oy - 24} stroke={DIM} strokeWidth={1} strokeDasharray="3,2" />
      <line x1={stripR} y1={oy - 2} x2={stripR} y2={oy - 24} stroke={DIM} strokeWidth={1} strokeDasharray="3,2" />
      <Dim x1={stripL} y1={oy - 18} x2={stripR} y2={oy - 18} label="12 in. design strip" side="above" />

      {/* thickness */}
      <Ext x1={ox - 6} y1={oy} x2={ox - 30} y2={oy} />
      <Ext x1={ox - 6} y1={yB} x2={ox - 30} y2={yB} />
      <Dim x1={ox - 24} y1={oy} x2={ox - 24} y2={yB} label={`${h} in.`} side="left" />

      {/* bar spacing */}
      {bars.slice(0, 2).map((x, i) => <Ext key={i} x1={x} y1={yB + 4} x2={x} y2={yB + 25} />)}
      <Dim x1={bars[0]} y1={yB + 20} x2={bars[1]} y2={yB + 20} label={`${spacing} in.`} />

      {/* bar callout and clear cover */}
      <line x1={bars[2] + 3} y1={barY + 3} x2={bars[2] + 22} y2={yB + 22} stroke={DIM} strokeWidth={1} />
      <T x={bars[2] + 25} y={yB + 26} anchor="start" size={11.5}>{`${bar} bars at ${spacing} in.`}</T>
      <T x={bars[2] + 25} y={yB + 42} anchor="start" size={11.5} color={DIM}>{`${cover} in. clear cover`}</T>
    </svg>
  );
}

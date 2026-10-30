import React from 'react';
import { T, Dim, Ext, INK, DIM } from './CtStructuralBParts';

/**
 * Cross-section of a concrete beam showing one layer of bottom bars inside a
 * stirrup with clear cover. The width is the unknown and is labelled b.
 * Drawn to scale (inches) at the minimum-spacing layout.
 */
export function CtStructuralBBarLayout({ n = 4, bar = '#9', db = 1.128, stirrup = '#3', ds = 0.375, cover = 1.5, clear = 4 / 3, h = 20 }) {
  const s = 11;
  const b = 2 * cover + 2 * ds + n * db + (n - 1) * clear;
  const ox = 120;
  const oy = 20;
  const xR = ox + b * s;
  const yB = oy + h * s;
  const c = cover * s;
  const t = ds * s;
  const barY = yB - (cover + ds + db / 2) * s;
  const barX = (i) => ox + (cover + ds + db / 2 + i * (db + clear)) * s;
  const W = xR + 120;
  const H = yB + 44;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Concrete beam section with ${n} ${bar} bars, ${stirrup} stirrup, ${cover} in. clear cover, width b`}
      style={{ width: '100%', height: 'auto' }}>
      <rect x={ox} y={oy} width={xR - ox} height={yB - oy} fill="var(--gray-100)" stroke={INK} strokeWidth={2} rx={1.5} />
      {/* stirrup, drawn as a band of its own bar diameter */}
      <rect x={ox + c + t / 2} y={oy + c + t / 2} width={xR - ox - 2 * c - t} height={yB - oy - 2 * c - t}
        fill="none" stroke={DIM} strokeWidth={t} rx={t * 1.5} />
      {Array.from({ length: n }, (_, i) => (
        <circle key={i} cx={barX(i)} cy={barY} r={(db / 2) * s} fill={INK} />
      ))}
      {/* two top hanger bars for the stirrup */}
      <circle cx={ox + c + t + 0.25 * s} cy={oy + c + t + 0.25 * s} r={0.25 * s} fill={INK} />
      <circle cx={xR - c - t - 0.25 * s} cy={oy + c + t + 0.25 * s} r={0.25 * s} fill={INK} />

      {/* labels with leaders */}
      <line x1={barX(n - 1) + 5} y1={barY - 5} x2={xR + 16} y2={barY - 38} stroke={DIM} strokeWidth={1} />
      <T x={xR + 19} y={barY - 42} anchor="start" size={11.5}>{`${n} ${bar} bars`}</T>
      <line x1={xR - c - t / 2} y1={(oy + yB) / 2} x2={xR + 16} y2={(oy + yB) / 2} stroke={DIM} strokeWidth={1} />
      <T x={xR + 19} y={(oy + yB) / 2} anchor="start" size={11.5}>{`${stirrup} stirrup`}</T>

      {/* clear cover at the side, measured to the stirrup */}
      <Dim x1={ox} y1={oy + 7 * s} x2={ox + c} y2={oy + 7 * s} />
      <line x1={ox - 4} y1={oy + 7 * s} x2={ox - 30} y2={oy + 7 * s} stroke={DIM} strokeWidth={1} />
      <T x={ox - 34} y={oy + 7 * s - 8} anchor="end" size={11.5}>{`${cover} in.`}</T>
      <T x={ox - 34} y={oy + 7 * s + 8} anchor="end" size={11.5}>clear (typ.)</T>

      {/* width */}
      <Ext x1={ox} y1={yB + 4} x2={ox} y2={yB + 26} />
      <Ext x1={xR} y1={yB + 4} x2={xR} y2={yB + 26} />
      <Dim x1={ox} y1={yB + 20} x2={xR} y2={yB + 20} label="b = ?" />
    </svg>
  );
}

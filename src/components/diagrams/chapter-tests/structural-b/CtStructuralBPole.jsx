import React from 'react';
import { Arrowhead, T, Dim, Ext, INK, LOAD, DIM } from './CtStructuralBParts';

/**
 * Round steel tube pole fixed at its base and free at its top, with an axial
 * load P at the top; beside it, the tube cross-section with its outside
 * diameter and wall thickness.
 */
export function CtStructuralBPole({ heightFt = 18, od = 6.0, t = 0.25 }) {
  const mk = 'ctStrBPoleArrow';
  const px = 92;
  const topY = 58;
  const baseY = topY + heightFt * 11;
  const halfW = 6;
  const dimX = px - 40;
  // section
  const cx = 270;
  const cy = (topY + baseY) / 2 - 10;
  const R = 52;
  const tr = Math.max(3, (t / (od / 2)) * R);
  const W = 400;
  const H = baseY + 28;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Fixed-base pole ${heightFt} ft tall, tube ${od} in. outside diameter, ${t} in. wall, axial load P at the top`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={8} /></defs>

      {/* elevation */}
      <rect x={px - halfW} y={topY} width={2 * halfW} height={baseY - topY} fill="#fff" stroke={INK} strokeWidth={2} />
      {/* fixed base: the pole runs into a hatched ground block */}
      <line x1={px - 34} y1={baseY} x2={px + 34} y2={baseY} stroke={INK} strokeWidth={1.8} />
      {Array.from({ length: 11 }, (_, i) => px - 30 + i * 6.4).map((x) => (
        <line key={x} x1={x + 4} y1={baseY + 1} x2={x - 4} y2={baseY + 11} stroke={INK} strokeWidth={1} />
      ))}
      <line x1={px} y1={topY - 46} x2={px} y2={topY - 4} stroke={LOAD} strokeWidth={2.4} markerEnd={`url(#${mk})`} />
      <T x={px + 10} y={topY - 34} anchor="start" color={LOAD} bold>P</T>
      <T x={px + 14} y={baseY - 14} anchor="start" size={11} color={DIM}>fixed base</T>
      <T x={px + 14} y={topY + 10} anchor="start" size={11} color={DIM}>free top</T>

      <Ext x1={px - halfW - 4} y1={topY} x2={dimX - 5} y2={topY} />
      <Ext x1={px - 42} y1={baseY} x2={dimX - 5} y2={baseY} />
      <Dim x1={dimX} y1={topY} x2={dimX} y2={baseY} label={`${heightFt} ft`} side="left" />

      {/* section */}
      <T x={cx} y={cy - R - 58} size={11.5} color={DIM}>Section</T>
      <circle cx={cx} cy={cy} r={R} fill="var(--gray-100)" stroke={INK} strokeWidth={1.8} />
      <circle cx={cx} cy={cy} r={R - tr} fill="#fff" stroke={INK} strokeWidth={1.5} />
      <Ext x1={cx - R} y1={cy - 6} x2={cx - R} y2={cy - R - 26} />
      <Ext x1={cx + R} y1={cy - 6} x2={cx + R} y2={cy - R - 26} />
      <Dim x1={cx - R} y1={cy - R - 20} x2={cx + R} y2={cy - R - 20} label={`OD = ${od.toFixed(1)} in.`} side="above" />
      <line x1={cx + (R - tr / 2) * Math.cos(Math.PI / 4)} y1={cy + (R - tr / 2) * Math.sin(Math.PI / 4)}
        x2={cx + R + 18} y2={cy + R + 14} stroke={DIM} strokeWidth={1} />
      <T x={cx + R + 20} y={cy + R + 20} anchor="start" size={11.5} color={DIM}>{`t = ${t} in.`}</T>
    </svg>
  );
}

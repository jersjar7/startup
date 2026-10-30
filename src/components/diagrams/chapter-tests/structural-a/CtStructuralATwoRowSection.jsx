import React from 'react';
import { T, Dim, Ext, INK, DIM, SEC } from './CtStructuralAParts';

/**
 * Reinforced concrete beam section with tension bars in two rows. Depths to
 * each row are measured from the top (compression) face. Drawn to scale.
 */
export function CtStructuralATwoRowSection({ b = 14, h = 26, d1 = 23.5, d2 = 20.5, n1 = 3, n2 = 2, bar = '#9', barDia = 1.128 }) {
  const s = 8;
  const ox = 74;
  const oy = 24;
  const wpx = b * s;
  const hpx = h * s;
  const xR = ox + wpx;
  const yB = oy + hpx;
  const r = (barDia / 2) * s;
  const inset = 2.0 * s; // to the bar centres at the sides
  const rowX = (n) => Array.from({ length: n }, (_, i) => (n === 1 ? ox + wpx / 2 : ox + inset + (i * (wpx - 2 * inset)) / (n - 1)));
  const y1 = oy + d1 * s;
  const y2 = oy + d2 * s;
  const row2x = n2 === 2 && n1 === 3 ? [rowX(3)[0], rowX(3)[2]] : rowX(n2);
  const dA = xR + 26;
  const dB = xR + 92;
  const W = dB + 54;
  const H = yB + 40;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Concrete beam ${b} by ${h} in. with ${n1} ${bar} bars at ${d1} in. and ${n2} ${bar} bars at ${d2} in.`}
      style={{ width: '100%', height: 'auto' }}>
      <rect x={ox} y={oy} width={wpx} height={hpx} fill="var(--gray-100)" stroke={INK} strokeWidth={2} rx={1.5} />
      <rect x={ox + 1.2 * s} y={oy + 1.2 * s} width={wpx - 2.4 * s} height={hpx - 2.4 * s} fill="none" stroke={SEC} strokeWidth={1.4} strokeDasharray="5,3" rx={4} />
      {rowX(n1).map((x, i) => <circle key={`a${i}`} cx={x} cy={y1} r={r} fill={INK} />)}
      {row2x.map((x, i) => <circle key={`b${i}`} cx={x} cy={y2} r={r} fill={INK} />)}

      <T x={ox + wpx / 2} y={oy + hpx * 0.38} size={12} color={DIM}>{`${n1 + n2} ${bar} bars`}</T>
      <T x={ox + wpx / 2} y={oy + hpx * 0.38 + 16} size={11} color={DIM}>{`(${n2} upper, ${n1} lower)`}</T>

      {/* width */}
      <Ext x1={ox} y1={yB + 4} x2={ox} y2={yB + 21} />
      <Ext x1={xR} y1={yB + 4} x2={xR} y2={yB + 21} />
      <Dim x1={ox} y1={yB + 16} x2={xR} y2={yB + 16} label={`${b} in.`} gap={13} />

      {/* total height */}
      <Ext x1={ox - 4} y1={oy} x2={ox - 30} y2={oy} />
      <Ext x1={ox - 4} y1={yB} x2={ox - 30} y2={yB} />
      <Dim x1={ox - 24} y1={oy} x2={ox - 24} y2={yB} label={`${h} in.`} side="left" />

      {/* depths to each row, from the top face */}
      <Ext x1={xR + 4} y1={oy} x2={dB + 5} y2={oy} />
      <Ext x1={row2x[row2x.length - 1] + r + 3} y1={y2} x2={dA + 5} y2={y2} />
      <Ext x1={rowX(n1)[n1 - 1] + r + 3} y1={y1} x2={dB + 5} y2={y1} />
      <Dim x1={dA} y1={oy} x2={dA} y2={y2} label={`${d2} in.`} side="right" />
      <Dim x1={dB} y1={oy} x2={dB} y2={y1} label={`${d1} in.`} side="right" />
    </svg>
  );
}

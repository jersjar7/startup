import React from 'react';
import { Arrowhead, T, Dim, Ext, INK, LOAD, DIM, SEC } from './CtStructuralAParts';

/**
 * Single-angle tension brace bolted through one leg to a gusset plate.
 * Left: elevation looking at the connected leg, with one line of bolts and
 * the pitch between them. Right: end view of the angle against the gusset
 * with the connection eccentricity x-bar. Both views at the same scale.
 */
export function CtStructuralABoltedAngle({ nBolts = 3, pitch = 3, edge = 1.5, leg = 4, t = 0.5, gage = 2.5, boltDia = 0.75, xbar = 1.18, shape = 'L4×4×1/2' }) {
  const s = 12;
  const ya = 76; // heel line in the elevation
  const legPx = leg * s;
  const tPx = t * s;
  const x0 = 58; // end of the angle inside the gusset
  const bx = Array.from({ length: nBolts }, (_, i) => x0 + (edge + i * pitch) * s);
  const by = ya + gage * s;
  const gR = bx[nBolts - 1] + edge * s; // gusset right edge
  const aEnd = gR + 128;
  const pY = ya + legPx / 2;
  // end view
  const sx = aEnd + 82; // gusset face = back of connected leg
  const sTop = ya;
  const cX = sx + xbar * s;
  const cY = sTop + xbar * s;
  const W = sx + legPx + 54;
  const H = ya + legPx + 48;
  const mk = 'ctStrABoltAngleArrow';

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`${shape} bolted through one leg with ${nBolts} bolts at ${pitch} in. pitch; x-bar ${xbar} in.`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} /></defs>

      {/* ── elevation ── */}
      <T x={(x0 + aEnd) / 2 - 20} y={18} size={12} color={DIM} bold>ELEVATION</T>
      <rect x={18} y={ya - 34} width={gR - 18} height={legPx + 74} fill="var(--gray-100)" stroke={INK} strokeWidth={1.6} />
      <rect x={x0} y={ya} width={aEnd - x0} height={legPx} fill="#fff" stroke={INK} strokeWidth={1.8} />
      <rect x={x0} y={ya} width={aEnd - x0} height={tPx} fill={SEC} stroke={INK} strokeWidth={1.2} />
      {bx.map((x, i) => (
        <g key={i}>
          <circle cx={x} cy={by} r={(boltDia / 2) * s + 1.5} fill="#fff" stroke={INK} strokeWidth={1.6} />
          <line x1={x - 3.5} y1={by} x2={x + 3.5} y2={by} stroke={INK} strokeWidth={1.2} />
          <line x1={x} y1={by - 3.5} x2={x} y2={by + 3.5} stroke={INK} strokeWidth={1.2} />
        </g>
      ))}
      <line x1={aEnd + 6} y1={pY} x2={aEnd + 52} y2={pY} stroke={LOAD} strokeWidth={2.4} markerEnd={`url(#${mk})`} />
      <T x={aEnd + 30} y={pY - 13} color={LOAD} bold>P</T>
      <T x={26} y={ya + legPx + 28} anchor="start" size={11} color={DIM}>gusset plate</T>
      <T x={(gR + aEnd) / 2} y={ya + legPx + 16} size={12}>{shape}</T>

      {/* pitch dimensions, above the angle */}
      {bx.map((x, i) => <Ext key={`e${i}`} x1={x} y1={by - 8} x2={x} y2={ya - 21} />)}
      {bx.slice(0, -1).map((x, i) => <Dim key={`d${i}`} x1={x} y1={ya - 16} x2={bx[i + 1]} y2={ya - 16} label={`${pitch} in.`} side="above" gap={10} />)}

      {/* ── end view ── */}
      <T x={sx + legPx / 2 - 6} y={18} size={12} color={DIM} bold>END VIEW</T>
      <rect x={sx - tPx} y={ya - 34} width={tPx} height={legPx + 44} fill="var(--gray-100)" stroke={INK} strokeWidth={1.6} />
      <path d={`M ${sx},${sTop} H ${sx + legPx} V ${sTop + tPx} H ${sx + tPx} V ${sTop + legPx} H ${sx} Z`}
        fill={SEC} stroke={INK} strokeWidth={1.8} strokeLinejoin="miter" />
      <circle cx={cX} cy={cY} r={2.6} fill={LOAD} />
      <line x1={cX - 7} y1={cY} x2={cX + 7} y2={cY} stroke={LOAD} strokeWidth={1} />
      <line x1={cX} y1={cY - 7} x2={cX} y2={cY + 7} stroke={LOAD} strokeWidth={1} />
      <Ext x1={cX} y1={cY + 9} x2={cX} y2={ya + legPx + 27} />
      <Ext x1={sx} y1={ya + legPx + 12} x2={sx} y2={ya + legPx + 27} />
      <Dim x1={sx} y1={ya + legPx + 22} x2={cX} y2={ya + legPx + 22} />
      <T x={cX + 8} y={ya + legPx + 22} anchor="start" size={12} color={DIM}>{`x̄ = ${xbar} in.`}</T>
    </svg>
  );
}

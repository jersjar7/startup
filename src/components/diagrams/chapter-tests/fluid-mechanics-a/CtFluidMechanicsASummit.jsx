import React from 'react';
import { T, WaterSym } from './CtFluidMechanicsAParts';

/**
 * Profile of a transmission main leaving a reservoir and crossing a ridge.
 * The reservoir surface and the pipe summit sit at heights that follow the
 * elevations given (10 px per m); the horizontal scale is schematic.
 * Does NOT show: velocity, head loss or the summit pressure.
 */
export function CtFluidMechanicsASummit({ resEl = 120.0, summitEl = 115.0, d = 300 }) {
  const W = 440;
  const s = 10; // px per m, vertical
  const surf = 50;
  const sx = 300;
  const sy = surf + (resEl - summitEl) * s;
  const cover = 12;
  const valleyX = 200;
  const valleyY = sy + 84;
  const endX = 428;
  const endY = valleyY - 2;
  const bankTop = surf - 8;
  const resBot = surf + 100;
  const lb = (y) => 36 + ((y - bankTop) / (resBot - bankTop)) * 12; // left bank x at y
  const rb = (y) => 130 - ((y - bankTop) / (resBot - bankTop)) * 12; // right bank x at y
  const ground = `M 14,${bankTop} L 36,${bankTop} L 48,${resBot} L 118,${resBot} L 130,${bankTop} L 150,${bankTop} L ${valleyX},${valleyY - cover} L ${sx},${sy - cover} L ${endX},${endY - cover}`;
  const pipe = `M 108,${resBot - 12} L 150,${resBot - 2} L ${valleyX},${valleyY} L ${sx},${sy} L ${endX},${endY}`;
  const H = valleyY + 30;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Pipeline profile: reservoir surface El. ${resEl} m, pipe summit El. ${summitEl} m, pipe diameter ${d} mm`}
      style={{ width: '100%', height: 'auto' }}>
      {/* reservoir */}
      <polygon points={`${lb(surf)},${surf} ${rb(surf)},${surf} 118,${resBot} 48,${resBot}`} fill="var(--info)" fillOpacity={0.16} />
      <line x1={lb(surf)} y1={surf} x2={rb(surf)} y2={surf} stroke="var(--info)" strokeWidth={1.6} />
      <WaterSym x={84} y={surf} />
      <T x={84} y={surf - 24}>{`El. ${resEl.toFixed(1)} m`}</T>

      {/* ground line and buried main */}
      <path d={ground} fill="none" stroke="var(--gray-500)" strokeWidth={1.4} strokeLinejoin="round" />
      <T x={392} y={sy + 26} color="var(--gray-500)">ground</T>
      <path d={pipe} fill="none" stroke="var(--charcoal)" strokeWidth={4} strokeLinejoin="round" strokeLinecap="round" />
      <circle cx={sx} cy={sy} r={4.5} fill="var(--ember)" />

      <T x={sx} y={sy + 36} color="var(--ember)" bold>summit</T>
      <T x={sx} y={sy + 52}>{`El. ${summitEl.toFixed(1)} m`}</T>
      <T x={valleyX} y={valleyY + 18}>{`D = ${d} mm`}</T>
    </svg>
  );
}

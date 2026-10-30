import React from 'react';
import { DimensionLine, Label } from '../../primitives';

/**
 * Crossing-gate arm: a uniform slender rod on a pin, seen from the side.
 * Shows: overall length, pivot offset from the short end, mass.
 * Does NOT show: the centroid distance or the moment of inertia.
 */
export function CtDynamicsAGateArm({ length = 6.0, offset = 0.5, mass = 18 }) {
  const S = 52; // px per metre
  const x0 = 20;
  const L = length * S;
  const x1 = x0 + L;
  const rodY = 76;
  const rodH = 8;
  const px = x0 + offset * S;
  const postTop = rodY + 14;
  const postBot = rodY + 84;
  const dimOff = rodY - 22; // pivot offset dimension
  const dimAll = rodY - 54; // overall length dimension

  return (
    <svg viewBox={`0 0 ${Math.round(x1 + 20)} ${postBot + 16}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Uniform slender gate arm ${length} m long, ${mass} kg, pinned ${offset} m from one end`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Extension lines */}
      <line x1={x0} y1={rodY - 8} x2={x0} y2={dimAll - 6} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x1} y1={rodY - 8} x2={x1} y2={dimAll - 6} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={px} y1={rodY - 8} x2={px} y2={dimOff - 6} stroke="var(--gray-300)" strokeWidth={1} />

      {/* Dimensions */}
      <DimensionLine x1={x0} y1={dimAll} x2={x1} y2={dimAll} label="" />
      <Label x={(x0 + x1) / 2} y={dimAll - 11} color="var(--gray-500)" fontSize={12}>{`${length.toFixed(1)} m`}</Label>
      <DimensionLine x1={x0} y1={dimOff} x2={px} y2={dimOff} label="" />
      <Label x={px + 8} y={dimOff} color="var(--gray-500)" fontSize={12} anchor="start">{`${offset.toFixed(1)} m`}</Label>

      {/* Rod */}
      <rect x={x0} y={rodY - rodH / 2} width={L} height={rodH} rx={2}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <Label x={(px + x1) / 2 + 40} y={rodY + 20} color="var(--charcoal)" fontSize={12}>{`uniform slender arm, ${mass} kg`}</Label>

      {/* Post and pin bracket */}
      <rect x={px - 9} y={postTop} width={18} height={postBot - postTop} rx={2}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.8} />
      <line x1={px - 4} y1={postTop} x2={px - 3} y2={rodY + 3} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={px + 4} y1={postTop} x2={px + 3} y2={rodY + 3} stroke="var(--charcoal)" strokeWidth={1.5} />
      <circle cx={px} cy={rodY} r={4.5} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.8} />
      <Label x={px + 16} y={rodY + 20} color="var(--charcoal)" fontSize={12} italic anchor="start">O</Label>
      <line x1={px - 26} y1={postBot} x2={px + 26} y2={postBot} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 5 }, (_, i) => (
        <line key={i} x1={px - 20 + i * 11} y1={postBot} x2={px - 27 + i * 11} y2={postBot + 7}
          stroke="var(--gray-400)" strokeWidth={1} />
      ))}
    </svg>
  );
}

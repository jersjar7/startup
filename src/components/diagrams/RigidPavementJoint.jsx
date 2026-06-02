import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

/**
 * Rigid (concrete) pavement joint with a load-transfer dowel bar.
 * Shows: two concrete slabs meeting at a joint, a dowel bar across the joint,
 * the subgrade below, and a wheel load near the joint.
 * Does NOT show: stresses, deflections, or design values.
 */
export function RigidPavementJoint() {
  const W = 360, H = 220;
  const slabTop = 70, slabBot = 120;
  const jointX = 185;
  const left = 30, right = 330;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Rigid pavement joint with a dowel bar over the subgrade"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Subgrade */}
      <rect x={left} y={slabBot} width={right - left} height={H - slabBot - 20} fill="rgba(180,160,130,0.16)" />
      <Label x={W / 2} y={slabBot + 42} color="var(--gray-500)" italic fontSize={10}>subgrade</Label>
      {Array.from({ length: 14 }, (_, i) => left + 8 + i * 22).map((x) => (
        <line key={x} x1={x} y1={H - 20} x2={x - 8} y2={H - 12} stroke="var(--charcoal)" strokeWidth={1} />
      ))}
      <line x1={left} y1={H - 20} x2={right} y2={H - 20} stroke="var(--charcoal)" strokeWidth={2} />

      {/* Two concrete slabs */}
      <rect x={left} y={slabTop} width={jointX - 6 - left} height={slabBot - slabTop}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <rect x={jointX + 6} y={slabTop} width={right - (jointX + 6)} height={slabBot - slabTop}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={(left + jointX) / 2 - 10} y={slabTop - 8} color="var(--gray-500)" fontSize={10}>slab</Label>

      {/* Joint gap */}
      <Label x={jointX} y={slabTop - 8} color="var(--charcoal)" fontSize={9}>joint</Label>

      {/* Dowel bar across the joint */}
      <rect x={jointX - 40} y={(slabTop + slabBot) / 2 - 4} width={80} height={8}
        fill="var(--forest)" stroke="var(--forest)" rx={2} />
      <Label x={jointX} y={slabBot + 14} color="var(--forest)" bold fontSize={10}>dowel bar</Label>

      {/* Wheel load near the joint */}
      <ForceArrow x1={jointX - 30} y1={slabTop - 46} x2={jointX - 30} y2={slabTop - 4}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowMain" />
      <Label x={jointX - 30} y={slabTop - 54} color="var(--charcoal)" bold fontSize={11}>load</Label>
    </svg>
  );
}

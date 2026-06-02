import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

/**
 * Deep foundation (pile) load transfer.
 * Shows: ground surface, pile shaft, applied load Q on top, skin-friction
 * arrows along the shaft (Qs), and end-bearing arrow at the tip (Qp).
 * Does NOT show: capacity values or the factor of safety.
 */
export function PileCapacity() {
  const W = 320, H = 280;
  const groundY = 70;
  const pileTop = groundY;
  const pileBot = 240;
  const cx = 160, halfW = 16;

  // skin-friction arrow rows along the shaft
  const rows = [110, 150, 190];

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Pile transferring load by end bearing and skin friction"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />
      <ArrowMarkerDefs id="arrowForest" color="var(--forest)" size={7} />

      {/* Soil body */}
      <rect x={0} y={groundY} width={W} height={H - groundY} fill="rgba(180,160,130,0.12)" />
      {/* Ground surface + hatching */}
      <line x1={0} y1={groundY} x2={W} y2={groundY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 12 }, (_, i) => 14 + i * 26).map((x) => (
        <line key={x} x1={x} y1={groundY} x2={x - 7} y2={groundY - 8} stroke="var(--charcoal)" strokeWidth={1} />
      ))}

      {/* Applied load Q (down, onto pile top) */}
      <ForceArrow x1={cx} y1={groundY - 56} x2={cx} y2={groundY - 4}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowMain" />
      <Label x={cx + 14} y={groundY - 44} color="var(--charcoal)" bold anchor="start">Q</Label>

      {/* Pile shaft */}
      <rect x={cx - halfW} y={pileTop} width={halfW * 2} height={pileBot - pileTop}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={1} />

      {/* Skin friction (Qs): small upward arrows on both shaft faces */}
      {rows.map((y) => (
        <g key={y}>
          <line x1={cx - halfW - 18} y1={y} x2={cx - halfW - 18} y2={y - 16}
            stroke="var(--forest)" strokeWidth={1.5} markerEnd="url(#arrowForest)" />
          <line x1={cx + halfW + 18} y1={y} x2={cx + halfW + 18} y2={y - 16}
            stroke="var(--forest)" strokeWidth={1.5} markerEnd="url(#arrowForest)" />
        </g>
      ))}
      <Label x={cx + halfW + 26} y={150} color="var(--forest)" bold fontSize={11} anchor="start">{'Q'}s</Label>

      {/* End bearing (Qp): upward arrow under the tip */}
      <line x1={cx} y1={pileBot + 40} x2={cx} y2={pileBot + 4}
        stroke="var(--forest)" strokeWidth={2.5} markerEnd="url(#arrowForest)" />
      <Label x={cx + 14} y={pileBot + 26} color="var(--forest)" bold anchor="start">{'Q'}p</Label>
    </svg>
  );
}

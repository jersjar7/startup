import React from 'react';
import { DashedLine, DimensionLine, Label } from './primitives';

/**
 * Strip footing cross-section for bearing capacity problems.
 *
 * Shows: ground surface, footing embedded at depth Df, width B dimension.
 * Student computes ultimate or allowable bearing capacity.
 */
export function FootingSection({
  width = 4,
  depth = 3,
  unit = 'ft',
}) {
  const W = 420;

  // Scale so the largest dimension fits ~140px
  const maxDim = Math.max(width, depth);
  const footingScale = 140 / maxDim;
  const footingW = width * footingScale;
  const footingThickness = 14;
  const depthPx = depth * footingScale;

  const groundY = 60;
  const centerX = W / 2;
  const footingLeft = centerX - footingW / 2;
  const footingRight = centerX + footingW / 2;
  const footingTop = groundY + depthPx;
  const footingBot = footingTop + footingThickness;

  const HH = footingBot + 55;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Strip footing, B = ${width} ${unit}, Df = ${depth} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Soil fill */}
      <rect x={40} y={groundY} width={W - 80} height={footingBot - groundY + 30}
        fill="rgba(180,160,130,0.10)" />

      {/* Clear space above footing (excavation) */}
      <rect x={footingLeft - 6} y={groundY} width={footingW + 12} height={depthPx}
        fill="var(--cream)" stroke="none" />

      {/* Ground surface line */}
      <line x1={40} y1={groundY} x2={footingLeft - 6} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={footingRight + 6} y1={groundY} x2={W - 40} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Ground hatching */}
      {Array.from({ length: 14 }, (_, i) => {
        const x = 46 + i * 24;
        if (x > footingLeft - 12 && x < footingRight + 12) return null;
        return (
          <line key={i}
            x1={x} y1={groundY}
            x2={x - 5} y2={groundY - 7}
            stroke="var(--charcoal)" strokeWidth={1.2} />
        );
      })}

      {/* Excavation walls (dashed) */}
      <DashedLine x1={footingLeft - 6} y1={groundY} x2={footingLeft - 6} y2={footingTop}
        color="var(--gray-400)" strokeWidth={1} dasharray="4,3" />
      <DashedLine x1={footingRight + 6} y1={groundY} x2={footingRight + 6} y2={footingTop}
        color="var(--gray-400)" strokeWidth={1} dasharray="4,3" />

      {/* Footing */}
      <rect x={footingLeft} y={footingTop} width={footingW} height={footingThickness}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={1} />

      {/* Width B dimension (below footing) */}
      <DimensionLine
        x1={footingLeft} y1={footingBot + 18}
        x2={footingRight} y2={footingBot + 18}
        label={`B = ${width} ${unit}`}
        offset={14} fontSize={10} />

      {/* Depth Df dimension (right side, bottom-to-top for label on right) */}
      <DimensionLine
        x1={footingRight + 24} y1={footingTop}
        x2={footingRight + 24} y2={groundY}
        label={`Df = ${depth} ${unit}`}
        offset={22} fontSize={10} />

      {/* Ground level label */}
      <Label x={W - 46} y={groundY - 10} fontSize={8} color="var(--gray-500)">
        GL
      </Label>
    </svg>
  );
}

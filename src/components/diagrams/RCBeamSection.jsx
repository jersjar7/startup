import React from 'react';
import { DimensionLine, Label } from './primitives';

/**
 * Reinforced concrete beam cross-section.
 *
 * Shows: concrete rectangle, tension rebar (filled circles),
 *        stirrup outline (dashed), width b, effective depth d.
 *
 * Does NOT show: stress block, forces, or moment capacity (student solves).
 */
export function RCBeamSection({
  b = 12,
  d = 18,
  numBars = 3,
  unit = 'in.',
}) {
  const W = 320;
  const HH = 280;

  // Concrete section geometry
  const cover = 2.5; // assumed cover in real units
  const h = d + cover + 0.5; // approximate total height (d + cover + half bar)
  const maxDim = Math.max(b, h);
  const scale = 160 / maxDim; // fit within 160px

  const secW = b * scale;
  const secH = h * scale;

  const cx = W / 2;
  const secLeft = cx - secW / 2;
  const secRight = cx + secW / 2;
  const secTop = 40;
  const secBot = secTop + secH;

  // Effective depth line
  const dPx = d * scale;
  const dLineY = secTop + dPx;

  // Rebar positions (at centroid of tension steel)
  const barY = dLineY; // rebar centroid at depth d from top
  const barR = 5; // symbolic radius
  const barSpacing = (secW - 24) / Math.max(numBars - 1, 1);
  const barStartX = secLeft + 12;

  // Stirrup outline (inset from concrete)
  const stirInset = 8;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`RC beam section, b = ${b} ${unit}, d = ${d} ${unit}, ${numBars} bars`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Concrete fill */}
      <rect x={secLeft} y={secTop} width={secW} height={secH}
        fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} rx={2} />

      {/* 2. Stirrup (dashed inset rectangle) */}
      <rect x={secLeft + stirInset} y={secTop + stirInset}
        width={secW - 2 * stirInset} height={secH - 2 * stirInset}
        fill="none" stroke="var(--gray-400)" strokeWidth={1.5}
        strokeDasharray="4,3" rx={2} />

      {/* 3. Tension rebar (filled circles) */}
      {Array.from({ length: numBars }, (_, i) => {
        const bx = numBars === 1 ? cx : barStartX + i * barSpacing;
        return (
          <circle key={i} cx={bx} cy={barY} r={barR}
            fill="var(--charcoal)" />
        );
      })}

      {/* 4. Effective depth d dashed line */}
      <line x1={secLeft - 4} y1={dLineY} x2={secRight + 4} y2={dLineY}
        stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />

      {/* 5. Dimension: width b (below section) */}
      <DimensionLine x1={secLeft} y1={secBot + 20} x2={secRight} y2={secBot + 20}
        label={`b = ${b} ${unit}`} offset={12} fontSize={9} />

      {/* 6. Dimension: effective depth d (right side, bottom-to-top) */}
      <DimensionLine x1={secRight + 20} y1={dLineY} x2={secRight + 20} y2={secTop}
        label={`d = ${d} ${unit}`} offset={24} fontSize={9} />

      {/* 7. Labels */}
      <Label x={cx} y={secTop + secH * 0.35} fontSize={8} color="var(--gray-400)">
        Concrete
      </Label>

      <Label x={cx} y={secTop - 10} fontSize={8} color="var(--charcoal)" bold>
        Cross-Section
      </Label>
    </svg>
  );
}

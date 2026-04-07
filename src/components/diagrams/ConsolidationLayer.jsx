import React from 'react';
import { DimensionLine, Label, ArrowMarkerDefs, ForceArrow } from './primitives';

/**
 * Clay consolidation layer with drainage boundaries.
 *
 * Shows: clay layer between permeable/impermeable boundaries,
 * drainage arrows indicating flow direction, thickness H.
 * Student determines Hdr based on one-way vs two-way drainage.
 */
export function ConsolidationLayer({
  thickness = 20,
  topPermeable = true,
  bottomPermeable = false,
  topLabel = 'Sand',
  bottomLabel = 'Rock',
  unit = 'ft',
}) {
  const W = 420;
  const colW = 160;
  const colLeft = (W - colW) / 2;
  const colRight = colLeft + colW;

  const boundaryH = 28;
  const clayH = 130;
  const topPad = 30;

  const topBoundTop = topPad;
  const topBoundBot = topBoundTop + boundaryH;
  const clayTop = topBoundBot;
  const clayBot = clayTop + clayH;
  const botBoundTop = clayBot;
  const botBoundBot = botBoundTop + boundaryH;

  const HH = botBoundBot + 30;
  const arrowX = colRight + 40;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Clay layer, ${thickness} ${unit} thick, ${topPermeable ? 'permeable' : 'impermeable'} top, ${bottomPermeable ? 'permeable' : 'impermeable'} bottom`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowDrain" color="var(--info)" size={7} />

      {/* Top boundary (sand or rock) */}
      <rect x={colLeft} y={topBoundTop} width={colW} height={boundaryH}
        fill={topPermeable ? 'rgba(180,160,130,0.20)' : 'rgba(140,130,120,0.25)'}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Top boundary hatching if impermeable */}
      {!topPermeable && Array.from({ length: 6 }, (_, i) => (
        <line key={`th${i}`}
          x1={colLeft + 10 + i * 26} y1={topBoundTop + 4}
          x2={colLeft + 20 + i * 26} y2={topBoundBot - 4}
          stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Top boundary dot pattern if permeable (sand texture) */}
      {topPermeable && Array.from({ length: 10 }, (_, i) => (
        <circle key={`td${i}`}
          cx={colLeft + 14 + (i % 5) * 30 + (Math.floor(i / 5) * 15)}
          cy={topBoundTop + 10 + Math.floor(i / 5) * 10}
          r={1.5} fill="var(--gray-400)" opacity={0.5} />
      ))}

      {/* Top boundary label */}
      <Label x={colLeft - 14} y={topBoundTop + boundaryH / 2 - 10}
        fontSize={9} color="var(--charcoal)" anchor="end" bold>
        {topLabel}
      </Label>
      <Label x={colLeft - 14} y={topBoundTop + boundaryH / 2 + 2}
        fontSize={7} color="var(--gray-500)" anchor="end">
        ({topPermeable ? 'permeable' : 'impermeable'})
      </Label>

      {/* Clay layer */}
      <rect x={colLeft} y={clayTop} width={colW} height={clayH}
        fill="rgba(160,210,240,0.15)"
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Clay label */}
      <Label x={colLeft + colW / 2} y={clayTop + clayH / 2 - 8}
        fontSize={10} color="var(--charcoal)" bold>
        Clay
      </Label>
      <Label x={colLeft + colW / 2} y={clayTop + clayH / 2 + 8}
        fontSize={9} color="var(--gray-500)">
        (consolidating)
      </Label>

      {/* Bottom boundary (rock or sand) */}
      <rect x={colLeft} y={botBoundTop} width={colW} height={boundaryH}
        fill={bottomPermeable ? 'rgba(180,160,130,0.20)' : 'rgba(140,130,120,0.25)'}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Bottom boundary hatching if impermeable */}
      {!bottomPermeable && Array.from({ length: 6 }, (_, i) => (
        <line key={`bh${i}`}
          x1={colLeft + 10 + i * 26} y1={botBoundTop + 4}
          x2={colLeft + 20 + i * 26} y2={botBoundBot - 4}
          stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Bottom boundary dot pattern if permeable */}
      {bottomPermeable && Array.from({ length: 10 }, (_, i) => (
        <circle key={`bd${i}`}
          cx={colLeft + 14 + (i % 5) * 30 + (Math.floor(i / 5) * 15)}
          cy={botBoundTop + 10 + Math.floor(i / 5) * 10}
          r={1.5} fill="var(--gray-400)" opacity={0.5} />
      ))}

      {/* Bottom boundary label */}
      <Label x={colLeft - 14} y={botBoundTop + boundaryH / 2}
        fontSize={9} color="var(--charcoal)" anchor="end" bold>
        {bottomLabel}
      </Label>
      <Label x={colLeft - 14} y={botBoundTop + boundaryH / 2 + 12}
        fontSize={7} color="var(--gray-500)" anchor="end">
        ({bottomPermeable ? 'permeable' : 'impermeable'})
      </Label>

      {/* Clay thickness dimension (left side) */}
      <DimensionLine
        x1={colLeft - 36} y1={clayBot}
        x2={colLeft - 36} y2={clayTop}
        label={`H = ${thickness} ${unit}`}
        offset={-30} fontSize={9} />

      {/* Drainage arrows */}
      {topPermeable && (
        <ForceArrow
          x1={arrowX} y1={clayTop + clayH * 0.6}
          x2={arrowX} y2={clayTop + 8}
          color="var(--info)" strokeWidth={2} markerId="arrowDrain" />
      )}
      {bottomPermeable && (
        <ForceArrow
          x1={arrowX} y1={clayTop + clayH * 0.4}
          x2={arrowX} y2={clayBot - 8}
          color="var(--info)" strokeWidth={2} markerId="arrowDrain" />
      )}

      {/* Drainage label */}
      <Label x={arrowX - 10} y={clayTop + clayH / 2 - 10}
        fontSize={8} color="var(--info)" rotate={-90}>
        drainage
      </Label>
    </svg>
  );
}

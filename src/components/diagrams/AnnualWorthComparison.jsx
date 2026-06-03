import React from 'react';
import { ArrowMarkerDefs, Label } from './primitives';

/**
 * Side-by-side cash flow diagrams for two alternatives with different lives.
 * Shared year scale emphasizes the lifespan difference.
 * Shows: initial cost, annual O&M, salvage value for each alternative.
 * Does NOT show: the annual worth values (that's the answer).
 */
export function AnnualWorthComparison({
  costX = 30000, omX = 8000, salvX = 4000, nX = 6, labelX = 'Pump X',
  costY = 50000, omY = 5000, salvY = 8000, nY = 12, labelY = 'Pump Y',
  rate = 10,
}) {
  const W = 490;
  const H = 230;
  const padL = 62;
  const padR = 20;

  const maxN = Math.max(nX, nY);
  const tlStart = padL;
  const tlEnd = W - padR;
  const pxPerYear = (tlEnd - tlStart) / maxN;
  const yearX = (yr) => tlStart + yr * pxPerYear;

  // Proportional arrow heights with minimums for visibility
  const maxCost = Math.max(costX, costY);
  const maxOm = Math.max(omX, omY);
  const maxSalv = Math.max(salvX, salvY);
  const costArrowH = (v) => Math.max(26, (v / maxCost) * 46);
  const omArrowH = (v) => Math.max(14, (v / maxOm) * 22);
  const salvArrowH = (v) => Math.max(12, (v / maxSalv) * 20);

  const section1Y = 58;
  const section2Y = 148;

  const fmt = (v) => v.toLocaleString();

  // Extend the viewBox left so long alternative labels (e.g. "Compressor A")
  // are never clipped; short labels ("Pump X") leave minX at 0 unchanged.
  const labelLen = Math.max(String(labelX).length, String(labelY).length);
  const minX = Math.min(0, padL - 10 - labelLen * 6.4 - 4);

  const sections = [
    { label: labelX, cost: costX, om: omX, salv: salvX, n: nX, timelineY: section1Y },
    { label: labelY, cost: costY, om: omY, salv: salvY, n: nY, timelineY: section2Y },
  ];

  return (
    <svg viewBox={`${minX} 0 ${W - minX} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Annual worth comparison: ${labelX} (${nX} yr) vs ${labelY} (${nY} yr), MARR = ${rate}%`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowCost" color="var(--charcoal)" size={6} />
      <ArrowMarkerDefs id="arrowOm" color="var(--gray-400)" size={5} />
      <ArrowMarkerDefs id="arrowSalv" color="var(--forest)" size={6} />

      {/* MARR label */}
      <Label x={W / 2} y={14} fontSize={10} color="var(--gray-500)" italic>
        MARR = {rate}%
      </Label>

      {sections.map((s, si) => {
        const tY = s.timelineY;
        const cH = costArrowH(s.cost);
        const oH = omArrowH(s.om);
        const sH = salvArrowH(s.salv);

        return (
          <g key={si}>
            {/* Section label */}
            <Label x={padL - 10} y={tY}
              fontSize={11} color="var(--charcoal)" bold anchor="end">
              {s.label}
            </Label>

            {/* Timeline (only extends to this pump's life) */}
            <line x1={yearX(0) - 4} y1={tY} x2={yearX(s.n) + 4} y2={tY}
              stroke="var(--charcoal)" strokeWidth={2} />

            {/* Year ticks */}
            {Array.from({ length: s.n + 1 }, (_, i) => {
              const showLabel = i === 0 || i === s.n
                || (s.n > 8 && i === Math.floor(s.n / 2));
              const isLastYear = i === s.n;
              return (
                <g key={i}>
                  <line x1={yearX(i)} y1={tY - 3} x2={yearX(i)} y2={tY + 3}
                    stroke="var(--charcoal)" strokeWidth={1} />
                  {showLabel && (
                    isLastYear
                      ? /* Last year label goes right of the green arrow */
                        <Label x={yearX(i) + 10} y={tY - sH / 2} fontSize={8}
                          color="var(--gray-400)" anchor="start">
                          {i}
                        </Label>
                      : <Label x={yearX(i)} y={tY - 12} fontSize={8}
                          color="var(--gray-400)">
                          {i}
                        </Label>
                  )}
                </g>
              );
            })}

            {/* Initial cost (downward at year 0) */}
            <line x1={yearX(0)} y1={tY + 2} x2={yearX(0)} y2={tY + cH}
              stroke="var(--charcoal)" strokeWidth={2}
              markerEnd="url(#arrowCost)" />
            <Label x={yearX(0) - 6} y={tY + cH / 2 + 4}
              fontSize={9} color="var(--charcoal)" anchor="end">
              {fmt(s.cost)}
            </Label>

            {/* O&M arrows (downward at years 1 through n) */}
            {Array.from({ length: s.n }, (_, i) => (
              <line key={i}
                x1={yearX(i + 1)} y1={tY + 2}
                x2={yearX(i + 1)} y2={tY + oH}
                stroke="var(--gray-400)" strokeWidth={1}
                markerEnd="url(#arrowOm)" />
            ))}
            <Label x={yearX(Math.ceil(s.n / 2))} y={tY + oH + 14}
              fontSize={9} color="var(--gray-400)" italic>
              {fmt(s.om)}/yr
            </Label>

            {/* Salvage (upward at year n) — omitted when there is no salvage */}
            {s.salv > 0 && (
              <>
                <line x1={yearX(s.n)} y1={tY - 2} x2={yearX(s.n)} y2={tY - sH}
                  stroke="var(--forest)" strokeWidth={2}
                  markerEnd="url(#arrowSalv)" />
                <Label x={yearX(s.n)} y={tY - sH - 8}
                  fontSize={9} color="var(--forest)">
                  {fmt(s.salv)}
                </Label>
              </>
            )}
          </g>
        );
      })}
    </svg>
  );
}

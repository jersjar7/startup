import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Life-cycle cash-flow diagram for a bridge deck (not to scale).
 * Shows: first cost at year 0, overlays at the given years, an annual
 * maintenance cost every year, and a salvage value at the end.
 * Does NOT show: the present worth (that is the answer).
 */
export function CtEconomicsADeckLifeCycle({
  first = 1200000, overlay = 300000, overlayYears = [10, 20],
  annual = 20000, salvage = 150000, life = 30, rate = 4,
}) {
  const W = 470;
  const x0 = 30;
  const step = (W - x0 - 40) / life;
  const X = (k) => x0 + k * step;
  const axisY = 96;
  const fmt = (v) => v.toLocaleString('en-US');
  const down = { first: 112, overlay: 66, annual: 18 };

  return (
    <svg viewBox={`0 0 ${W} ${axisY + 144}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Bridge deck life-cycle cash flows over 30 years"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctEconADeckArrow" color="var(--charcoal)" size={6} />
      <ArrowMarkerDefs id="ctEconADeckArrowE" color="var(--ember)" size={7} />
      <ArrowMarkerDefs id="ctEconADeckArrowF" color="var(--forest)" size={7} />

      {/* Time line with year labels every 5 years, above the line */}
      <line x1={X(0) - 6} y1={axisY} x2={X(life) + 10} y2={axisY} stroke="var(--charcoal)" strokeWidth={1.5} />
      {Array.from({ length: life + 1 }, (_, k) => (
        <line key={k} x1={X(k)} y1={axisY - 3} x2={X(k)} y2={axisY + 3} stroke="var(--charcoal)" strokeWidth={1} />
      ))}
      {Array.from({ length: life / 5 }, (_, j) => j * 5).map((k) => (
        <Label key={k} x={X(k)} y={axisY - 14} fontSize={11} color="var(--gray-500)">{k}</Label>
      ))}
      <Label x={X(life)} y={axisY - 14} fontSize={11} color="var(--gray-500)">{life}</Label>
      <Label x={X(life / 2) + 3 * step} y={axisY - 34} fontSize={11} color="var(--gray-500)" italic>years</Label>

      {/* Annual maintenance, every year 1..life */}
      {Array.from({ length: life }, (_, j) => j + 1).map((k) => (
        <line key={k} x1={X(k)} y1={axisY + 1} x2={X(k)} y2={axisY + down.annual}
          stroke="var(--gray-500)" strokeWidth={1.2} markerEnd="url(#ctEconADeckArrow)" />
      ))}

      {/* First cost */}
      <line x1={X(0)} y1={axisY + 1} x2={X(0)} y2={axisY + down.first}
        stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctEconADeckArrowE)" />
      <Label x={X(0) - 4} y={axisY + down.first + 14} fontSize={12} color="var(--charcoal)" anchor="start">{fmt(first)}</Label>

      {/* Overlays */}
      {overlayYears.map((k) => (
        <g key={k}>
          <line x1={X(k)} y1={axisY + 1} x2={X(k)} y2={axisY + down.overlay}
            stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctEconADeckArrowE)" />
          <Label x={X(k)} y={axisY + down.overlay + 14} fontSize={12} color="var(--charcoal)">{fmt(overlay)}</Label>
        </g>
      ))}

      {/* Maintenance at overlay years, offset right so it is not hidden */}
      {overlayYears.map((k) => (
        <line key={`m${k}`} x1={X(k) + 4} y1={axisY + 1} x2={X(k) + 4} y2={axisY + down.annual}
          stroke="var(--charcoal)" strokeWidth={1.2} markerEnd="url(#ctEconADeckArrow)" />
      ))}

      {/* Salvage */}
      <line x1={X(life)} y1={axisY - 26} x2={X(life)} y2={axisY - 70}
        stroke="var(--forest)" strokeWidth={2.2} markerEnd="url(#ctEconADeckArrowF)" />
      <Label x={X(life)} y={axisY - 82} fontSize={12} color="var(--charcoal)">{fmt(salvage)}</Label>

      {/* Maintenance and legend lines */}
      <Label x={X(life)} y={axisY + 32} fontSize={11} color="var(--gray-500)" anchor="end">{fmt(annual)} per year</Label>
      <Label x={X(life)} y={axisY + 46} fontSize={11} color="var(--gray-500)" anchor="end">years 1 to {life}</Label>
      <Label x={X(life)} y={axisY + 132} fontSize={11} color="var(--gray-500)" italic anchor="end">
        dollars, i = {rate}%, not to scale
      </Label>
    </svg>
  );
}

import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Cash-flow diagram of a rising maintenance cost: base in year 1, growing by
 * a uniform gradient each year to year n. Arrow lengths follow the amounts.
 * Shows: each year's cost and the interest rate.
 * Does NOT show: the equivalent annual cost (that is the answer).
 */
export function CtEconomicsBPavementGradient({ base = 3000, gradient = 1500, years = 10, rate = 6 }) {
  const W = 440;
  const x0 = 26;
  const step = (W - x0 - 26) / years;
  const X = (k) => x0 + k * step;
  const axisY = 30;
  const maxAmt = base + gradient * (years - 1);
  const len = (v) => (v / maxAmt) * 130;
  const fmt = (v) => v.toLocaleString('en-US');
  const H = axisY + len(maxAmt) + 24;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Maintenance costs from ${fmt(base)} dollars in year 1 rising ${fmt(gradient)} dollars per year to year ${years}, i = ${rate}%`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctEconBGradArrow" color="var(--ember)" size={7} />

      {/* Time line, year labels above it */}
      <line x1={X(0) - 6} y1={axisY} x2={X(years) + 10} y2={axisY} stroke="var(--charcoal)" strokeWidth={1.5} />
      {Array.from({ length: years + 1 }, (_, k) => (
        <g key={k}>
          <line x1={X(k)} y1={axisY - 4} x2={X(k)} y2={axisY + 4} stroke="var(--charcoal)" strokeWidth={1.5} />
          <Label x={X(k)} y={axisY - 14} fontSize={11} color="var(--gray-500)">{k}</Label>
        </g>
      ))}
      <Label x={X(0) - 4} y={axisY + 18} fontSize={11} color="var(--gray-500)" italic anchor="start">year</Label>

      {/* Maintenance costs (outflows, down) */}
      {Array.from({ length: years }, (_, j) => {
        const k = j + 1;
        const v = base + gradient * j;
        const L = len(v);
        return (
          <g key={k}>
            <line x1={X(k)} y1={axisY + 1} x2={X(k)} y2={axisY + L}
              stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctEconBGradArrow)" />
            <Label x={X(k)} y={axisY + L + 12} fontSize={11} color="var(--charcoal)">{fmt(v)}</Label>
          </g>
        );
      })}

      <Label x={X(0) - 4} y={axisY + 70} fontSize={12} color="var(--gray-500)" italic anchor="start">i = {rate}%</Label>
      <Label x={X(0) - 4} y={axisY + 88} fontSize={11} color="var(--gray-500)" italic anchor="start">dollars</Label>
    </svg>
  );
}

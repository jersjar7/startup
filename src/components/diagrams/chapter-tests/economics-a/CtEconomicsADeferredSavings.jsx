import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Cash-flow diagram: equal annual savings that start after a deferral.
 * Shows: the time line in years, an upward arrow of `amount` at each year
 * from `first` to `last`, the interest rate, and P = ? at year 0.
 * Does NOT show: the present worth (that is the answer).
 */
export function CtEconomicsADeferredSavings({ amount = 12000, first = 3, last = 10, rate = 6 }) {
  const W = 440;
  const x0 = 30;
  const step = (W - x0 - 56) / last;
  const X = (k) => x0 + k * step;
  const axisY = 104;
  const up = 62;
  const fmt = (v) => v.toLocaleString('en-US');

  return (
    <svg viewBox={`0 0 ${W} 128`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Cash flow: ${fmt(amount)} dollars per year in years ${first} to ${last}, i = ${rate}%`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctEconADefArrow" color="var(--charcoal)" size={7} />
      <ArrowMarkerDefs id="ctEconADefArrowP" color="var(--ember)" size={7} />

      {/* Time line */}
      <line x1={X(0) - 8} y1={axisY} x2={X(last) + 14} y2={axisY} stroke="var(--charcoal)" strokeWidth={1.5} />
      {Array.from({ length: last + 1 }, (_, k) => (
        <g key={k}>
          <line x1={X(k)} y1={axisY - 4} x2={X(k)} y2={axisY + 4} stroke="var(--charcoal)" strokeWidth={1.5} />
          <Label x={X(k)} y={axisY + 16} fontSize={11} color="var(--gray-500)">{k}</Label>
        </g>
      ))}
      <Label x={X(last) + 14} y={axisY + 16} fontSize={11} color="var(--gray-500)" italic anchor="start">years</Label>

      {/* Savings arrows (inflows, up) */}
      {Array.from({ length: last - first + 1 }, (_, j) => {
        const k = first + j;
        return (
          <line key={k} x1={X(k)} y1={axisY - 2} x2={X(k)} y2={axisY - up}
            stroke="var(--charcoal)" strokeWidth={2} markerEnd="url(#ctEconADefArrow)" />
        );
      })}
      {/* Bracket over the series with its label */}
      <path d={`M ${X(first)} ${axisY - up - 12} V ${axisY - up - 18} H ${X(last)} V ${axisY - up - 12}`}
        fill="none" stroke="var(--gray-400)" strokeWidth={1} />
      <Label x={(X(first) + X(last)) / 2} y={axisY - up - 30} fontSize={12} color="var(--charcoal)">
        {fmt(amount)} dollars per year
      </Label>

      {/* P = ? at year 0 */}
      <line x1={X(0)} y1={axisY - 2} x2={X(0)} y2={axisY - up}
        stroke="var(--ember)" strokeWidth={2} strokeDasharray="5,3" markerEnd="url(#ctEconADefArrowP)" />
      <Label x={X(0)} y={axisY - up - 14} fontSize={12} color="var(--ember)" bold>P = ?</Label>

      <Label x={X(1)} y={axisY - up + 8} fontSize={12} color="var(--gray-500)" italic anchor="start">i = {rate}%</Label>
    </svg>
  );
}

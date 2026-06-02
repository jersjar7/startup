import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

/**
 * Single-period cash-flow diagram for a rate-of-return problem.
 * Shows: a time line, an investment (downward arrow) at year 0 and a return
 * (upward arrow) at year 1.
 * Does NOT show: the rate of return (that is the answer).
 */
export function CashFlowIRR() {
  const W = 320, H = 180;
  const axisY = 95;
  const t0 = 70, t1 = 250;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Cash-flow diagram: investment at year 0, return at year 1"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Time line */}
      <line x1={36} y1={axisY} x2={W - 24} y2={axisY} stroke="var(--charcoal)" strokeWidth={1.5} />
      {[t0, t1].map((x, i) => (
        <g key={x}>
          <line x1={x} y1={axisY - 4} x2={x} y2={axisY + 4} stroke="var(--charcoal)" strokeWidth={1.5} />
          <Label x={x} y={axisY + 16} color="var(--gray-500)" fontSize={10}>{i}</Label>
        </g>
      ))}
      <Label x={W - 24} y={axisY + 16} color="var(--gray-400)" italic fontSize={9} anchor="end">year</Label>

      {/* Investment P (down, outflow) at t=0 */}
      <ForceArrow x1={t0} y1={axisY} x2={t0} y2={axisY + 52}
        color="var(--error)" strokeWidth={2.5} markerId="arrowMain" />
      <Label x={t0} y={axisY + 66} color="var(--error)" bold fontSize={12}>P</Label>

      {/* Return F (up, inflow) at t=1 */}
      <ForceArrow x1={t1} y1={axisY} x2={t1} y2={axisY - 58}
        color="var(--forest)" strokeWidth={2.5} markerId="arrowMain" />
      <Label x={t1} y={axisY - 68} color="var(--forest)" bold fontSize={12}>F</Label>
    </svg>
  );
}

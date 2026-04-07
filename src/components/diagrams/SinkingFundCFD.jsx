import React from 'react';
import { ArrowMarkerDefs, Label } from './primitives';

/**
 * Cash flow diagram for a sinking fund problem.
 * Shows: timeline with equal upward deposit arrows, future target F.
 * Does NOT show: the deposit amount A (that's the answer).
 */
export function SinkingFundCFD({ n = 10, F = 500000, rate = 6 }) {
  const W = 460;
  const H = 200;
  const padL = 36;
  const padR = 24;

  const timelineY = 130;
  const startX = padL;
  const endX = W - padR;
  const span = endX - startX;
  const yearX = (yr) => startX + (yr / n) * span;

  const arrowH = 54;
  const fmt = (v) => v.toLocaleString();

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Sinking fund cash flow: ${n} deposits, F = ${fmt(F)}, i = ${rate}%`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowDeposit" color="var(--ember)" size={6} />

      {/* Timeline */}
      <line x1={startX - 4} y1={timelineY} x2={endX + 4} y2={timelineY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Year ticks and labels */}
      {Array.from({ length: n + 1 }, (_, i) => (
        <g key={i}>
          <line x1={yearX(i)} y1={timelineY - 4} x2={yearX(i)} y2={timelineY + 4}
            stroke="var(--charcoal)" strokeWidth={1.5} />
          <Label x={yearX(i)} y={timelineY + 16} fontSize={9} color="var(--gray-400)">
            {i}
          </Label>
        </g>
      ))}

      {/* Deposit arrows (upward) at years 1 through n */}
      {Array.from({ length: n }, (_, i) => (
        <line key={i}
          x1={yearX(i + 1)} y1={timelineY - 2}
          x2={yearX(i + 1)} y2={timelineY - arrowH}
          stroke="var(--ember)" strokeWidth={1.5}
          markerEnd="url(#arrowDeposit)" />
      ))}

      {/* "A = ?" label above arrows */}
      <Label x={(yearX(1) + yearX(n)) / 2} y={timelineY - arrowH - 14}
        fontSize={13} color="var(--ember)" bold italic>
        A = ?
      </Label>

      {/* F label below year n */}
      <Label x={yearX(n)} y={timelineY + 36}
        fontSize={11} color="var(--charcoal)" bold anchor="end">
        F = {fmt(F)}
      </Label>

      {/* Interest rate */}
      <Label x={startX + 4} y={timelineY - arrowH - 14}
        fontSize={10} color="var(--gray-500)" italic anchor="start">
        i = {rate}%
      </Label>
    </svg>
  );
}

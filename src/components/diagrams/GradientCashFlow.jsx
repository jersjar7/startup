import React from 'react';
import { ArrowMarkerDefs, DashedLine, Label } from './primitives';

/**
 * Arithmetic gradient cash flow diagram.
 * Shows: timeline, downward cost arrows increasing by G each year,
 * dashed line at base annuity level with labels.
 * Does NOT show: the present worth (that's the answer).
 */
export function GradientCashFlow({ base = 10000, gradient = 2000, n = 10, rate = 8 }) {
  const W = 460;
  const H = 230;
  const padL = 50;
  const padR = 24;

  const timelineY = 42;
  const startX = padL;
  const endX = W - padR;
  const span = endX - startX;
  const yearX = (yr) => startX + (yr / n) * span;

  const costAt = (k) => base + (k - 1) * gradient;
  const maxCost = costAt(n);
  const maxArrowH = 130;
  const arrowH = (k) => (costAt(k) / maxCost) * maxArrowH;
  const baseLineH = (base / maxCost) * maxArrowH;

  const fmt = (v) => v.toLocaleString();

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Gradient cash flow: A = ${fmt(base)}, G = ${fmt(gradient)}, n = ${n}, i = ${rate}%`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowGrad" color="var(--charcoal)" size={6} />

      {/* Timeline */}
      <line x1={startX - 4} y1={timelineY} x2={endX + 4} y2={timelineY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Year ticks and labels (above timeline) */}
      {Array.from({ length: n + 1 }, (_, i) => (
        <g key={i}>
          <line x1={yearX(i)} y1={timelineY - 4} x2={yearX(i)} y2={timelineY + 4}
            stroke="var(--charcoal)" strokeWidth={1.5} />
          <Label x={yearX(i)} y={timelineY - 14} fontSize={9} color="var(--gray-400)">
            {i}
          </Label>
        </g>
      ))}

      {/* Downward cost arrows at years 1 through n */}
      {Array.from({ length: n }, (_, i) => {
        const k = i + 1;
        return (
          <line key={i}
            x1={yearX(k)} y1={timelineY + 2}
            x2={yearX(k)} y2={timelineY + arrowH(k)}
            stroke="var(--charcoal)" strokeWidth={1.5}
            markerEnd="url(#arrowGrad)" />
        );
      })}

      {/* Dashed line at base annuity level */}
      <DashedLine
        x1={yearX(0.5)} y1={timelineY + baseLineH}
        x2={yearX(n + 0.4)} y2={timelineY + baseLineH}
        color="var(--ember)" strokeWidth={1} dasharray="4,3" />

      {/* Base annuity label (left side) */}
      <Label x={padL - 8} y={timelineY + baseLineH / 2 + 2}
        fontSize={10} color="var(--ember)" italic anchor="end">
        A = {fmt(base)}
      </Label>

      {/* Gradient label (right of last arrow, between base line and tip) */}
      <text x={yearX(n) + 12} y={timelineY + baseLineH + (arrowH(n) - baseLineH) / 2}
        fill="var(--gray-500)" fontFamily="var(--font-body)" fontWeight={400}
        fontStyle="italic" fontSize={10} textAnchor="start" dominantBaseline="middle">
        G = {fmt(gradient)}
      </text>

      {/* Cost values at first and last year */}
      <Label x={yearX(1)} y={timelineY + arrowH(1) + 12}
        fontSize={8} color="var(--gray-400)">
        {fmt(costAt(1))}
      </Label>
      <Label x={yearX(n)} y={timelineY + arrowH(n) + 12}
        fontSize={8} color="var(--gray-400)">
        {fmt(maxCost)}
      </Label>

      {/* Interest rate */}
      <Label x={padL - 8} y={timelineY - 14}
        fontSize={10} color="var(--gray-500)" italic anchor="end">
        i = {rate}%
      </Label>
    </svg>
  );
}

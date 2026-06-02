import React from 'react';
import { Label } from './primitives';

/**
 * Volumetric (phase) diagram of a compacted asphalt mix.
 * Shows: the three phases stacked by volume — air, asphalt binder, aggregate —
 * with VMA (air + asphalt voids) and Va (air) brackets on the right.
 * Does NOT show: numeric Va / VMA / VFA values (those are the answers).
 */
export function AsphaltVolumetrics() {
  const x = 95, w = 90;
  const yAir = 36, yAsph = 70, yAgg = 116, yBot = 214;

  const phase = (y0, y1, fill, lbl, lblColor) => (
    <g>
      <rect x={x} y={y0} width={w} height={y1 - y0} fill={fill} stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={x - 10} y={(y0 + y1) / 2} color={lblColor} fontSize={10} anchor="end">{lbl}</Label>
    </g>
  );

  // bracket helper (right side)
  const bracket = (y0, y1, bx, label, color) => (
    <g>
      <line x1={bx} y1={y0} x2={bx} y2={y1} stroke={color} strokeWidth={1.5} />
      <line x1={bx - 5} y1={y0} x2={bx} y2={y0} stroke={color} strokeWidth={1.5} />
      <line x1={bx - 5} y1={y1} x2={bx} y2={y1} stroke={color} strokeWidth={1.5} />
      <Label x={bx + 6} y={(y0 + y1) / 2} color={color} bold fontSize={11} anchor="start">{label}</Label>
    </g>
  );

  return (
    <svg viewBox="0 0 300 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Asphalt mix phase diagram: air, asphalt, and aggregate volumes with VMA and air-void brackets"
      style={{ width: '100%', height: 'auto' }}>

      {phase(yAir, yAsph, 'var(--cream)', 'air', 'var(--gray-500)')}
      {phase(yAsph, yAgg, 'var(--charcoal)', 'asphalt', 'var(--charcoal)')}
      {phase(yAgg, yBot, 'rgba(180,160,130,0.45)', 'aggregate', 'var(--gray-600)')}

      {/* Brackets: Va (air only) and VMA (air + asphalt) */}
      {bracket(yAir, yAsph, x + w + 14, 'Va', 'var(--ember)')}
      {bracket(yAir, yAgg, x + w + 52, 'VMA', 'var(--forest)')}
    </svg>
  );
}

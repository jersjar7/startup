import React from 'react';
import { Label, DimensionLine } from '../../primitives';

/**
 * Semi-elliptical tunnel opening, cross-section, with a lane envelope of a
 * required vertical clearance centered on the centreline.
 * Shows: span, rise, the clearance height, the envelope, and its width w as
 * the unknown.
 * Does NOT show: the value of w.
 */
export function CtMathematicsBTunnel({ span = 8.0, rise = 3.0, clearance = 2.2, unit = 'm' }) {
  const s = 300 / span;
  const a = (span / 2) * s;
  const b = rise * s;
  const c = clearance * s;
  const padL = 56;
  const padR = 52;
  const padT = 30;
  const cx = padL + a;
  const floor = padT + b;
  const W = Math.round(2 * a + padL + padR);
  const H = Math.round(floor + 70);
  const xw = a * Math.sqrt(Math.max(0, 1 - (c / b) ** 2));
  const top = floor - c;
  const f = (v) => v.toFixed(1);
  const xr = cx + a + 24;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Semi-elliptical tunnel ${f(span)} ${unit} wide and ${f(rise)} ${unit} high; a lane needing ${f(clearance)} ${unit} of clearance, width w asked`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Lining */}
      <path d={`M ${cx - a} ${floor} A ${a} ${b} 0 0 1 ${cx + a} ${floor}`} fill="var(--gray-400)" fillOpacity={0.08}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Lane envelope: full clearance height across width w */}
      <rect x={cx - xw} y={top} width={2 * xw} height={c} fill="var(--ember)" fillOpacity={0.08}
        stroke="var(--ember)" strokeWidth={1.8} strokeDasharray="6,3" />

      {/* Roadway */}
      <line x1={cx - a - 12} y1={floor} x2={cx + a + 12} y2={floor} stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Centreline */}
      <line x1={cx} y1={floor} x2={cx} y2={padT - 22} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="10,3,2,3" />
      <Label x={cx + 6} y={padT - 20} anchor="start" color="var(--gray-500)" fontSize={11}>CL</Label>

      {/* Clearance height, on the right outside the lining */}
      <line x1={cx + xw} y1={top} x2={xr + 6} y2={top} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={xr} y1={floor} x2={xr} y2={top} offset={0.001} />
      <Label x={xr + 14} y={floor - c / 2} rotate={-90} color="var(--gray-500)" fontSize={11}>{`${f(clearance)} ${unit}`}</Label>

      {/* Rise, on the left outside the lining */}
      <line x1={cx} y1={floor - b} x2={padL - 32} y2={floor - b} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={padL - 26} y1={floor} x2={padL - 26} y2={floor - b} offset={0.001} />
      <Label x={padL - 40} y={floor - b / 2} rotate={-90} color="var(--gray-500)" fontSize={11}>{`${f(rise)} ${unit}`}</Label>

      {/* Lane width w (the unknown), just below the roadway */}
      <DimensionLine x1={cx - xw} y1={floor + 14} x2={cx + xw} y2={floor + 14} color="var(--ember)" />
      <Label x={cx} y={floor + 30} color="var(--ember)" fontSize={13} bold italic>w</Label>

      {/* Span, below that */}
      <DimensionLine x1={cx - a} y1={floor + 44} x2={cx + a} y2={floor + 44} offset={14} label={`${f(span)} ${unit}`} />
    </svg>
  );
}

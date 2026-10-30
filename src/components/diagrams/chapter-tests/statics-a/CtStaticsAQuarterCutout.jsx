import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Rectangular plate with a quarter-circle notch cut from the top right
 * corner (circle centred on that corner).
 * Shows: width, height, notch radius, the x-axis along the bottom edge.
 * Does NOT show: any centroid.
 */
export function CtStaticsAQuarterCutout({ width = 300, height = 200, radius = 120, unit = 'mm' }) {
  const S = 0.9;
  const x0 = 56;
  const y0 = 26; // top edge
  const w = width * S;
  const h = height * S;
  const r = radius * S;
  const x1 = x0 + w;
  const yb = y0 + h;
  const gray = 'var(--gray-500)';
  const d = `M ${x0} ${yb} L ${x1} ${yb} L ${x1} ${y0 + r} A ${r} ${r} 0 0 1 ${x1 - r} ${y0} L ${x0} ${y0} Z`;
  const rAng = (225 * Math.PI) / 180;
  const rp = { x: x1 + r * Math.cos(rAng), y: y0 - r * Math.sin(rAng) };

  return (
    <svg viewBox={`0 0 ${Math.round(x1 + 52)} ${Math.round(yb + 50)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Rectangle ${width} by ${height} ${unit} with a ${radius} ${unit} radius quarter circle removed at the top right corner`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStAQcArrow" color="var(--gray-500)" size={7} />

      <path d={d} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.2} strokeLinejoin="round" />
      {/* Removed quarter circle outline */}
      <path d={`M ${x1 - r} ${y0} L ${x1} ${y0} L ${x1} ${y0 + r}`} fill="none" stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <circle cx={x1} cy={y0} r={2.5} fill="var(--gray-500)" />
      <line x1={x1} y1={y0} x2={rp.x} y2={rp.y} stroke={gray} strokeWidth={1} markerEnd="url(#ctStAQcArrow)" />
      <Label x={x1 - r / 2} y={y0 - 12}>{`R = ${radius} ${unit}`}</Label>

      {/* Reference axis along the bottom edge */}
      <line x1={x1 + 4} y1={yb} x2={x1 + 30} y2={yb} stroke={gray} strokeWidth={1} strokeDasharray="5,3" />
      <Label x={x1 + 36} y={yb} italic anchor="start">x</Label>

      {/* Width */}
      <line x1={x0} y1={yb + 8} x2={x0} y2={yb + 34} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x1} y1={yb + 8} x2={x1} y2={yb + 34} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x0} y1={yb + 28} x2={x1} y2={yb + 28} stroke={gray} strokeWidth={1} />
      <line x1={x0 - 4} y1={yb + 32} x2={x0 + 4} y2={yb + 24} stroke={gray} strokeWidth={1.4} />
      <line x1={x1 - 4} y1={yb + 32} x2={x1 + 4} y2={yb + 24} stroke={gray} strokeWidth={1.4} />
      <Label x={(x0 + x1) / 2} y={yb + 40}>{`${width} ${unit}`}</Label>

      {/* Height */}
      <line x1={x0 - 22} y1={y0} x2={x0 - 22} y2={yb} stroke={gray} strokeWidth={1} />
      <line x1={x0 - 26} y1={y0 + 4} x2={x0 - 18} y2={y0 - 4} stroke={gray} strokeWidth={1.4} />
      <line x1={x0 - 26} y1={yb + 4} x2={x0 - 18} y2={yb - 4} stroke={gray} strokeWidth={1.4} />
      <line x1={x0 - 30} y1={y0} x2={x0 - 4} y2={y0} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x0 - 30} y1={yb} x2={x0 - 4} y2={yb} stroke="var(--gray-300)" strokeWidth={1} />
      <Label x={x0 - 30} y={(y0 + yb) / 2} rotate={-90}>{`${height} ${unit}`}</Label>
    </svg>
  );
}

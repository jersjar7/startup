import React from 'react';
import { Label } from '../../primitives';

/**
 * Plate bounded by the x-axis, the line x = L and the curve y = k*sqrt(x).
 * Shows: the shaded region, the curve equation, the bounding line, axis
 * ticks. Does NOT show the centroid.
 */
export function CtMathematicsARootRegion({ k = 2, L = 4 }) {
  const top = k * Math.sqrt(L);
  const s = 150 / Math.max(L, top);
  const ox = 44, oy = 22 + top * s + 16;
  const X = (u) => ox + u * s;
  const Y = (v) => oy - v * s;
  const pts = [];
  for (let i = 0; i <= 60; i++) { const u = (L * i * i) / 3600; pts.push(`${X(u).toFixed(1)},${Y(k * Math.sqrt(u)).toFixed(1)}`); }
  const region = [`${X(0)},${Y(0)}`, ...pts, `${X(L)},${Y(0)}`];
  const W = X(L) + 46, H = oy + 30;
  const lu = L * 0.5;

  return (
    <svg viewBox={`0 0 ${W.toFixed(0)} ${H.toFixed(0)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Region under y = ${k}√x from x = 0 to ${L} ft`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMathARootAx" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L8,4 L0,8 Z" fill="var(--gray-500)" />
        </marker>
      </defs>
      <polygon points={region.join(' ')} fill="var(--ember)" fillOpacity={0.14} stroke="none" />
      {/* axes */}
      <line x1={X(0)} y1={Y(0)} x2={X(L) + 34} y2={Y(0)} stroke="var(--gray-500)" strokeWidth={1.3} markerEnd="url(#ctMathARootAx)" />
      <line x1={X(0)} y1={Y(0)} x2={X(0)} y2={Y(top) - 24} stroke="var(--gray-500)" strokeWidth={1.3} markerEnd="url(#ctMathARootAx)" />
      <Label x={X(L) + 36} y={Y(0) + 14} anchor="end" italic>x (ft)</Label>
      <Label x={X(0) + 8} y={Y(top) - 22} anchor="start" italic>y (ft)</Label>
      {/* boundary */}
      <polyline points={pts.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={X(L)} y1={Y(0)} x2={X(L)} y2={Y(top)} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={X(0)} y1={Y(0)} x2={X(L)} y2={Y(0)} stroke="var(--charcoal)" strokeWidth={2.5} />
      <Label x={X(lu) - 8} y={Y(k * Math.sqrt(lu)) - 14} anchor="end" color="var(--charcoal)" fontSize={12}>y = {k}√x</Label>
      {/* ticks */}
      <Label x={X(0) - 8} y={Y(0) + 12} anchor="end" fontSize={11}>0</Label>
      <Label x={X(L)} y={Y(0) + 14} fontSize={11}>{L}</Label>
      <line x1={X(0) - 4} y1={Y(top)} x2={X(0)} y2={Y(top)} stroke="var(--gray-500)" strokeWidth={1.3} />
      <line x1={X(0)} y1={Y(top)} x2={X(L)} y2={Y(top)} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <Label x={X(0) - 8} y={Y(top)} anchor="end" fontSize={11}>{+top.toFixed(2)}</Label>
      <Label x={X(L) + 8} y={(Y(0) + Y(top)) / 2} anchor="start" italic fontSize={11}>x = {L}</Label>
    </svg>
  );
}

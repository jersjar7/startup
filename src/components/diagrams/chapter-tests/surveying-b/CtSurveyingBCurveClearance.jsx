import React from 'react';
import { arcPath } from '../../geo';
import { Label } from '../../primitives';

/**
 * Horizontal curve, plan view, to scale. Back tangent runs east to the PI,
 * the road turns right by I. Shows the PI station, I, and the external
 * distance E from the PI to the middle of the curve. R, T, L and the PC/PT
 * stations are not shown (they are what the student computes).
 */
export function CtSurveyingBCurveClearance({ I = 38.3333, iText = '38°20′00″', E = 48.5, piSta = '52+46.80' }) {
  const rad = (d) => (d * Math.PI) / 180;
  const R = E / (1 / Math.cos(rad(I / 2)) - 1);
  const T = R * Math.tan(rad(I / 2));
  const s = 380 / (2 * T * (1 + Math.cos(rad(I))) / 2 + 60);
  const pc = { x: 48, y: 40 };
  const pi = { x: pc.x + T * s, y: pc.y };
  const pt = { x: pi.x + T * s * Math.cos(rad(I)), y: pi.y + T * s * Math.sin(rad(I)) };
  const O = { x: pc.x, y: pc.y + R * s };
  // middle of the curve: on the line from the PI to the center, R from O
  const dx = pi.x - O.x;
  const dy = pi.y - O.y;
  const dl = Math.hypot(dx, dy);
  const M = { x: O.x + (dx / dl) * R * s, y: O.y + (dy / dl) * R * s };
  const ext = 30;
  const before = { x: pc.x - ext, y: pc.y };
  const after = { x: pt.x + ext * Math.cos(rad(I)), y: pt.y + ext * Math.sin(rad(I)) };
  const W = Math.ceil(Math.max(after.x, pi.x + 150) + 12);
  const H = Math.ceil(after.y + 12);
  // dimension E, offset to the left of the PI-M line
  const ux = (M.x - pi.x) / Math.hypot(M.x - pi.x, M.y - pi.y);
  const uy = (M.y - pi.y) / Math.hypot(M.x - pi.x, M.y - pi.y);
  const off = 0;
  const e1 = { x: pi.x - uy * off, y: pi.y + ux * off };
  const e2 = { x: M.x - uy * off, y: M.y + ux * off };
  const tick = (p) => <line x1={p.x - ux * 0 - uy * 5} y1={p.y + ux * 5} x2={p.x + uy * 5} y2={p.y - ux * 5} stroke="var(--gray-500)" strokeWidth={1.2} />;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Horizontal curve with PI at station ${piSta}, intersection angle ${iText}, external distance ${E} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {/* road centerline before and after the curve */}
      <line x1={before.x} y1={before.y} x2={pc.x} y2={pc.y} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={pt.x} y1={pt.y} x2={after.x} y2={after.y} stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* tangents and back tangent extension */}
      <line x1={pc.x} y1={pc.y} x2={pi.x + 96} y2={pi.y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="6,4" />
      <line x1={pi.x} y1={pi.y} x2={pt.x} y2={pt.y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="6,4" />
      {/* curve */}
      <path d={`M ${pc.x},${pc.y} A ${R * s},${R * s} 0 0 1 ${pt.x},${pt.y}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* external distance */}
      <line x1={e1.x} y1={e1.y} x2={e2.x} y2={e2.y} stroke="var(--ember)" strokeWidth={1.8} />
      {tick(e1)}{tick(e2)}
      {/* label outside the curve, above the back tangent; the short leader never crosses the arc */}
      <Label x={pi.x - 16} y={pi.y - 14} anchor="end" color="var(--ember)" fontSize={12}>{`E = ${E.toFixed(2)} ft`}</Label>
      <line x1={pi.x - 16} y1={pi.y - 7} x2={(e1.x + e2.x) / 2 - 2} y2={(e1.y + e2.y) / 2 - 1} stroke="var(--ember)" strokeWidth={0.9} />
      <circle cx={(e1.x + e2.x) / 2} cy={(e1.y + e2.y) / 2} r={1.8} fill="var(--ember)" />
      {/* intersection angle */}
      <path d={arcPath(pi.x, pi.y, 62, -I, 0)} fill="none" stroke="var(--gray-500)" strokeWidth={1.3} />
      <Label x={pi.x + 72} y={pi.y + 14} anchor="start" color="var(--charcoal)" fontSize={12}>{`I = ${iText}`}</Label>

      {[pc, pi, pt].map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={3.2} fill="var(--charcoal)" />)}
      <Label x={pc.x} y={pc.y - 14} color="var(--charcoal)" fontSize={12} bold>PC</Label>
      <Label x={pi.x + 8} y={pi.y - 28} anchor="start" color="var(--charcoal)" fontSize={12} bold>PI</Label>
      <Label x={pi.x + 8} y={pi.y - 13} anchor="start" color="var(--gray-500)" fontSize={12}>{`Sta ${piSta}`}</Label>
      <Label x={pt.x + 10} y={pt.y - 8} anchor="start" color="var(--charcoal)" fontSize={12} bold>PT</Label>
    </svg>
  );
}

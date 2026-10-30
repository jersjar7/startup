import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Three rope forces on an eye bolt. Two are given by slope triangles
 * (3-4-5 up and to the right, 12-5-13 down and to the right), one is
 * horizontal to the left.
 * Shows: the three forces, their slope triangles, the x-y axes.
 * Does NOT show: components or the resultant.
 */
export function CtStaticsAEyeBoltForces({ f1 = 200, f2 = 260, f3 = 150, unit = 'N' }) {
  const ox = 150;
  const oy = 112;
  const r0 = 9; // eye radius
  const L = 104;
  const u1 = { x: 0.6, y: -0.8 };
  const u2 = { x: 12 / 13, y: 5 / 13 };
  const t1 = { x: ox + u1.x * L, y: oy + u1.y * L };
  const t2 = { x: ox + u2.x * L, y: oy + u2.y * L };
  const t3 = { x: ox - L, y: oy };

  // Slope triangle for F1 (3 across, 4 up), set off to the lower right of the arrow.
  const s1 = 8;
  const p1 = { x: ox + u1.x * 38 + 0.8 * 26, y: oy + u1.y * 38 + 0.6 * 26 };
  const q1 = { x: p1.x + 3 * s1, y: p1.y }; // right-angle corner
  const r1 = { x: p1.x + 3 * s1, y: p1.y - 4 * s1 };

  // Slope triangle for F2 (12 across, 5 down), set off below the arrow.
  const s2 = 3;
  const p2 = { x: ox + u2.x * 40 - (5 / 13) * 20, y: oy + u2.y * 40 + (12 / 13) * 20 };
  const q2 = { x: p2.x, y: p2.y + 5 * s2 }; // right-angle corner
  const r2 = { x: p2.x + 12 * s2, y: p2.y + 5 * s2 };

  const tri = 'var(--gray-500)';

  return (
    <svg viewBox="0 0 330 222" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Three forces on an eye bolt: ${f1} ${unit} on a 3-4-5 slope, ${f2} ${unit} on a 12-5-13 slope, ${f3} ${unit} horizontal`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStAEyeArrow" color="var(--ember)" size={9} />
      <ArrowMarkerDefs id="ctStAEyeAxis" color="var(--gray-500)" size={7} />

      {/* Axes key, bottom left */}
      <line x1={22} y1={204} x2={62} y2={204} stroke="var(--gray-500)" strokeWidth={1.2} markerEnd="url(#ctStAEyeAxis)" />
      <line x1={22} y1={204} x2={22} y2={164} stroke="var(--gray-500)" strokeWidth={1.2} markerEnd="url(#ctStAEyeAxis)" />
      <Label x={72} y={204} italic anchor="start">x</Label>
      <Label x={22} y={155} italic>y</Label>

      {/* Forces */}
      <line x1={ox + u1.x * r0} y1={oy + u1.y * r0} x2={t1.x} y2={t1.y} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStAEyeArrow)" />
      <line x1={ox + u2.x * r0} y1={oy + u2.y * r0} x2={t2.x} y2={t2.y} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStAEyeArrow)" />
      <line x1={ox - r0} y1={oy} x2={t3.x} y2={t3.y} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStAEyeArrow)" />
      <Label x={t1.x + 6} y={t1.y - 4} color="var(--ember)" bold anchor="start">{`${f1} ${unit}`}</Label>
      <Label x={t2.x + 2} y={t2.y + 18} color="var(--ember)" bold anchor="middle">{`${f2} ${unit}`}</Label>
      <Label x={t3.x + 4} y={t3.y - 14} color="var(--ember)" bold anchor="start">{`${f3} ${unit}`}</Label>

      {/* Slope triangle F1 */}
      <polygon points={`${p1.x},${p1.y} ${q1.x},${q1.y} ${r1.x},${r1.y}`} fill="none" stroke={tri} strokeWidth={1.2} />
      <Label x={(p1.x + q1.x) / 2} y={p1.y + 10}>3</Label>
      <Label x={q1.x + 8} y={(q1.y + r1.y) / 2}>4</Label>

      {/* Slope triangle F2 */}
      <polygon points={`${p2.x},${p2.y} ${q2.x},${q2.y} ${r2.x},${r2.y}`} fill="none" stroke={tri} strokeWidth={1.2} />
      <Label x={p2.x - 8} y={(p2.y + q2.y) / 2}>5</Label>
      <Label x={(q2.x + r2.x) / 2} y={q2.y + 10}>12</Label>

      {/* Eye bolt */}
      <circle cx={ox} cy={oy} r={r0} fill="#fff" stroke="var(--charcoal)" strokeWidth={2.4} />
      <circle cx={ox} cy={oy} r={3} fill="var(--charcoal)" />
    </svg>
  );
}

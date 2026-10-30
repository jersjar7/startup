import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Vertical mast OA with two guy cables from its top A to ground anchors
 * B and C, drawn in an oblique 3D view (x right, y receding, z up).
 * Shows: coordinates of A, B, C (m) and the two cable tensions.
 * Does NOT show: components or the resultant.
 */
export function CtStaticsAMastCables({
  a = [0, 0, 8], b = [4, -1, 0], c = [-4, -8, 0], tab = 1800, tac = 2400, unit = 'N',
}) {
  const S = 18;
  const k = 0.55; // receding scale
  const cos = Math.cos(Math.PI / 6);
  const sin = Math.sin(Math.PI / 6);
  const ox = 172;
  const oy = 14 + S * (a[2] + 1.6);
  const P = ([x, y, z]) => ({ x: ox + S * (x + k * y * cos), y: oy - S * (z + k * y * sin) });
  const O = P([0, 0, 0]);
  const A = P(a);
  const B = P(b);
  const C = P(c);
  // x-axis stops short of B so B's small y = -1 offset is not lost on it
  const X = P([Math.min(7, b[0] - 1.6), 0, 0]);
  const Y = P([0, 7, 0]);
  const Z = P([0, 0, a[2] + 1.6]);
  const fmt = (v) => `(${v.join(', ')})`;
  const mAB = { x: (A.x + B.x) / 2, y: (A.y + B.y) / 2 };
  const mAC = { x: (A.x + C.x) / 2, y: (A.y + C.y) / 2 };
  const W = 336;
  const H = Math.max(C.y, B.y) + 30;

  return (
    <svg viewBox={`0 0 ${W} ${Math.round(H)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Mast with top A at ${fmt(a)} m and cables to B ${fmt(b)} m and C ${fmt(c)} m`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStAMastAxis" color="var(--gray-500)" size={7} />

      {/* Axes */}
      <line x1={O.x} y1={O.y} x2={X.x} y2={X.y} stroke="var(--gray-500)" strokeWidth={1.2} strokeDasharray="5,3" markerEnd="url(#ctStAMastAxis)" />
      <line x1={O.x} y1={O.y} x2={Y.x} y2={Y.y} stroke="var(--gray-500)" strokeWidth={1.2} strokeDasharray="5,3" markerEnd="url(#ctStAMastAxis)" />
      <line x1={A.x} y1={A.y} x2={Z.x} y2={Z.y} stroke="var(--gray-500)" strokeWidth={1.2} strokeDasharray="5,3" markerEnd="url(#ctStAMastAxis)" />
      <Label x={X.x} y={X.y - 12} italic>x</Label>
      <Label x={Y.x + 8} y={Y.y - 6} italic anchor="start">y</Label>
      <Label x={Z.x + 10} y={Z.y + 4} italic anchor="start">z</Label>

      {/* Ground dashes from O to the anchors (plan lines) */}
      <line x1={O.x} y1={O.y} x2={B.x} y2={B.y} stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="2,3" />
      <line x1={O.x} y1={O.y} x2={C.x} y2={C.y} stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="2,3" />

      {/* Mast */}
      <line x1={O.x} y1={O.y} x2={A.x} y2={A.y} stroke="var(--charcoal)" strokeWidth={5} strokeLinecap="round" />

      {/* Cables */}
      <line x1={A.x} y1={A.y} x2={B.x} y2={B.y} stroke="var(--ember)" strokeWidth={1.8} />
      <line x1={A.x} y1={A.y} x2={C.x} y2={C.y} stroke="var(--ember)" strokeWidth={1.8} />
      <Label x={mAB.x + 10} y={mAB.y} color="var(--ember)" bold anchor="start">{`${tab.toLocaleString('en-US')} ${unit}`}</Label>
      <Label x={mAC.x - 10} y={mAC.y} color="var(--ember)" bold anchor="end">{`${tac.toLocaleString('en-US')} ${unit}`}</Label>

      {/* Points */}
      <circle cx={A.x} cy={A.y} r={3.5} fill="var(--charcoal)" />
      <circle cx={B.x} cy={B.y} r={3.5} fill="var(--charcoal)" />
      <circle cx={C.x} cy={C.y} r={3.5} fill="var(--charcoal)" />
      <circle cx={O.x} cy={O.y} r={3} fill="var(--charcoal)" />
      <Label x={A.x - 10} y={A.y - 8} color="var(--charcoal)" anchor="end"><tspan fontWeight={600}>A</tspan>{` ${fmt(a)}`}</Label>
      <Label x={B.x + 8} y={B.y + 14} color="var(--charcoal)" anchor="start"><tspan fontWeight={600}>B</tspan>{` ${fmt(b)}`}</Label>
      <Label x={C.x} y={C.y + 16} color="var(--charcoal)" anchor="start"><tspan fontWeight={600}>C</tspan>{` ${fmt(c)}`}</Label>
      <Label x={O.x - 10} y={O.y - 2} color="var(--charcoal)" anchor="end" bold>O</Label>
      <Label x={W - 8} y={14} anchor="end">coordinates in m</Label>
    </svg>
  );
}

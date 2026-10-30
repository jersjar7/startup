import React from 'react';
import { Label } from '../../primitives';
import { iso } from './iso';

/**
 * Mast on the z axis with two guy cables to ground anchors, isometric.
 * Shows: axes, mast top A and anchors B, C with coordinates (m), the angle
 * between the cables marked theta. Does NOT show the angle's value.
 */
export function CtMathematicsAGuyedMast({ A = [0, 0, 20], B = [12, -9, 0], C = [-15, 0, 0] }) {
  const s = 5.8, ox = 178, oy = 160;
  const P = (v) => iso(ox, oy, s, v);
  const O = P([0, 0, 0]), a = P(A), b = P(B), c = P(C);
  const xE = P([17, 0, 0]), yE = P([0, 17, 0]), zE = P([0, 0, A[2] + 5]);
  const xN = P([-19, 0, 0]);
  const yN = P([0, -5, 0]);
  const fmt = (v) => `(${v.map((n) => String(n).replace('-', '−')).join(', ')})`;
  // small arc at A between the two cables (projected)
  const u1 = { x: b.x - a.x, y: b.y - a.y }, u2 = { x: c.x - a.x, y: c.y - a.y };
  const n1 = Math.hypot(u1.x, u1.y), n2 = Math.hypot(u2.x, u2.y);
  const r = 22;
  const p1 = { x: a.x + (u1.x / n1) * r, y: a.y + (u1.y / n1) * r };
  const p2 = { x: a.x + (u2.x / n2) * r, y: a.y + (u2.y / n2) * r };
  const bis = { x: u1.x / n1 + u2.x / n2, y: u1.y / n1 + u2.y / n2 };
  const bl = Math.hypot(bis.x, bis.y);

  return (
    <svg viewBox="0 0 360 232" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Mast top A ${fmt(A)} m with guy cables to B ${fmt(B)} m and C ${fmt(C)} m`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMathAMastAx" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L8,4 L0,8 Z" fill="var(--gray-400)" />
        </marker>
      </defs>
      {/* axes */}
      <line x1={xN.x} y1={xN.y} x2={xE.x} y2={xE.y} stroke="var(--gray-400)" strokeWidth={1} markerEnd="url(#ctMathAMastAx)" />
      <line x1={yN.x} y1={yN.y} x2={yE.x} y2={yE.y} stroke="var(--gray-400)" strokeWidth={1} markerEnd="url(#ctMathAMastAx)" />
      <line x1={a.x} y1={a.y} x2={zE.x} y2={zE.y} stroke="var(--gray-400)" strokeWidth={1} markerEnd="url(#ctMathAMastAx)" />
      <Label x={xE.x - 6} y={xE.y + 4} anchor="end" italic>x</Label>
      <Label x={yE.x + 6} y={yE.y + 4} anchor="start" italic>y</Label>
      <Label x={zE.x + 9} y={zE.y + 4} anchor="start" italic>z</Label>
      {/* mast */}
      <line x1={O.x} y1={O.y} x2={a.x} y2={a.y} stroke="var(--charcoal)" strokeWidth={4} strokeLinecap="round" />
      {/* cables */}
      <line x1={a.x} y1={a.y} x2={b.x} y2={b.y} stroke="var(--ember)" strokeWidth={1.8} />
      <line x1={a.x} y1={a.y} x2={c.x} y2={c.y} stroke="var(--ember)" strokeWidth={1.8} />
      <path d={`M ${p1.x},${p1.y} Q ${a.x + (bis.x / bl) * r * 1.15},${a.y + (bis.y / bl) * r * 1.15} ${p2.x},${p2.y}`} fill="none" stroke="var(--ember)" strokeWidth={1.3} />
      <Label x={a.x + 12} y={a.y + 36} italic bold color="var(--ember)" fontSize={13}>θ</Label>
      {/* points */}
      {[a, b, c].map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={3.5} fill="var(--charcoal)" />)}
      <circle cx={O.x} cy={O.y} r={2.5} fill="var(--charcoal)" />
      <Label x={a.x + 10} y={a.y - 4} anchor="start" bold color="var(--charcoal)">A {fmt(A)}</Label>
      <Label x={b.x - 8} y={b.y + 14} anchor="middle" bold color="var(--charcoal)">B {fmt(B)}</Label>
      <Label x={c.x + 7} y={c.y + 14} anchor="start" bold color="var(--charcoal)">C {fmt(C)}</Label>
      <Label x={O.x - 9} y={O.y + 4} anchor="end" color="var(--charcoal)">O</Label>
      <Label x={8} y={14} anchor="start" fontSize={11}>coordinates in m</Label>
    </svg>
  );
}

import React from 'react';
import { Label } from '../../primitives';
import { iso } from './iso';

/**
 * Pier with a bracket, a cable force at the bracket tip A, isometric.
 * Shows: axes, pier base O and point A with coordinates (m), the force F
 * as components. Does NOT show the moment.
 */
export function CtMathematicsAPierMoment({ O = [1, 2, 0], A = [3, 2, 6], F = [5, -3, -4], unit = 'kN' }) {
  const s = 21, ox = 170, oy = 178;
  const P = (v) => iso(ox, oy, s, v);
  const o0 = P([0, 0, 0]);
  const pb = P(O), pt = P([O[0], O[1], A[2]]), pa = P(A);
  const xE = P([4.6, 0, 0]), yE = P([0, 5.2, 0]), zE = P([0, 0, 7.6]);
  // force arrow drawn along the projected direction of F, fixed length
  const tip = P([A[0] + F[0], A[1] + F[1], A[2] + F[2]]);
  const dx = tip.x - pa.x, dy = tip.y - pa.y, dl = Math.hypot(dx, dy);
  const fe = { x: pa.x + (dx / dl) * 70, y: pa.y + (dy / dl) * 70 };
  const sg = (n, e, first) => `${n < 0 ? '−' : first ? '' : '+'}${first ? '' : ' '}${Math.abs(n)}${e}`;
  const fLabel = `F = ${sg(F[0], 'i', true)} ${sg(F[1], 'j')} ${sg(F[2], 'k')} ${unit}`;
  const fmt = (v) => `(${v.join(', ')})`;

  return (
    <svg viewBox="0 0 300 250" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Pier base O ${fmt(O)} m, bracket tip A ${fmt(A)} m, force ${fLabel}`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMathAPierAx" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L8,4 L0,8 Z" fill="var(--gray-400)" />
        </marker>
        <marker id="ctMathAPierF" markerWidth={10} markerHeight={10} refX={9} refY={5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L10,5 L0,10 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* axes */}
      <line x1={o0.x} y1={o0.y} x2={xE.x} y2={xE.y} stroke="var(--gray-400)" strokeWidth={1} markerEnd="url(#ctMathAPierAx)" />
      <line x1={o0.x} y1={o0.y} x2={yE.x} y2={yE.y} stroke="var(--gray-400)" strokeWidth={1} markerEnd="url(#ctMathAPierAx)" />
      <line x1={o0.x} y1={o0.y} x2={zE.x} y2={zE.y} stroke="var(--gray-400)" strokeWidth={1} markerEnd="url(#ctMathAPierAx)" />
      <Label x={xE.x - 6} y={xE.y + 4} anchor="end" italic>x</Label>
      <Label x={yE.x + 6} y={yE.y + 4} anchor="start" italic>y</Label>
      <Label x={zE.x} y={zE.y - 9} italic>z</Label>
      {/* pier and bracket */}
      <line x1={pb.x} y1={pb.y} x2={pt.x} y2={pt.y} stroke="var(--charcoal)" strokeWidth={7} strokeLinecap="butt" />
      <line x1={pt.x} y1={pt.y} x2={pa.x} y2={pa.y} stroke="var(--charcoal)" strokeWidth={4} strokeLinecap="round" />
      {[-12, -6, 0, 6].map((d) => <line key={d} x1={pb.x + d} y1={pb.y + 2} x2={pb.x + d - 5} y2={pb.y + 8} stroke="var(--gray-500)" strokeWidth={1} />)}
      <line x1={pb.x - 14} y1={pb.y + 2} x2={pb.x + 12} y2={pb.y + 2} stroke="var(--charcoal)" strokeWidth={1.5} />
      {/* force */}
      <line x1={pa.x} y1={pa.y} x2={fe.x} y2={fe.y} stroke="var(--ember)" strokeWidth={2.5} markerEnd="url(#ctMathAPierF)" />
      <Label x={fe.x - 4} y={fe.y + 15} anchor="middle" bold color="var(--ember)" fontSize={12}>{fLabel}</Label>
      {/* points */}
      <circle cx={pa.x} cy={pa.y} r={3.5} fill="var(--charcoal)" />
      <circle cx={pb.x} cy={pb.y} r={3.5} fill="var(--charcoal)" />
      <Label x={pa.x - 8} y={pa.y - 12} anchor="end" bold color="var(--charcoal)">A {fmt(A)}</Label>
      <Label x={pb.x} y={pb.y + 22} anchor="middle" bold color="var(--charcoal)">O {fmt(O)}</Label>
      <Label x={8} y={14} anchor="start" fontSize={11}>coordinates in m</Label>
    </svg>
  );
}

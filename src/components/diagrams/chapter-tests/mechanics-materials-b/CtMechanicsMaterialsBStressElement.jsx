import React from 'react';
import { Label } from '../../primitives';

// Plane stress element. Normal arrows point away from a face for tension
// and into it for compression; shear arrows run along the faces (positive
// tau_xy acts upward on the right face).
export function CtMechanicsMaterialsBStressElement({ sx = 90, sy = -30, txy = 45, unit = 'MPa' }) {
  const cx = 190;
  const cy = 124;
  const h = 46;
  const L = cx - h;
  const R = cx + h;
  const T = cy - h;
  const B = cy + h;
  const so = 8;
  const ng = 15;
  const nl = 34;
  const sl = 30;
  const sg = txy >= 0 ? 1 : -1;
  const n = (x1, y1, x2, y2, k) => (
    <line key={k} x1={x1} y1={y1} x2={x2} y2={y2} stroke="var(--charcoal)" strokeWidth={2} markerEnd="url(#ctMmBElN)" />
  );
  const s = (x1, y1, x2, y2, k) => (
    <line key={k} x1={x1} y1={y1} x2={x2} y2={y2} stroke="var(--ember)" strokeWidth={1.75} markerEnd="url(#ctMmBElS)" />
  );
  const tx = sx > 0;
  const ty = sy > 0;

  return (
    <svg viewBox="0 0 380 266" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Stress element: sigma x ${sx} ${unit}, sigma y ${sy} ${unit}, tau xy ${txy} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMmBElN" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--charcoal)" />
        </marker>
        <marker id="ctMmBElS" markerWidth={7} markerHeight={7} refX={6} refY={3.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 7,3.5 L 0,7 Z" fill="var(--ember)" />
        </marker>
      </defs>
      <rect x={L} y={T} width={2 * h} height={2 * h} fill="var(--gray-400)" fillOpacity={0.12} stroke="var(--charcoal)" strokeWidth={2} />

      {tx ? n(R + ng, cy, R + ng + nl, cy, 'rx') : n(R + ng + nl, cy, R + ng, cy, 'rx')}
      {tx ? n(L - ng, cy, L - ng - nl, cy, 'lx') : n(L - ng - nl, cy, L - ng, cy, 'lx')}
      <Label x={R + ng + nl + 6} y={cy} anchor="start" bold color="var(--charcoal)">{`${Math.abs(sx)} ${unit}`}</Label>
      <Label x={L - ng - nl - 6} y={cy} anchor="end" bold color="var(--charcoal)">{`${Math.abs(sx)} ${unit}`}</Label>

      {ty ? n(cx, T - ng, cx, T - ng - nl, 'ty') : n(cx, T - ng - nl, cx, T - ng, 'ty')}
      {ty ? n(cx, B + ng, cx, B + ng + nl, 'by') : n(cx, B + ng + nl, cx, B + ng, 'by')}
      <Label x={cx} y={T - ng - nl - 12} bold color="var(--charcoal)">{`${Math.abs(sy)} ${unit}`}</Label>
      <Label x={cx} y={B + ng + nl + 13} bold color="var(--charcoal)">{`${Math.abs(sy)} ${unit}`}</Label>

      {s(R + so, cy + sg * sl, R + so, cy - sg * sl, 'rs')}
      {s(L - so, cy - sg * sl, L - so, cy + sg * sl, 'ls')}
      {s(cx - sg * sl, T - so, cx + sg * sl, T - so, 'ts')}
      {s(cx + sg * sl, B + so, cx - sg * sl, B + so, 'bs')}
      <Label x={R + so + 7} y={cy + 24} anchor="start" bold color="var(--ember)">{`${Math.abs(txy)} ${unit}`}</Label>

      <line x1={30} y1={248} x2={64} y2={248} stroke="var(--gray-500)" strokeWidth={1.25} markerEnd="url(#ctMmBElN)" />
      <line x1={30} y1={248} x2={30} y2={214} stroke="var(--gray-500)" strokeWidth={1.25} markerEnd="url(#ctMmBElN)" />
      <Label x={74} y={248} italic color="var(--gray-500)">x</Label>
      <Label x={30} y={204} italic color="var(--gray-500)">y</Label>
    </svg>
  );
}

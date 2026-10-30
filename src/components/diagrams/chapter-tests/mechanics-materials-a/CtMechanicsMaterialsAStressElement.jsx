import React from 'react';
import { Label } from '../../primitives';

// Plane stress element. Normal arrows point out for tension, in for
// compression; shear arrows run along the faces (positive: up on the +x face).
export function CtMechanicsMaterialsAStressElement({ sx = -45, sy = 75, txy = 32, unit = 'MPa' }) {
  const cx = 190;
  const cy = 140;
  const h = 48;
  const L = cx - h;
  const R = cx + h;
  const T = cy - h;
  const B = cy + h;
  const so = 7; // shear arrow offset from face
  const ng = 14; // normal arrow gap from face (clears the shear arrows)
  const nl = 34;
  const sl = 34; // half-length of shear arrows
  const sgn = txy >= 0 ? 1 : -1;

  const nArrow = (x1, y1, x2, y2, key) => (
    <line key={key} x1={x1} y1={y1} x2={x2} y2={y2} stroke="var(--charcoal)" strokeWidth={2} markerEnd="url(#ctMmAElemN)" />
  );
  const sArrow = (x1, y1, x2, y2, key) => (
    <line key={key} x1={x1} y1={y1} x2={x2} y2={y2} stroke="var(--ember)" strokeWidth={1.75} markerEnd="url(#ctMmAElemS)" />
  );
  const tx = sx > 0;
  const ty = sy > 0;

  return (
    <svg viewBox="0 0 380 286" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Stress element: sigma x ${sx} ${unit}, sigma y ${sy} ${unit}, shear ${txy} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMmAElemN" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--charcoal)" />
        </marker>
        <marker id="ctMmAElemS" markerWidth={7} markerHeight={7} refX={6} refY={3.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 7,3.5 L 0,7 Z" fill="var(--ember)" />
        </marker>
      </defs>
      <rect x={L} y={T} width={2 * h} height={2 * h} fill="var(--gray-400)" fillOpacity={0.12} stroke="var(--charcoal)" strokeWidth={2} />

      {/* sigma x */}
      {tx ? nArrow(R + ng, cy, R + ng + nl, cy, 'rx') : nArrow(R + ng + nl, cy, R + ng, cy, 'rx')}
      {tx ? nArrow(L - ng, cy, L - ng - nl, cy, 'lx') : nArrow(L - ng - nl, cy, L - ng, cy, 'lx')}
      <Label x={R + ng + nl + 6} y={cy} anchor="start" bold color="var(--charcoal)">{`${Math.abs(sx)} ${unit}`}</Label>
      <Label x={L - ng - nl - 6} y={cy} anchor="end" bold color="var(--charcoal)">{`${Math.abs(sx)} ${unit}`}</Label>

      {/* sigma y */}
      {ty ? nArrow(cx, T - ng, cx, T - ng - nl, 'ty') : nArrow(cx, T - ng - nl, cx, T - ng, 'ty')}
      {ty ? nArrow(cx, B + ng, cx, B + ng + nl, 'by') : nArrow(cx, B + ng + nl, cx, B + ng, 'by')}
      <Label x={cx} y={T - ng - nl - 12} bold color="var(--charcoal)">{`${Math.abs(sy)} ${unit}`}</Label>
      <Label x={cx} y={B + ng + nl + 13} bold color="var(--charcoal)">{`${Math.abs(sy)} ${unit}`}</Label>

      {/* shear */}
      {sArrow(R + so, cy + sgn * sl, R + so, cy - sgn * sl, 'rs')}
      {sArrow(L - so, cy - sgn * sl, L - so, cy + sgn * sl, 'ls')}
      {sArrow(cx - sgn * sl, T - so, cx + sgn * sl, T - so, 'ts')}
      {sArrow(cx + sgn * sl, B + so, cx - sgn * sl, B + so, 'bs')}
      <Label x={R + 16} y={T - 14} anchor="start" bold color="var(--ember)">{`${Math.abs(txy)} ${unit}`}</Label>

      {/* axes */}
      <line x1={36} y1={262} x2={72} y2={262} stroke="var(--gray-500)" strokeWidth={1.25} markerEnd="url(#ctMmAElemN)" />
      <line x1={36} y1={262} x2={36} y2={226} stroke="var(--gray-500)" strokeWidth={1.25} markerEnd="url(#ctMmAElemN)" />
      <Label x={82} y={262} italic color="var(--gray-500)">x</Label>
      <Label x={36} y={216} italic color="var(--gray-500)">y</Label>
    </svg>
  );
}

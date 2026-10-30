import React from 'react';
import { Label, ArrowMarkerDefs } from '../../primitives';

/**
 * Plan view of a planted strip bounded by a straight sidewalk edge
 * y = m x + c above and a curved curb y = k x^2 below, with the region shaded.
 * Shows: both boundaries with their equations, the shaded region, the two
 * crossing points P and Q.
 * Does NOT show: the crossing coordinates or the area.
 */
export function CtMathematicsBCurbRegion({ k = 0.25, m = 0.5, c = 6, unit = 'm' }) {
  // Crossings of k x^2 = m x + c.
  const disc = Math.sqrt(m * m + 4 * k * c);
  const x1 = (m - disc) / (2 * k);
  const x2 = (m + disc) / (2 * k);
  const yTop = Math.max(k * x1 * x1, k * x2 * x2) + 2.2;
  const xmin = x1 - 2.5;
  const xmax = x2 + 5;
  const s = 22;
  const padL = 18;
  const padT = 22;
  const X = (x) => padL + (x - xmin) * s;
  const Y = (y) => padT + (yTop - y) * s;
  const W = Math.round(X(xmax) + 20);
  const H = Math.round(Y(0) + 24);

  const fmt = (v) => (Number.isInteger(v) ? `${v}` : v.toFixed(2).replace(/0+$/, ''));
  const par = [];
  const xa = -Math.sqrt(yTop / k);
  const xb = Math.sqrt((yTop - 0.4) / k) - 0.0;
  for (let i = 0; i <= 80; i++) { const x = xa + ((xb - xa) * i) / 80; par.push(`${X(x).toFixed(1)},${Y(k * x * x).toFixed(1)}`); }
  const region = [];
  for (let i = 0; i <= 60; i++) { const x = x1 + ((x2 - x1) * i) / 60; region.push(`${X(x).toFixed(1)},${Y(k * x * x).toFixed(1)}`); }
  region.push(`${X(x2).toFixed(1)},${Y(m * x2 + c).toFixed(1)}`, `${X(x1).toFixed(1)},${Y(m * x1 + c).toFixed(1)}`);
  const lx0 = xmin + 0.3;
  const lx1 = xmax - 0.2;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Region between the ground line y = ${m}x + ${c} and the ditch bottom y = ${k}x squared, shaded; x and y in ${unit}`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctMathBCurbAxis" color="var(--gray-500)" size={7} />

      {/* Axes */}
      <line x1={X(xmin)} y1={Y(0)} x2={X(xmax)} y2={Y(0)} stroke="var(--gray-500)" strokeWidth={1.2} markerEnd="url(#ctMathBCurbAxis)" />
      <line x1={X(0)} y1={Y(0) + 6} x2={X(0)} y2={padT - 8} stroke="var(--gray-500)" strokeWidth={1.2} markerEnd="url(#ctMathBCurbAxis)" />
      <Label x={X(xmax) - 4} y={Y(0) + 13} color="var(--gray-500)" fontSize={11} italic>{`x (${unit})`}</Label>
      <Label x={X(0) - 8} y={padT - 4} anchor="end" color="var(--gray-500)" fontSize={11} italic>{`y (${unit})`}</Label>
      <Label x={X(0) - 8} y={Y(0) + 12} color="var(--gray-500)" fontSize={11}>O</Label>

      {/* Planted region */}
      <polygon points={region.join(' ')} fill="var(--ember)" fillOpacity={0.16} stroke="none" />

      {/* Curb (parabola) and sidewalk edge (line) */}
      <polyline points={par.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.2} />
      <line x1={X(lx0)} y1={Y(m * lx0 + c)} x2={X(lx1)} y2={Y(m * lx1 + c)} stroke="var(--forest)" strokeWidth={2.2} />

      <Label x={X(xa) + 8} y={Y(yTop) + 2} anchor="start" color="var(--charcoal)" fontSize={12}>{`y = ${fmt(k)}x²`}</Label>
      {(() => {
        const xl = lx1 - 1.9;
        const ang = (-Math.atan(m) * 180) / Math.PI;
        const nx = Math.sin((-ang * Math.PI) / 180) * 13;
        const ny = Math.cos((-ang * Math.PI) / 180) * 13;
        return (
          <Label x={X(xl) + nx} y={Y(m * xl + c) + ny} rotate={ang} color="var(--forest)" fontSize={12}>{`y = ${fmt(m)}x + ${fmt(c)}`}</Label>
        );
      })()}

      {[['P', x1, -12], ['Q', x2, -14]].map(([n, xv, dx]) => (
        <g key={n}>
          <circle cx={X(xv)} cy={Y(k * xv * xv)} r={3.5} fill="var(--charcoal)" />
          <Label x={X(xv) + dx} y={Y(k * xv * xv) - 10} color="var(--charcoal)" fontSize={13} bold>{n}</Label>
        </g>
      ))}
    </svg>
  );
}

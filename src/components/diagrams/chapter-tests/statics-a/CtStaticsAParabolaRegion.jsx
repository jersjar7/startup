import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Region under y = kx^2 from x = 0 to x = b, with a vertical strip of
 * width dx at a general x.
 * Shows: the curve, the bound b, a typical strip of height y.
 * Does NOT show: the centroid.
 */
export function CtStaticsAParabolaRegion({ curveLabel = 'y = kx²' }) {
  const ox = 40;
  const oy = 210;
  const bw = 250; // px for x = b
  const hh = 170; // px for y at x = b
  const f = (t) => oy - hh * t * t; // t = x/b
  const pts = Array.from({ length: 41 }, (_, i) => {
    const t = i / 40;
    return `${ox + bw * t},${f(t)}`;
  });
  const region = `M ${ox} ${oy} L ${pts.join(' L ')} L ${ox + bw} ${oy} Z`;
  const t0 = 0.66;
  const sx = ox + bw * t0;
  const sw = 12;
  const sTop = f(t0 + sw / 2 / bw);
  const gray = 'var(--gray-500)';

  return (
    <svg viewBox="0 0 330 264" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Region under the curve y equals k x squared from x equals 0 to b, with a vertical strip"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStAParAxis" color="var(--charcoal)" size={8} />

      <path d={region} fill="var(--ember)" fillOpacity={0.1} stroke="none" />
      {/* Strip */}
      <rect x={sx - sw / 2} y={sTop} width={sw} height={oy - sTop} fill="var(--ember)" fillOpacity={0.35} stroke="var(--ember)" strokeWidth={1.2} />

      {/* Curve and bound */}
      <polyline points={pts.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.2} />
      <line x1={ox + bw} y1={f(1)} x2={ox + bw} y2={oy} stroke="var(--charcoal)" strokeWidth={1.8} />

      {/* Axes */}
      <line x1={ox} y1={oy} x2={ox + bw + 40} y2={oy} stroke="var(--charcoal)" strokeWidth={1.4} markerEnd="url(#ctStAParAxis)" />
      <line x1={ox} y1={oy} x2={ox} y2={18} stroke="var(--charcoal)" strokeWidth={1.4} markerEnd="url(#ctStAParAxis)" />
      <Label x={ox + bw + 48} y={oy} italic color="var(--charcoal)" anchor="start">x</Label>
      <Label x={ox} y={10} italic color="var(--charcoal)">y</Label>
      <Label x={ox - 10} y={oy + 10} color="var(--charcoal)" italic>0</Label>

      {/* Labels */}
      <Label x={ox + bw * 0.8 - 8} y={f(0.8) - 8} color="var(--charcoal)" italic anchor="end">{curveLabel}</Label>
      <Label x={ox + bw} y={oy + 14} color="var(--charcoal)" italic>b</Label>
      <Label x={sx} y={oy + 14} color="var(--ember)" italic>dx</Label>
      <Label x={sx - sw / 2 - 6} y={(sTop + oy) / 2} color="var(--ember)" italic anchor="end">y</Label>
      <line x1={ox} y1={oy + 32} x2={sx} y2={oy + 32} stroke={gray} strokeWidth={1} />
      <line x1={ox} y1={oy + 27} x2={ox} y2={oy + 37} stroke={gray} strokeWidth={1} />
      <line x1={sx} y1={oy + 27} x2={sx} y2={oy + 37} stroke={gray} strokeWidth={1} />
      <Label x={(ox + sx) / 2} y={oy + 45} italic>x</Label>
    </svg>
  );
}

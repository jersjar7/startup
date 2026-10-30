import React from 'react';
import { T, Dim, Ext, Head, Leader } from './CtFluidMechanicsBParts';

/**
 * Pump shaft turning inside a sleeve bearing, long section. The oil film is
 * drawn enlarged so it can be seen.
 * Shows: shaft diameter, sleeve length, speed, clearance note.
 * Does NOT show: shear stress or torque (student solves).
 */
export function CtFluidMechanicsBBearing({ d = 80, len = 120, clearance = 0.2, rpm = 1200, mu = 0.12 }) {
  const W = 440;
  const s = 1; // px per mm
  const cy = 118;
  const r = (d * s) / 2;
  const gap = 6; // drawn, not to scale
  const th = 22;
  const sx0 = 150;
  const sx1 = sx0 + len * s;
  const shx0 = 84;
  const shx1 = 384;
  const topY = cy - r - gap - th;
  const botY = cy + r + gap + th;
  const H = botY + 46;
  const hatch = (y0) => Array.from({ length: Math.ceil((len * s + th) / 8) }, (_, i) => {
    const x = sx0 + i * 8;
    return <line key={`${y0}-${i}`} x1={x} y1={y0 + th} x2={x + th} y2={y0} stroke="var(--gray-500)" strokeWidth={1} />;
  });
  const ex = 352; // rotation ellipse
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Shaft ${d} mm in diameter turning at ${rpm} rpm in a sleeve bearing ${len} mm long with an oil film`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <clipPath id="ctFmbBearClipTop"><rect x={sx0} y={topY} width={len * s} height={th} /></clipPath>
        <clipPath id="ctFmbBearClipBot"><rect x={sx0} y={cy + r + gap} width={len * s} height={th} /></clipPath>
      </defs>
      {/* shaft */}
      <rect x={shx0} y={cy - r} width={shx1 - shx0} height={2 * r} fill="var(--gray-200)" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={shx0 - 8} y1={cy} x2={shx1 + 8} y2={cy} stroke="var(--gray-400)" strokeWidth={0.9} strokeDasharray="10,3,2,3" />
      {/* oil film */}
      <rect x={sx0} y={cy - r - gap} width={len * s} height={gap} fill="var(--ember)" fillOpacity={0.45} />
      <rect x={sx0} y={cy + r} width={len * s} height={gap} fill="var(--ember)" fillOpacity={0.45} />
      {/* sleeve, sectioned */}
      <g clipPath="url(#ctFmbBearClipTop)">{hatch(topY)}</g>
      <g clipPath="url(#ctFmbBearClipBot)">{hatch(cy + r + gap)}</g>
      <rect x={sx0} y={topY} width={len * s} height={th} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <rect x={sx0} y={cy + r + gap} width={len * s} height={th} fill="none" stroke="var(--charcoal)" strokeWidth={2} />

      {/* sleeve length */}
      <Ext x1={sx0} y1={topY - 3} x2={sx0} y2={topY - 26} />
      <Ext x1={sx1} y1={topY - 3} x2={sx1} y2={topY - 26} />
      <Dim x1={sx0} y1={topY - 18} x2={sx1} y2={topY - 18} label={`${len} mm`} lx={(sx0 + sx1) / 2} ly={topY - 30} />

      {/* shaft diameter */}
      <Ext x1={shx0 - 3} y1={cy - r} x2={shx0 - 30} y2={cy - r} />
      <Ext x1={shx0 - 3} y1={cy + r} x2={shx0 - 30} y2={cy + r} />
      <Dim x1={shx0 - 22} y1={cy - r} x2={shx0 - 22} y2={cy + r} label={`${d} mm`} lx={shx0 - 28} ly={cy - 14} anchor="end" />

      {/* oil film label */}
      <T x={sx1 + 30} y={topY - 14} anchor="start" color="var(--gray-500)">oil film</T>
      <T x={sx1 + 30} y={topY + 2} anchor="start" color="var(--gray-500)">{`μ = ${mu} Pa·s`}</T>
      <Leader x1={sx1 + 26} y1={topY + 2} x2={sx1 - 4} y2={cy - r - gap / 2} />

      {/* rotation */}
      <path d={`M ${ex},${cy - r - 6} A 11,${r + 6} 0 0 1 ${ex},${cy + r + 6}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      <Head x={ex - 1} y={cy + r + 6} dx={-1} dy={0.25} size={8} />
      <T x={ex} y={cy + r + 24} anchor="middle">{`${rpm.toLocaleString('en-US')} rpm`}</T>

      <T x={shx0 - 50} y={H - 12} anchor="start" color="var(--gray-500)">{`diametral clearance ${clearance.toFixed(2)} mm (film drawn enlarged)`}</T>
    </svg>
  );
}

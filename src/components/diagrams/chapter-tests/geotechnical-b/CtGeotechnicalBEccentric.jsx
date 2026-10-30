import React from 'react';
import { SubText, SurfaceHatch, HDim } from './ctGeoBParts';

/**
 * Strip footing (per foot of length) carrying a vertical load and a moment at
 * the top of the footing, both at the footing centerline. Footing width to
 * scale. Shows the loads given, never the soil pressure.
 */
export function CtGeotechnicalBEccentric({
  B = 8,
  V = 24,
  M = 16,
  unit = 'ft',
  vUnit = 'kips/ft',
  mUnit = 'kip-ft/ft',
}) {
  const W = 420;
  const sc = 220 / B;
  const cx = 200;
  const fL = cx - (B * sc) / 2;
  const fR = cx + (B * sc) / 2;
  const fTop = 128;
  const fT = 1.5 * sc;
  const fBot = fTop + fT;
  const colW = 1.5 * sc;
  const gY = fTop - 0.8 * sc;
  const colTop = 78;
  const H = fBot + 44;
  const r = 28;
  const mY = colTop - 2;
  // moment arc: clockwise around (cx, mY), from left side over the top to the right
  const a0 = (200 * Math.PI) / 180;
  const a1 = (-20 * Math.PI) / 180;
  const p0 = { x: cx + r * Math.cos(a0), y: mY - r * Math.sin(a0) };
  const p1 = { x: cx + r * Math.cos(a1), y: mY - r * Math.sin(a1) };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Strip footing ${B} ${unit} wide with a vertical load of ${V} ${vUnit} and a moment of ${M} ${mUnit}`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctGeoBEccArrow" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* Soil */}
      <rect x={12} y={gY} width={W - 24} height={fBot + 10 - gY} fill="var(--gray-400)" fillOpacity={0.12} />
      <line x1={12} y1={gY} x2={cx - colW / 2} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={cx + colW / 2} y1={gY} x2={W - 12} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      <SurfaceHatch x1={12} x2={cx - colW / 2 - 4} y={gY} step={18} len={6} />
      <SurfaceHatch x1={cx + colW / 2 + 4} x2={W - 12} y={gY} step={18} len={6} />

      {/* Column stub and footing */}
      <rect x={cx - colW / 2} y={colTop} width={colW} height={fTop - colTop}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <rect x={fL} y={fTop} width={fR - fL} height={fT}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={cx} y1={fBot + 4} x2={cx} y2={fBot + 16} stroke="var(--gray-500)" strokeWidth={1} />
      <text x={cx + 6} y={fBot + 12} fill="var(--gray-500)" fontFamily="var(--font-body)" fontSize={11}>CL</text>

      {/* Vertical load */}
      <line x1={cx} y1={8} x2={cx} y2={colTop - 2} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctGeoBEccArrow)" />
      <SubText x={cx - 10} y={20} color="var(--ember)" anchor="end">{`V = ${V} ${vUnit}`}</SubText>

      {/* Moment */}
      <path d={`M ${p0.x} ${p0.y} A ${r} ${r} 0 1 1 ${p1.x} ${p1.y}`} fill="none" stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctGeoBEccArrow)" />
      <SubText x={cx + r + 14} y={mY - 18} color="var(--ember)">{`M = ${M} ${mUnit}`}</SubText>

      <HDim y={fBot + 24} x1={fL} x2={fR} label={`B = ${B} ${unit}`} />
    </svg>
  );
}

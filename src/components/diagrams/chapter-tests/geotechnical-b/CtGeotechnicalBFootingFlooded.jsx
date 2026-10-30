import React from 'react';
import { SubText, WaterMark, SurfaceHatch, VDim, HDim } from './ctGeoBParts';

/**
 * Strip footing cross-section drawn to scale with the water table at the
 * ground surface, so all of the soil drawn is below water. Shows B, Df and the
 * soil properties given. Never shows a capacity.
 */
export function CtGeotechnicalBFootingFlooded({
  B = 4,
  Df = 3,
  unit = 'ft',
  soil = [],
  footingT = 1.25,
}) {
  const W = 420;
  const sc = Math.min(150 / B, 100 / Df);
  const gY = 22;
  const baseY = gY + Df * sc;
  const ft = footingT * sc;
  const cx = 170;
  const fw = B * sc;
  const fL = cx - fw / 2;
  const fR = cx + fw / 2;
  const colW = Math.max(26, fw * 0.24);
  const textTop = baseY + 54;
  const soilBot = textTop + Math.max(0, soil.length - 1) * 16 + 18;
  const H = soilBot + 8;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Strip footing, B = ${B} ${unit}, Df = ${Df} ${unit}, water table at the ground surface`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Soil, all below the water table */}
      <rect x={12} y={gY} width={W - 24} height={soilBot - gY} fill="var(--gray-400)" fillOpacity={0.12} />
      <rect x={12} y={gY} width={W - 24} height={soilBot - gY} fill="var(--info)" fillOpacity={0.08} />

      {/* Ground surface = water table */}
      <line x1={12} y1={gY} x2={cx - colW / 2} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={cx + colW / 2} y1={gY} x2={W - 12} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      <SurfaceHatch x1={12} x2={cx - colW / 2 - 4} y={gY} step={18} len={6} />
      <SurfaceHatch x1={cx + colW / 2 + 4} x2={fR + 20} y={gY} step={18} len={6} />
      <SurfaceHatch x1={fR + 42} x2={W - 110} y={gY} step={18} len={6} />
      <WaterMark x={W - 40} y={gY} />
      <SubText x={W - 52} y={gY - 10} color="var(--info)" anchor="end">WT at ground surface</SubText>

      {/* Column stub and footing */}
      <rect x={cx - colW / 2} y={2} width={colW} height={baseY - ft - 2}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <rect x={fL} y={baseY - ft} width={fw} height={ft}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Dimensions */}
      <HDim y={baseY + 16} x1={fL} x2={fR} label={`B = ${B} ${unit}`} />
      <VDim x={fR + 30} y1={gY} y2={baseY} label={`D_f = ${Df} ${unit}`} side="right" />

      {/* Soil properties */}
      {soil.map((t, i) => (
        <SubText key={i} x={24} y={textTop + i * 16}>{t}</SubText>
      ))}
    </svg>
  );
}

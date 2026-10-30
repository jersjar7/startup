import React from 'react';
import { SubText, WaterMark, SurfaceHatch, VDim, HDim } from './ctGeoAParts';

/**
 * Strip footing cross-section drawn to scale: width B, embedment Df, the column
 * stub it carries, the soil properties given, and an optional water table at
 * the footing base. Shows givens only, never a capacity or a load.
 */
export function CtGeotechnicalAFooting({
  B = 5,
  Df = 3,
  unit = 'ft',
  waterAtBase = false,
  soilAbove = [],
  soilBelow = [],
  footingT = 1.25,
}) {
  const W = 420;
  const sc = Math.min(180 / B, 120 / Df);
  const gY = 18;
  const baseY = gY + Df * sc;
  const ft = footingT * sc;
  const cx = W / 2;
  const fw = B * sc;
  const fL = cx - fw / 2;
  const fR = cx + fw / 2;
  const colW = Math.max(26, fw * 0.24);
  const below = 46 + soilBelow.length * 16;
  const soilBot = baseY + below + 4;
  const H = soilBot + 8;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Strip footing, B = ${B} ${unit}, Df = ${Df} ${unit}${waterAtBase ? ', water table at the footing base' : ''}`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Soil */}
      <rect x={12} y={gY} width={W - 24} height={soilBot - gY} fill="var(--gray-400)" fillOpacity={0.12} />
      {waterAtBase && (
        <rect x={12} y={baseY} width={W - 24} height={soilBot - baseY} fill="var(--info)" fillOpacity={0.08} />
      )}

      {/* Ground surface */}
      <line x1={12} y1={gY} x2={cx - colW / 2} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={cx + colW / 2} y1={gY} x2={W - 12} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      <SurfaceHatch x1={12} x2={cx - colW / 2 - 4} y={gY} step={18} len={6} />
      <SurfaceHatch x1={cx + colW / 2 + 4} x2={fR + 22} y={gY} step={18} len={6} />
      <SurfaceHatch x1={fR + 38} x2={W - 12} y={gY} step={18} len={6} />

      {/* Column stub and footing */}
      <rect x={cx - colW / 2} y={2} width={colW} height={baseY - ft - 2}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <rect x={fL} y={baseY - ft} width={fw} height={ft}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Water table at the base */}
      {waterAtBase && (
        <g>
          <line x1={12} y1={baseY} x2={fL - 4} y2={baseY} stroke="var(--info)" strokeWidth={1.5} strokeDasharray="7,4" />
          <line x1={fR + 4} y1={baseY} x2={W - 12} y2={baseY} stroke="var(--info)" strokeWidth={1.5} strokeDasharray="7,4" />
          <WaterMark x={W - 32} y={baseY} />
          <SubText x={W - 44} y={baseY - 9} color="var(--info)" anchor="end">WT</SubText>
        </g>
      )}

      {/* Dimensions */}
      <HDim y={baseY + 16} x1={fL} x2={fR} label={`B = ${B} ${unit}`} />
      <VDim x={fR + 30} y1={gY} y2={baseY} label={`D_f = ${Df} ${unit}`} side="right" />

      {/* Soil properties */}
      {soilAbove.map((t, i) => (
        <SubText key={`a${i}`} x={24} y={(gY + baseY) / 2 - ((soilAbove.length - 1) * 16) / 2 + i * 16 + 4}
          color="var(--charcoal)">{t}</SubText>
      ))}
      {soilBelow.map((t, i) => (
        <SubText key={`b${i}`} x={24} y={baseY + 50 + i * 16} color="var(--charcoal)">{t}</SubText>
      ))}
    </svg>
  );
}

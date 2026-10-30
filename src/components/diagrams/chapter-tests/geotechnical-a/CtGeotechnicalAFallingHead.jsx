import React from 'react';
import { SubText, WaterMark, VDim, HDim } from './ctGeoAParts';

/**
 * Falling-head permeameter drawn to one scale: a soil sample in a water bath
 * whose surface is level with the sample top (the datum), and a standpipe on
 * the sample whose water level falls from h1 to h2. Widths keep the true
 * standpipe-to-sample ratio. Shows the givens only, never K.
 */
export function CtGeotechnicalAFallingHead({
  D = 10, L = 12, d = 1.0, h1 = 80, h2 = 40, t = '10 min', unit = 'cm',
}) {
  const s = 3; // px per cm, every direction
  const cx = 170;
  const top = 10;
  const yT = top + 18 + h1 * s; // datum: bath surface = sample top
  const sw = D * s;
  const sh = L * s;
  const tw = Math.max(3, d * s);
  const stone = 4;
  const yS = yT + sh; // sample bottom
  const yB = yS + stone + 6; // bath floor
  const bathL = 90;
  const bathR = 290;
  const y1 = yT - h1 * s;
  const y2 = yT - h2 * s;
  const W = 452;
  const H = yB + 38;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Falling-head permeameter: sample ${D} ${unit} diameter by ${L} ${unit}, standpipe ${d} ${unit}, head falls from ${h1} to ${h2} ${unit} in ${t}`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Bath water up to the datum */}
      <rect x={bathL} y={yT} width={bathR - bathL} height={yB - yT} fill="var(--info)" fillOpacity={0.10} />
      <polyline points={`${bathL},${yT - 16} ${bathL},${yB} ${bathR},${yB} ${bathR},${yT - 16}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={bathL} y1={yT} x2={bathR} y2={yT} stroke="var(--info)" strokeWidth={1.4} />
      <WaterMark x={bathR - 22} y={yT} />

      {/* Porous stone and sample */}
      <rect x={cx - sw / 2 - 3} y={yS} width={sw + 6} height={stone} fill="var(--gray-400)" fillOpacity={0.6} />
      <rect x={cx - sw / 2} y={yT} width={sw} height={sh} fill="var(--gray-400)" fillOpacity={0.45}
        stroke="var(--charcoal)" strokeWidth={1.6} />
      <rect x={cx - sw / 2 - 3} y={yT - 3} width={sw + 6} height={3} fill="var(--charcoal)" />

      {/* Standpipe */}
      <rect x={cx - tw / 2} y={y1} width={tw} height={yT - 3 - y1} fill="var(--info)" fillOpacity={0.55} />
      <line x1={cx - tw / 2} y1={top} x2={cx - tw / 2} y2={yT - 3} stroke="var(--charcoal)" strokeWidth={1.2} />
      <line x1={cx + tw / 2} y1={top} x2={cx + tw / 2} y2={yT - 3} stroke="var(--charcoal)" strokeWidth={1.2} />

      {/* Head levels */}
      <line x1={cx + tw / 2 + 2} y1={y1} x2={386} y2={y1} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <line x1={cx + tw / 2 + 2} y1={y2} x2={310} y2={y2} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <line x1={bathR} y1={yT} x2={386} y2={yT} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <SubText x={cx - 10} y={y1} anchor="end">{'t = 0'}</SubText>
      <SubText x={cx - 10} y={y2} anchor="end">{`t = ${t}`}</SubText>
      <SubText x={cx - 10} y={(y1 + y2) / 2} anchor="end" color="var(--gray-500)">{`standpipe, d = ${Number(d).toFixed(1)} ${unit}`}</SubText>

      <VDim x={304} y1={yT} y2={y2} label={`h_2 = ${h2} ${unit}`} side="right" />
      <VDim x={380} y1={yT} y2={y1} label={`h_1 = ${h1} ${unit}`} side="right" />

      {/* Sample dimensions */}
      <VDim x={cx + sw / 2 + 14} y1={yT} y2={yS} label={`L = ${L} ${unit}`} side="right" />
      <line x1={cx - sw / 2} y1={yS + stone + 2} x2={cx - sw / 2} y2={yB + 18} stroke="var(--gray-400)" strokeWidth={0.8} />
      <line x1={cx + sw / 2} y1={yS + stone + 2} x2={cx + sw / 2} y2={yB + 18} stroke="var(--gray-400)" strokeWidth={0.8} />
      <HDim y={yB + 14} x1={cx - sw / 2} x2={cx + sw / 2} label={`D = ${D} ${unit}`} />
    </svg>
  );
}

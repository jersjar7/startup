import React from 'react';
import { SubText, WaterMark, SurfaceHatch, VDim } from './ctGeoAParts';

/**
 * Excavation dewatered to its floor, a sand layer under the floor and a
 * gravel aquifer below it whose piezometric level stands above the floor.
 * Drawn to scale. Shows the givens only, never a gradient or safety factor.
 */
export function CtGeotechnicalAUplift({
  cut = 9, sandH = 10, head = 7, unit = 'ft',
  sand = ['Sand', 'γ_sat = 120 pcf'], gravel = 'Gravel aquifer',
}) {
  const s = 11;
  const gY = 16;
  const fY = gY + cut * s; // excavation floor
  const bY = fY + sandH * s; // sand / gravel boundary
  const endY = bY + 46;
  const W = 440;
  const fL = 150;
  const fR = 330;
  const side = cut * s * 0.75; // cut slope run
  const pX = fR - 46; // piezometer
  const pY = fY - head * s;
  const H = endY + 8;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Excavation floor over ${sandH} ${unit} of sand on a gravel aquifer; piezometric level ${head} ${unit} above the floor`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Soil outside and below the cut */}
      <polygon points={`12,${gY} ${fL - side},${gY} ${fL},${fY} ${fR},${fY} ${fR + side},${gY} ${W - 12},${gY} ${W - 12},${bY} 12,${bY}`}
        fill="var(--gray-400)" fillOpacity={0.12} />
      <rect x={12} y={bY} width={W - 24} height={endY - bY} fill="var(--gray-400)" fillOpacity={0.28} />
      <polyline points={`12,${gY} ${fL - side},${gY} ${fL},${fY} ${fR},${fY} ${fR + side},${gY} ${W - 12},${gY}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <SurfaceHatch x1={12} x2={fL - side - 4} y={gY} step={16} len={6} />
      <SurfaceHatch x1={fR + side + 4} x2={W - 12} y={gY} step={16} len={6} />
      <line x1={12} y1={bY} x2={W - 12} y2={bY} stroke="var(--charcoal)" strokeWidth={1.4} />
      <line x1={12} y1={endY} x2={W - 12} y2={endY} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="6,4" />

      {/* Piezometer: tip in the gravel, water standing above the floor */}
      <rect x={pX - 2.5} y={pY} width={5} height={bY + 14 - pY} fill="var(--info)" fillOpacity={0.5} />
      <line x1={pX - 2.5} y1={pY - 24} x2={pX - 2.5} y2={bY + 14} stroke="var(--charcoal)" strokeWidth={1.2} />
      <line x1={pX + 2.5} y1={pY - 24} x2={pX + 2.5} y2={bY + 14} stroke="var(--charcoal)" strokeWidth={1.2} />
      <WaterMark x={pX} y={pY - 1} />
      <SubText x={pX - 12} y={pY - 16} anchor="end" color="var(--info)">piezometer</SubText>
      <line x1={pX + 4} y1={pY} x2={pX + 32} y2={pY} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <VDim x={pX + 26} y1={fY} y2={pY} label={`${head} ${unit}`} side="right" />

      {/* Labels */}
      <SubText x={fL + 10} y={fY - 14} color="var(--gray-500)">floor (dewatered)</SubText>
      <SubText x={fL - side + 8} y={(fY + bY) / 2 - 8} bold>{sand[0]}</SubText>
      {sand.slice(1).map((t, i) => (
        <SubText key={i} x={fL - side + 8} y={(fY + bY) / 2 + 8 + i * 16} color="var(--gray-500)">{t}</SubText>
      ))}
      <SubText x={fL - side + 8} y={(bY + endY) / 2} bold>{gravel}</SubText>
      <line x1={12} y1={fY} x2={fL - 4} y2={fY} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <VDim x={30} y1={fY} y2={bY} label={`${sandH} ${unit}`} side="right" />
    </svg>
  );
}

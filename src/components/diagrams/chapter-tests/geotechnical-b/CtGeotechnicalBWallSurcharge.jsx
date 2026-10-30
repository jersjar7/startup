import React from 'react';
import { SubText, SurfaceHatch, VDim } from './ctGeoBParts';

/**
 * Smooth vertical wall retaining level, dry backfill that carries a uniform
 * surcharge over its whole surface. Shows the wall height, the surcharge and
 * the backfill properties. Never shows a pressure diagram or a force.
 */
export function CtGeotechnicalBWallSurcharge({
  H = 14,
  q = 250,
  unit = 'ft',
  qUnit = 'psf',
  soil = [],
}) {
  const W = 420;
  const sc = Math.min(14, 200 / H);
  const top = 62;
  const baseY = top + H * sc;
  const wallL = 58;
  const wallR = 88;
  const soilR = 340;
  const VH = baseY + 22;
  const arrowTop = top - 30;
  const n = 9;
  const ys = (top + baseY) / 2 - ((soil.length - 1) * 16) / 2;

  return (
    <svg viewBox={`0 0 ${W} ${VH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Retaining wall ${H} ${unit} high with a uniform surcharge of ${q} ${qUnit} on the backfill`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctGeoBSurArrow" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* Backfill */}
      <rect x={wallR} y={top} width={soilR - wallR} height={baseY - top} fill="var(--gray-400)" fillOpacity={0.12} />
      <line x1={wallR} y1={top} x2={soilR} y2={top} stroke="var(--charcoal)" strokeWidth={2} />
      <SurfaceHatch x1={wallR + 4} x2={soilR} y={top} step={22} len={6} />

      {/* Surcharge */}
      <line x1={wallR + 8} y1={arrowTop} x2={soilR - 8} y2={arrowTop} stroke="var(--ember)" strokeWidth={1.5} />
      {Array.from({ length: n }, (_, i) => {
        const x = wallR + 8 + (i * (soilR - wallR - 16)) / (n - 1);
        return <line key={i} x1={x} y1={arrowTop} x2={x} y2={top - 3} stroke="var(--ember)" strokeWidth={1.5} markerEnd="url(#ctGeoBSurArrow)" />;
      })}
      <SubText x={(wallR + soilR) / 2} y={arrowTop - 14} color="var(--ember)" anchor="middle">{`q = ${q} ${qUnit}`}</SubText>

      {/* Wall */}
      <rect x={wallL} y={top - 4} width={wallR - wallL} height={baseY - top + 4}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Ground at the base */}
      <line x1={14} y1={baseY} x2={soilR} y2={baseY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 16 }, (_, i) => {
        const x = 20 + i * 20;
        return <line key={i} x1={x} y1={baseY} x2={x - 5} y2={baseY + 7} stroke="var(--charcoal)" strokeWidth={1} />;
      })}

      {soil.map((t, i) => <SubText key={i} x={wallR + 18} y={ys + i * 16}>{t}</SubText>)}

      <VDim x={soilR + 16} y1={top} y2={baseY} label={`${H} ${unit}`} side="right" />
    </svg>
  );
}

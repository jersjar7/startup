import React from 'react';
import { SubText, WaterMark, SurfaceHatch, VDim } from './ctGeoAParts';

/**
 * Smooth vertical wall retaining level backfill with a water table inside the
 * backfill, drawn to scale. Shows the depth to the water table, the depth
 * below it and the backfill properties. Never shows a pressure or a force.
 */
export function CtGeotechnicalAWallWater({
  H1 = 8,
  H2 = 8,
  unit = 'ft',
  above = [],
  below = [],
}) {
  const W = 420;
  const sc = Math.min(13, 210 / (H1 + H2));
  const top = 16;
  const wtY = top + H1 * sc;
  const baseY = wtY + H2 * sc;
  const wallL = 58;
  const wallR = 88;
  const soilR = 340;
  const H = baseY + 22;
  const block = (lines, a, b) => {
    const h = (lines.length - 1) * 16;
    return (a + b) / 2 - h / 2;
  };
  const ya = block(above, top, wtY);
  const yb = block(below, wtY, baseY);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Retaining wall, water table ${H1} ${unit} below the top of the backfill, ${H2} ${unit} of backfill below it`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Backfill */}
      <rect x={wallR} y={top} width={soilR - wallR} height={baseY - top} fill="var(--gray-400)" fillOpacity={0.12} />
      <rect x={wallR} y={wtY} width={soilR - wallR} height={baseY - wtY} fill="var(--info)" fillOpacity={0.09} />
      <line x1={wallR} y1={top} x2={soilR} y2={top} stroke="var(--charcoal)" strokeWidth={2} />
      <SurfaceHatch x1={wallR + 4} x2={soilR} y={top} step={22} len={6} />

      {/* Wall */}
      <rect x={wallL} y={top - 4} width={wallR - wallL} height={baseY - top + 4}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Ground at the base */}
      <line x1={14} y1={baseY} x2={soilR} y2={baseY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 16 }, (_, i) => {
        const x = 20 + i * 20;
        return <line key={i} x1={x} y1={baseY} x2={x - 5} y2={baseY + 7} stroke="var(--charcoal)" strokeWidth={1} />;
      })}

      {/* Water table */}
      <line x1={wallR} y1={wtY} x2={soilR} y2={wtY} stroke="var(--info)" strokeWidth={1.5} strokeDasharray="7,4" />
      <WaterMark x={soilR - 22} y={wtY} />
      <SubText x={soilR - 34} y={wtY - 9} color="var(--info)" anchor="end">WT</SubText>

      {/* Backfill properties */}
      {above.map((t, i) => <SubText key={`a${i}`} x={wallR + 16} y={ya + i * 16}>{t}</SubText>)}
      {below.map((t, i) => <SubText key={`b${i}`} x={wallR + 16} y={yb + i * 16}>{t}</SubText>)}

      {/* Dimensions */}
      <VDim x={soilR + 16} y1={top} y2={wtY} label={`${H1} ${unit}`} side="right" />
      <VDim x={soilR + 16} y1={wtY} y2={baseY} label={`${H2} ${unit}`} side="right" />
    </svg>
  );
}

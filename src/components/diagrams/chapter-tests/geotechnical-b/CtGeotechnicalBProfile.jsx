import React from 'react';
import { SubText, WaterMark, SurfaceHatch, VDim, SOIL_TINT } from './ctGeoBParts';

/**
 * Soil profile drawn to scale: optional free water standing above the ground
 * (a river or lake bed), layers with their properties, an optional water table
 * inside the soil, an optional point of interest, and an optional last layer
 * that continues downward (drawn open, with no thickness). Shows givens only.
 *
 * layers: [{ thick, lines: [], kind: 'sand' | 'clay' | ..., open: false }]
 * point:  { layer: index, depth: depth below the top of that layer, label }
 */
export function CtGeotechnicalBProfile({
  layers = [],
  freeWater = 0,
  wtDepth = null,
  point = null,
  unit = 'ft',
  waterLabel = 'Water',
}) {
  const W = 440;
  const soilL = 14;
  const soilR = 320;
  const closed = layers.filter((l) => !l.open).reduce((s, l) => s + l.thick, 0);
  const openThick = layers.filter((l) => l.open).reduce((s, l) => s + l.thick, 0);
  const sc = Math.min(11, 250 / (freeWater + closed + openThick));
  const top = 18;
  const gY = top + freeWater * sc;
  let y = gY;
  const ys = layers.map((l) => {
    const a = y;
    y += l.thick * sc;
    return { a, b: y };
  });
  const bottom = y;
  const H = bottom + (layers.length && layers[layers.length - 1].open ? 14 : 22);
  const col1 = soilR + 18;
  const col2 = soilR + 70;

  const textBlock = (lines, a, b) => {
    const h = (lines.length - 1) * 16;
    return (a + b) / 2 - h / 2;
  };

  let pY = null;
  if (point) pY = ys[point.layer].a + point.depth * sc;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Soil profile with layer thicknesses and properties"
      style={{ width: '100%', height: 'auto' }}>
      {/* Free water above the ground */}
      {freeWater > 0 && (
        <g>
          <rect x={soilL} y={top} width={soilR - soilL} height={gY - top} fill="var(--info)" fillOpacity={0.12} />
          <line x1={soilL} y1={top} x2={soilR} y2={top} stroke="var(--info)" strokeWidth={1.6} />
          <WaterMark x={soilR - 26} y={top} />
          <SubText x={28} y={(top + gY) / 2} color="var(--info)">{waterLabel}</SubText>
        </g>
      )}

      {/* Layers */}
      {layers.map((l, i) => (
        <g key={i}>
          <rect x={soilL} y={ys[i].a} width={soilR - soilL} height={ys[i].b - ys[i].a}
            fill="var(--gray-400)" fillOpacity={SOIL_TINT[l.kind] ?? 0.12} />
          {i > 0 && <line x1={soilL} y1={ys[i].a} x2={soilR} y2={ys[i].a} stroke="var(--charcoal)" strokeWidth={1.4} />}
          {l.lines.map((t, k) => (
            <SubText key={k} x={28} y={textBlock(l.lines, ys[i].a, ys[i].b) + k * 16}>{t}</SubText>
          ))}
          {!l.open && (
            <VDim x={col1} y1={ys[i].a} y2={ys[i].b} label={`${l.thick} ${unit}`} side="right" />
          )}
        </g>
      ))}
      {layers.length > 0 && layers[layers.length - 1].open && (
        <line x1={soilL} y1={bottom} x2={soilR} y2={bottom} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="5,4" />
      )}
      {layers.length > 0 && !layers[layers.length - 1].open && (
        <line x1={soilL} y1={bottom} x2={soilR} y2={bottom} stroke="var(--charcoal)" strokeWidth={1.4} />
      )}

      {/* Ground surface (mudline) */}
      <line x1={soilL} y1={gY} x2={soilR} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      {freeWater === 0 && <SurfaceHatch x1={soilL} x2={soilR} y={gY} step={20} len={6} />}

      {/* Water table inside the soil */}
      {wtDepth !== null && freeWater === 0 && (
        <g>
          {wtDepth > 0 && (
            <line x1={soilL} y1={gY + wtDepth * sc} x2={soilR} y2={gY + wtDepth * sc}
              stroke="var(--info)" strokeWidth={1.5} strokeDasharray="7,4" />
          )}
          <WaterMark x={soilR - 26} y={gY + wtDepth * sc} />
          <SubText x={soilR - 38} y={gY + wtDepth * sc - 9} color="var(--info)" anchor="end">WT</SubText>
        </g>
      )}

      {/* Free water depth */}
      {freeWater > 0 && (
        <VDim x={col1} y1={top} y2={gY} label={`${freeWater} ${unit}`} side="right" />
      )}

      {/* Point of interest */}
      {point && (
        <g>
          <circle cx={250} cy={pY} r={4} fill="var(--ember)" />
          <SubText x={260} y={pY} color="var(--ember)" bold>{point.label}</SubText>
          <line x1={262 + String(point.label).length * 9} y1={pY} x2={col2 + 6} y2={pY} stroke="var(--gray-400)" strokeWidth={0.8} strokeDasharray="2,3" />
          <line x1={col1 + 8} y1={ys[point.layer].a} x2={col2 + 6} y2={ys[point.layer].a} stroke="var(--gray-400)" strokeWidth={0.8} strokeDasharray="2,3" />
          <VDim x={col2} y1={ys[point.layer].a} y2={pY} label={`${point.depth} ${unit}`} side="right" />
        </g>
      )}
    </svg>
  );
}

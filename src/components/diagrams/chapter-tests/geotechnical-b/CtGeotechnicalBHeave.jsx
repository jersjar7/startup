import React from 'react';
import { SubText, WaterMark, SurfaceHatch, VDim, SOIL_TINT } from './ctGeoBParts';

/**
 * Dry excavation in a saturated clay layer that sits on a sand under artesian
 * pressure. A standpipe piezometer screened in the sand shows the piezometric
 * level. The clay thickness and the piezometric level are to scale; the
 * excavation depth is the unknown d, so it is drawn only as a sketch depth.
 */
export function CtGeotechnicalBHeave({
  clayT = 30,
  piezoBelowGround = 6,
  unit = 'ft',
  clayLines = [],
  sandLines = [],
  sketchDepth = 0.4,
}) {
  const W = 440;
  const soilL = 14;
  const soilR = 340;
  const sc = Math.min(8, 230 / (clayT + 7));
  const gY = 30;
  const clayB = gY + clayT * sc;
  const sandB = clayB + 7 * sc;
  const H = sandB + 12;
  const exL = 60;
  const exR = 190;
  const exB = gY + clayT * sketchDepth * sc;
  const px = 268;
  const tw = 8;
  const pzY = gY + piezoBelowGround * sc;
  const tubeTop = 8;

  const block = (lines, a, b, x) => lines.map((t, i) => (
    <SubText key={i} x={x} y={(a + b) / 2 - ((lines.length - 1) * 16) / 2 + i * 16}>{t}</SubText>
  ));

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Excavation in ${clayT} ${unit} of clay over artesian sand; piezometer level ${piezoBelowGround} ${unit} below the ground`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Soil */}
      <rect x={soilL} y={gY} width={soilR - soilL} height={clayB - gY} fill="var(--gray-400)" fillOpacity={SOIL_TINT.clay} />
      <rect x={soilL} y={clayB} width={soilR - soilL} height={sandB - clayB} fill="var(--gray-400)" fillOpacity={SOIL_TINT.sand} />
      {/* Excavation (cut out of the clay) */}
      <rect x={exL} y={gY - 1} width={exR - exL} height={exB - gY + 1} fill="var(--cream)" />
      <polyline points={`${soilL},${gY} ${exL},${gY} ${exL},${exB} ${exR},${exB} ${exR},${gY} ${soilR},${gY}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <SurfaceHatch x1={soilL} x2={exL - 2} y={gY} step={16} len={6} />
      <SurfaceHatch x1={exR + 2} x2={px - 14} y={gY} step={16} len={6} />
      <SurfaceHatch x1={exL + 2} x2={exR} y={exB} step={16} len={6} />
      <line x1={soilL} y1={clayB} x2={soilR} y2={clayB} stroke="var(--charcoal)" strokeWidth={1.4} />
      <line x1={soilL} y1={sandB} x2={soilR} y2={sandB} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="5,4" />

      {/* Piezometer standpipe screened in the sand */}
      <rect x={px - tw / 2} y={pzY} width={tw} height={clayB + 3 * sc - pzY} fill="var(--info)" fillOpacity={0.25} />
      <line x1={px - tw / 2} y1={tubeTop} x2={px - tw / 2} y2={clayB + 3 * sc} stroke="var(--charcoal)" strokeWidth={1.4} />
      <line x1={px + tw / 2} y1={tubeTop} x2={px + tw / 2} y2={clayB + 3 * sc} stroke="var(--charcoal)" strokeWidth={1.4} />
      {Array.from({ length: 4 }, (_, i) => (
        <line key={i} x1={px - tw / 2} y1={clayB + 0.6 * sc + i * 0.6 * sc} x2={px + tw / 2} y2={clayB + 0.6 * sc + i * 0.6 * sc}
          stroke="var(--charcoal)" strokeWidth={1} />
      ))}
      <line x1={px - tw / 2} y1={pzY} x2={px + tw / 2} y2={pzY} stroke="var(--info)" strokeWidth={1.6} />
      <WaterMark x={px + 16} y={pzY} />
      <line x1={px + tw / 2} y1={pzY} x2={px + 24} y2={pzY} stroke="var(--info)" strokeWidth={1} />
      <SubText x={px - 12} y={tubeTop + 4} anchor="end" size={11}>Piezometer</SubText>

      {/* Labels */}
      {block(clayLines, exB, clayB, exL - 30)}
      {block(sandLines, clayB, sandB, 28)}

      {/* Dimensions */}
      <VDim x={exL - 16} y1={gY} y2={exB} label="d" side="left" />
      <VDim x={soilR + 18} y1={gY} y2={clayB} label={`${clayT} ${unit}`} side="right" />
      <VDim x={px + 40} y1={gY} y2={pzY} label={`${piezoBelowGround} ${unit}`} side="right" />
    </svg>
  );
}

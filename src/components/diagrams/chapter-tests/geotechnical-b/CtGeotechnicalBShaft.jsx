import React from 'react';
import { SubText, SurfaceHatch, VDim, HDim, SOIL_TINT } from './ctGeoBParts';

/**
 * Drilled shaft through two clay layers, drawn to scale (diameter and
 * lengths). Each layer shows its thickness along the shaft and the properties
 * given; the lower clay continues below the tip. Shows givens only.
 *
 * layers: [{ thick, lines: [] }] from the top; the last one continues below.
 */
export function CtGeotechnicalBShaft({
  D = 3,
  layers = [],
  below = 4,
  unit = 'ft',
}) {
  const W = 440;
  const L = layers.reduce((s, l) => s + l.thick, 0);
  const sc = Math.min(7, 250 / (L + below));
  const gY = 40;
  const tipY = gY + L * sc;
  const botY = tipY + below * sc;
  const cx = 110;
  const sw = D * sc;
  const soilL = 14;
  const soilR = 350;
  const H = botY + 10;
  let y = gY;
  const ys = layers.map((l) => {
    const a = y;
    y += l.thick * sc;
    return { a, b: y };
  });

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Drilled shaft ${D} ${unit} in diameter, ${L} ${unit} long, through two clay layers`}
      style={{ width: '100%', height: 'auto' }}>
      {layers.map((l, i) => (
        <g key={i}>
          <rect x={soilL} y={ys[i].a} width={soilR - soilL}
            height={(i === layers.length - 1 ? botY : ys[i].b) - ys[i].a}
            fill="var(--gray-400)" fillOpacity={i === 0 ? SOIL_TINT.silt : SOIL_TINT.clay} />
          {i > 0 && <line x1={soilL} y1={ys[i].a} x2={soilR} y2={ys[i].a} stroke="var(--charcoal)" strokeWidth={1.4} />}
          {l.lines.map((t, k) => (
            <SubText key={k} x={cx + 40} y={(ys[i].a + ys[i].b) / 2 - ((l.lines.length - 1) * 16) / 2 + k * 16}>{t}</SubText>
          ))}
          <VDim x={soilR + 16} y1={ys[i].a} y2={ys[i].b} label={`${l.thick} ${unit}`} side="right" />
        </g>
      ))}
      <line x1={soilL} y1={botY} x2={soilR} y2={botY} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="5,4" />

      {/* Ground surface */}
      <line x1={soilL} y1={gY} x2={cx - sw / 2} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={cx + sw / 2} y1={gY} x2={soilR} y2={gY} stroke="var(--charcoal)" strokeWidth={2} />
      <SurfaceHatch x1={soilL} x2={cx - sw / 2 - 4} y={gY} step={16} len={6} />
      <SurfaceHatch x1={cx + sw / 2 + 4} x2={soilR} y={gY} step={16} len={6} />

      {/* Shaft */}
      <rect x={cx - sw / 2} y={gY - 12} width={sw} height={tipY - gY + 12}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={soilR} y1={tipY} x2={soilR + 22} y2={tipY} stroke="var(--gray-400)" strokeWidth={0.8} />
      <line x1={cx + sw / 2 + 4} y1={tipY} x2={cx + 34} y2={tipY} stroke="var(--gray-400)" strokeWidth={0.8} />
      <SubText x={cx + 38} y={tipY} size={11} color="var(--gray-500)">Tip</SubText>

      <HDim y={gY - 22} x1={cx - sw / 2} x2={cx + sw / 2} label="" below={false} />
      <SubText x={cx + sw / 2 + 10} y={gY - 22} color="var(--gray-500)">{`D = ${D} ${unit}`}</SubText>
    </svg>
  );
}

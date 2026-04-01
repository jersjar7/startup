import React from 'react';
import {
  DimensionLine, Label,
} from './primitives';

export function BuiltUpSection({
  botW = 200, botH = 30,
  webW = 30, webH = 140,
  topW = 150, topH = 30,
}) {
  const scale = 1.1;
  const ox = 60;
  const oy = 30;

  const bW = botW * scale;
  const bH = botH * scale;
  const wW = webW * scale;
  const wH = webH * scale;
  const tW = topW * scale;
  const tH = topH * scale;
  const totalH = bH + wH + tH;

  const centerX = ox + bW / 2;
  const webLeft = centerX - wW / 2;
  const topLeft = centerX - tW / 2;
  const svgBottom = oy + totalH;


  return (
    <svg viewBox="0 0 380 300" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Built-up I-section with three rectangles"
      style={{ width: '100%', height: 'auto' }}>

      {/* Top flange */}
      <rect x={topLeft} y={oy} width={tW} height={tH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Web */}
      <rect x={webLeft} y={oy + tH} width={wW} height={wH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Bottom flange */}
      <rect x={ox} y={oy + tH + wH} width={bW} height={bH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Dimensions — bottom flange width */}
      <DimensionLine x1={ox} y1={svgBottom + 14} x2={ox + bW} y2={svgBottom + 14}
        label={`${botW}`} offset={12} />

      {/* Dimensions — top flange width */}
      <DimensionLine x1={topLeft} y1={oy - 10} x2={topLeft + tW} y2={oy - 10}
        label={`${topW}`} offset={-10} />

      {/* Heights on right side */}
      <DimensionLine x1={ox + bW + 14} y1={svgBottom} x2={ox + bW + 14} y2={oy + tH + wH}
        label={`${botH}`} offset={18} />
      <DimensionLine x1={ox + bW + 14} y1={oy + tH + wH} x2={ox + bW + 14} y2={oy + tH}
        label={`${webH}`} offset={18} />
      <DimensionLine x1={ox + bW + 14} y1={oy + tH} x2={ox + bW + 14} y2={oy}
        label={`${topH}`} offset={18} />

      {/* Web width label */}
      <Label x={webLeft + wW / 2} y={oy + tH + wH / 2}
        color="var(--gray-500)" fontSize={9}>
        {webW}
      </Label>

    </svg>
  );
}

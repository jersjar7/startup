import React from 'react';
import { DimensionLine, Label } from './primitives';

/**
 * Flexible pavement cross-section — stacked layers.
 *
 * Shows: surface, base, and subbase layers with thickness labels,
 * layer coefficient annotations, and drainage coefficients.
 * Student computes the total Structural Number.
 */
export function PavementStack({
  surface = { a: 0.44, D: 3, label: 'HMA Surface' },
  base = { a: 0.14, D: 8, m: 1.0, label: 'Crushed Stone Base' },
  subbase = { a: 0.11, D: 10, m: 1.0, label: 'Granular Subbase' },
  unit = 'in.',
}) {
  const W = 400;
  const layerW = 200;
  const left = (W - layerW) / 2;
  const right = left + layerW;

  // Scale layer thicknesses to pixel heights
  const totalD = surface.D + base.D + subbase.D;
  const scale = Math.min(8, 140 / totalD);
  const surfH = surface.D * scale;
  const baseH = base.D * scale;
  const subH = subbase.D * scale;

  const topPad = 20;
  const surfTop = topPad;
  const surfBot = surfTop + surfH;
  const baseTop = surfBot;
  const baseBot = baseTop + baseH;
  const subTop = baseBot;
  const subBot = subTop + subH;

  const groundY = subBot;
  const HH = groundY + 40;

  // Colors
  const surfFill = 'rgba(80,80,80,0.22)';
  const baseFill = 'rgba(160,140,110,0.18)';
  const subFill = 'rgba(190,175,150,0.12)';

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Pavement cross-section: ${surface.D} ${unit} surface, ${base.D} ${unit} base, ${subbase.D} ${unit} subbase`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Surface layer */}
      <rect x={left} y={surfTop} width={layerW} height={surfH}
        fill={surfFill} stroke="var(--charcoal)" strokeWidth={1.5} />
      <Label x={left + layerW / 2} y={surfTop + surfH / 2}
        fontSize={9} color="var(--charcoal)" bold>
        {surface.label}
      </Label>

      {/* Base layer */}
      <rect x={left} y={baseTop} width={layerW} height={baseH}
        fill={baseFill} stroke="var(--charcoal)" strokeWidth={1.5} />
      <Label x={left + layerW / 2} y={baseTop + baseH / 2}
        fontSize={9} color="var(--charcoal)" bold>
        {base.label}
      </Label>

      {/* Subbase layer */}
      <rect x={left} y={subTop} width={layerW} height={subH}
        fill={subFill} stroke="var(--charcoal)" strokeWidth={1.5} />
      <Label x={left + layerW / 2} y={subTop + subH / 2}
        fontSize={9} color="var(--charcoal)" bold>
        {subbase.label}
      </Label>

      {/* Subgrade hatch below */}
      {Array.from({ length: 12 }, (_, i) => (
        <line key={`sg${i}`}
          x1={left + i * 18} y1={groundY + 3}
          x2={left + 10 + i * 18} y2={groundY + 12}
          stroke="var(--gray-400)" strokeWidth={0.8} />
      ))}
      <Label x={left + layerW / 2} y={groundY + 26}
        fontSize={8} color="var(--gray-500)">
        Subgrade
      </Label>

      {/* Thickness dimensions — right side, bottom-to-top */}
      <DimensionLine
        x1={right + 20} y1={surfBot}
        x2={right + 20} y2={surfTop}
        label={`D\u2081 = ${surface.D} ${unit}`}
        offset={24} fontSize={8} />

      <DimensionLine
        x1={right + 20} y1={baseBot}
        x2={right + 20} y2={baseTop}
        label={`D\u2082 = ${base.D} ${unit}`}
        offset={24} fontSize={8} />

      <DimensionLine
        x1={right + 20} y1={subBot}
        x2={right + 20} y2={subTop}
        label={`D\u2083 = ${subbase.D} ${unit}`}
        offset={24} fontSize={8} />

      {/* Layer coefficient annotations — left side */}
      <Label x={left - 10} y={surfTop + surfH / 2}
        fontSize={8} color="var(--gray-500)" anchor="end">
        a{'\u2081'} = {surface.a}
      </Label>

      <Label x={left - 10} y={baseTop + baseH / 2 - 6}
        fontSize={8} color="var(--gray-500)" anchor="end">
        a{'\u2082'} = {base.a}
      </Label>
      {base.m != null && base.m !== 1.0 && (
        <Label x={left - 10} y={baseTop + baseH / 2 + 6}
          fontSize={7} color="var(--gray-500)" anchor="end">
          m{'\u2082'} = {base.m}
        </Label>
      )}

      <Label x={left - 10} y={subTop + subH / 2 - 6}
        fontSize={8} color="var(--gray-500)" anchor="end">
        a{'\u2083'} = {subbase.a}
      </Label>
      {subbase.m != null && subbase.m !== 1.0 && (
        <Label x={left - 10} y={subTop + subH / 2 + 6}
          fontSize={7} color="var(--gray-500)" anchor="end">
          m{'\u2083'} = {subbase.m}
        </Label>
      )}
    </svg>
  );
}

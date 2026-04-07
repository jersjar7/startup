import React from 'react';
import { DashedLine, DimensionLine, Label, ArrowMarkerDefs, ForceArrow } from './primitives';

/**
 * Layered soil profile for effective stress problems.
 *
 * Shows: stacked soil layers, water table marker, optional surcharge arrow.
 * Student reads layer properties and computes effective stress at depth.
 *
 * Each layer: { name, h, gamma, saturated }
 * saturated layers get a blue tint below the water table.
 */
export function SoilProfile({
  layers = [
    { name: 'Dry Sand', h: 5, gamma: 110, saturated: false },
    { name: 'Sat. Clay', h: 8, gamma: 120, saturated: true },
  ],
  wtDepth = 5,
  surcharge = 0,
  depthUnit = 'ft',
  weightUnit = 'pcf',
}) {
  const colW = 130;
  const colLeft = 80;
  const colRight = colLeft + colW;
  const totalDepth = layers.reduce((s, l) => s + l.h, 0);
  const scale = Math.min(12, 160 / totalDepth);
  const topPad = surcharge > 0 ? 65 : 30;
  const groundY = topPad;
  const bottomY = groundY + totalDepth * scale;
  const wtY = groundY + wtDepth * scale;
  const pressureUnit = weightUnit === 'pcf' ? 'psf' : 'kPa';

  const W = 420;
  const HH = bottomY + 40;

  // Build layer pixel positions
  let cy = groundY;
  const rects = layers.map((l) => {
    const r = { ...l, py: cy, ph: l.h * scale };
    cy += l.h * scale;
    return r;
  });

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Soil profile: ${layers.length} layers, water table at ${wtDepth} ${depthUnit}`}
      style={{ width: '100%', height: 'auto' }}>

      {surcharge > 0 && <ArrowMarkerDefs id="arrowSurcharge" />}

      {/* Ground surface line + hatching */}
      <line x1={colLeft - 20} y1={groundY} x2={colRight + 20} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 8 }, (_, i) => (
        <line key={i}
          x1={colLeft - 15 + i * 22} y1={groundY}
          x2={colLeft - 21 + i * 22} y2={groundY - 8}
          stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}

      {/* Soil layers */}
      {rects.map((r, i) => {
        const satStart = Math.max(r.py, wtY);
        const layerBot = r.py + r.ph;
        const hasSat = layerBot > wtY;

        return (
          <g key={i}>
            {/* Base soil fill (tan) */}
            <rect x={colLeft} y={r.py} width={colW} height={r.ph}
              fill="rgba(180,160,130,0.15)" />

            {/* Saturated zone blue tint */}
            {hasSat && (
              <rect x={colLeft} y={satStart} width={colW}
                height={layerBot - satStart}
                fill="rgba(160,210,240,0.18)" />
            )}

            {/* Layer border */}
            <rect x={colLeft} y={r.py} width={colW} height={r.ph}
              fill="none" stroke="var(--charcoal)" strokeWidth={1.5} />

            {/* Layer name label (right side) */}
            <Label x={colRight + 14} y={r.py + r.ph / 2 - 8}
              fontSize={9} color="var(--charcoal)" anchor="start" bold>
              {r.name}
            </Label>

            {/* Unit weight label with subscript for saturated */}
            <text x={colRight + 14} y={r.py + r.ph / 2 + 7}
              fill="var(--gray-500)" fontFamily="var(--font-body)"
              fontSize={8} textAnchor="start" dominantBaseline="middle">
              {r.saturated
                ? <>{'\u03B3'}<tspan dy="2" fontSize="6">sat</tspan>
                    <tspan dy="-2">{` = ${r.gamma} ${weightUnit}`}</tspan></>
                : <>{`\u03B3 = ${r.gamma} ${weightUnit}`}</>
              }
            </text>

            {/* Thickness dimension (left side) */}
            <DimensionLine
              x1={colLeft - 20} y1={r.py + r.ph}
              x2={colLeft - 20} y2={r.py}
              label={`${r.h} ${depthUnit}`}
              offset={-26} fontSize={9} />
          </g>
        );
      })}

      {/* Water table line */}
      <DashedLine x1={colLeft - 10} y1={wtY} x2={colRight + 10} y2={wtY}
        color="var(--info)" strokeWidth={1.5} dasharray="6,3" />
      <Label x={colRight + 16} y={wtY} fontSize={8}
        color="var(--info)" anchor="start" bold>
        WT
      </Label>

      {/* Surcharge arrow + label */}
      {surcharge > 0 && (
        <g>
          <ForceArrow
            x1={colLeft + colW / 2} y1={groundY - 38}
            x2={colLeft + colW / 2} y2={groundY - 4}
            markerId="arrowSurcharge" strokeWidth={2} />
          <Label x={colLeft + colW / 2} y={groundY - 46}
            fontSize={9} color="var(--charcoal)" bold>
            q = {surcharge} {pressureUnit}
          </Label>
        </g>
      )}
    </svg>
  );
}

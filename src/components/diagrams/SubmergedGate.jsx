import React from 'react';
import { DimensionLine, DashedLine, Label } from './primitives';

/**
 * Vertical rectangular gate submerged in water.
 *
 * Water body on the left, gate plate on the right edge.
 *
 * Shows: water fill, gate plate, gate height dimension,
 *        width annotation, submergence depth (if topDepth > 0).
 * Does NOT show: centroid, center of pressure, resultant force, I_xC (student solves).
 */
export function SubmergedGate({
  width = 2,
  height = 3,
  topDepth = 0,
  unit = 'm',
}) {
  const W = 380;
  const H = 250;

  // ── Layout — water left, gate right ──
  const waterLeftX = 40;
  const faceX = 210;             // right edge of water / structure face
  const groundY = 215;
  const faceTopY = 28;
  const gateThick = 10;

  // ── Water geometry ──
  const surfaceY = topDepth > 0 ? 55 : faceTopY + 14;

  // Scale: total visible depth maps to available pixels
  const totalDepth = topDepth + height;
  const availableH = groundY - surfaceY - 12;
  const scale = availableH / (totalDepth + 0.3);

  // ── Gate position ──
  const gateTopY = surfaceY + topDepth * scale;
  const gateH = height * scale;
  const gateBotY = gateTopY + gateH;

  // ── Water fill ──
  const waterPath = [
    `M ${waterLeftX},${surfaceY}`,
    `H ${faceX}`,
    `V ${groundY}`,
    `H ${waterLeftX}`,
    'Z',
  ].join(' ');

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Vertical rectangular gate ${width}${unit} wide, ${height}${unit} tall${topDepth > 0 ? `, top ${topDepth}${unit} below surface` : ', top at surface'}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Water fill */}
      <path d={waterPath} fill="rgba(160,210,240,0.30)" />

      {/* 2. Wall lines — contain the water */}
      <line x1={waterLeftX} y1={surfaceY} x2={waterLeftX} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />
      {topDepth > 0 && (
        <line x1={faceX} y1={surfaceY} x2={faceX} y2={gateTopY}
          stroke="var(--charcoal)" strokeWidth={2} />
      )}
      <line x1={faceX} y1={gateBotY} x2={faceX} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 3. Gate */}
      <rect x={faceX} y={gateTopY} width={gateThick} height={gateH}
        fill="rgba(232,104,58,0.15)"
        stroke="var(--ember)" strokeWidth={2.5} rx={1} />

      {/* 4. Ground line */}
      <line x1={waterLeftX - 10} y1={groundY} x2={faceX + gateThick + 70} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 5. Gate edge reference lines */}
      <DashedLine x1={faceX + gateThick + 4} y1={gateTopY}
        x2={faceX + gateThick + 56} y2={gateTopY} />
      <DashedLine x1={faceX + gateThick + 4} y1={gateBotY}
        x2={faceX + gateThick + 56} y2={gateBotY} />

      {/* 6. Gate height dimension */}
      <DimensionLine
        x1={faceX + gateThick + 48} y1={gateBotY}
        x2={faceX + gateThick + 48} y2={gateTopY}
        label={`${height} ${unit}`} offset={22} fontSize={10} />

      {/* 7. Submergence depth dimension (if gate top is below surface) */}
      {topDepth > 0 && (
        <>
          <DashedLine x1={faceX} y1={surfaceY}
            x2={faceX + gateThick + 56} y2={surfaceY} />
          <DimensionLine
            x1={faceX + gateThick + 48} y1={gateTopY}
            x2={faceX + gateThick + 48} y2={surfaceY}
            label={`${topDepth} ${unit}`} offset={22} fontSize={10} />
        </>
      )}

      {/* 8. Labels */}
      <Label x={faceX + gateThick + 6} y={gateTopY + gateH / 2}
        fontSize={10} color="var(--ember)" bold anchor="start">
        Gate
      </Label>

      {/* Width annotation (into the page) — below ground line */}
      <Label x={(waterLeftX + faceX) / 2} y={groundY + 16}
        fontSize={9} color="var(--gray-500)">
        b = {width} {unit}
      </Label>
    </svg>
  );
}

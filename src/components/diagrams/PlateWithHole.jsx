import React from 'react';
import { engY } from './geo';
import {
  DimensionLine, Label,
} from './primitives';

/**
 * Rectangular plate with a circular hole (centroid / net-area problems).
 * The viewBox is fitted to the plate + dimensions so portrait or landscape
 * plates never clip.
 */
export function PlateWithHole({ plateW = 300, plateH = 200, holeDia = 60, holeX = 150, holeY = 150 }) {
  // scale so the larger plate dimension is a comfortable on-screen size
  const scale = Math.min(0.9, 260 / Math.max(plateW, plateH));
  const ox = 50;
  const oy = 34;
  const pW = plateW * scale;
  const pH = plateH * scale;
  const hR = (holeDia / 2) * scale;
  const svgBottom = oy + pH;

  // Hole center: holeX from left, holeY from bottom (engineering convention)
  const holeSvgX = ox + holeX * scale;
  const holeSvgY = engY(oy, pH, holeY * scale);

  // content-fitted viewBox
  const minX = 34;
  const maxX = ox + pW + 78;                       // right dim label + text
  const minY = oy - 28;                            // top dim label
  const maxY = Math.max(svgBottom, holeSvgY + hR + 22) + 8;

  return (
    <svg viewBox={`${minX} ${minY} ${maxX - minX} ${maxY - minY}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${plateW}x${plateH} plate with ${holeDia} mm hole`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Plate */}
      <rect x={ox} y={oy} width={pW} height={pH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Hole */}
      <circle cx={holeSvgX} cy={holeSvgY} r={hR}
        fill="white" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Hole center crosshair */}
      <line x1={holeSvgX - 6} y1={holeSvgY} x2={holeSvgX + 6} y2={holeSvgY}
        stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={holeSvgX} y1={holeSvgY - 6} x2={holeSvgX} y2={holeSvgY + 6}
        stroke="var(--gray-400)" strokeWidth={1} />

      {/* Plate dimensions */}
      <DimensionLine x1={ox} y1={oy - 12} x2={ox + pW} y2={oy - 12}
        label={`${plateW} mm`} offset={-10} />
      <DimensionLine x1={ox + pW + 16} y1={svgBottom} x2={ox + pW + 16} y2={oy}
        label={`${plateH} mm`} offset={28} />

      {/* Hole diameter line + label */}
      <line x1={holeSvgX - hR} y1={holeSvgY} x2={holeSvgX + hR} y2={holeSvgY}
        stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="3,2" />
      <Label x={holeSvgX} y={holeSvgY + hR + 14} color="var(--gray-500)" fontSize={10}>
        {'⌀'} {holeDia} mm
      </Label>
    </svg>
  );
}

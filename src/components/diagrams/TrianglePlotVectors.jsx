import React from 'react';
import { ArrowMarkerDefs, ForceArrow, DashedLine, Label } from './primitives';

/**
 * Two vectors from the same origin forming a shaded triangle (parallelogram area context).
 * Shows: vectors u and v from origin, shaded triangle between them, dashed closing line.
 * Does NOT show: the area value.
 */
export function TrianglePlotVectors({ ux = 4, uy = 0, vx = 2, vy = 3 }) {
  const W = 360;
  const H = 240;
  const pad = 40;

  // Origin in SVG coordinates (bottom-left area with room for labels)
  const ox = pad + 40;
  const oy = H - pad - 30;

  // Scale vectors to fit nicely
  const maxCoord = Math.max(Math.abs(ux), Math.abs(uy), Math.abs(vx), Math.abs(vy), 1);
  const scale = Math.min(50, (W - 2 * pad - 80) / (maxCoord * 2));

  // Vector endpoints in SVG (y is flipped)
  const uTipX = ox + ux * scale;
  const uTipY = oy - uy * scale;
  const vTipX = ox + vx * scale;
  const vTipY = oy - vy * scale;

  // Triangle: origin -> u tip -> v tip
  const triPoints = `${ox},${oy} ${uTipX},${uTipY} ${vTipX},${vTipY}`;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Triangle formed by vectors u=(${ux},${uy}) and v=(${vx},${vy})`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowTV" />

      {/* Shaded triangle */}
      <polygon points={triPoints}
        fill="var(--forest-bg)" stroke="none" opacity={0.7} />

      {/* Dashed closing line (v tip to u tip) */}
      <DashedLine x1={uTipX} y1={uTipY} x2={vTipX} y2={vTipY}
        color="var(--gray-400)" strokeWidth={1.5} dasharray="5,3" />

      {/* Vector u */}
      <ForceArrow x1={ox} y1={oy} x2={uTipX} y2={uTipY}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowTV" />

      {/* Vector v */}
      <ForceArrow x1={ox} y1={oy} x2={vTipX} y2={vTipY}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowTV" />

      {/* Vector labels */}
      <Label x={(ox + uTipX) / 2} y={(oy + uTipY) / 2 + 16}
        fontSize={13} color="var(--charcoal)" bold italic>
        u
      </Label>
      <Label x={(ox + vTipX) / 2 - 14} y={(oy + vTipY) / 2}
        fontSize={13} color="var(--charcoal)" bold italic>
        v
      </Label>

      {/* Origin dot */}
      <circle cx={ox} cy={oy} r={3} fill="var(--charcoal)" />
    </svg>
  );
}

import React from 'react';
import { polar, K } from './geo';
import { ArrowMarkerDefs, DashedLine, AngleArc, Label, DimensionLine } from './primitives';

/**
 * Right triangle showing slope distance vs horizontal distance.
 *
 * Shows: slope line (hypotenuse), horizontal projection (dashed),
 *        vertical projection (dashed), vertical angle arc, SD label.
 * Does NOT show: computed HD or VD values (student solves).
 */
export function SlopeDistance({
  sd = 250,
  angle = 8,
  unit = 'm',
  below = false,
}) {
  const W = 380;
  const H = 220;

  // Origin — bottom-left of triangle
  const ox = 60;
  const oy = below ? 60 : 160;
  const slopeLen = 220;

  // Triangle tip — slope goes up-right (or down-right if below)
  const effectiveAngle = below ? -angle : angle;
  const tip = polar(ox, oy, slopeLen, effectiveAngle);

  // Horizontal endpoint (directly below/above tip)
  const hx = tip.x;
  const hy = oy;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Slope distance ${sd} ${unit} at ${angle} degrees ${below ? 'below' : 'above'} horizontal`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowSlope" color="var(--charcoal)" size={8} />

      {/* 1. Horizontal reference (dashed) */}
      <DashedLine x1={ox} y1={oy} x2={hx + 20} y2={oy} />

      {/* 2. Vertical drop/rise (dashed) */}
      <DashedLine x1={hx} y1={oy} x2={hx} y2={tip.y} />

      {/* 3. Slope line (bold) */}
      <line x1={ox} y1={oy} x2={tip.x} y2={tip.y}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 4. Origin point */}
      <circle cx={ox} cy={oy} r={3} fill="var(--charcoal)" />

      {/* 5. Endpoint */}
      <circle cx={tip.x} cy={tip.y} r={3} fill="var(--charcoal)" />

      {/* 6. Angle arc — large radius so small angles are legible */}
      <AngleArc cx={ox} cy={oy} radius={100}
        startAngle={0} endAngle={effectiveAngle}
        label={`${angle}\u00b0`} />

      {/* 7. Slope distance label — along the hypotenuse */}
      {(() => {
        const midSlope = polar(ox, oy, slopeLen / 2, effectiveAngle);
        const labelOffset = below ? 16 : -16;
        return (
          <Label x={midSlope.x} y={midSlope.y + labelOffset}
            fontSize={11} color="var(--charcoal)" bold>
            SD = {sd} {unit}
          </Label>
        );
      })()}

      {/* 8. Right angle marker at the vertical corner */}
      {(() => {
        const sz = 8;
        const cornerY = oy;
        const cornerX = hx;
        const dy = tip.y < oy ? -sz : sz;
        return (
          <path
            d={`M ${cornerX - sz},${cornerY} L ${cornerX - sz},${cornerY + dy} L ${cornerX},${cornerY + dy}`}
            fill="none" stroke="var(--gray-400)" strokeWidth={1} />
        );
      })()}
    </svg>
  );
}

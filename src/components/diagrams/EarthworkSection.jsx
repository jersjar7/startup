import React from 'react';
import { DimensionLine, DashedLine, Label } from './primitives';

/**
 * Earthwork cross-sections for volume computation.
 *
 * Shows: two trapezoidal cross-sections at stations separated by L,
 * with areas A1 and A2 labeled. Optionally shows Am at midpoint.
 * Student computes volume by average end area or prismoidal formula.
 */
export function EarthworkSection({
  A1 = 200,
  A2 = 300,
  Am = null,
  L = 100,
  unit = 'ft',
}) {
  const W = 440;
  const H = 220;

  // Layout — two cross-sections side by side
  const secW = 100;    // width of each cross-section trapezoid
  const maxA = Math.max(A1, A2, Am || 0);

  // Scale areas to visual heights (sqrt for area → height feel)
  const maxVisH = 90;
  const h1 = Math.sqrt(A1 / maxA) * maxVisH;
  const h2 = Math.sqrt(A2 / maxA) * maxVisH;
  const hm = Am ? Math.sqrt(Am / maxA) * maxVisH : 0;

  const groundY = 170;
  const sec1X = 80;
  const sec2X = W - 80;
  const midX = (sec1X + sec2X) / 2;

  // Trapezoid: wider at top (ground level), narrower at bottom (depth)
  // Represents a cut section shape
  const trapezoid = (cx, visH, baseW) => {
    const topW = baseW;
    const botW = baseW * 0.5;
    const top = groundY - visH;
    return `M ${cx - topW / 2},${groundY} L ${cx - botW / 2},${top} L ${cx + botW / 2},${top} L ${cx + topW / 2},${groundY} Z`;
  };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Earthwork sections: A1=${A1} ${unit}², A2=${A2} ${unit}², ${L} ${unit} apart${Am ? `, Am=${Am} ${unit}²` : ''}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Ground line */}
      <line x1={30} y1={groundY} x2={W - 30} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Ground hatching */}
      {Array.from({ length: 22 }, (_, i) => (
        <line key={`gh${i}`}
          x1={35 + i * 18} y1={groundY + 2}
          x2={45 + i * 18} y2={groundY + 10}
          stroke="var(--gray-400)" strokeWidth={0.7} />
      ))}

      {/* Section 1 (left) */}
      <path d={trapezoid(sec1X, h1, secW)}
        fill="rgba(232,104,58,0.10)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Section 2 (right) */}
      <path d={trapezoid(sec2X, h2, secW)}
        fill="rgba(232,104,58,0.10)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Mid-section (dashed outline, if Am provided) */}
      {Am && (
        <path d={trapezoid(midX, hm, secW * 0.85)}
          fill="rgba(232,104,58,0.06)"
          stroke="var(--gray-400)" strokeWidth={1.5} strokeDasharray="5,4" />
      )}

      {/* Area labels inside sections */}
      <Label x={sec1X} y={groundY - h1 / 2}
        fontSize={10} color="var(--charcoal)" bold>
        A{'\u2081'} = {A1}
      </Label>
      <Label x={sec1X} y={groundY - h1 / 2 + 14}
        fontSize={8} color="var(--gray-500)">
        {unit}{'\u00B2'}
      </Label>

      <Label x={sec2X} y={groundY - h2 / 2}
        fontSize={10} color="var(--charcoal)" bold>
        A{'\u2082'} = {A2}
      </Label>
      <Label x={sec2X} y={groundY - h2 / 2 + 14}
        fontSize={8} color="var(--gray-500)">
        {unit}{'\u00B2'}
      </Label>

      {Am && (
        <>
          <Label x={midX} y={groundY - hm / 2}
            fontSize={9} color="var(--gray-500)">
            A{'\u2098'} = {Am}
          </Label>
          <Label x={midX} y={groundY - hm / 2 + 12}
            fontSize={7} color="var(--gray-500)">
            {unit}{'\u00B2'}
          </Label>
        </>
      )}

      {/* L dimension along bottom */}
      <DimensionLine
        x1={sec1X} y1={groundY + 24}
        x2={sec2X} y2={groundY + 24}
        label={`L = ${L} ${unit}`}
        offset={12} fontSize={9} />

      {/* Station labels below sections */}
      <Label x={sec1X} y={groundY + 48}
        fontSize={8} color="var(--gray-500)">
        Sta. 1
      </Label>
      <Label x={sec2X} y={groundY + 48}
        fontSize={8} color="var(--gray-500)">
        Sta. 2
      </Label>
      {Am && (
        <Label x={midX} y={groundY + 48}
          fontSize={8} color="var(--gray-500)">
          Mid
        </Label>
      )}

      {/* Connecting dashed lines between sections (top edges) */}
      <DashedLine x1={sec1X} y1={groundY - h1}
        x2={sec2X} y2={groundY - h2}
        color="var(--gray-400)" strokeWidth={1} />
    </svg>
  );
}

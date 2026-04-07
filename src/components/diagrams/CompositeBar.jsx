import React from 'react';
import { ArrowMarkerDefs, ForceArrow, DimensionLine, Label } from './primitives';

/**
 * Two-segment composite bar under axial load.
 * Shows: two segments of different widths, material labels, length dimensions, force P.
 * Does NOT show: elongation values, E values (in problem text).
 */
export function CompositeBar({
  label1 = 'Steel', length1 = 600, label2 = 'Aluminum', length2 = 900,
  lengthUnit = 'mm', force = 50, forceUnit = 'kN',
}) {
  const W = 440;
  const H = 160;

  const midY = H / 2 - 6;
  const totalLen = length1 + length2;

  const barStartX = 100;
  const barTotalW = 220;
  const scale = barTotalW / totalLen;
  const seg1W = length1 * scale;
  const seg2W = length2 * scale;

  // Different heights to show different cross-sections
  const seg1H = 32;
  const seg2H = 42;

  const seg1X = barStartX;
  const seg2X = barStartX + seg1W;

  const arrowLen = 40;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Composite bar: ${label1} (${length1} ${lengthUnit}) + ${label2} (${length2} ${lengthUnit}), P = ${force} ${forceUnit}`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowP" color="var(--ember)" size={8} />

      {/* Segment 1 */}
      <rect x={seg1X} y={midY - seg1H / 2} width={seg1W} height={seg1H}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={2} />
      <Label x={seg1X + seg1W / 2} y={midY} fontSize={9} color="var(--charcoal)" bold>
        {label1}
      </Label>

      {/* Segment 2 */}
      <rect x={seg2X} y={midY - seg2H / 2} width={seg2W} height={seg2H}
        fill="white" stroke="var(--charcoal)" strokeWidth={2} rx={2} />
      <Label x={seg2X + seg2W / 2} y={midY} fontSize={9} color="var(--charcoal)" bold>
        {label2}
      </Label>

      {/* Left wall (fixed end) */}
      <line x1={seg1X} y1={midY - 30} x2={seg1X} y2={midY + 30}
        stroke="var(--charcoal)" strokeWidth={3} />
      {Array.from({ length: 5 }, (_, i) => {
        const hy = midY - 26 + i * 13;
        return (
          <line key={i} x1={seg1X} y1={hy} x2={seg1X - 10} y2={hy + 6}
            stroke="var(--gray-400)" strokeWidth={1.5} />
        );
      })}

      {/* Force arrow P (pulling right from end of segment 2) */}
      <ForceArrow
        x1={seg2X + seg2W + 6} y1={midY}
        x2={seg2X + seg2W + 6 + arrowLen} y2={midY}
        color="var(--ember)" strokeWidth={2.5} markerId="arrowP" />
      <Label x={seg2X + seg2W + 6 + arrowLen + 6} y={midY}
        fontSize={11} color="var(--ember)" bold anchor="start">
        {force} {forceUnit}
      </Label>

      {/* Length dimension segment 1 */}
      <DimensionLine
        x1={seg1X} y1={midY + seg2H / 2 + 20}
        x2={seg2X} y2={midY + seg2H / 2 + 20}
        label={`${length1} ${lengthUnit}`} offset={14} fontSize={9} />

      {/* Length dimension segment 2 */}
      <DimensionLine
        x1={seg2X} y1={midY + seg2H / 2 + 20}
        x2={seg2X + seg2W} y2={midY + seg2H / 2 + 20}
        label={`${length2} ${lengthUnit}`} offset={14} fontSize={9} />
    </svg>
  );
}

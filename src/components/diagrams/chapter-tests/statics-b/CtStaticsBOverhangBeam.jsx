import React from 'react';
import { ArrowMarkerDefs, PinSupport, RollerSupport, Label } from '../../primitives';
import { polar } from '../../geo';

/** Ground line with short hatch strokes under a support. */
function Ground({ x, y }) {
  return (
    <g>
      <line x1={x - 13} y1={y} x2={x + 13} y2={y} stroke="var(--charcoal)" strokeWidth={2} />
      {[0, 1, 2, 3, 4].map((i) => (
        <line key={i} x1={x - 8 + i * 5} y1={y} x2={x - 13 + i * 5} y2={y + 5} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}
    </g>
  );
}

/**
 * Beam on a pin at A and a roller at B with an overhang to C. Point load at
 * C and a clockwise couple inside the span.
 * Shows: supports, the load, the couple, all dimensions.
 * Does NOT show: reactions.
 */
export function CtStaticsBOverhangBeam({ span = 16, overhang = 6, coupleAt = 8, couple = 40, load = 10 }) {
  const S = 340 / (span + overhang);
  const x0 = 24;
  const by = 96;
  const xA = x0;
  const xB = x0 + span * S;
  const xC = xB + overhang * S;
  const xM = x0 + coupleAt * S;
  const bh = 10;
  const gray = 'var(--gray-500)';
  const dimY = by + bh / 2 + 52;
  const R = 22;
  // clockwise arc from about 140 deg round to 40 deg (going over the top)
  const a0 = polar(xM, by, R, 150);
  const a1 = polar(xM, by, R, 30);
  const ticks = [xA, xM, xB, xC];

  return (
    <svg viewBox={`0 0 ${xC + 26} ${dimY + 22}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Overhanging beam: span ${span} ft, overhang ${overhang} ft, ${load} kip load at C, ${couple} kip-ft clockwise couple ${coupleAt} ft from A`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBOvhArrow" color="var(--ember)" size={9} />

      <rect x={xA} y={by - bh / 2} width={xC - xA} height={bh} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} />
      <PinSupport x={xA} y={by + bh / 2} />
      <Ground x={xA} y={by + bh / 2 + 16} />
      <RollerSupport x={xB} y={by + bh / 2} />
      <Ground x={xB} y={by + bh / 2 + 26} />
      <Label x={xA} y={by - 18} color="var(--charcoal)" bold>A</Label>
      <Label x={xB} y={by - 18} color="var(--charcoal)" bold>B</Label>
      <Label x={xC + 8} y={by + 16} color="var(--charcoal)" bold anchor="start">C</Label>

      {/* Load at C */}
      <line x1={xC - 2} y1={by - 64} x2={xC - 2} y2={by - bh / 2 - 2} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBOvhArrow)" />
      <Label x={xC - 10} y={by - 54} color="var(--ember)" bold anchor="end">{`${load} kips`}</Label>

      {/* Clockwise couple */}
      <path d={`M ${a0.x},${a0.y} A ${R},${R} 0 0 1 ${a1.x},${a1.y}`} fill="none" stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctStBOvhArrow)" />
      <circle cx={xM} cy={by} r={2.6} fill="var(--ember)" />
      <Label x={xM} y={by - R - 14} color="var(--ember)" bold>{`${couple} kip-ft`}</Label>

      {/* Dimensions */}
      <line x1={xA} y1={dimY} x2={xC} y2={dimY} stroke={gray} strokeWidth={1} />
      {ticks.map((t) => <line key={t} x1={t} y1={dimY - 5} x2={t} y2={dimY + 5} stroke={gray} strokeWidth={1} />)}
      <Label x={(xA + xM) / 2} y={dimY + 13}>{`${coupleAt} ft`}</Label>
      <Label x={(xM + xB) / 2} y={dimY + 13}>{`${span - coupleAt} ft`}</Label>
      <Label x={(xB + xC) / 2} y={dimY + 13}>{`${overhang} ft`}</Label>
    </svg>
  );
}

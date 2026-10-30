import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Horizontal beam AB pinned to a wall at A and held at B by a tie rod to C
 * on the wall above A. End load at B and the beam's own weight at midspan.
 * Shows: geometry, end load, beam weight.
 * Does NOT show: the rod tension or the pin reactions.
 */
export function CtStaticsATieRodBeam({ span = 4, rise = 3, load = 6, weight = 2, unit = 'kN' }) {
  const S = 56;
  const wx = 84; // wall face
  const ay = 214;
  const axp = wx + 6; // pin A
  const bx = axp + span * S + 6;
  const cy = ay - rise * S;
  const mx = (wx + 6 + bx - 6) / 2;
  const gray = 'var(--gray-500)';
  const dimY = ay + 54;

  return (
    <svg viewBox={`0 0 ${bx + 44} ${dimY + 20}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Beam ${span} m long pinned at a wall, tie rod to a point ${rise} m above, ${load} ${unit} end load, ${weight} ${unit} self weight`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStATieArrow" color="var(--ember)" size={9} />
      <ArrowMarkerDefs id="ctStATieGray" color="var(--charcoal)" size={8} />

      {/* Wall */}
      <line x1={wx} y1={cy - 30} x2={wx} y2={ay + 30} stroke="var(--charcoal)" strokeWidth={2.2} />
      {Array.from({ length: Math.floor((ay - cy + 60) / 14) }, (_, i) => (
        <line key={i} x1={wx} y1={cy - 24 + i * 14} x2={wx - 9} y2={cy - 16 + i * 14} stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Tie rod */}
      <line x1={wx + 5} y1={cy + 4} x2={bx - 5} y2={ay - 4} stroke="var(--charcoal)" strokeWidth={1.8} />

      {/* Beam */}
      <rect x={wx + 6} y={ay - 6} width={bx - wx - 6} height={12} rx={2} fill="none" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Pins */}
      <circle cx={wx + 6} cy={ay} r={4.5} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.8} />
      <circle cx={wx + 5} cy={cy} r={4.5} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.8} />
      <circle cx={bx - 6} cy={ay} r={4} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.8} />
      <Label x={wx + 16} y={ay + 20} color="var(--charcoal)" bold>A</Label>
      <Label x={bx + 14} y={ay - 2} color="var(--charcoal)" bold>B</Label>
      <Label x={wx + 18} y={cy - 6} color="var(--charcoal)" bold>C</Label>

      {/* Loads */}
      <line x1={bx - 6} y1={ay - 70} x2={bx - 6} y2={ay - 9} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStATieArrow)" />
      <Label x={bx - 6} y={ay - 82} color="var(--ember)" bold>{`${load} ${unit}`}</Label>
      <line x1={mx} y1={ay + 6} x2={mx} y2={ay + 34} stroke="var(--charcoal)" strokeWidth={1.6} markerEnd="url(#ctStATieGray)" />
      <Label x={mx + 8} y={ay + 24} color="var(--charcoal)" anchor="start">{`W = ${weight} ${unit}`}</Label>

      {/* Span dimension (above beam would clash with rod; put it under, left of W) */}
      <line x1={axp} y1={dimY} x2={bx - 6} y2={dimY} stroke={gray} strokeWidth={1} />
      <line x1={axp} y1={dimY - 5} x2={axp} y2={dimY + 5} stroke={gray} strokeWidth={1} />
      <line x1={bx - 6} y1={dimY - 5} x2={bx - 6} y2={dimY + 5} stroke={gray} strokeWidth={1} />
      <line x1={axp} y1={ay + 30} x2={axp} y2={dimY + 5} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={bx - 6} y1={ay + 10} x2={bx - 6} y2={dimY + 5} stroke="var(--gray-300)" strokeWidth={1} />
      <Label x={(axp + bx - 6) / 2} y={dimY + 12}>{`${span} m`}</Label>

      {/* Rise dimension, left of the wall */}
      <line x1={wx - 40} y1={cy} x2={wx - 40} y2={ay} stroke={gray} strokeWidth={1} />
      <line x1={wx - 45} y1={cy} x2={wx - 35} y2={cy} stroke={gray} strokeWidth={1} />
      <line x1={wx - 45} y1={ay} x2={wx - 35} y2={ay} stroke={gray} strokeWidth={1} />
      <Label x={wx - 46} y={(cy + ay) / 2} anchor="end">{`${rise} m`}</Label>
    </svg>
  );
}

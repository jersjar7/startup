import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Column with a bracket load and a horizontal wind load, base point O.
 * Shows: bracket load and its eccentricity, horizontal load at the top,
 * heights of both loads above O.
 * Does NOT show: the equivalent force-couple at O.
 */
export function CtStaticsAColumnBracket({
  height = 16, bracketHeight = 12, ecc = 2, p = 20, h = 4, unit = 'kips',
}) {
  const S = 16; // px per ft
  const cx = 150; // column centerline
  const baseY = height * S + 34;
  const topY = baseY - height * S;
  const brY = baseY - bracketHeight * S;
  const hw = 9; // half column width
  const ex = cx + ecc * S * 1.0; // load line
  const dimX1 = cx - hw - 20;
  const dimX2 = cx - hw - 82;
  const gray = 'var(--gray-500)';

  return (
    <svg viewBox={`0 0 300 ${baseY + 30}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Column ${height} ft tall with ${p} ${unit} bracket load at ${ecc} ft eccentricity and ${h} ${unit} horizontal load at the top`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStAColArrow" color="var(--ember)" size={9} />

      {/* Ground and base */}
      <line x1={cx - 70} y1={baseY} x2={cx + 70} y2={baseY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 13 }, (_, i) => (
        <line key={i} x1={cx - 64 + i * 11} y1={baseY} x2={cx - 72 + i * 11} y2={baseY + 8} stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Column */}
      <rect x={cx - hw} y={topY} width={2 * hw} height={baseY - topY} fill="none" stroke="var(--charcoal)" strokeWidth={2.2} />
      <line x1={cx} y1={topY - 6} x2={cx} y2={baseY + 4} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="8,3,2,3" />

      {/* Bracket (seat) */}
      <polygon points={`${cx + hw},${brY} ${ex + 12},${brY} ${ex + 12},${brY + 6} ${cx + hw},${brY + 26}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />

      {/* Bracket load */}
      <line x1={ex} y1={brY - 46} x2={ex} y2={brY - 2} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStAColArrow)" />
      <Label x={ex + 8} y={brY - 28} color="var(--ember)" bold anchor="start">{`${p} ${unit}`}</Label>

      {/* Eccentricity dimension, below the bracket */}
      <line x1={ex} y1={brY + 10} x2={ex} y2={brY + 44} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={cx} y1={brY + 38} x2={ex} y2={brY + 38} stroke={gray} strokeWidth={1} />
      <line x1={cx} y1={brY + 33} x2={cx} y2={brY + 43} stroke={gray} strokeWidth={1} />
      <line x1={ex} y1={brY + 33} x2={ex} y2={brY + 43} stroke={gray} strokeWidth={1} />
      <Label x={ex + 6} y={brY + 38} anchor="start">{`${ecc} ft`}</Label>

      {/* Horizontal load at the top, acting to the left */}
      <line x1={cx + hw + 78} y1={topY + 2} x2={cx + hw + 2} y2={topY + 2} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStAColArrow)" />
      <Label x={cx + hw + 44} y={topY - 12} color="var(--ember)" bold>{`${h} ${unit}`}</Label>

      {/* Height dimensions on the left */}
      <line x1={cx - hw - 4} y1={topY + 2} x2={dimX2 - 6} y2={topY + 2} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={cx - hw - 4} y1={brY} x2={dimX1 - 6} y2={brY} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={dimX1} y1={brY} x2={dimX1} y2={baseY} stroke={gray} strokeWidth={1} />
      <line x1={dimX1 - 5} y1={brY} x2={dimX1 + 5} y2={brY} stroke={gray} strokeWidth={1} />
      <line x1={dimX1 - 5} y1={baseY} x2={dimX1 + 5} y2={baseY} stroke={gray} strokeWidth={1} />
      <Label x={dimX1 - 6} y={(brY + baseY) / 2} anchor="end">{`${bracketHeight} ft`}</Label>
      <line x1={dimX2} y1={topY + 2} x2={dimX2} y2={baseY} stroke={gray} strokeWidth={1} />
      <line x1={dimX2 - 5} y1={topY + 2} x2={dimX2 + 5} y2={topY + 2} stroke={gray} strokeWidth={1} />
      <line x1={dimX2 - 5} y1={baseY} x2={dimX2 + 5} y2={baseY} stroke={gray} strokeWidth={1} />
      <Label x={dimX2 - 6} y={(topY + baseY) / 2} anchor="end">{`${height} ft`}</Label>

      {/* Base point */}
      <circle cx={cx} cy={baseY} r={3.5} fill="var(--charcoal)" />
      <Label x={cx + 14} y={baseY + 16} color="var(--charcoal)" bold>O</Label>
    </svg>
  );
}

import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * A crate on a rough floor pushed by a horizontal force P at a given height.
 * Shows: size, push height, weight at the center, mu.
 * Does NOT show: whether it slides or tips.
 */
export function CtStaticsBCrateTip({ width = 4, height = 6, pushAt = 5, weight = 600, mu = 0.35 }) {
  const S = 26;
  const fy = 196;
  const cl = 130;
  const cr = cl + width * S;
  const ct = fy - height * S;
  const py = fy - pushAt * S;
  const cx = (cl + cr) / 2;
  const cy = (ct + fy) / 2;
  const gray = 'var(--gray-500)';
  const tail = cl - 70;
  const dX = tail - 16;

  return (
    <svg viewBox={`0 0 ${cr + 70} ${fy + 50}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Crate ${width} by ${height} ft weighing ${weight} lb pushed by P at ${pushAt} ft, floor friction ${mu}`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBCrateArrow" color="var(--ember)" size={9} />

      {/* Floor */}
      <line x1={20} y1={fy} x2={cr + 56} y2={fy} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 19 }, (_, i) => (
        <line key={i} x1={26 + i * 15} y1={fy} x2={18 + i * 15} y2={fy + 8} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}

      {/* Crate */}
      <rect x={cl} y={ct} width={cr - cl} height={fy - ct} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={cx} cy={cy} r={2.8} fill="var(--charcoal)" />
      <line x1={cx} y1={cy} x2={cx} y2={cy + 52} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBCrateArrow)" />
      <Label x={cx + 8} y={cy + 40} color="var(--ember)" bold anchor="start">{`${weight} lb`}</Label>

      {/* Push */}
      <line x1={tail} y1={py} x2={cl - 3} y2={py} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBCrateArrow)" />
      <Label x={tail + 30} y={py - 12} color="var(--ember)" bold italic>P</Label>

      {/* Push height */}
      <line x1={dX} y1={py} x2={dX} y2={fy} stroke={gray} strokeWidth={1} />
      <line x1={dX - 5} y1={py} x2={tail - 4} y2={py} stroke={gray} strokeWidth={1} />
      <line x1={dX - 5} y1={fy} x2={dX + 5} y2={fy} stroke={gray} strokeWidth={1} />
      <Label x={dX - 8} y={(py + fy) / 2} anchor="end">{`${pushAt} ft`}</Label>

      {/* Height */}
      <line x1={cr + 26} y1={ct} x2={cr + 26} y2={fy} stroke={gray} strokeWidth={1} />
      <line x1={cr + 4} y1={ct} x2={cr + 31} y2={ct} stroke={gray} strokeWidth={1} />
      <line x1={cr + 21} y1={fy} x2={cr + 31} y2={fy} stroke={gray} strokeWidth={1} />
      <Label x={cr + 34} y={(ct + fy) / 2} anchor="start">{`${height} ft`}</Label>

      {/* Width */}
      <line x1={cl} y1={fy + 24} x2={cr} y2={fy + 24} stroke={gray} strokeWidth={1} />
      <line x1={cl} y1={fy + 12} x2={cl} y2={fy + 29} stroke={gray} strokeWidth={1} />
      <line x1={cr} y1={fy + 12} x2={cr} y2={fy + 29} stroke={gray} strokeWidth={1} />
      <Label x={(cl + cr) / 2} y={fy + 37}>{`${width} ft`}</Label>
      <Label x={20} y={fy + 24} color="var(--charcoal)" anchor="start">{`μs = ${mu}`}</Label>
    </svg>
  );
}

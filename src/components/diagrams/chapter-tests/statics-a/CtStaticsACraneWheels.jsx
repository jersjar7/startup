import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Two crane wheel loads on a runway girder.
 * Shows: the two wheel loads and their spacing.
 * Does NOT show: the resultant or its location.
 */
export function CtStaticsACraneWheels({ p1 = 18, p2 = 12, spacing = 10, unit = 'kips' }) {
  const S = 18; // px per ft
  const x1 = 90;
  const x2 = x1 + spacing * S;
  const railY = 96;
  const wr = 10; // wheel radius
  const beamTop = railY + 4;
  const beamBot = beamTop + 26;
  const gray = 'var(--gray-500)';
  const W = x2 + 90;
  const dimY = beamBot + 26;

  return (
    <svg viewBox={`0 0 ${W} ${dimY + 22}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Crane wheel loads of ${p1} and ${p2} ${unit} spaced ${spacing} ft on a runway girder`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStACraneArrow" color="var(--ember)" size={9} />

      {/* Girder with break lines at both ends */}
      <line x1={20} y1={beamTop} x2={W - 20} y2={beamTop} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={20} y1={beamBot} x2={W - 20} y2={beamBot} stroke="var(--charcoal)" strokeWidth={2} />
      <path d={`M 20 ${beamTop - 4} L 20 ${beamTop + 10} L 14 ${beamTop + 14} L 26 ${beamTop + 18} L 20 ${beamTop + 22} L 20 ${beamBot + 4}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.4} />
      <path d={`M ${W - 20} ${beamTop - 4} L ${W - 20} ${beamTop + 10} L ${W - 26} ${beamTop + 14} L ${W - 14} ${beamTop + 18} L ${W - 20} ${beamTop + 22} L ${W - 20} ${beamBot + 4}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.4} />
      <rect x={20} y={railY} width={W - 40} height={4} fill="var(--charcoal)" />

      {/* End truck frame and wheels */}
      <rect x={x1 - 24} y={railY - 2 * wr - 16} width={x2 - x1 + 48} height={14} rx={3} fill="none" stroke="var(--charcoal)" strokeWidth={1.8} />
      <circle cx={x1} cy={railY - wr} r={wr} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={x2} cy={railY - wr} r={wr} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={x1} cy={railY - wr} r={2.5} fill="var(--charcoal)" />
      <circle cx={x2} cy={railY - wr} r={2.5} fill="var(--charcoal)" />

      {/* Wheel loads */}
      <line x1={x1} y1={railY - 2 * wr - 58} x2={x1} y2={railY - 2 * wr - 18} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStACraneArrow)" />
      <line x1={x2} y1={railY - 2 * wr - 58} x2={x2} y2={railY - 2 * wr - 18} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStACraneArrow)" />
      <Label x={x1 - 8} y={railY - 2 * wr - 48} color="var(--ember)" bold anchor="end">{`${p1} ${unit}`}</Label>
      <Label x={x2 + 8} y={railY - 2 * wr - 48} color="var(--ember)" bold anchor="start">{`${p2} ${unit}`}</Label>

      {/* Spacing dimension */}
      <line x1={x1} y1={beamBot + 6} x2={x1} y2={dimY + 6} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x2} y1={beamBot + 6} x2={x2} y2={dimY + 6} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={x1} y1={dimY} x2={x2} y2={dimY} stroke={gray} strokeWidth={1} />
      <line x1={x1 - 4} y1={dimY + 4} x2={x1 + 4} y2={dimY - 4} stroke={gray} strokeWidth={1.4} />
      <line x1={x2 - 4} y1={dimY + 4} x2={x2 + 4} y2={dimY - 4} stroke={gray} strokeWidth={1.4} />
      <Label x={(x1 + x2) / 2} y={dimY + 13}>{`${spacing} ft`}</Label>
    </svg>
  );
}

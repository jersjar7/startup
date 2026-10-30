import React from 'react';
import { DimensionLine, FixedSupport, Label } from '../../primitives';

// Rod anchored at a wall with a small gap to a rigid abutment (gap exaggerated).
export function CtMechanicsMaterialsAGapRod({ length = 25, gap = '0.040 in.', dT = 90 }) {
  const xW = 40;
  const xEnd = 356;
  const xAb = 372;
  const cy = 92;

  return (
    <svg viewBox="0 0 420 170" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Steel rod ${length} ft long anchored at one end with a ${gap} gap to a rigid abutment; temperature rise ${dT} degrees F`}
      style={{ width: '100%', height: 'auto' }}>
      <FixedSupport x={xW} y={cy - 34} height={68} side="left" />
      <FixedSupport x={xAb} y={cy - 34} height={68} side="right" />
      <rect x={xW} y={cy - 6} width={xEnd - xW} height={12} fill="var(--gray-400)" fillOpacity={0.25} stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={(xW + xEnd) / 2} y={cy - 22} color="var(--charcoal)">steel rod</Label>
      <Label x={(xW + xEnd) / 2} y={cy + 24} bold color="var(--ember)">{`ΔT = +${dT}°F`}</Label>
      {/* Gap */}
      <line x1={xEnd} y1={cy - 8} x2={xEnd} y2={cy - 52} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={xAb} y1={cy - 36} x2={xAb} y2={cy - 52} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={xEnd} y1={cy - 48} x2={xAb} y2={cy - 48} fontSize={12} tickSize={4} />
      <Label x={xAb} y={cy - 64} anchor="end" color="var(--charcoal)">{`gap ${gap} (exaggerated)`}</Label>
      {/* Length */}
      <DimensionLine x1={xW} y1={cy + 52} x2={xEnd} y2={cy + 52} label={`${length} ft`} offset={13} fontSize={12} />
      <Label x={xW + 4} y={cy - 46} anchor="start" color="var(--charcoal)">anchored</Label>
    </svg>
  );
}

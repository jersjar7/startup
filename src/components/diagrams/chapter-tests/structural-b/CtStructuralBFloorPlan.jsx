import React from 'react';
import { T, Dim, Ext, INK, LOAD, SEC } from './CtStructuralBParts';

/**
 * Framing plan of one floor bay: girders along the two long sides between
 * corner columns, beams spanning between the girders at equal spacing. One
 * interior beam (B1) is picked out. Drawn to scale.
 */
export function CtStructuralBFloorPlan({ girderFt = 32, beamFt = 24, spacingFt = 8, pick = 2 }) {
  const s = 9;
  const ox = 30;
  const oy = 50;
  const xR = ox + girderFt * s;
  const yB = oy + beamFt * s;
  const nSp = Math.round(girderFt / spacingFt);
  const bx = (i) => ox + i * spacingFt * s;
  const dimY = oy - 30;
  const dimX = xR + 30;
  const W = dimX + 46;
  const H = yB + 16;
  const col = 9;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Framing plan: girders ${girderFt} ft long, beams spanning ${beamFt} ft at ${spacingFt} ft spacing`}
      style={{ width: '100%', height: 'auto' }}>
      {/* girders */}
      <line x1={ox} y1={oy} x2={xR} y2={oy} stroke={INK} strokeWidth={3.5} />
      <line x1={ox} y1={yB} x2={xR} y2={yB} stroke={INK} strokeWidth={3.5} />
      {/* beams */}
      {Array.from({ length: nSp + 1 }, (_, i) => (
        <line key={i} x1={bx(i)} y1={oy} x2={bx(i)} y2={yB}
          stroke={i === pick ? LOAD : INK} strokeWidth={i === pick ? 3 : 1.8} />
      ))}
      {/* columns */}
      {[[ox, oy], [xR, oy], [ox, yB], [xR, yB]].map(([x, y], i) => (
        <rect key={i} x={x - col / 2} y={y - col / 2} width={col} height={col} fill={INK} />
      ))}
      <T x={bx(pick) + 8} y={(oy + yB) / 2} anchor="start" color={LOAD} bold>B1</T>
      <T x={(bx(0) + bx(1)) / 2} y={oy + 14} size={11} color={SEC}>girder</T>
      <T x={(bx(0) + bx(1)) / 2} y={yB - 14} size={11} color={SEC}>girder</T>

      {/* beam spacing */}
      {Array.from({ length: nSp + 1 }, (_, i) => (
        <Ext key={i} x1={bx(i)} y1={oy - 7} x2={bx(i)} y2={dimY - 5} />
      ))}
      {Array.from({ length: nSp }, (_, i) => (
        <Dim key={i} x1={bx(i)} y1={dimY} x2={bx(i + 1)} y2={dimY} label={`${spacingFt} ft`} side="above" />
      ))}

      {/* beam span */}
      <Ext x1={xR + 7} y1={oy} x2={dimX + 5} y2={oy} />
      <Ext x1={xR + 7} y1={yB} x2={dimX + 5} y2={yB} />
      <Dim x1={dimX} y1={oy} x2={dimX} y2={yB} label={`${beamFt} ft`} side="right" />
    </svg>
  );
}

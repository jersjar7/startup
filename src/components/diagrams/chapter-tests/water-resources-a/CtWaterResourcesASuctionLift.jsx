import React from 'react';
import { Label } from '../../primitives';

/**
 * Lift station pump drawing from a wet well whose water surface is below the
 * pump: a suction lift.
 * Shows: wet well water surface, suction pipe with bell inlet, pump on its
 * pad, impeller centerline, and the vertical distance from the water surface
 * up to the impeller centerline.
 * Props: lift (drawn height, ft); label (text for that dimension, such as an
 * unknown z, or null to print the value).
 * Does NOT show: NPSH available, pressures or heads.
 */
export function CtWaterResourcesASuctionLift({ lift = 8, label = null }) {
  const s = 12; // px per ft
  const wellL = 84;
  const wellR = 214;
  const wellTop = 12;
  const wsY = 176;
  const wellBot = 226;
  const clY = wsY - lift * s;
  const pumpX = 280;
  const r = 17;
  const pipeX = 150;
  const dimX = 58;

  return (
    <svg viewBox={`0 0 400 ${wellBot + 16}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Pump with impeller centerline ${label || `${lift} ft`} above the wet well water surface`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctWraASuctionArrow" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L8,4 L0,8 Z" fill="var(--info)" />
        </marker>
      </defs>

      {/* Wet well water */}
      <rect x={wellL} y={wsY} width={wellR - wellL} height={wellBot - wsY} fill="var(--info)" fillOpacity={0.2} />
      <line x1={wellL} y1={wsY} x2={wellR} y2={wsY} stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={`${wellR - 34},${wsY - 11} ${wellR - 22},${wsY - 11} ${wellR - 28},${wsY - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />
      <Label x={wellR + 8} y={wsY - 7} color="var(--info)" fontSize={11} anchor="start">low water level</Label>
      <Label x={(wellL + pipeX) / 2 - 4} y={wsY + 26} color="var(--info)" fontSize={12}>wet well</Label>

      {/* Wet well walls and floor */}
      <polyline points={`${wellL},${wellTop} ${wellL},${wellBot} ${wellR},${wellBot} ${wellR},${wellTop}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.4} />
      {Array.from({ length: 9 }, (_, i) => (
        <line key={i} x1={wellL + 8 + i * 14} y1={wellBot + 2} x2={wellL + 2 + i * 14} y2={wellBot + 9} stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Pump pad */}
      <rect x={pumpX - 34} y={clY + r + 2} width={68} height={12} fill="var(--gray-400)" fillOpacity={0.25} stroke="var(--charcoal)" strokeWidth={1.4} />
      <line x1={wellR} y1={clY + r + 14} x2={392} y2={clY + r + 14} stroke="var(--charcoal)" strokeWidth={1.4} />

      {/* Suction pipe: bell inlet under water, up, across to the pump */}
      <polyline points={`${pipeX},${wsY + 30} ${pipeX},${clY} ${pumpX - r},${clY}`} fill="none" stroke="var(--charcoal)" strokeWidth={5} strokeLinejoin="round" />
      <path d={`M ${pipeX - 9},${wsY + 36} L ${pipeX - 3},${wsY + 28} L ${pipeX + 3},${wsY + 28} L ${pipeX + 9},${wsY + 36}`} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={pipeX + 12} y1={wsY - 14} x2={pipeX + 12} y2={wsY - 54} stroke="var(--info)" strokeWidth={1.5} markerEnd="url(#ctWraASuctionArrow)" />

      {/* Discharge pipe */}
      <polyline points={`${pumpX},${clY - r} ${pumpX},${clY - 40} ${388},${clY - 40}`} fill="none" stroke="var(--charcoal)" strokeWidth={5} strokeLinejoin="round" />
      <Label x={344} y={clY - 54} color="var(--gray-500)" fontSize={11}>discharge</Label>

      {/* Pump */}
      <circle cx={pumpX} cy={clY} r={r} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <polygon points={`${pumpX - 7},${clY - 8} ${pumpX - 7},${clY + 8} ${pumpX + 9},${clY}`} fill="var(--charcoal)" />
      <Label x={(wellR + pumpX - r) / 2} y={clY - 12} color="var(--charcoal)" fontSize={12} bold>pump</Label>

      {/* Impeller centerline extended to the dimension */}
      <line x1={dimX - 6} y1={clY} x2={pipeX - 6} y2={clY} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="8,3,2,3" />
      <line x1={dimX - 6} y1={wsY} x2={wellL - 3} y2={wsY} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={dimX} y1={clY} x2={dimX} y2={wsY} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={dimX - 4} y1={clY + 4} x2={dimX + 4} y2={clY - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={dimX - 4} y1={wsY + 4} x2={dimX + 4} y2={wsY - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={dimX - 8} y={(clY + wsY) / 2} color="var(--charcoal)" fontSize={label ? 14 : 12} italic={!!label} anchor="end">{label || `${lift.toFixed(1)} ft`}</Label>
      <Label x={pumpX + r + 8} y={clY + 1} color="var(--gray-500)" fontSize={11} anchor="start">impeller ℄</Label>
      <line x1={pumpX + r + 2} y1={clY} x2={pumpX + r + 6} y2={clY} stroke="var(--gray-500)" strokeWidth={1} />
    </svg>
  );
}

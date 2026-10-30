import React from 'react';
import { T, Arrow, Dim, Ext, WaterSym, Ground } from './CtFluidMechanicsAParts';

/**
 * Outfall flap gate hinged along its top edge, water on both sides, held
 * shut by a horizontal force P at its bottom edge. Depths drawn to scale.
 * Does NOT show: hydrostatic forces, their lines of action, or P's value.
 */
export function CtFluidMechanicsAFlapGate({ gate = 1.8, width = 1.0, land = 3.0, sea = 1.2 }) {
  const W = 450;
  const s = 180 / land; // px per m
  const floor = 236;
  const landY = floor - land * s;
  const seaY = floor - sea * s;
  const hingeY = floor - gate * s;
  const wallL = 222;
  const wallR = 246;
  const gx = wallR - 3; // gate plate centerline (on the outlet face)
  const top = landY - 34;
  const H = floor + 16;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Flap gate ${gate} m high hinged at the top, land-side water ${land} m and sea-side water ${sea} m above the gate bottom`}
      style={{ width: '100%', height: 'auto' }}>
      {/* land-side water */}
      <polygon points={`76,${landY} ${wallL},${landY} ${wallL},${hingeY} ${gx - 3},${hingeY} ${gx - 3},${floor} 76,${floor}`}
        fill="var(--info)" fillOpacity={0.15} />
      <line x1={76} y1={landY} x2={wallL} y2={landY} stroke="var(--info)" strokeWidth={1.6} />
      <WaterSym x={110} y={landY} />
      <T x={150} y={landY + 22} color="var(--gray-500)">land side</T>

      {/* sea-side water */}
      <rect x={gx + 3} y={seaY} width={380 - gx - 3} height={floor - seaY} fill="var(--info)" fillOpacity={0.15} />
      <line x1={gx + 3} y1={seaY} x2={380} y2={seaY} stroke="var(--info)" strokeWidth={1.6} />
      <WaterSym x={352} y={seaY} />
      <T x={330} y={seaY - 26} color="var(--gray-500)">sea side</T>

      {/* headwall above the opening */}
      <rect x={wallL} y={top} width={wallR - wallL} height={hingeY - top} fill="var(--gray-400)" fillOpacity={0.45}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* gate plate and hinge */}
      <rect x={gx - 3} y={hingeY} width={6} height={floor - hingeY} fill="var(--charcoal)" />
      <circle cx={gx} cy={hingeY} r={4.5} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <T x={gx + 12} y={hingeY - 12} anchor="start" color="var(--gray-500)">hinge</T>
      <T x={wallR + 10} y={top + 12} anchor="start" color="var(--gray-500)">headwall</T>
      <line x1={gx + 12} y1={seaY + 24} x2={gx + 3} y2={seaY + 24} stroke="var(--gray-500)" strokeWidth={0.9} />
      <T x={gx + 14} y={seaY + 24} anchor="start" color="var(--gray-500)">{`flap gate, ${width.toFixed(1)} m wide`}</T>

      <Ground x1={60} x2={400} y={floor} />

      {/* holding force at the bottom edge */}
      <Arrow x1={gx + 58} y1={floor - 8} x2={gx + 4} y2={floor - 8} color="var(--ember)" width={2.4} />
      <T x={gx + 66} y={floor - 8} anchor="start" color="var(--ember)" bold italic>P</T>

      {/* land depth */}
      <Ext x1={72} y1={landY} x2={52} y2={landY} />
      <Dim x1={58} y1={landY} x2={58} y2={floor} label={`${land.toFixed(1)} m`} lx={52} ly={(landY + floor) / 2} anchor="end" />

      {/* gate height, on the land side */}
      <Ext x1={wallL - 4} y1={hingeY} x2={188} y2={hingeY} />
      <Dim x1={194} y1={hingeY} x2={194} y2={floor} label={`${gate.toFixed(1)} m`} lx={188} ly={(hingeY + floor) / 2} anchor="end" />

      {/* sea depth */}
      <Ext x1={384} y1={seaY} x2={404} y2={seaY} />
      <Dim x1={398} y1={seaY} x2={398} y2={floor} label={`${sea.toFixed(1)} m`} lx={406} ly={(seaY + floor) / 2} anchor="start" />
    </svg>
  );
}

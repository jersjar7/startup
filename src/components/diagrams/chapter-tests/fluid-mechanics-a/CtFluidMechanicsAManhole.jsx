import React from 'react';
import { T, Dim, Ext, WaterSym, Leader } from './CtFluidMechanicsAParts';

/**
 * Empty precast manhole set in saturated ground, section view, to scale.
 * Shows: outside diameter, wall, overall height, groundwater height above
 * the bottom of the base, manhole weight.
 * Does NOT show: buoyant force or factor of safety.
 */
export function CtFluidMechanicsAManhole({ od = 5, wall = 6, height = 10, gw = 8, weight = 8500 }) {
  const W = 420;
  const s = 20; // px per ft
  const ground = 44;
  const bottom = ground + height * s;
  const cx = 230;
  const ox1 = cx - (od * s) / 2;
  const ox2 = cx + (od * s) / 2;
  const t = (wall / 12) * s;
  const slab = 0.75 * s;
  const lid = 0.5 * s;
  const gwy = bottom - gw * s;
  const H = bottom + 26;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Precast manhole ${od} ft outside diameter, ${height} ft tall, groundwater ${gw} ft above the bottom`}
      style={{ width: '100%', height: 'auto' }}>
      {/* soil, saturated below the water table */}
      <rect x={20} y={ground} width={W - 40} height={H - 6 - ground} fill="var(--cream-dark)" />
      <rect x={20} y={gwy} width={W - 40} height={H - 6 - gwy} fill="var(--info)" fillOpacity={0.12} />
      <line x1={20} y1={gwy} x2={W - 20} y2={gwy} stroke="var(--info)" strokeWidth={1.4} strokeDasharray="7,4" />
      <WaterSym x={370} y={gwy} />
      <line x1={20} y1={ground} x2={W - 20} y2={ground} stroke="var(--charcoal)" strokeWidth={2} />
      <T x={370} y={ground - 12} color="var(--gray-500)">ground</T>

      {/* manhole: walls, base slab, cover */}
      <rect x={ox1} y={ground} width={od * s} height={height * s} fill="var(--cream)" />
      <rect x={ox1} y={ground} width={od * s} height={height * s} fill="var(--gray-400)" fillOpacity={0.45}
        stroke="var(--charcoal)" strokeWidth={2} />
      <rect x={ox1 + t} y={ground + lid} width={od * s - 2 * t} height={height * s - lid - slab} fill="var(--cream)"
        stroke="var(--charcoal)" strokeWidth={1.2} />
      <T x={cx} y={ground + (height * s) / 2 - 9}>W =</T>
      <T x={cx} y={ground + (height * s) / 2 + 9}>{`${weight.toLocaleString('en-US')} lb`}</T>

      {/* wall label */}
      <T x={W - 26} y={gwy + 60} anchor="end" color="var(--gray-500)">{`${wall}-in. wall`}</T>
      <Leader x1={W - 92} y1={gwy + 60} x2={ox2 - t / 2} y2={gwy + 60} />

      {/* outside diameter */}
      <Ext x1={ox1} y1={ground - 4} x2={ox1} y2={ground - 26} />
      <Ext x1={ox2} y1={ground - 4} x2={ox2} y2={ground - 26} />
      <Dim x1={ox1} y1={ground - 20} x2={ox2} y2={ground - 20} label={`${od.toFixed(1)} ft OD`} lx={cx} ly={ground - 31} />

      {/* overall height and groundwater height */}
      <Ext x1={ox1 - 4} y1={bottom} x2={88} y2={bottom} />
      <Ext x1={ox1 - 4} y1={ground} x2={140} y2={ground} />
      <Dim x1={146} y1={ground} x2={146} y2={bottom} label={`${height} ft`} lx={140} ly={(ground + bottom) / 2} anchor="end" />
      <Dim x1={96} y1={gwy} x2={96} y2={bottom} label={`${gw.toFixed(1)} ft`} lx={90} ly={(gwy + bottom) / 2} anchor="end" />
    </svg>
  );
}

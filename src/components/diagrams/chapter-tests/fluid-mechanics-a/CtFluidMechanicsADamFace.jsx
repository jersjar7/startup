import React from 'react';
import { T, Dim, Ext, WaterSym, Ground } from './CtFluidMechanicsAParts';

/**
 * Gravity dam with a battered upstream face. Water depth and face angle are
 * drawn to scale (the face run is depth / tan(angle)).
 * Does NOT show: any force or component (student solves).
 */
export function CtFluidMechanicsADamFace({ depth = 9, angle = 70 }) {
  const W = 462;
  const s = 180 / depth; // px per m
  const base = 214;
  const surf = base - depth * s;
  const crestY = surf - 1 * s - 4;
  const heelX = 222;
  const t = Math.tan((angle * Math.PI) / 180);
  const faceAt = (y) => heelX + (base - y) / t;
  const crestUx = faceAt(crestY);
  const crestDx = crestUx + 46;
  const toeX = crestDx + (base - crestY) * 0.48;
  const H = base + 16;
  const lblY = (surf + base) / 2 + 10;
  const a = (angle * Math.PI) / 180;
  const ar = 30;
  const lr = 46;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Gravity dam, upstream face at ${angle} degrees from horizontal, water depth ${depth} m`}
      style={{ width: '100%', height: 'auto' }}>
      {/* reservoir */}
      <polygon points={`90,${surf} ${faceAt(surf)},${surf} ${heelX},${base} 90,${base}`}
        fill="var(--info)" fillOpacity={0.15} />
      <line x1={90} y1={surf} x2={faceAt(surf)} y2={surf} stroke="var(--info)" strokeWidth={1.6} />
      <WaterSym x={150} y={surf} />

      {/* dam body */}
      <polygon points={`${heelX},${base} ${crestUx},${crestY} ${crestDx},${crestY} ${toeX},${base}`}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <T x={(faceAt(lblY) + crestDx + (lblY - crestY) * 0.48) / 2} y={lblY} color="var(--gray-500)">concrete dam</T>

      <Ground x1={70} x2={W - 8} y={base} />

      {/* face angle, measured inside the dam from the base */}
      <path d={`M ${heelX + ar},${base} A ${ar},${ar} 0 0 0 ${heelX + ar * Math.cos(a)},${base - ar * Math.sin(a)}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.2} />
      <T x={heelX + lr * Math.cos(a / 2) + 6} y={base - lr * Math.sin(a / 2)}>{`${angle}°`}</T>

      {/* depth */}
      <Ext x1={86} y1={surf} x2={66} y2={surf} />
      <Dim x1={72} y1={surf} x2={72} y2={base} label={`${depth.toFixed(1)} m`} lx={66} ly={(surf + base) / 2} anchor="end" />
    </svg>
  );
}

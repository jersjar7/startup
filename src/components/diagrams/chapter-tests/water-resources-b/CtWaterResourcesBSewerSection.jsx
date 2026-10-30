import React from 'react';
import { Label } from '../../primitives';

/**
 * Cross-section of a circular sewer flowing part full, drawn to scale.
 * Shows: inside diameter and flow depth, both with units.
 * Does NOT show: the depth ratio, velocity or discharge.
 */
export function CtWaterResourcesBSewerSection({ dia = 24, depth = 7.2 }) {
  const cx = 200;
  const cy = 112;
  const r = 88;
  const wallT = 11;
  const d = (depth / dia) * 2 * r;
  const wsY = cy + r - d;
  const half = Math.sqrt(r * r - (wsY - cy) ** 2);
  const seg = `M ${cx - half},${wsY} A ${r},${r} 0 0 0 ${cx + half},${wsY} Z`;
  const dimR = cx + r + wallT + 22;
  const dimL = cx - r - wallT - 22;
  const tick = (x, y) => <line x1={x - 4} y1={y + 4} x2={x + 4} y2={y - 4} stroke="var(--gray-500)" strokeWidth={1.2} />;

  return (
    <svg viewBox={`0 0 400 ${cy + r + wallT + 12}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Circular sewer, ${dia} in. inside diameter, flowing ${depth} in. deep`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Pipe wall */}
      <circle cx={cx} cy={cy} r={r + wallT / 2} fill="none" stroke="var(--gray-400)" strokeWidth={wallT} />
      <circle cx={cx} cy={cy} r={r + wallT} fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      <circle cx={cx} cy={cy} r={r} fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />

      {/* Flow */}
      <path d={seg} fill="var(--info)" fillOpacity={0.25} />
      <line x1={cx - half} y1={wsY} x2={cx + half} y2={wsY} stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={`${cx - 6},${wsY - 11} ${cx + 6},${wsY - 11} ${cx},${wsY - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />

      {/* Diameter (inside) */}
      <line x1={cx + 4} y1={cy - r} x2={dimR + 4} y2={cy - r} stroke="var(--gray-500)" strokeWidth={0.8} strokeDasharray="3,3" />
      <line x1={cx + 4} y1={cy + r} x2={dimR + 4} y2={cy + r} stroke="var(--gray-500)" strokeWidth={0.8} strokeDasharray="3,3" />
      <line x1={dimR} y1={cy - r} x2={dimR} y2={cy + r} stroke="var(--gray-500)" strokeWidth={1} />
      {tick(dimR, cy - r)}
      {tick(dimR, cy + r)}
      <Label x={dimR + 8} y={cy} color="var(--charcoal)" fontSize={12} anchor="start">{`D = ${dia} in.`}</Label>

      {/* Flow depth */}
      <line x1={dimL - 4} y1={wsY} x2={cx - half - 4} y2={wsY} stroke="var(--gray-500)" strokeWidth={0.8} strokeDasharray="3,3" />
      <line x1={dimL - 4} y1={cy + r} x2={cx - 4} y2={cy + r} stroke="var(--gray-500)" strokeWidth={0.8} strokeDasharray="3,3" />
      <line x1={dimL} y1={wsY} x2={dimL} y2={cy + r} stroke="var(--gray-500)" strokeWidth={1} />
      {tick(dimL, wsY)}
      {tick(dimL, cy + r)}
      <Label x={dimL - 8} y={(wsY + cy + r) / 2} color="var(--charcoal)" fontSize={12} anchor="end">{`d = ${depth} in.`}</Label>
    </svg>
  );
}

import React from 'react';
import { Label, ArrowMarkerDefs } from '../../primitives';

/**
 * Conical sand stockpile fed by a conveyor.
 * Shows: the cone, its height h, the base radius r = ratio * h, the feed rate.
 * Does NOT show: the rate at which h rises.
 */
export function CtMathematicsBStockpile({ ratio = 1.5, feed = '6 m³/min' }) {
  const hPx = 104;
  const rPx = hPx * ratio;
  const padL = 30;
  const padT = 70;
  const cx = padL + rPx + 10;
  const base = padT + hPx;
  const apex = { x: cx, y: padT };
  const ey = 16; // base ellipse half-height
  const W = Math.round(cx + rPx + 40);
  const H = Math.round(base + ey + 50);

  // Conveyor: inclined belt from the upper left ending just past the apex.
  const head = { x: cx - 8, y: padT - 46 };
  const tail = { x: padL - 6, y: padT + 6 };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Conical stockpile of height h and base radius ${ratio}h, fed at ${feed}`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctMathBPileArrow" color="var(--ember)" />
      <ArrowMarkerDefs id="ctMathBPileDim" color="var(--gray-500)" size={7} />

      {/* Ground */}
      <line x1={cx - rPx - 26} y1={base + ey} x2={cx + rPx + 26} y2={base + ey} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Cone body */}
      <path d={`M ${cx - rPx} ${base} L ${apex.x} ${apex.y} L ${cx + rPx} ${base} A ${rPx} ${ey} 0 0 1 ${cx - rPx} ${base} Z`}
        fill="var(--gray-400)" fillOpacity={0.14} stroke="var(--charcoal)" strokeWidth={2.2} strokeLinejoin="round" />
      {/* Hidden back half of the base */}
      <path d={`M ${cx - rPx} ${base} A ${rPx} ${ey} 0 0 1 ${cx + rPx} ${base}`} fill="none" stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="4,3" />

      {/* Height and radius */}
      <line x1={cx} y1={apex.y + 4} x2={cx} y2={base} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="4,3" />
      <Label x={cx + 8} y={(apex.y + base) / 2 + 10} anchor="start" color="var(--charcoal)" fontSize={13} italic bold>h</Label>
      <line x1={cx} y1={base} x2={cx + rPx} y2={base} stroke="var(--gray-500)" strokeWidth={1} />
      <circle cx={cx} cy={base} r={2.5} fill="var(--gray-500)" />
      {/* Radius dimension below the ground */}
      <line x1={cx} y1={base + 4} x2={cx} y2={base + ey + 26} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={cx + rPx} y1={base + 4} x2={cx + rPx} y2={base + ey + 26} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={cx} y1={base + ey + 20} x2={cx + rPx} y2={base + ey + 20} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={cx} y1={base + ey + 15} x2={cx} y2={base + ey + 25} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={cx + rPx} y1={base + ey + 15} x2={cx + rPx} y2={base + ey + 25} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={cx + rPx / 2} y={base + ey + 34} color="var(--charcoal)" fontSize={12} italic>{`r = ${ratio}h`}</Label>

      {/* Conveyor belt */}
      <line x1={tail.x} y1={tail.y} x2={head.x} y2={head.y} stroke="var(--charcoal)" strokeWidth={5} strokeLinecap="round" />
      <circle cx={head.x} cy={head.y} r={4} fill="var(--gray-400)" fillOpacity={0.25} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={head.x + 6} y1={head.y + 8} x2={head.x + 6} y2={apex.y - 6} stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctMathBPileArrow)" />
      <Label x={head.x + 16} y={head.y + 4} anchor="start" color="var(--ember)" fontSize={12} bold>{feed}</Label>
      <Label x={padL + 6} y={padT - 30} anchor="start" color="var(--gray-500)" fontSize={11}>conveyor</Label>
    </svg>
  );
}

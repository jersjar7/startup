import React from 'react';
import { polar } from './geo';
import { ArrowMarkerDefs, ForceArrow, AngleArc, DashedLine, Label } from './primitives';

/**
 * Crate being pulled by an angled cable on a horizontal floor.
 * Shows: crate, floor, cable tension at angle.
 * Does NOT show: N, f, mg, μ label (student derives these).
 */
export function CrateCablePull({
  mass = 60, tension = 400, angle = 30,
}) {
  const W = 340;
  const H = 200;

  // Crate
  const crateW = 70;
  const crateH = 50;
  const crateX = 120;
  const crateY = 105;
  const cx = crateX + crateW / 2;

  // Floor
  const floorY = crateY + crateH;

  // Cable attachment (top-right corner of crate)
  const attachX = crateX + crateW;
  const attachY = crateY;

  // Tension arrow
  const tArrow = 80;
  const tEnd = polar(attachX, attachY, tArrow, angle);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${mass} kg crate on floor, cable at ${angle}° with ${tension} N tension`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowT" color="var(--ember)" size={8} />

      {/* Floor */}
      <line x1={20} y1={floorY} x2={W - 20} y2={floorY}
        stroke="var(--charcoal)" strokeWidth={2} />
      {/* Floor hatching */}
      {Array.from({ length: 9 }, (_, i) => {
        const hx = 30 + i * 32;
        return (
          <line key={i} x1={hx} y1={floorY} x2={hx - 10} y2={floorY + 8}
            stroke="var(--gray-400)" strokeWidth={1} />
        );
      })}

      {/* Crate */}
      <rect x={crateX} y={crateY} width={crateW} height={crateH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={3} />
      <Label x={cx} y={crateY + crateH / 2} fontSize={11} color="var(--charcoal)" bold>
        {mass} kg
      </Label>

      {/* Dashed horizontal reference from attachment point */}
      <DashedLine x1={attachX} y1={attachY}
        x2={attachX + tArrow * Math.cos(angle * Math.PI / 180) + 8} y2={attachY}
        color="var(--gray-400)" strokeWidth={1} dasharray="3,3" />

      {/* Cable / tension arrow */}
      <ForceArrow x1={attachX} y1={attachY} x2={tEnd.x} y2={tEnd.y}
        color="var(--ember)" strokeWidth={2.5} markerId="arrowT" />
      <Label x={tEnd.x + 6} y={tEnd.y - 8} fontSize={11} color="var(--ember)" bold anchor="start">
        {tension} N
      </Label>

      {/* Angle arc */}
      <AngleArc cx={attachX} cy={attachY} radius={32}
        startAngle={0} endAngle={angle} label={`${angle}\u00b0`} />
    </svg>
  );
}

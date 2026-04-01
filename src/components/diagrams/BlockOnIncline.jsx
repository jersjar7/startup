import React from 'react';
import { basis, along } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, AngleArc, Label,
} from './primitives';

/**
 * Block sliding down a frictionless incline.
 * Shows: inclined surface, block, weight arrow (W down), angle of incline.
 * Does NOT show: normal force, friction, acceleration, force components.
 */
export function BlockOnIncline({ weight = 500, angle = 30 }) {
  const b = basis(angle);

  // Ramp geometry
  const rampStartX = 40;
  const rampStartY = 200;
  const rampLen = 280;
  const rampEnd = along(rampStartX, rampStartY, b.uphill, rampLen);

  // Block on ramp (midway up)
  const blockCenter = along(rampStartX, rampStartY, b.uphill, 160);
  const halfW = 22;
  const blockH = 28;

  // Block corners
  const bl = along(blockCenter.x, blockCenter.y, b.downhill, halfW);
  const br = along(blockCenter.x, blockCenter.y, b.uphill, halfW);
  const tr = along(br.x, br.y, b.outward, blockH);
  const tl = along(bl.x, bl.y, b.outward, blockH);
  const blockPoly = `${bl.x},${bl.y} ${br.x},${br.y} ${tr.x},${tr.y} ${tl.x},${tl.y}`;

  // Block visual center (for weight arrow)
  const blockMid = along(blockCenter.x, blockCenter.y, b.outward, blockH / 2);

  // Weight arrow (straight down from block center)
  const wArrowLen = 55;

  return (
    <svg viewBox="0 0 360 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${weight} N block on ${angle}-degree frictionless incline`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowIncline" />

      {/* 1. Ground line */}
      <line x1={20} y1={rampStartY} x2={rampStartX + 80} y2={rampStartY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 2. Inclined surface */}
      <line x1={rampStartX} y1={rampStartY} x2={rampEnd.x} y2={rampEnd.y}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 3. Block */}
      <polygon points={blockPoly}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* 4. Weight arrow (straight down) */}
      <ForceArrow x1={blockMid.x} y1={blockMid.y}
        x2={blockMid.x} y2={blockMid.y + wArrowLen}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowIncline" />
      <Label x={blockMid.x + 16} y={blockMid.y + wArrowLen - 10}
        color="var(--charcoal)" bold fontSize={11} anchor="start">
        {weight} N
      </Label>

      {/* 5. Angle arc at base */}
      <AngleArc cx={rampStartX} cy={rampStartY} radius={40}
        startAngle={0} endAngle={angle} label={`${angle}\u00b0`} />

      {/* 6. "Frictionless" label on surface */}
      <Label x={rampEnd.x - 30} y={rampEnd.y - 16}
        color="var(--gray-400)" italic fontSize={9} anchor="end">
        frictionless
      </Label>

    </svg>
  );
}

import React from 'react';
import { basis, along } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, AngleArc, DashedLine, Label,
} from './primitives';

export function BlockOnRamp({ weight = 800, angle = 25, mu = 0.50, showPush = true }) {
  const b = basis(angle);

  // Ramp geometry
  const rampLen = 260;
  const rampStart = { x: 40, y: 200 };  // bottom-left of ramp (SVG coords)
  const rampEnd = along(rampStart.x, rampStart.y, b.uphill, rampLen);

  // Block position on ramp surface
  const blockDist = 140;
  const blockBase = along(rampStart.x, rampStart.y, b.uphill, blockDist);

  // Block dimensions
  const halfW = 25;
  const blockH = 36;

  // Block corners (sitting on the ramp surface)
  const bl = along(blockBase.x, blockBase.y, b.downhill, halfW);
  const br = along(blockBase.x, blockBase.y, b.uphill, halfW);
  const tr = along(br.x, br.y, b.outward, blockH);
  const tl = along(bl.x, bl.y, b.outward, blockH);

  // Block center (for weight arrow origin)
  const blockCenter = {
    x: (bl.x + br.x + tr.x + tl.x) / 4,
    y: (bl.y + br.y + tr.y + tl.y) / 4,
  };

  // Arrow endpoints
  const arrowLen = 55;
  const weightEnd = { x: blockCenter.x, y: blockCenter.y + arrowLen };
  const pushStart = { x: blockCenter.x - 70, y: blockCenter.y };
  const pushEnd = { x: blockCenter.x - 10, y: blockCenter.y };

  return (
    <svg viewBox="0 0 380 250" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Block on ${angle}-degree ramp, W = ${weight} N`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />
      <ArrowMarkerDefs id="arrowEmber" color="var(--ember)" size={7} />

      {/* Ramp surface */}
      <line x1={rampStart.x} y1={rampStart.y} x2={rampEnd.x} y2={rampEnd.y}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Ground (horizontal) */}
      <line x1={rampStart.x - 20} y1={rampStart.y} x2={rampStart.x + 120} y2={rampStart.y}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Angle arc at base */}
      <AngleArc cx={rampStart.x} cy={rampStart.y} radius={40}
        startAngle={0} endAngle={angle} label={`${angle}\u00b0`} />

      {/* Block */}
      <polygon
        points={`${bl.x},${bl.y} ${br.x},${br.y} ${tr.x},${tr.y} ${tl.x},${tl.y}`}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2}
      />

      {/* Weight W (straight down from block center) */}
      <ForceArrow x1={blockCenter.x} y1={blockCenter.y}
        x2={weightEnd.x} y2={weightEnd.y}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={weightEnd.x + 6} y={weightEnd.y - 6}
        color="var(--charcoal)" bold fontSize={11} anchor="start">
        W
      </Label>

      {/* Horizontal push P — only when the problem statement applies one */}
      {showPush && (
        <>
          <ForceArrow x1={pushStart.x} y1={pushStart.y}
            x2={pushEnd.x} y2={pushEnd.y}
            color="var(--ember)" strokeWidth={2} markerId="arrowEmber" />
          <Label x={pushStart.x - 8} y={pushStart.y}
            color="var(--ember)" bold fontSize={12} anchor="end">
            P
          </Label>
          <DashedLine x1={pushEnd.x} y1={blockCenter.y}
            x2={blockCenter.x + 40} y2={blockCenter.y}
            color="var(--gray-400)" dasharray="3,3" />
        </>
      )}

    </svg>
  );
}

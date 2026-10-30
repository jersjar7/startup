import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan of a signalized intersection: an east-west arterial crossed by a
 * narrower side street, with a marked crosswalk across the arterial's west leg.
 * Drawn to scale (3 px per ft).
 *
 * Shows: crosswalk length (curb to curb) and crosswalk width, lanes.
 * Does NOT show: pedestrian counts or any signal time.
 */
export function CtTransportationACrosswalk({ crossLength = 64, crossWidth = 10, sideWidth = 36 }) {
  const s = 3; // px per ft
  const W = 440;
  const top = 70;
  const roadH = crossLength * s;
  const bot = top + roadH;
  const sideW = sideWidth * s;
  const sideL = 250;
  const sideR = sideL + sideW;
  const cwR = sideL - 18; // crosswalk east edge (stop clear of the curb return)
  const cwL = cwR - crossWidth * s;
  const leg = 32;
  const legN = 52; // north leg, long enough to carry the street name above it
  const H = bot + leg + 4;
  const curb = 'var(--charcoal)';

  // Arterial lane lines at 12, 24, 40, 52 ft from the north curb (two-way left-turn lane in the middle)
  const laneY = (ft) => top + ft * s;
  const westEnd = 24;
  const eastEnd = W - 12;

  const bars = [];
  for (let yy = top + 5; yy < bot - 4; yy += 12) bars.push(yy);

  const lanes = (x1, x2) => (
    <g>
      <line x1={x1} y1={laneY(12)} x2={x2} y2={laneY(12)} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="10,8" />
      <line x1={x1} y1={laneY(52)} x2={x2} y2={laneY(52)} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="10,8" />
      <line x1={x1} y1={laneY(24)} x2={x2} y2={laneY(24)} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={x1} y1={laneY(40)} x2={x2} y2={laneY(40)} stroke="var(--gray-500)" strokeWidth={1.2} />
    </g>
  );

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Intersection plan, crosswalk ${crossLength} ft long and ${crossWidth} ft wide across the arterial`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Curbs of the arterial (broken at the side street) */}
      <line x1={westEnd} y1={top} x2={sideL} y2={top} stroke={curb} strokeWidth={2} />
      <line x1={sideR} y1={top} x2={eastEnd} y2={top} stroke={curb} strokeWidth={2} />
      <line x1={westEnd} y1={bot} x2={sideL} y2={bot} stroke={curb} strokeWidth={2} />
      <line x1={sideR} y1={bot} x2={eastEnd} y2={bot} stroke={curb} strokeWidth={2} />
      {/* Side street curbs */}
      <line x1={sideL} y1={top - legN} x2={sideL} y2={top} stroke={curb} strokeWidth={2} />
      <line x1={sideR} y1={top - legN} x2={sideR} y2={top} stroke={curb} strokeWidth={2} />
      <line x1={sideL} y1={bot} x2={sideL} y2={bot + leg} stroke={curb} strokeWidth={2} />
      <line x1={sideR} y1={bot} x2={sideR} y2={bot + leg} stroke={curb} strokeWidth={2} />
      <line x1={sideL + sideW / 2} y1={top - legN + 10} x2={sideL + sideW / 2} y2={top - 6} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={sideL + sideW / 2} y1={bot + 6} x2={sideL + sideW / 2} y2={bot + leg} stroke="var(--gray-500)" strokeWidth={1.2} />

      {/* Arterial lane lines, west and east of the intersection */}
      {lanes(westEnd, cwL - 14)}
      {lanes(sideR + 10, eastEnd)}

      {/* Crosswalk across the west leg */}
      <line x1={cwL} y1={top} x2={cwL} y2={bot} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={cwR} y1={top} x2={cwR} y2={bot} stroke="var(--charcoal)" strokeWidth={1.5} />
      {bars.map((yy) => (
        <rect key={yy} x={cwL + 3} y={yy} width={cwR - cwL - 6} height={6} fill="var(--gray-300)" />
      ))}

      {/* Crosswalk length: curb to curb */}
      <line x1={cwL - 26} y1={top} x2={cwL - 26} y2={bot} stroke="var(--ember)" strokeWidth={1.2} />
      <line x1={cwL - 32} y1={top} x2={cwL - 20} y2={top} stroke="var(--ember)" strokeWidth={1.2} />
      <line x1={cwL - 32} y1={bot} x2={cwL - 20} y2={bot} stroke="var(--ember)" strokeWidth={1.2} />
      <rect x={cwL - 52} y={(top + bot) / 2 - 9} width={52} height={18} fill="#fff" />
      <Label x={cwL - 26} y={(top + bot) / 2} color="var(--ember)" fontSize={12} bold>{`${crossLength} ft`}</Label>

      {/* Crosswalk width, above the north curb */}
      <line x1={cwL} y1={top - 14} x2={cwR} y2={top - 14} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={cwL} y1={top - 20} x2={cwL} y2={top - 8} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={cwR} y1={top - 20} x2={cwR} y2={top - 8} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={cwL - 6} y={top - 14} color="var(--gray-500)" fontSize={12} anchor="end">{`${crossWidth} ft`}</Label>
      <Label x={cwL - 30} y={bot + 18} color="var(--charcoal)" fontSize={11} anchor="end">crosswalk</Label>
      <line x1={cwL - 26} y1={bot + 16} x2={(cwL + cwR) / 2} y2={bot - 4} stroke="var(--gray-500)" strokeWidth={0.8} />

      {/* Street names */}
      <Label x={westEnd + 4} y={top - 14} color="var(--gray-500)" fontSize={11} anchor="start">ARTERIAL</Label>
      <Label x={(sideL + sideR) / 2} y={top - legN - 8} color="var(--gray-500)" fontSize={11} anchor="middle">SIDE STREET</Label>

    </svg>
  );
}

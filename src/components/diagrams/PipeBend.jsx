import React from 'react';
import { deg } from './geo';
import { ArrowMarkerDefs, ForceArrow, AngleArc, Label } from './primitives';

/**
 * Horizontal pipe bend showing control volume with flow arrows.
 *
 * The pipe enters horizontally from the left and exits at the bend angle
 * (measured from the inlet direction). For a 90° bend, exit goes downward.
 *
 * Shows: pipe as closed path with smooth bend, flow velocity arrows,
 *        pressure/velocity/diameter labels, bend angle arc.
 * Does NOT show: force components Fx/Fy, resultant force (student solves).
 */
export function PipeBend({
  angle = 90,
  diameter = 0.3,
  velocity = 4,
  pressure = 200,
}) {
  const W = 400;
  const H = 260;

  const pipeW = 36;
  const halfW = pipeW / 2;
  const inletLen = 110;
  const outletLen = 100;

  // Bend point — where the pipe centerline begins to curve
  const bcx = 155;
  const bcy = 80;
  const bendR = 50;
  const aRad = deg(angle);

  const inletStartX = bcx - inletLen;

  // Arc center is BELOW the pipe centerline (pipe bends downward)
  const arcCx = bcx;
  const arcCy = bcy + bendR;

  // Outlet centerline direction
  const outDirX = Math.cos(aRad);
  const outDirY = Math.sin(aRad);

  // Outlet centerline start (where arc meets straight outlet)
  const outStartX = arcCx + bendR * Math.sin(aRad);
  const outStartY = arcCy - bendR * Math.cos(aRad);

  // Wall radii from arc center
  const outerR = bendR + halfW;   // outside of bend (top wall of inlet)
  const innerR = bendR - halfW;   // inside of bend (bottom wall of inlet)

  // Wall positions at arc end (θ = angle)
  const outerEndX = arcCx + outerR * Math.sin(aRad);
  const outerEndY = arcCy - outerR * Math.cos(aRad);
  const innerEndX = arcCx + innerR * Math.sin(aRad);
  const innerEndY = arcCy - innerR * Math.cos(aRad);

  // Outlet straight wall endpoints
  const outOuterEndX = outerEndX + outletLen * outDirX;
  const outOuterEndY = outerEndY + outletLen * outDirY;
  const outInnerEndX = innerEndX + outletLen * outDirX;
  const outInnerEndY = innerEndY + outletLen * outDirY;

  const largeArc = angle > 180 ? 1 : 0;

  // Pipe path: top of inlet → outer arc CW → outer outlet wall →
  //            cross → inner outlet wall → inner arc CCW → bottom of inlet
  const pipePath = [
    `M ${inletStartX},${bcy - halfW}`,
    `H ${bcx}`,
    `A ${outerR},${outerR} 0 ${largeArc} 1 ${outerEndX},${outerEndY}`,
    `L ${outOuterEndX},${outOuterEndY}`,
    `L ${outInnerEndX},${outInnerEndY}`,
    `L ${innerEndX},${innerEndY}`,
    `A ${innerR},${innerR} 0 ${largeArc} 0 ${bcx},${bcy + halfW}`,
    `H ${inletStartX}`,
    'Z',
  ].join(' ');

  // ── Flow arrows ──
  const arrowLen = 44;
  const inArrowX1 = inletStartX + 16;
  const inArrowX2 = inArrowX1 + arrowLen;

  const outArrowMid = 40;
  const outAx1 = outStartX + outArrowMid * outDirX;
  const outAy1 = outStartY + outArrowMid * outDirY;
  const outAx2 = outAx1 + arrowLen * outDirX;
  const outAy2 = outAy1 + arrowLen * outDirY;

  const angleArcR = 40;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${angle}-degree horizontal pipe bend, D=${diameter} m, v=${velocity} m/s, P=${pressure} kPa`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowFlow" color="var(--ember)" size={8} />

      {/* 1. Pipe body */}
      <path d={pipePath} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2}
        strokeLinejoin="round" />

      {/* 2. Flow arrows */}
      <ForceArrow x1={inArrowX1} y1={bcy} x2={inArrowX2} y2={bcy}
        color="var(--ember)" strokeWidth={2.5} markerId="arrowFlow" />
      <ForceArrow x1={outAx1} y1={outAy1} x2={outAx2} y2={outAy2}
        color="var(--ember)" strokeWidth={2.5} markerId="arrowFlow" />

      {/* 3. Labels */}
      <Label x={inArrowX1 + arrowLen / 2} y={bcy - 8}
        fontSize={10} color="var(--ember)" bold>
        v = {velocity} m/s
      </Label>

      <Label x={inletStartX + 2} y={bcy - halfW - 14}
        fontSize={9} color="var(--gray-500)" anchor="start">
        P = {pressure} kPa
      </Label>

      <Label x={inletStartX + inletLen / 2} y={bcy + halfW + 16}
        fontSize={9} color="var(--gray-500)">
        D = {diameter} m
      </Label>
    </svg>
  );
}

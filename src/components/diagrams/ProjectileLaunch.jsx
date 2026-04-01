import React from 'react';
import { polar } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, AngleArc, DashedLine, Label,
} from './primitives';

/**
 * Projectile launched from ground at angle θ with initial velocity v₀.
 * Shows: ground line, v₀ arrow at angle, parabolic trajectory (dashed), max height h.
 * Does NOT show: velocity components, time, horizontal range.
 */
export function ProjectileLaunch({ v0 = 20, angle = 60 }) {
  const ox = 50;
  const groundY = 180;
  const arrowLen = 90;
  const tip = polar(ox, groundY, arrowLen, angle);

  // Parabolic trajectory (decorative dashed arc)
  const peakH = 100; // visual height of arc
  const range = 200; // visual horizontal range
  const points = [];
  for (let i = 0; i <= 40; i++) {
    const t = i / 40;
    const px = ox + t * range;
    const py = groundY - 4 * peakH * t * (1 - t);
    points.push(`${px},${py}`);
  }

  // Peak point for height dimension
  const peakX = ox + range / 2;
  const peakY = groundY - peakH;

  return (
    <svg viewBox="0 0 360 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Projectile launched at ${angle} degrees with velocity ${v0} m/s`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowProj" />

      {/* 1. Ground line */}
      <line x1={20} y1={groundY} x2={340} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 2. Trajectory (dashed parabola) */}
      <polyline points={points.join(' ')}
        fill="none" stroke="var(--gray-400)" strokeWidth={1.5}
        strokeDasharray="4,3" />

      {/* 3. Launch velocity arrow */}
      <ForceArrow x1={ox} y1={groundY} x2={tip.x} y2={tip.y}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowProj" />

      {/* 4. Velocity label */}
      <Label x={tip.x + 8} y={tip.y - 6} color="var(--charcoal)" bold fontSize={11} anchor="start">
        {v0} m/s
      </Label>

      {/* 5. Angle arc */}
      <AngleArc cx={ox} cy={groundY} radius={32}
        startAngle={0} endAngle={angle} label={`${angle}\u00b0`} />

      {/* 6. Horizontal reference (dashed) */}
      <DashedLine x1={ox} y1={groundY} x2={ox + arrowLen + 20} y2={groundY}
        color="var(--gray-400)" strokeWidth={1} />

      {/* 7. Max height dashed lines */}
      <DashedLine x1={peakX} y1={peakY} x2={peakX} y2={groundY}
        color="var(--gray-400)" strokeWidth={1} />
      <DashedLine x1={20} y1={peakY} x2={peakX + 10} y2={peakY}
        color="var(--gray-400)" strokeWidth={1} />

      {/* 8. Height label */}
      <Label x={peakX + 14} y={(peakY + groundY) / 2} color="var(--gray-500)" italic fontSize={12} anchor="start">
        h
      </Label>

      {/* 9. Launch dot */}
      <circle cx={ox} cy={groundY} r={3} fill="var(--charcoal)" />

    </svg>
  );
}

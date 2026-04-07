import React from 'react';
import { polar, deg } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, AngleArc, DashedLine, Label,
} from './primitives';

/**
 * Projectile launched from ground at angle θ with initial velocity v₀.
 * Shows: ground line, v₀ arrow at angle, parabolic trajectory (dashed).
 * Does NOT show: range, max height, velocity components (student solves).
 */
export function ProjectileLaunch({ v0 = 20, angle = 60 }) {
  const ox = 50;
  const groundY = 180;
  const arrowLen = 90;
  const tip = polar(ox, groundY, arrowLen, angle);

  // Physics-based trajectory shape scaled to fit the diagram.
  // H/R ratio = tan(angle)/4 determines the arc proportions.
  const rad = deg(angle);
  const tanA = Math.tan(rad);
  const sinA = Math.sin(rad);
  const cosA = Math.cos(rad);

  // Visual range of the parabola in SVG pixels
  const visRange = 240;
  // Peak height derived from angle: H = R * tan(θ)/4
  const visPeak = visRange * tanA / 4;
  // Cap peak so it doesn't overflow the viewBox
  const maxPeak = 140;
  const scale = visPeak > maxPeak ? maxPeak / visPeak : 1;
  const peakH = visPeak * scale;
  const range = visRange * scale;

  // Parametric parabola: y = 4H·t·(1-t), x = range·t
  // At t=0, slope = 4H/range = tan(θ) — matches the launch angle
  const points = [];
  for (let i = 0; i <= 40; i++) {
    const t = i / 40;
    const px = ox + t * range;
    const py = groundY - 4 * peakH * t * (1 - t);
    points.push(`${px},${py}`);
  }

  return (
    <svg viewBox="0 0 360 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Projectile launched at ${angle} degrees with velocity ${v0} m/s`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowProj" />

      {/* Ground line */}
      <line x1={20} y1={groundY} x2={340} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Trajectory (dashed parabola) */}
      <polyline points={points.join(' ')}
        fill="none" stroke="var(--gray-400)" strokeWidth={1.5}
        strokeDasharray="4,3" />

      {/* Launch velocity arrow */}
      <ForceArrow x1={ox} y1={groundY} x2={tip.x} y2={tip.y}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowProj" />

      {/* Velocity label */}
      <Label x={tip.x + 8} y={tip.y - 6} color="var(--charcoal)" bold fontSize={11} anchor="start">
        {v0} m/s
      </Label>

      {/* Angle arc */}
      <AngleArc cx={ox} cy={groundY} radius={32}
        startAngle={0} endAngle={angle} label={`${angle}\u00b0`} />

      {/* Launch dot */}
      <circle cx={ox} cy={groundY} r={3} fill="var(--charcoal)" />
    </svg>
  );
}

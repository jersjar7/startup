import React from 'react';
import { polar, arcPath } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, DashedLine, Label,
} from './primitives';

/**
 * Car traveling along a circular curve.
 * Shows: curve arc, radius ρ, car dot, velocity arrow tangent, "accelerating" note.
 * Does NOT show: a_t, a_n, total acceleration (student calculates these).
 */
export function CarOnCurve({ radius = 200, speed = 30, accelT = 2 }) {
  const cx = 310; // circle center — right side
  const cy = 40;
  const r = 150; // visual radius
  const carAngle = 230; // car position on arc

  // Arc from 195° to 275°
  const arcD = arcPath(cx, cy, r, 195, 275);

  // Car position
  const car = polar(cx, cy, r, carAngle);

  // Velocity arrow (tangent to curve — perpendicular to radius, pointing forward)
  const tangentAngle = carAngle + 90;
  const vTip = polar(car.x, car.y, 55, tangentAngle);

  // Radius midpoint for label
  const radiusMid = polar(cx, cy, r * 0.45, carAngle);

  return (
    <svg viewBox="0 0 400 260" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Car on circular curve, radius ${radius} m, speed ${speed} m/s`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowCurve" />

      {/* 1. Curved road (thick arc) */}
      <path d={arcD} fill="none" stroke="var(--charcoal)" strokeWidth={3.5}
        strokeLinecap="round" />

      {/* 2. Radius dashed line from center to car */}
      <DashedLine x1={cx} y1={cy} x2={car.x} y2={car.y}
        color="var(--gray-400)" strokeWidth={1} />

      {/* 3. Center dot + label */}
      <circle cx={cx} cy={cy} r={3} fill="var(--gray-400)" />
      <Label x={cx - 16} y={cy - 12} color="var(--gray-400)" fontSize={10}>
        center
      </Label>

      {/* 4. Radius label — positioned clear of other elements */}
      <Label x={radiusMid.x + 20} y={radiusMid.y - 10} color="var(--gray-500)" italic fontSize={12}>
        {'\u03C1'} = {radius} m
      </Label>

      {/* 5. Car dot */}
      <circle cx={car.x} cy={car.y} r={5} fill="var(--charcoal)" />

      {/* 6. Velocity arrow (tangent direction) */}
      <ForceArrow x1={car.x} y1={car.y} x2={vTip.x} y2={vTip.y}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowCurve" />

      {/* 7. Velocity label — below and left of arrow tip, away from other labels */}
      <Label x={vTip.x - 50} y={vTip.y + 20} color="var(--charcoal)" bold fontSize={11}>
        v = {speed} m/s
      </Label>

      {/* 8. Accelerating note — bottom-left, far from velocity label */}
      <Label x={40} y={240} color="var(--gray-500)" fontSize={10} italic anchor="start">
        accelerating at {accelT} m/s{'\u00B2'}
      </Label>

    </svg>
  );
}

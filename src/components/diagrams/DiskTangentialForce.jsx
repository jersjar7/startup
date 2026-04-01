import React from 'react';
import { polar } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, DimensionLine, Label,
} from './primitives';

/**
 * Disk on axle with tangential force applied at the rim.
 * Shows: disk outline, axle dot, force arrow at rim, radius dimension, mass label.
 * Does NOT show: angular acceleration, torque, I (student calculates these).
 */
export function DiskTangentialForce({ mass = 10, radius = 0.3, force = 15 }) {
  const cx = 180;
  const cy = 120;
  const visualR = 70;
  const arrowLen = 55;

  // Force applied tangent at the right side of the disk (pointing up)
  const forceStart = polar(cx, cy, visualR, 0); // right side of disk
  const forceEnd = { x: forceStart.x, y: forceStart.y - arrowLen };

  return (
    <svg viewBox="0 0 360 260" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Disk m=${mass} kg, R=${radius} m, tangential force ${force} N`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowDisk" />

      {/* 1. Disk (circle) */}
      <circle cx={cx} cy={cy} r={visualR}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 2. Axle dot */}
      <circle cx={cx} cy={cy} r={4} fill="var(--charcoal)" />

      {/* 3. Radius dimension line (horizontal from center to right) */}
      <DimensionLine x1={cx} y1={cy + 14} x2={cx + visualR} y2={cy + 14}
        label={`R = ${radius} m`} offset={14} />

      {/* 4. Tangential force arrow at rim */}
      <ForceArrow x1={forceStart.x} y1={forceStart.y}
        x2={forceEnd.x} y2={forceEnd.y}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowDisk" />
      <Label x={forceEnd.x + 14} y={forceEnd.y + 6}
        color="var(--charcoal)" bold fontSize={11} anchor="start">
        {force} N
      </Label>

      {/* 5. Force application dot at rim */}
      <circle cx={forceStart.x} cy={forceStart.y} r={3} fill="var(--charcoal)" />

      {/* 6. Mass label */}
      <Label x={cx} y={cy + visualR + 40} color="var(--charcoal)" bold fontSize={12}>
        m = {mass} kg
      </Label>

      {/* 7. "frictionless axle" note */}
      <Label x={cx} y={cy + visualR + 54} color="var(--gray-400)" italic fontSize={9}>
        frictionless axle
      </Label>

    </svg>
  );
}

import React from 'react';
import {
  DimensionLine, AxisLine, Label,
} from './primitives';

/**
 * Solid cylinder cross-section with centroidal axis and offset parallel axis.
 * Shows: cylinder outline, centroidal axis, offset axis, distance d, R and m labels.
 * Does NOT show: I_c formula, I result (student calculates these).
 */
export function CylinderParallelAxis({ mass = 12, radius = 0.2, distance = 0.5 }) {
  const cx = 140;
  const cy = 120;
  const visualR = 50;
  const scale = visualR / radius; // pixels per meter
  const offsetPx = distance * scale; // d in pixels
  const offsetX = cx + offsetPx;

  return (
    <svg viewBox="0 0 360 260" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Cylinder m=${mass} kg, R=${radius} m, offset axis at d=${distance} m`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Cylinder (circle cross-section) */}
      <circle cx={cx} cy={cy} r={visualR}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 2. Centroidal axis (vertical through center) */}
      <AxisLine x1={cx} y1={cy - visualR - 30} x2={cx} y2={cy + visualR + 30}
        label="c" color="var(--forest)" />
      <circle cx={cx} cy={cy} r={3} fill="var(--forest)" />

      {/* 3. Offset axis (vertical, d away) */}
      <AxisLine x1={offsetX} y1={cy - visualR - 30} x2={offsetX} y2={cy + visualR + 30}
        label="a" color="var(--ember)" />

      {/* 4. Distance d between axes */}
      <line x1={cx} y1={cy + visualR + 16} x2={offsetX} y2={cy + visualR + 16}
        stroke="var(--ember)" strokeWidth={1.5} />
      <line x1={cx} y1={cy + visualR + 10} x2={cx} y2={cy + visualR + 22}
        stroke="var(--ember)" strokeWidth={1} />
      <line x1={offsetX} y1={cy + visualR + 10} x2={offsetX} y2={cy + visualR + 22}
        stroke="var(--ember)" strokeWidth={1} />
      <Label x={(cx + offsetX) / 2} y={cy + visualR + 30} color="var(--ember)" italic bold fontSize={12}>
        d = {distance} m
      </Label>

      {/* 5. Radius dimension */}
      <DimensionLine x1={cx} y1={cy} x2={cx + visualR} y2={cy}
        label={`R = ${radius} m`} offset={-14} />

      {/* 6. Mass label */}
      <Label x={cx} y={cy - visualR - 40} color="var(--charcoal)" bold fontSize={12}>
        m = {mass} kg
      </Label>

    </svg>
  );
}

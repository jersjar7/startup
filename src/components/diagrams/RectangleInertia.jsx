import React from 'react';
import {
  DimensionLine, AxisLine, Label,
} from './primitives';

export function RectangleInertia({ width = 150, height = 300 }) {
  const scale = 0.7;
  const ox = 115;
  const oy = 16;
  const rW = width * scale;
  const rH = height * scale;
  const cx = ox + rW / 2;
  const cy = oy + rH / 2;

  return (
    <svg viewBox="0 0 380 280" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Rectangle ${width}x${height} mm with centroidal axis`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Rectangle */}
      <rect x={ox} y={oy} width={rW} height={rH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Centroidal horizontal axis */}
      <AxisLine x1={ox - 30} y1={cy} x2={ox + rW + 30} y2={cy}
        label="x" color="var(--ember)" />

      {/* Centroid marker */}
      <circle cx={cx} cy={cy} r={3} fill="var(--ember)" />

      {/* Dimensions */}
      <DimensionLine x1={ox} y1={oy + rH + 16} x2={ox + rW} y2={oy + rH + 16}
        label={`b = ${width}`} offset={14} />
      <DimensionLine x1={ox + rW + 16} y1={oy + rH} x2={ox + rW + 16} y2={oy} offset={30} />
      <Label x={ox + rW + 46} y={(oy + cy) / 2} fontSize={11}>
        h = {height}
      </Label>

    </svg>
  );
}

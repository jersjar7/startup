import React from 'react';
import {
  DimensionLine, AxisLine, Label,
} from './primitives';

export function ParallelAxisRect({ width = 50, height = 100 }) {
  const scale = 1.4;
  const ox = 120;
  const oy = 30;
  const rW = width * scale;
  const rH = height * scale;
  const cx = ox + rW / 2;
  const cy = oy + rH / 2;
  const baseY = oy + rH;

  return (
    <svg viewBox="0 0 360 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Rectangle ${width}x${height} with parallel axes`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Rectangle */}
      <rect x={ox} y={oy} width={rW} height={rH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Centroidal axis */}
      <AxisLine x1={ox - 40} y1={cy} x2={ox + rW + 40} y2={cy}
        label="xc" color="var(--forest)" />
      <circle cx={cx} cy={cy} r={3} fill="var(--forest)" />

      {/* Base axis */}
      <AxisLine x1={ox - 40} y1={baseY} x2={ox + rW + 40} y2={baseY}
        label="x'" color="var(--ember)" />

      {/* d distance between axes */}
      <line x1={ox - 24} y1={cy} x2={ox - 24} y2={baseY}
        stroke="var(--ember)" strokeWidth={1.5}
        strokeDasharray="3,3" />
      <line x1={ox - 30} y1={cy} x2={ox - 18} y2={cy}
        stroke="var(--ember)" strokeWidth={1} />
      <line x1={ox - 30} y1={baseY} x2={ox - 18} y2={baseY}
        stroke="var(--ember)" strokeWidth={1} />
      <Label x={ox - 36} y={(cy + baseY) / 2} color="var(--ember)" italic bold fontSize={12} anchor="end">
        d
      </Label>

      {/* Dimensions */}
      <DimensionLine x1={ox} y1={oy - 12} x2={ox + rW} y2={oy - 12}
        label={`${width}`} offset={-10} />
      <DimensionLine x1={ox + rW + 16} y1={oy + rH} x2={ox + rW + 16} y2={oy} offset={20} />
      <Label x={ox + rW + 36} y={(oy + cy) / 2} fontSize={11}>
        {height}
      </Label>

    </svg>
  );
}

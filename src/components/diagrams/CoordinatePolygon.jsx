import React from 'react';
import { Label } from './primitives';

/**
 * Polygon with labeled vertices on a coordinate grid.
 *
 * Shows: x/y axes, vertex dots with coordinate labels,
 *        polygon outline, light area fill.
 * Does NOT show: area value (student computes).
 */
export function CoordinatePolygon({
  vertices = [
    { x: 0, y: 0, label: 'A' },
    { x: 6, y: 0, label: 'B' },
    { x: 3, y: 4, label: 'C' },
  ],
}) {
  const W = 360;
  const H = 260;

  // Compute data bounds
  const xs = vertices.map(v => v.x);
  const ys = vertices.map(v => v.y);
  const minX = Math.min(...xs);
  const maxX = Math.max(...xs);
  const minY = Math.min(...ys);
  const maxY = Math.max(...ys);

  const rangeX = maxX - minX || 1;
  const rangeY = maxY - minY || 1;

  // Plot area with padding for labels
  const plotLeft = 60;
  const plotRight = W - 40;
  const plotTop = 40;
  const plotBot = H - 50;
  const plotW = plotRight - plotLeft;
  const plotH = plotBot - plotTop;

  // Scale to fit, maintaining aspect ratio
  const scaleX = plotW / rangeX;
  const scaleY = plotH / rangeY;
  const scale = Math.min(scaleX, scaleY) * 0.85;

  // Center the plot
  const dataW = rangeX * scale;
  const dataH = rangeY * scale;
  const offsetX = plotLeft + (plotW - dataW) / 2;
  const offsetY = plotTop + (plotH - dataH) / 2;

  // Convert data → SVG
  const toSvg = (vx, vy) => ({
    sx: offsetX + (vx - minX) * scale,
    sy: offsetY + (maxY - vy) * scale,  // y-flip
  });

  // Axis origin in SVG
  const origin = toSvg(Math.min(0, minX), Math.min(0, minY));

  // Polygon path
  const pts = vertices.map(v => toSvg(v.x, v.y));
  const polyPath = pts.map((p, i) =>
    `${i === 0 ? 'M' : 'L'} ${p.sx},${p.sy}`
  ).join(' ') + ' Z';

  // Axis extent
  const axisMinX = toSvg(minX - rangeX * 0.1, 0);
  const axisMaxX = toSvg(maxX + rangeX * 0.15, 0);
  const axisMinY = toSvg(0, minY - rangeY * 0.1);
  const axisMaxY = toSvg(0, maxY + rangeY * 0.15);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Polygon with vertices ${vertices.map(v => `${v.label}(${v.x},${v.y})`).join(', ')}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Axes */}
      <line x1={axisMinX.sx} y1={origin.sy} x2={axisMaxX.sx} y2={origin.sy}
        stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={origin.sx} y1={axisMinY.sy} x2={origin.sx} y2={axisMaxY.sy}
        stroke="var(--gray-400)" strokeWidth={1} />

      {/* Axis labels */}
      <Label x={axisMaxX.sx + 10} y={origin.sy}
        fontSize={10} color="var(--gray-400)" bold>x</Label>
      <Label x={origin.sx} y={axisMaxY.sy - 12}
        fontSize={10} color="var(--gray-400)" bold>y</Label>

      {/* 2. Polygon fill */}
      <path d={polyPath} fill="rgba(45,122,95,0.08)"
        stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />

      {/* 3. Vertex dots and labels */}
      {vertices.map((v, i) => {
        const p = pts[i];
        // Smart label placement — offset away from polygon centroid
        const cx = pts.reduce((s, pt) => s + pt.sx, 0) / pts.length;
        const cy = pts.reduce((s, pt) => s + pt.sy, 0) / pts.length;
        const dx = p.sx - cx;
        const dy = p.sy - cy;
        const len = Math.sqrt(dx * dx + dy * dy) || 1;
        const labelDist = 18;
        const lx = p.sx + (dx / len) * labelDist;
        const ly = p.sy + (dy / len) * labelDist;

        return (
          <React.Fragment key={i}>
            <circle cx={p.sx} cy={p.sy} r={3.5} fill="var(--charcoal)" />
            <Label x={lx} y={ly} fontSize={9} color="var(--charcoal)" bold>
              {v.label}({v.x}, {v.y})
            </Label>
          </React.Fragment>
        );
      })}
    </svg>
  );
}

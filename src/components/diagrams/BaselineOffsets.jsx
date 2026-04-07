import React from 'react';
import { Label } from './primitives';

/**
 * Baseline with perpendicular offset measurements to an irregular boundary.
 *
 * Shows: baseline (bold), offset lines (vertical), offset values,
 *        smooth boundary curve through offset tops, shaded area between.
 *
 * Used for trapezoidal rule and Simpson's 1/3 rule area problems.
 * Does NOT show: computed area (student solves).
 */
export function BaselineOffsets({
  offsets = [0, 8, 12, 10, 0],
  spacing = 20,
  unit = 'm',
}) {
  const n = offsets.length;
  const totalWidth = (n - 1) * spacing;
  const maxOffset = Math.max(...offsets);

  const W = 460;
  const H = 220;

  // Layout
  const baseY = 160;
  const plotLeft = 70;
  const plotRight = W - 50;
  const plotTop = 40;

  // Scales
  const hScale = (plotRight - plotLeft) / totalWidth;
  const availH = baseY - plotTop - 10;
  const vScale = maxOffset > 0 ? availH / (maxOffset * 1.15) : 1;

  // Offset point positions
  const pts = offsets.map((h, i) => ({
    x: plotLeft + i * spacing * hScale,
    y: baseY - h * vScale,
    h,
  }));

  // Smooth curve through offset tops using Catmull-Rom → cubic Bezier conversion
  const curvePath = (() => {
    if (pts.length < 2) return '';
    let d = `M ${pts[0].x},${pts[0].y}`;
    for (let i = 0; i < pts.length - 1; i++) {
      const p0 = pts[Math.max(0, i - 1)];
      const p1 = pts[i];
      const p2 = pts[i + 1];
      const p3 = pts[Math.min(pts.length - 1, i + 2)];
      // Catmull-Rom to cubic Bezier control points
      const cp1x = p1.x + (p2.x - p0.x) / 6;
      const cp1y = p1.y + (p2.y - p0.y) / 6;
      const cp2x = p2.x - (p3.x - p1.x) / 6;
      const cp2y = p2.y - (p3.y - p1.y) / 6;
      d += ` C ${cp1x},${cp1y} ${cp2x},${cp2y} ${p2.x},${p2.y}`;
    }
    return d;
  })();

  // Shaded area path — curve + baseline close
  const areaPath = curvePath +
    ` L ${pts[pts.length - 1].x},${baseY}` +
    ` L ${pts[0].x},${baseY} Z`;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Baseline with ${n} offsets at ${spacing} ${unit} intervals for area computation`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Shaded area */}
      <path d={areaPath} fill="rgba(45,122,95,0.08)" />

      {/* 2. Irregular boundary curve */}
      <path d={curvePath} fill="none" stroke="var(--charcoal)" strokeWidth={2} />

      {/* 3. Baseline */}
      <line x1={pts[0].x - 15} y1={baseY} x2={pts[pts.length - 1].x + 15} y2={baseY}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 4. Offset lines */}
      {pts.map((p, i) => (
        <g key={i}>
          {/* Vertical offset line */}
          {p.h > 0 && (
            <line x1={p.x} y1={baseY} x2={p.x} y2={p.y}
              stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
          )}
          {/* Offset dot at top */}
          <circle cx={p.x} cy={p.y} r={2.5} fill="var(--charcoal)" />
          {/* Base tick */}
          <line x1={p.x} y1={baseY - 3} x2={p.x} y2={baseY + 3}
            stroke="var(--charcoal)" strokeWidth={1.5} />
          {/* Offset value label */}
          <Label x={p.x} y={p.h > 0 ? p.y - 10 : baseY - 12}
            fontSize={8} color="var(--gray-500)">
            {p.h}
          </Label>
        </g>
      ))}

      {/* 5. Spacing dimension — between first two offsets */}
      {n >= 2 && (
        <>
          <line x1={pts[0].x} y1={baseY + 18} x2={pts[1].x} y2={baseY + 18}
            stroke="var(--gray-500)" strokeWidth={1} />
          <line x1={pts[0].x} y1={baseY + 14} x2={pts[0].x} y2={baseY + 22}
            stroke="var(--gray-500)" strokeWidth={1} />
          <line x1={pts[1].x} y1={baseY + 14} x2={pts[1].x} y2={baseY + 22}
            stroke="var(--gray-500)" strokeWidth={1} />
          <Label x={(pts[0].x + pts[1].x) / 2} y={baseY + 30}
            fontSize={9} color="var(--gray-500)">
            w = {spacing} {unit}
          </Label>
        </>
      )}

      {/* 6. Label for offsets */}
      <Label x={pts[0].x - 20} y={baseY}
        fontSize={8} color="var(--gray-400)" anchor="end">
        Baseline
      </Label>
    </svg>
  );
}

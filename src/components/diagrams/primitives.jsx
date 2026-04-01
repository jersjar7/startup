import React from 'react';
import { polar, arcPath, K } from './geo';

/* ═══════════════════════════════════════
   Shared SVG primitives for statics diagrams.
   Composed inside parent <svg> elements.
   ═══════════════════════════════════════ */

/* ── Arrow marker definitions ── */
export function ArrowMarkerDefs({ id = 'arrowhead', color = 'var(--charcoal)', size = 8 }) {
  return (
    <defs>
      <marker
        id={id}
        markerWidth={size}
        markerHeight={size}
        refX={size - 1}
        refY={size / 2}
        orient="auto-start-reverse"
        markerUnits="userSpaceOnUse"
      >
        <path
          d={`M 0,0 L ${size},${size / 2} L 0,${size} Z`}
          fill={color}
        />
      </marker>
    </defs>
  );
}

/* ── Force arrow (line with arrowhead) ── */
export function ForceArrow({
  x1, y1, x2, y2,
  color = 'var(--charcoal)',
  strokeWidth = 2,
  markerId = 'arrowhead',
}) {
  return (
    <line
      x1={x1} y1={y1} x2={x2} y2={y2}
      stroke={color}
      strokeWidth={strokeWidth}
      markerEnd={`url(#${markerId})`}
    />
  );
}

/* ── Dashed line ── */
export function DashedLine({
  x1, y1, x2, y2,
  color = 'var(--gray-400)',
  strokeWidth = 1.5,
  dasharray = '4,3',
}) {
  return (
    <line
      x1={x1} y1={y1} x2={x2} y2={y2}
      stroke={color}
      strokeWidth={strokeWidth}
      strokeDasharray={dasharray}
    />
  );
}

/* ── Dimension line (line with size ticks at both ends + label) ── */
export function DimensionLine({
  x1, y1, x2, y2,
  label,
  offset = 0,
  color = 'var(--gray-500)',
  fontSize = 11,
  tickSize = 5,
}) {
  const mx = (x1 + x2) / 2;
  const my = (y1 + y2) / 2;
  const dx = x2 - x1;
  const dy = y2 - y1;
  const len = Math.sqrt(dx * dx + dy * dy);
  const nx = -dy / len;
  const ny = dx / len;

  return (
    <g>
      <line
        x1={x1} y1={y1} x2={x2} y2={y2}
        stroke={color} strokeWidth={1}
      />
      {/* End ticks */}
      <line
        x1={x1 + nx * tickSize} y1={y1 + ny * tickSize}
        x2={x1 - nx * tickSize} y2={y1 - ny * tickSize}
        stroke={color} strokeWidth={1}
      />
      <line
        x1={x2 + nx * tickSize} y1={y2 + ny * tickSize}
        x2={x2 - nx * tickSize} y2={y2 - ny * tickSize}
        stroke={color} strokeWidth={1}
      />
      {label && (
        <text
          x={mx + nx * (offset || 10)}
          y={my + ny * (offset || 10)}
          fill={color}
          fontFamily="var(--font-body)"
          fontSize={fontSize}
          textAnchor="middle"
          dominantBaseline="middle"
        >
          {label}
        </text>
      )}
    </g>
  );
}

/* ── Angle arc ── */
export function AngleArc({
  cx, cy, radius = 24, startAngle = 0, endAngle = 35,
  color = 'var(--ember)', strokeWidth = 1.5, label,
}) {
  const d = arcPath(cx, cy, radius, startAngle, endAngle);
  const midAngle = (startAngle + endAngle) / 2;
  const labelPt = polar(cx, cy, radius + K.ARC_LABEL_OFFSET, midAngle);

  return (
    <g>
      <path d={d} fill="none" stroke={color} strokeWidth={strokeWidth} />
      {label && (
        <text
          x={labelPt.x} y={labelPt.y}
          fill={color}
          fontFamily="var(--font-body)"
          fontStyle="italic"
          fontSize={12}
          textAnchor="middle"
          dominantBaseline="middle"
        >
          {label}
        </text>
      )}
    </g>
  );
}

/* ── Right angle marker (small square) ── */
export function RightAngleMarker({
  x, y, size = 12, rotation = 0,
  color = 'var(--gray-400)', strokeWidth = 1.5,
}) {
  return (
    <g transform={`rotate(${rotation}, ${x}, ${y})`}>
      <polyline
        points={`${x + size},${y} ${x + size},${y - size} ${x},${y - size}`}
        fill="none"
        stroke={color}
        strokeWidth={strokeWidth}
      />
    </g>
  );
}

/* ── Pin support (triangle) ── */
export function PinSupport({
  x, y, size = 16,
  color = 'var(--charcoal)', strokeWidth = 2,
}) {
  const half = size / 2;
  return (
    <g>
      <polygon
        points={`${x},${y} ${x - half},${y + size} ${x + half},${y + size}`}
        fill="none"
        stroke={color}
        strokeWidth={strokeWidth}
        strokeLinejoin="round"
      />
      <line
        x1={x - half - 4} y1={y + size}
        x2={x + half + 4} y2={y + size}
        stroke={color} strokeWidth={strokeWidth}
      />
    </g>
  );
}

/* ── Roller support (triangle + circle) ── */
export function RollerSupport({
  x, y, size = 16,
  color = 'var(--charcoal)', strokeWidth = 2,
}) {
  const half = size / 2;
  const circleR = 4;
  return (
    <g>
      <polygon
        points={`${x},${y} ${x - half},${y + size} ${x + half},${y + size}`}
        fill="none"
        stroke={color}
        strokeWidth={strokeWidth}
        strokeLinejoin="round"
      />
      <circle cx={x - half / 2} cy={y + size + circleR + 1} r={circleR}
        fill="none" stroke={color} strokeWidth={1.5} />
      <circle cx={x + half / 2} cy={y + size + circleR + 1} r={circleR}
        fill="none" stroke={color} strokeWidth={1.5} />
    </g>
  );
}

/* ── Fixed support (hatched wall) ── */
export function FixedSupport({
  x, y, height = 60, side = 'left',
  color = 'var(--charcoal)', strokeWidth = 2,
}) {
  const hatchCount = 5;
  const hatchLen = 10;
  const hatchSpacing = height / (hatchCount + 1);
  const dir = side === 'left' ? -1 : 1;

  return (
    <g>
      <line x1={x} y1={y} x2={x} y2={y + height}
        stroke={color} strokeWidth={strokeWidth} />
      {Array.from({ length: hatchCount }, (_, i) => {
        const hy = y + hatchSpacing * (i + 1);
        return (
          <line key={i}
            x1={x} y1={hy}
            x2={x + dir * hatchLen} y2={hy + 6}
            stroke={color} strokeWidth={1.5}
          />
        );
      })}
    </g>
  );
}

/* ── Distributed load arrows (series of downward arrows) ── */
export function DistributedLoadArrows({
  x, y, width, arrowLen = 30, count = 6,
  color = 'var(--ember)', markerId = 'arrowEmber',
}) {
  const spacing = width / (count - 1);
  return (
    <g>
      {/* Top line connecting arrow tails */}
      <line x1={x} y1={y} x2={x + width} y2={y}
        stroke={color} strokeWidth={1.5} />
      {Array.from({ length: count }, (_, i) => {
        const ax = x + i * spacing;
        return (
          <line key={i}
            x1={ax} y1={y} x2={ax} y2={y + arrowLen}
            stroke={color} strokeWidth={1.5}
            markerEnd={`url(#${markerId})`}
          />
        );
      })}
    </g>
  );
}

/* ── Couple arrow (curved moment arrow) ── */
export function CoupleArrow({
  cx, cy, radius = 20, ccw = true,
  color = 'var(--ember)', strokeWidth = 1.5,
  markerId = 'arrowEmber', label,
}) {
  // Arc spans ~260° leaving a gap for the arrowhead
  const startDeg = ccw ? 220 : 320;
  const endDeg = ccw ? 320 : 220;
  const startPt = polar(cx, cy, radius, startDeg);
  const endPt = polar(cx, cy, radius, endDeg);
  // Large arc (> 180°), sweep direction based on CCW/CW
  const sweepFlag = ccw ? 1 : 0;

  return (
    <g>
      <path
        d={`M ${startPt.x},${startPt.y} A ${radius},${radius} 0 1 ${sweepFlag} ${endPt.x},${endPt.y}`}
        fill="none"
        stroke={color}
        strokeWidth={strokeWidth}
        markerEnd={`url(#${markerId})`}
      />
      {label && (
        <text
          x={cx} y={cy - radius - 8}
          fill={color}
          fontFamily="var(--font-body)"
          fontStyle="italic"
          fontSize={12}
          textAnchor="middle"
        >
          {label}
        </text>
      )}
    </g>
  );
}

/* ── Rectangle shape ── */
export function RectShape({
  x, y, width, height,
  color = 'var(--charcoal)', strokeWidth = 2.5,
  fill = 'none',
}) {
  return (
    <rect
      x={x} y={y} width={width} height={height}
      fill={fill}
      stroke={color}
      strokeWidth={strokeWidth}
      rx={1}
    />
  );
}

/* ── Centroid marker (crosshair dot) ── */
export function CentroidMarker({
  cx, cy, size = 6,
  color = 'var(--ember)',
}) {
  return (
    <g>
      <circle cx={cx} cy={cy} r={2.5} fill={color} />
      <line x1={cx - size} y1={cy} x2={cx + size} y2={cy}
        stroke={color} strokeWidth={1} />
      <line x1={cx} y1={cy - size} x2={cx} y2={cy + size}
        stroke={color} strokeWidth={1} />
    </g>
  );
}

/* ── Axis line (with label) ── */
export function AxisLine({
  x1, y1, x2, y2, label,
  color = 'var(--gray-400)', strokeWidth = 1,
  dasharray = '6,3',
}) {
  const mx = (x1 + x2) / 2;
  const my = (y1 + y2) / 2;
  return (
    <g>
      <line
        x1={x1} y1={y1} x2={x2} y2={y2}
        stroke={color} strokeWidth={strokeWidth}
        strokeDasharray={dasharray}
      />
      {label && (
        <text
          x={x2 + 6} y={y2 + 4}
          fill={color}
          fontFamily="var(--font-body)"
          fontStyle="italic"
          fontSize={11}
          textAnchor="start"
        >
          {label}
        </text>
      )}
    </g>
  );
}

/* ── SVG label text (reusable) ── */
export function Label({
  x, y, children,
  color = 'var(--gray-500)',
  fontSize = 12,
  italic = false,
  anchor = 'middle',
  bold = false,
  rotate = 0,
}) {
  return (
    <text
      x={x} y={y}
      fill={color}
      fontFamily="var(--font-body)"
      fontStyle={italic ? 'italic' : 'normal'}
      fontWeight={bold ? 600 : 400}
      fontSize={fontSize}
      textAnchor={anchor}
      dominantBaseline="middle"
      transform={rotate ? `rotate(${rotate}, ${x}, ${y})` : undefined}
    >
      {children}
    </text>
  );
}

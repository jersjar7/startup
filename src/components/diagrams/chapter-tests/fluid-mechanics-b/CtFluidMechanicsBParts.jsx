import React from 'react';

/* Small drawing parts shared by the fluid mechanics B figures. Not a figure
   itself, so it is not registered. Arrowheads are plain polygons, so no
   marker ids are needed and several figures can share a page. */

export const FONT = 'var(--font-body)';

export function T({ x, y, children, anchor = 'middle', size = 12, color = 'var(--charcoal)', italic = false, bold = false }) {
  return (
    <text x={x} y={y} fill={color} fontFamily={FONT} fontSize={size}
      textAnchor={anchor} dominantBaseline="middle"
      fontStyle={italic ? 'italic' : 'normal'} fontWeight={bold ? 600 : 400}>
      {children}
    </text>
  );
}

/* Arrowhead with its tip at (x, y), pointing along (dx, dy). */
export function Head({ x, y, dx, dy, size = 8, color = 'var(--charcoal)' }) {
  const L = Math.hypot(dx, dy) || 1;
  const ux = dx / L;
  const uy = dy / L;
  const bx = x - ux * size;
  const by = y - uy * size;
  const w = size * 0.42;
  return (
    <polygon
      points={`${x},${y} ${bx - uy * w},${by + ux * w} ${bx + uy * w},${by - ux * w}`}
      fill={color}
    />
  );
}

/* Straight arrow from (x1, y1) to a tip at (x2, y2). */
export function Arrow({ x1, y1, x2, y2, color = 'var(--charcoal)', width = 2, size = 9 }) {
  const L = Math.hypot(x2 - x1, y2 - y1) || 1;
  const ex = x2 - ((x2 - x1) / L) * size * 0.8;
  const ey = y2 - ((y2 - y1) / L) * size * 0.8;
  return (
    <g>
      <line x1={x1} y1={y1} x2={ex} y2={ey} stroke={color} strokeWidth={width} />
      <Head x={x2} y={y2} dx={x2 - x1} dy={y2 - y1} size={size} color={color} />
    </g>
  );
}

/* Dimension line with arrowheads at both ends. The label is placed by the
   caller (lx, ly, anchor) so it never lands on the line. */
export function Dim({ x1, y1, x2, y2, label, lx, ly, anchor = 'middle', color = 'var(--gray-500)', size = 12 }) {
  return (
    <g>
      <line x1={x1} y1={y1} x2={x2} y2={y2} stroke={color} strokeWidth={1} />
      <Head x={x1} y={y1} dx={x1 - x2} dy={y1 - y2} size={7} color={color} />
      <Head x={x2} y={y2} dx={x2 - x1} dy={y2 - y1} size={7} color={color} />
      {label != null && <T x={lx} y={ly} anchor={anchor} color={color} size={size}>{label}</T>}
    </g>
  );
}

/* Thin extension line for dimensions. */
export function Ext({ x1, y1, x2, y2 }) {
  return <line x1={x1} y1={y1} x2={x2} y2={y2} stroke="var(--gray-400)" strokeWidth={0.8} />;
}

/* Free water surface symbol: inverted triangle sitting on the surface line,
   with two short lines under the surface. */
export function WaterSym({ x, y, color = 'var(--info)' }) {
  return (
    <g>
      <polygon points={`${x - 6},${y - 11} ${x + 6},${y - 11} ${x},${y - 1}`} fill="none" stroke={color} strokeWidth={1.3} />
      <line x1={x - 7} y1={y + 4} x2={x + 7} y2={y + 4} stroke={color} strokeWidth={1.2} />
      <line x1={x - 4} y1={y + 8} x2={x + 4} y2={y + 8} stroke={color} strokeWidth={1.2} />
    </g>
  );
}

/* Hatched ground under a horizontal line from x1 to x2 at y. */
export function Ground({ x1, x2, y, depth = 9, step = 10 }) {
  const n = Math.floor((x2 - x1) / step);
  return (
    <g>
      <line x1={x1} y1={y} x2={x2} y2={y} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: n }, (_, i) => {
        const hx = x1 + 4 + i * step;
        return <line key={i} x1={hx + depth} y1={y} x2={hx} y2={y + depth} stroke="var(--gray-500)" strokeWidth={1} />;
      })}
    </g>
  );
}

/* Leader line from a label to the thing it names, ending in a small dot. */
export function Leader({ x1, y1, x2, y2 }) {
  return (
    <g>
      <line x1={x1} y1={y1} x2={x2} y2={y2} stroke="var(--gray-500)" strokeWidth={0.9} />
      <circle cx={x2} cy={y2} r={1.8} fill="var(--gray-500)" />
    </g>
  );
}

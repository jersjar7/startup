import React from 'react';

// Shared drawing parts for the structural version A figures. Not registered:
// the figures compose these. Every marker id is passed in by the figure so
// several figures can share a page without collisions.

export const INK = 'var(--charcoal)';
export const LOAD = 'var(--ember)';
export const DIM = 'var(--gray-500)';
export const SEC = 'var(--gray-400)';
export const FONT = 'var(--font-body)';

export function Arrowhead({ id, color = INK, size = 8 }) {
  return (
    <marker id={id} markerWidth={size} markerHeight={size} refX={size - 1} refY={size / 2}
      orient="auto-start-reverse" markerUnits="userSpaceOnUse">
      <path d={`M 0,0 L ${size},${size / 2} L 0,${size} Z`} fill={color} />
    </marker>
  );
}

export function T({ x, y, children, anchor = 'middle', size = 12, color = INK, bold = false, italic = false }) {
  return (
    <text x={x} y={y} fill={color} fontFamily={FONT} fontSize={size}
      fontWeight={bold ? 600 : 400} fontStyle={italic ? 'italic' : 'normal'}
      textAnchor={anchor} dominantBaseline="middle">
      {children}
    </text>
  );
}

// Ground line with short hatch strokes below it, from x1 to x2 at y.
export function Ground({ x1, x2, y, color = INK }) {
  const n = Math.max(2, Math.round((x2 - x1) / 6));
  const step = (x2 - x1) / n;
  return (
    <g>
      <line x1={x1} y1={y} x2={x2} y2={y} stroke={color} strokeWidth={1.5} />
      {Array.from({ length: n }, (_, i) => (
        <line key={i} x1={x1 + (i + 1) * step} y1={y} x2={x1 + (i + 1) * step - 5} y2={y + 6}
          stroke={color} strokeWidth={1} />
      ))}
    </g>
  );
}

// Pin: triangle with its apex at (x, y), sitting on hatched ground.
export function Pin({ x, y, s = 14, color = INK }) {
  const h = s / 2 + 1;
  return (
    <g>
      <polygon points={`${x},${y} ${x - h},${y + s} ${x + h},${y + s}`} fill="none"
        stroke={color} strokeWidth={1.8} strokeLinejoin="round" />
      <Ground x1={x - h - 5} x2={x + h + 5} y={y + s} color={color} />
    </g>
  );
}

// Roller: triangle on two wheels, on hatched ground. Total height s + 9.
export function Roller({ x, y, s = 14, color = INK }) {
  const h = s / 2 + 1;
  const r = 3.5;
  return (
    <g>
      <polygon points={`${x},${y} ${x - h},${y + s} ${x + h},${y + s}`} fill="none"
        stroke={color} strokeWidth={1.8} strokeLinejoin="round" />
      <circle cx={x - h / 2} cy={y + s + r} r={r} fill="none" stroke={color} strokeWidth={1.4} />
      <circle cx={x + h / 2} cy={y + s + r} r={r} fill="none" stroke={color} strokeWidth={1.4} />
      <Ground x1={x - h - 5} x2={x + h + 5} y={y + s + 2 * r} color={color} />
    </g>
  );
}

// Internal hinge: open circle.
export function Hinge({ x, y, r = 4.5, color = INK }) {
  return <circle cx={x} cy={y} r={r} fill="#fff" stroke={color} strokeWidth={1.8} />;
}

// Dimension line with end ticks (slanted 45 degrees, drafting style) and
// extension-free label. side: 'above' | 'below' | 'left' | 'right'.
export function Dim({ x1, y1, x2, y2, label, side = 'below', gap = 11, size = 12, color = DIM }) {
  const horiz = Math.abs(y2 - y1) < Math.abs(x2 - x1);
  const t = 4;
  const tick = (x, y) => <line x1={x - t} y1={y + t} x2={x + t} y2={y - t} stroke={color} strokeWidth={1.2} />;
  let lx = (x1 + x2) / 2;
  let ly = (y1 + y2) / 2;
  let anchor = 'middle';
  if (horiz) ly += side === 'above' ? -gap : gap;
  else if (side === 'left') { lx -= gap - 4; anchor = 'end'; } else { lx += gap - 4; anchor = 'start'; }
  return (
    <g>
      <line x1={x1} y1={y1} x2={x2} y2={y2} stroke={color} strokeWidth={1} />
      {tick(x1, y1)}
      {tick(x2, y2)}
      {label && <T x={lx} y={ly} anchor={anchor} size={size} color={color}>{label}</T>}
    </g>
  );
}

// Thin extension line (for dimensions taken off a point).
export function Ext({ x1, y1, x2, y2, color = SEC }) {
  return <line x1={x1} y1={y1} x2={x2} y2={y2} stroke={color} strokeWidth={0.8} />;
}

// Row of downward load arrows from y (tails) to y + len (tips), x1..x2.
export function Udl({ x1, x2, y, len = 22, count, markerId, color = LOAD }) {
  const n = count || Math.max(3, Math.round((x2 - x1) / 22) + 1);
  const step = (x2 - x1) / (n - 1);
  return (
    <g>
      <line x1={x1} y1={y} x2={x2} y2={y} stroke={color} strokeWidth={1.5} />
      {Array.from({ length: n }, (_, i) => (
        <line key={i} x1={x1 + i * step} y1={y} x2={x1 + i * step} y2={y + len}
          stroke={color} strokeWidth={1.4} markerEnd={`url(#${markerId})`} />
      ))}
    </g>
  );
}

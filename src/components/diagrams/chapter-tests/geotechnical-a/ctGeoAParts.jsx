import React from 'react';

/* Small drawing helpers shared by the geotechnical version A figures.
   Not figures themselves, so not registered in DIAGRAMS. */

export const SOIL_TINT = { sand: 0.10, clay: 0.24, gravel: 0.16, fill: 0.06, rock: 0.32, silt: 0.17 };

/** Text with simple subscripts: 'γ_sat = 125 pcf' draws "sat" as a subscript. */
export function SubText({ x, y, children, size = 12, color = 'var(--charcoal)', anchor = 'start', bold = false, italic = false }) {
  const parts = String(children).split(/_([A-Za-z0-9]+)/);
  return (
    <text x={x} y={y} fill={color} fontFamily="var(--font-body)" fontSize={size}
      fontWeight={bold ? 600 : 400} fontStyle={italic ? 'italic' : 'normal'}
      textAnchor={anchor} dominantBaseline="middle">
      {parts.map((p, i) => (i % 2 === 1
        ? <tspan key={i} dy={size * 0.3} fontSize={size * 0.72}>{p}</tspan>
        : <tspan key={i} dy={i === 0 ? 0 : -size * 0.3}>{p}</tspan>))}
    </text>
  );
}

/** Standard water surface symbol: inverted triangle resting on the line, two short bars under it. */
export function WaterMark({ x, y, size = 9 }) {
  const h = size * 0.87;
  return (
    <g>
      <polygon points={`${x},${y} ${x - size / 2},${y - h} ${x + size / 2},${y - h}`}
        fill="none" stroke="var(--info)" strokeWidth={1.4} strokeLinejoin="round" />
      <line x1={x - size * 0.45} y1={y + 3.5} x2={x + size * 0.45} y2={y + 3.5} stroke="var(--info)" strokeWidth={1.2} />
      <line x1={x - size * 0.25} y1={y + 6.5} x2={x + size * 0.25} y2={y + 6.5} stroke="var(--info)" strokeWidth={1.2} />
    </g>
  );
}

/** Short ground-surface hatch marks under a horizontal line from x1 to x2. */
export function SurfaceHatch({ x1, x2, y, step = 14, len = 7 }) {
  const n = Math.max(1, Math.floor((x2 - x1 - 4) / step));
  return (
    <g>
      {Array.from({ length: n }, (_, i) => {
        const x = x1 + 6 + i * step;
        return <line key={i} x1={x} y1={y} x2={x - len * 0.7} y2={y + len}
          stroke="var(--charcoal)" strokeWidth={1} />;
      })}
    </g>
  );
}

/** Vertical dimension with end ticks and a horizontal label beside it. */
export function VDim({ x, y1, y2, label, side = 'left', color = 'var(--gray-500)', size = 12 }) {
  const top = Math.min(y1, y2);
  const bot = Math.max(y1, y2);
  const lx = side === 'left' ? x - 7 : x + 7;
  return (
    <g>
      <line x1={x} y1={top} x2={x} y2={bot} stroke={color} strokeWidth={1} />
      <line x1={x - 5} y1={top} x2={x + 5} y2={top} stroke={color} strokeWidth={1} />
      <line x1={x - 5} y1={bot} x2={x + 5} y2={bot} stroke={color} strokeWidth={1} />
      <SubText x={lx} y={(top + bot) / 2} size={size} color={color} anchor={side === 'left' ? 'end' : 'start'}>{label}</SubText>
    </g>
  );
}

/** Horizontal dimension with end ticks and the label under (or over) it. */
export function HDim({ y, x1, x2, label, below = true, color = 'var(--gray-500)', size = 12 }) {
  return (
    <g>
      <line x1={x1} y1={y} x2={x2} y2={y} stroke={color} strokeWidth={1} />
      <line x1={x1} y1={y - 5} x2={x1} y2={y + 5} stroke={color} strokeWidth={1} />
      <line x1={x2} y1={y - 5} x2={x2} y2={y + 5} stroke={color} strokeWidth={1} />
      <SubText x={(x1 + x2) / 2} y={below ? y + 14 : y - 12} size={size} color={color} anchor="middle">{label}</SubText>
    </g>
  );
}

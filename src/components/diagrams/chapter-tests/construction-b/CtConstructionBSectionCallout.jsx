import React from 'react';

/**
 * Fragment of a foundation plan: a wall in plan, a section cut line across it,
 * and the section callout bubbles at both ends of the cut (number over sheet,
 * with the solid arrowhead showing the viewing direction).
 * Shows: the callout as drawn. Does NOT show: what it means.
 */
export function CtConstructionBSectionCallout({ section = '3', sheet = 'S-301', thisSheet = 'S-101' }) {
  const wallY1 = 92; const wallY2 = 120; const cutX = 200;
  const R = 26;
  const topC = { x: cutX, y: 34 }; const botC = { x: cutX, y: 182 };
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle' };
  const bubble = (c, key) => (
    <g key={key}>
      {/* solid arrowhead on the right side of the bubble: the viewer looks that way */}
      <path d={`M ${c.x + R - 3} ${c.y - 14} L ${c.x + R + 18} ${c.y} L ${c.x + R - 3} ${c.y + 14} Z`} fill="var(--charcoal)" />
      <circle cx={c.x} cy={c.y} r={R} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.8} />
      <line x1={c.x - R} y1={c.y} x2={c.x + R} y2={c.y} stroke="var(--charcoal)" strokeWidth={1.2} />
      <text x={c.x} y={c.y - 10} fill="var(--charcoal)" fontSize={14} fontWeight={700} textAnchor="middle" {...font}>{section}</text>
      <text x={c.x} y={c.y + 11} fill="var(--charcoal)" fontSize={11} fontWeight={600} textAnchor="middle" {...font}
        fontFamily="var(--font-mono)">{sheet}</text>
    </g>
  );
  return (
    <svg viewBox="0 0 400 238" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Plan fragment with a wall, a section cut line and its section callout bubbles"
      style={{ width: '100%', height: 'auto' }}>
      {/* Wall in plan */}
      <rect x={20} y={wallY1} width={360} height={wallY2 - wallY1} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      {/* Concrete stipple: dots plus small open aggregate triangles */}
      {Array.from({ length: 33 }, (_, i) => {
        const x = 28 + i * 10.4;
        if (Math.abs(x - cutX) < 14) return null;
        const yd = wallY1 + 6 + ((i * 7) % 17);
        const yd2 = wallY1 + 8 + ((i * 11 + 9) % 15);
        return (
          <g key={i} fill="var(--gray-500)">
            <circle cx={x} cy={yd} r={0.9} />
            <circle cx={x + 5} cy={yd2} r={0.8} />
            {i % 3 === 0 && Math.abs(x + 5 - cutX) > 14 && (
              <path d={`M ${x + 2} ${wallY1 + 19} l 3.4 -5 l 3.4 5 Z`} fill="none" stroke="var(--gray-500)" strokeWidth={0.8} />
            )}
          </g>
        );
      })}
      {/* Cut line */}
      <line x1={cutX} y1={topC.y + R} x2={cutX} y2={botC.y - R} stroke="var(--charcoal)" strokeWidth={2.4} strokeDasharray="16,5,3,5" />
      {bubble(topC, 't')}
      {bubble(botC, 'b')}
      <text x={20} y={226} fill="var(--gray-500)" fontSize={11.5} textAnchor="start" {...font}>{`FOUNDATION PLAN (sheet ${thisSheet}), part`}</text>
      <text x={24} y={wallY1 - 12} fill="var(--charcoal)" fontSize={12} textAnchor="start" {...font}>concrete wall</text>
    </svg>
  );
}

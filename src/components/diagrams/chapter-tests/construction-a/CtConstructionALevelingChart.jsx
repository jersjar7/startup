import React from 'react';

/**
 * Bar chart of four activities at their early starts, crew size on each bar,
 * total float drawn as a dashed box after the bar.
 * Shows: early-start schedule, crews, float. Does NOT show: the leveled schedule or any daily total.
 */
export function CtConstructionALevelingChart({
  days = 8,
  bars = [
    { id: 'P', start: 0, dur: 5, crew: 4, float: 0 },
    { id: 'S', start: 5, dur: 3, crew: 2, float: 0 },
    { id: 'Q', start: 0, dur: 4, crew: 5, float: 4 },
    { id: 'R', start: 2, dur: 3, crew: 3, float: 3 },
  ],
  links = [['P', 'S']],
}) {
  const L = 40; const T = 24; const dx = 40; const rowH = 40; const bh = 22;
  const X = (d) => L + d * dx;
  const rowY = (i) => T + 8 + i * rowH;
  const H = rowY(bars.length) + 24;
  const W = X(days) + 14;
  const idx = Object.fromEntries(bars.map((b, i) => [b.id, i]));
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle' };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Bar chart of activities P, S, Q and R at their early starts with crew sizes and total float"
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctConALevelArrow" markerWidth={7} markerHeight={7} refX={6.5} refY={3.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 7,3.5 L 0,7 Z" fill="var(--charcoal)" />
        </marker>
      </defs>
      {/* Day grid */}
      {Array.from({ length: days + 1 }, (_, d) => (
        <g key={d}>
          <line x1={X(d)} y1={T} x2={X(d)} y2={rowY(bars.length) - 6} stroke="var(--gray-200)" strokeWidth={0.8} />
          <text x={X(d)} y={T - 10} fill="var(--gray-500)" fontSize={11} textAnchor="middle" {...font}
            fontFamily="var(--font-mono)">{d}</text>
        </g>
      ))}
      <text x={L - 30} y={T - 10} fill="var(--gray-500)" fontSize={11} textAnchor="start" {...font}>Day</text>

      {bars.map((b, i) => {
        const y = rowY(i);
        return (
          <g key={b.id}>
            <text x={L - 14} y={y + bh / 2} fill="var(--charcoal)" fontSize={13} fontWeight={700} textAnchor="middle" {...font}>{b.id}</text>
            {b.float > 0 && (
              <g>
                <rect x={X(b.start + b.dur)} y={y} width={b.float * dx} height={bh} rx={6}
                  fill="none" stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="5,3" />
                <text x={X(b.start + b.dur + b.float / 2)} y={y + bh / 2} fill="var(--gray-500)" fontSize={11}
                  textAnchor="middle" {...font}>{`float ${b.float} d`}</text>
              </g>
            )}
            <rect x={X(b.start)} y={y} width={b.dur * dx} height={bh} rx={6}
              fill={b.float > 0 ? 'var(--ember-bg)' : 'var(--cream-dark)'} stroke={b.float > 0 ? 'var(--ember)' : 'var(--charcoal)'} strokeWidth={1.5} />
            <text x={X(b.start + b.dur / 2)} y={y + bh / 2} fill="var(--charcoal)" fontSize={11.5} fontWeight={600}
              textAnchor="middle" {...font}>{`${b.crew} workers`}</text>
          </g>
        );
      })}
      {links.map(([f, t]) => {
        const a = bars[idx[f]]; const b = bars[idx[t]];
        const xa = X(a.start + a.dur);
        return (
          <path key={f + t} d={`M ${xa - 8} ${rowY(idx[f]) + bh} L ${xa - 8} ${rowY(idx[t]) + bh / 2} L ${X(b.start) - 1} ${rowY(idx[t]) + bh / 2}`}
            fill="none" stroke="var(--charcoal)" strokeWidth={1.2} markerEnd="url(#ctConALevelArrow)" />
        );
      })}
      {/* Legend */}
      <rect x={L} y={rowY(bars.length) + 2} width={22} height={12} rx={4} fill="none" stroke="var(--gray-400)" strokeDasharray="5,3" strokeWidth={1.2} />
      <text x={L + 30} y={rowY(bars.length) + 8} fill="var(--gray-500)" fontSize={11} textAnchor="start" {...font}>total float (room to move the bar later)</text>
    </svg>
  );
}

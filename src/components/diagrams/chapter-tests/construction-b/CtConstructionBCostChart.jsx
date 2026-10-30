import React from 'react';

/**
 * Early-start bar chart with the budget of each activity (thousand dollars)
 * and a status-date line. Budgets are spread evenly over each bar.
 * Shows: schedule, budgets, status date. Does NOT show: planned or earned value.
 */
export function CtConstructionBCostChart({
  days = 10,
  status = 6,
  bars = [
    { id: 'A', start: 0, dur: 4, budget: 20 },
    { id: 'B', start: 2, dur: 6, budget: 36 },
    { id: 'C', start: 4, dur: 6, budget: 30 },
    { id: 'D', start: 6, dur: 4, budget: 16 },
  ],
}) {
  const L = 46; const T = 46; const dx = 34; const rowH = 38; const bh = 24;
  const X = (d) => L + d * dx;
  const rowY = (i) => T + 8 + i * rowH;
  const bottom = rowY(bars.length) - 6;
  const H = bottom + 28;
  const W = X(days) + 14;
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle' };
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Bar chart of four activities with their budgets and a status date line"
      style={{ width: '100%', height: 'auto' }}>
      {Array.from({ length: days + 1 }, (_, d) => (
        <g key={d}>
          <line x1={X(d)} y1={T} x2={X(d)} y2={bottom} stroke="var(--gray-200)" strokeWidth={0.8} />
          <text x={X(d)} y={T - 10} fill="var(--gray-500)" fontSize={11} textAnchor="middle" {...font}
            fontFamily="var(--font-mono)">{d}</text>
        </g>
      ))}
      <text x={6} y={T - 10} fill="var(--gray-500)" fontSize={11} textAnchor="start" {...font}>Day</text>
      {bars.map((b, i) => {
        const y = rowY(i);
        return (
          <g key={b.id}>
            <text x={L - 22} y={y + bh / 2} fill="var(--charcoal)" fontSize={13} fontWeight={700} textAnchor="middle" {...font}>{b.id}</text>
            <rect x={X(b.start)} y={y} width={b.dur * dx} height={bh} rx={6}
              fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.5} />
            <text x={X(b.start + b.dur / 2)} y={y + bh / 2} fill="var(--charcoal)" fontSize={12} fontWeight={600}
              textAnchor="middle" {...font} fontFamily="var(--font-mono)">{b.budget}</text>
          </g>
        );
      })}
      <line x1={X(status)} y1={T - 4} x2={X(status)} y2={bottom + 4} stroke="var(--ember)" strokeWidth={2} strokeDasharray="6,4" />
      <text x={X(status)} y={T - 30} fill="var(--ember)" fontSize={11.5} fontWeight={600} textAnchor="middle" {...font}>{`status: end of day ${status}`}</text>
      <text x={L} y={bottom + 18} fill="var(--gray-500)" fontSize={11} textAnchor="start" {...font}>Budgets in thousand dollars, spread evenly over each bar</text>
    </svg>
  );
}

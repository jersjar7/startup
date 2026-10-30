import React from 'react';

/**
 * Earned-value S-curves at a status date. BCWS runs to the budget at
 * completion; BCWP and ACWP stop at the status date.
 * Shows: BAC, the three values at the status date. Does NOT show: CPI, SPI, EAC.
 */
export function CtConstructionAEarnedValue({
  bac = 2400, months = 12, status = 6, bcws = 1100, bcwp = 960, acwp = 1200, yMax = 2800, yStep = 400,
}) {
  const L = 62; const T = 14; const PW = 312; const PH = 210;
  const X = (m) => L + (m / months) * PW;
  const Y = (v) => T + PH - (v / yMax) * PH;
  const smooth = (x) => 3 * x * x - 2 * x * x * x;
  // exponent so the planned curve passes through bcws at the status date
  const target = bcws / bac;
  let lo = 0.2; let hi = 5;
  for (let i = 0; i < 60; i++) {
    const p = (lo + hi) / 2;
    if (smooth((status / months) ** p) > target) lo = p; else hi = p;
  }
  const p = (lo + hi) / 2;
  const plan = (m) => bac * smooth((m / months) ** p);
  const path = (f, end, k = 1) => Array.from({ length: 49 }, (_, i) => {
    const m = (end * i) / 48;
    return `${i ? 'L' : 'M'} ${X(m).toFixed(1)} ${Y(f(m) * k).toFixed(1)}`;
  }).join(' ');
  const n = (v) => v.toLocaleString('en-US');
  const ticks = Array.from({ length: Math.floor(yMax / yStep) + 1 }, (_, i) => i * yStep);
  const W = L + PW + 64;
  const H = T + PH + 44;
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle' };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Earned value curves: BCWS to a budget of ${bac} thousand dollars over ${months} months, BCWP and ACWP to month ${status}`}
      style={{ width: '100%', height: 'auto' }}>
      {ticks.map((v) => (
        <g key={v}>
          <line x1={L} y1={Y(v)} x2={L + PW} y2={Y(v)} stroke="var(--gray-200)" strokeWidth={v ? 0.8 : 1.2} />
          <text x={L - 6} y={Y(v)} fill="var(--gray-500)" fontSize={11} textAnchor="end" {...font}
            fontFamily="var(--font-mono)">{n(v)}</text>
        </g>
      ))}
      {Array.from({ length: months / 2 + 1 }, (_, i) => i * 2).map((m) => (
        <text key={m} x={X(m)} y={T + PH + 12} fill="var(--gray-500)" fontSize={11} textAnchor="middle" {...font}
          fontFamily="var(--font-mono)">{m}</text>
      ))}
      <line x1={L} y1={T} x2={L} y2={T + PH} stroke="var(--charcoal)" strokeWidth={1.2} />
      <text x={L + PW / 2} y={T + PH + 30} fill="var(--charcoal)" fontSize={12} textAnchor="middle" {...font}>Month</text>
      <text x={14} y={T + PH / 2} fill="var(--charcoal)" fontSize={12} textAnchor="middle" {...font}
        transform={`rotate(-90, 14, ${T + PH / 2})`}>Cumulative cost (thousand dollars)</text>

      {/* Status date */}
      <line x1={X(status)} y1={T + 4} x2={X(status)} y2={T + PH} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="5,3" />

      {/* Curves */}
      <path d={path(plan, months)} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <path d={path(plan, status, acwp / bcws)} fill="none" stroke="var(--gray-500)" strokeWidth={2} strokeDasharray="7,4" />
      <path d={path(plan, status, bcwp / bcws)} fill="none" stroke="var(--ember)" strokeWidth={2.2} />
      {[[acwp, 'var(--gray-500)'], [bcws, 'var(--charcoal)'], [bcwp, 'var(--ember)']].map(([v, c]) => (
        <circle key={v} cx={X(status)} cy={Y(v)} r={3.2} fill={c} />
      ))}

      {/* Curve names */}
      <text x={X(months) + 6} y={Y(bac) - 8} fill="var(--charcoal)" fontSize={11.5} fontWeight={600} textAnchor="start" {...font}>BCWS</text>
      <text x={X(months) + 6} y={Y(bac) + 8} fill="var(--charcoal)" fontSize={11} textAnchor="start" {...font}>{`BAC ${n(bac)}`}</text>
      <circle cx={X(months)} cy={Y(bac)} r={3.2} fill="var(--charcoal)" />
      <text x={X(status) - 34} y={Y(acwp) - 22} fill="var(--gray-500)" fontSize={11.5} fontWeight={600} textAnchor="end" {...font}>ACWP</text>
      <line x1={X(status) - 32} y1={Y(acwp) - 18} x2={X(status) - 14} y2={Y(acwp * 0.88) - 2} stroke="var(--gray-500)" strokeWidth={0.8} />
      <text x={X(status) + 10} y={Y(bcwp) + 18} fill="var(--ember)" fontSize={11.5} fontWeight={600} textAnchor="start" {...font}>BCWP</text>

      {/* Values at the status date */}
      <rect x={L + 10} y={T + 8} width={138} height={78} rx={6} fill="#fff" stroke="var(--gray-300)" strokeWidth={1} />
      <text x={L + 20} y={T + 21} fill="var(--charcoal)" fontSize={11} fontWeight={600} textAnchor="start" {...font}>{`Status date: month ${status}`}</text>
      {[['BCWS', bcws, 'var(--charcoal)'], ['BCWP', bcwp, 'var(--ember)'], ['ACWP', acwp, 'var(--gray-500)']].map(([k, v, c], i) => (
        <g key={k}>
          <text x={L + 20} y={T + 40 + i * 16} fill={c} fontSize={11.5} fontWeight={600} textAnchor="start" {...font}>{k}</text>
          <text x={L + 138} y={T + 40 + i * 16} fill="var(--charcoal)" fontSize={11.5} textAnchor="end" {...font}
            fontFamily="var(--font-mono)">{n(v)}</text>
        </g>
      ))}
    </svg>
  );
}

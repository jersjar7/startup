import React from 'react';

/**
 * Transformed scatter plot: ln(y) against x with the least-squares line.
 * Points come from props; the line is drawn from the intercept and slope the
 * statement gives. The value the question asks for is not marked.
 */
export function CtStatisticsBLogPlot({
  points = [], a = 0.405, b = -0.092, xMax = 10, xStep = 2,
  yMin = -0.6, yMax = 0.6, yStep = 0.2,
  xTitle = 'Time, t (h)', yTitle = 'ln C  (C in mg/L)',
}) {
  const W = 420;
  const plotL = 64;
  const plotR = W - 18;
  const plotT = 14;
  const plotB = 200;
  const X = (v) => plotL + (v / xMax) * (plotR - plotL);
  const Y = (v) => plotB - ((v - yMin) / (yMax - yMin)) * (plotB - plotT);
  const H = plotB + 44;

  const xt = [];
  for (let v = 0; v <= xMax + 1e-9; v += xStep) xt.push(v);
  const yt = [];
  for (let v = yMin; v <= yMax + 1e-9; v += yStep) yt.push(Math.round(v * 100) / 100);

  const lx2 = xMax;
  const ly1 = a;
  const ly2 = a + b * lx2;
  const fmtY = (v) => (v === 0 ? '0' : v.toFixed(1).replace('-', '−'));

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Plot of ln C against time with a fitted straight line"
      style={{ width: '100%', height: 'auto' }}>
      {/* Grid */}
      {yt.map((v) => (
        <line key={`gy${v}`} x1={plotL} y1={Y(v)} x2={plotR} y2={Y(v)}
          stroke="var(--gray-400)" strokeOpacity={0.35} strokeWidth={v === 0 ? 1.2 : 0.8} />
      ))}
      {xt.map((v) => (
        <line key={`gx${v}`} x1={X(v)} y1={plotT} x2={X(v)} y2={plotB} stroke="var(--gray-400)" strokeOpacity={0.35} strokeWidth={0.8} />
      ))}
      {/* Axes */}
      <line x1={plotL} y1={plotB} x2={plotR} y2={plotB} stroke="var(--charcoal)" strokeWidth={1.4} />
      <line x1={plotL} y1={plotB} x2={plotL} y2={plotT} stroke="var(--charcoal)" strokeWidth={1.4} />
      {xt.map((v) => (
        <g key={`tx${v}`}>
          <line x1={X(v)} y1={plotB} x2={X(v)} y2={plotB + 4} stroke="var(--charcoal)" strokeWidth={1} />
          <text x={X(v)} y={plotB + 15} fill="var(--gray-500)" fontFamily="var(--font-mono)" fontSize={11}
            textAnchor="middle" dominantBaseline="middle">{v}</text>
        </g>
      ))}
      {yt.map((v) => (
        <g key={`ty${v}`}>
          <line x1={plotL - 4} y1={Y(v)} x2={plotL} y2={Y(v)} stroke="var(--charcoal)" strokeWidth={1} />
          <text x={plotL - 7} y={Y(v)} fill="var(--gray-500)" fontFamily="var(--font-mono)" fontSize={11}
            textAnchor="end" dominantBaseline="middle">{fmtY(v)}</text>
        </g>
      ))}
      <text x={(plotL + plotR) / 2} y={plotB + 34} fill="var(--gray-500)" fontFamily="var(--font-body)"
        fontSize={11.5} textAnchor="middle" dominantBaseline="middle">{xTitle}</text>
      <text x={14} y={(plotT + plotB) / 2} fill="var(--gray-500)" fontFamily="var(--font-body)"
        fontSize={11.5} textAnchor="middle" dominantBaseline="middle"
        transform={`rotate(-90, 14, ${(plotT + plotB) / 2})`}>{yTitle}</text>

      {/* Fitted line */}
      <line x1={X(0)} y1={Y(ly1)} x2={X(lx2)} y2={Y(ly2)} stroke="var(--ember)" strokeWidth={2} />
      {/* Points */}
      {points.map(([px, py], i) => (
        <circle key={i} cx={X(px)} cy={Y(py)} r={4} fill="var(--charcoal)" />
      ))}
    </svg>
  );
}

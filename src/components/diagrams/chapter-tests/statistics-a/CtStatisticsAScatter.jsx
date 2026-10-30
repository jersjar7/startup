import React from 'react';

/**
 * Scatter plot of paired data, with an optional fitted line.
 * Shows: the data points on scaled axes with ticks and units, and the fitted
 *        line only when the question gives it.
 * Does NOT show: the slope, intercept or r when those are asked for.
 *
 * props:
 *   points   [[x, y], ...]
 *   xRange   [min, max, step]   axis extent and tick spacing
 *   yRange   [min, max, step]
 *   xLabel, yLabel              axis titles with units
 *   line     { a, b, label, labelAt } or null: y = a + b x, label placed at x = labelAt
 *   decimals [xDec, yDec]        tick label decimals
 */
export function CtStatisticsAScatter({
  points = [[0.8, 0.1], [1.2, 0.25], [1.9, 0.55], [2.4, 0.8], [3.0, 1.15], [3.5, 1.35]],
  xRange = [0, 4, 1],
  yRange = [0, 1.5, 0.5],
  xLabel = 'Rainfall, x (in)',
  yLabel = 'Runoff, y (in)',
  line = null,
  decimals = [0, 1],
}) {
  const W = 420;
  const H = 270;
  const L = 58;
  const R = W - 16;
  const T = 14;
  const B = H - 50;
  const X = (x) => L + ((x - xRange[0]) / (xRange[1] - xRange[0])) * (R - L);
  const Yp = (y) => B - ((y - yRange[0]) / (yRange[1] - yRange[0])) * (B - T);

  const ticks = ([lo, hi, st]) => {
    const out = [];
    for (let v = lo; v <= hi + st / 1000; v += st) out.push(+v.toFixed(6));
    return out;
  };
  const xt = ticks(xRange);
  const yt = ticks(yRange);

  let lineEl = null;
  if (line) {
    // Clip the line to the plot box.
    const f = (x) => line.a + line.b * x;
    let x1 = xRange[0];
    let x2 = xRange[1];
    const clip = (x) => {
      const y = f(x);
      if (y > yRange[1]) return (yRange[1] - line.a) / line.b;
      if (y < yRange[0]) return (yRange[0] - line.a) / line.b;
      return x;
    };
    x1 = clip(x1);
    x2 = clip(x2);
    const lx = line.labelAt ?? (x1 + x2) / 2;
    lineEl = (
      <g>
        <line x1={X(x1)} y1={Yp(f(x1))} x2={X(x2)} y2={Yp(f(x2))} stroke="var(--ember)" strokeWidth={2} />
        {line.label && (
          <text x={X(lx)} y={Yp(f(lx)) + (line.labelDy ?? -14)} fill="var(--ember)" fontFamily="var(--font-body)"
            fontWeight={600} fontSize={12} textAnchor={line.labelAnchor ?? 'start'} dominantBaseline="middle">
            {line.label}
          </text>
        )}
      </g>
    );
  }

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Scatter plot of ${yLabel} against ${xLabel}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Axes */}
      <line x1={L} y1={B} x2={R} y2={B} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={L} y1={B} x2={L} y2={T} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Ticks and tick labels */}
      {xt.map((v) => (
        <g key={`tx${v}`}>
          <line x1={X(v)} y1={B} x2={X(v)} y2={B + 5} stroke="var(--charcoal)" strokeWidth={1} />
          <text x={X(v)} y={B + 16} fill="var(--gray-500)" fontFamily="var(--font-mono)" fontSize={11}
            textAnchor="middle" dominantBaseline="middle">{v.toFixed(decimals[0])}</text>
        </g>
      ))}
      {yt.map((v) => (
        <g key={`ty${v}`}>
          <line x1={L - 5} y1={Yp(v)} x2={L} y2={Yp(v)} stroke="var(--charcoal)" strokeWidth={1} />
          <text x={L - 9} y={Yp(v)} fill="var(--gray-500)" fontFamily="var(--font-mono)" fontSize={11}
            textAnchor="end" dominantBaseline="middle">{v.toFixed(decimals[1])}</text>
        </g>
      ))}

      {/* Axis titles */}
      <text x={(L + R) / 2} y={H - 10} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={12}
        textAnchor="middle" dominantBaseline="middle">{xLabel}</text>
      <text x={14} y={(T + B) / 2} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={12}
        textAnchor="middle" dominantBaseline="middle" transform={`rotate(-90, 14, ${(T + B) / 2})`}>{yLabel}</text>

      {lineEl}

      {/* Data points */}
      {points.map(([x, y], i) => (
        <circle key={i} cx={X(x)} cy={Yp(y)} r={4.5} fill="var(--charcoal)" />
      ))}
    </svg>
  );
}

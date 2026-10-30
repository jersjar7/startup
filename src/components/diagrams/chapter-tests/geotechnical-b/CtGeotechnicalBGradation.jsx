import React from 'react';

/**
 * Grain-size distribution curve on a semi-log chart, particle size decreasing
 * to the right as on a standard sieve-analysis sheet. The curve passes through
 * the given (size, percent finer) points, joined by a monotone cubic in log
 * size so it never overshoots. Gridlines at every 1-9 multiple so D10, D30 and
 * D60 can be read. Shows the measured curve only, never a coefficient.
 */
export function CtGeotechnicalBGradation({
  points = [[0.05, 0], [0.075, 3], [0.1, 10], [0.2, 19], [0.4, 30], [1, 45], [2, 60], [4.75, 74], [10, 90], [20, 100]],
  dMax = 20,
  dMin = 0.05,
  sieves = [{ d: 4.75, label: 'No. 4' }, { d: 0.075, label: 'No. 200' }],
}) {
  const x0 = 50;
  const x1 = 426;
  const y0 = 34;
  const y1 = 252;
  const W = 440;
  const H = 292;
  const lmax = Math.log10(dMax);
  const span = lmax - Math.log10(dMin);
  const X = (d) => x0 + ((lmax - Math.log10(d)) / span) * (x1 - x0);
  const Y = (p) => y1 - (p / 100) * (y1 - y0);

  // Gridlines at 1..9 times each power of ten within range
  const grid = [];
  for (let e = -3; e <= 3; e++) {
    for (let m = 1; m <= 9; m++) {
      const d = m * 10 ** e;
      if (d >= dMin - 1e-9 && d <= dMax + 1e-9) grid.push({ d, major: m === 1 });
    }
  }
  const labelled = [20, 10, 5, 2, 1, 0.5, 0.2, 0.1, 0.05].filter((d) => d >= dMin - 1e-9 && d <= dMax + 1e-9);
  const fmt = (d) => (d >= 1 ? String(d) : String(d).replace(/^0/, '0'));

  // Monotone cubic (Fritsch-Carlson) in u = log10(d)
  const pts = [...points].sort((a, b) => a[0] - b[0]).map(([d, p]) => [Math.log10(d), p]);
  const n = pts.length;
  const dk = [];
  for (let i = 0; i < n - 1; i++) dk.push((pts[i + 1][1] - pts[i][1]) / (pts[i + 1][0] - pts[i][0]));
  const m = pts.map((_, i) => {
    if (i === 0) return dk[0];
    if (i === n - 1) return dk[n - 2];
    if (dk[i - 1] * dk[i] <= 0) return 0;
    return (2 * dk[i - 1] * dk[i]) / (dk[i - 1] + dk[i]);
  });
  const path = [];
  for (let i = 0; i < n - 1; i++) {
    const [ua, pa] = pts[i];
    const [ub, pb] = pts[i + 1];
    const h = ub - ua;
    for (let s = 0; s <= 16; s++) {
      const t = s / 16;
      const h00 = 2 * t ** 3 - 3 * t ** 2 + 1;
      const h10 = t ** 3 - 2 * t ** 2 + t;
      const h01 = -2 * t ** 3 + 3 * t ** 2;
      const h11 = t ** 3 - t ** 2;
      const u = ua + t * h;
      const p = h00 * pa + h10 * h * m[i] + h01 * pb + h11 * h * m[i + 1];
      if (i > 0 && s === 0) continue;
      path.push(`${path.length ? 'L' : 'M'} ${X(10 ** u).toFixed(2)} ${Y(p).toFixed(2)}`);
    }
  }

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Grain-size distribution curve, percent finer by weight against particle size in millimeters on a log scale"
      style={{ width: '100%', height: 'auto' }}>
      {/* Grid */}
      {grid.map(({ d, major }) => (
        <line key={`g${d}`} x1={X(d)} y1={y0} x2={X(d)} y2={y1}
          stroke={major ? 'var(--gray-500)' : 'var(--gray-400)'} strokeWidth={major ? 0.9 : 0.5} />
      ))}
      {Array.from({ length: 11 }, (_, i) => (
        <line key={`h${i}`} x1={x0} y1={Y(i * 10)} x2={x1} y2={Y(i * 10)}
          stroke={i % 5 === 0 ? 'var(--gray-500)' : 'var(--gray-400)'} strokeWidth={i % 5 === 0 ? 0.9 : 0.5} />
      ))}
      <rect x={x0} y={y0} width={x1 - x0} height={y1 - y0} fill="none" stroke="var(--charcoal)" strokeWidth={1.2} />

      {/* Sieve markers on the top edge */}
      {sieves.map((s) => (
        <g key={s.label}>
          <line x1={X(s.d)} y1={y0 - 5} x2={X(s.d)} y2={y0 + 6} stroke="var(--charcoal)" strokeWidth={1.4} />
          <text x={X(s.d)} y={y0 - 10} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={11}
            textAnchor="middle">{s.label}</text>
        </g>
      ))}

      {/* Curve */}
      <path d={path.join(' ')} fill="none" stroke="var(--ember)" strokeWidth={2.2} strokeLinejoin="round" />

      {/* Axis labels */}
      {Array.from({ length: 11 }, (_, i) => (
        <text key={`yl${i}`} x={x0 - 6} y={Y(i * 10)} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={11}
          textAnchor="end" dominantBaseline="middle">{i * 10}</text>
      ))}
      {labelled.map((d) => (
        <text key={`xl${d}`} x={X(d)} y={y1 + 14} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={11}
          textAnchor="middle">{fmt(d)}</text>
      ))}
      <text x={(x0 + x1) / 2} y={y1 + 32} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={12}
        textAnchor="middle">Particle size (mm), log scale</text>
      <text x={14} y={(y0 + y1) / 2} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={12}
        textAnchor="middle" transform={`rotate(-90 14 ${(y0 + y1) / 2})`}>Percent finer by weight (%)</text>
    </svg>
  );
}

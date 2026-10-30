import React from 'react';

/**
 * Normal curve drawn to scale (mean +/- 3.5 sd) with the lower tail below a
 * specification limit shaded. Shows the mean and the limit the question
 * gives, never the tail probability.
 */
export function CtStatisticsBNormalTail({
  mean = 66, sd = 4, limit = 60, unit = 'ksi', decimals = 1,
  axisTitle = 'Yield strength (ksi)',
}) {
  const W = 420;
  const L = 16;
  const R = W - 16;
  const baseY = 136;
  const peakH = 118;
  const xMin = mean - 3.5 * sd;
  const xMax = mean + 3.5 * sd;
  const X = (v) => L + ((v - xMin) / (xMax - xMin)) * (R - L);
  const Y = (v) => baseY - Math.exp(-0.5 * ((v - mean) / sd) ** 2) * peakH;

  const N = 160;
  const pts = [];
  const tail = [`${X(xMin).toFixed(1)},${baseY}`];
  for (let i = 0; i <= N; i++) {
    const v = xMin + (i / N) * (xMax - xMin);
    pts.push(`${X(v).toFixed(1)},${Y(v).toFixed(1)}`);
    if (v <= limit) tail.push(`${X(v).toFixed(1)},${Y(v).toFixed(1)}`);
  }
  tail.push(`${X(limit).toFixed(1)},${Y(limit).toFixed(1)}`, `${X(limit).toFixed(1)},${baseY}`);

  const xm = X(mean);
  const xl = X(limit);
  const fmt = (v) => v.toFixed(decimals);
  const H = baseY + 48;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Normal curve, mean ${fmt(mean)} ${unit}, lower tail below ${fmt(limit)} ${unit} shaded`}
      style={{ width: '100%', height: 'auto' }}>
      <polygon points={tail.join(' ')} fill="var(--ember-bg)" stroke="none" />
      <polyline points={pts.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.2} />
      <line x1={L} y1={baseY} x2={R} y2={baseY} stroke="var(--charcoal)" strokeWidth={1.4} />

      {/* Limit */}
      <line x1={xl} y1={baseY + 5} x2={xl} y2={Y(limit) - 26} stroke="var(--ember)" strokeWidth={1.6} strokeDasharray="5,3" />
      <text x={xl} y={baseY + 18} fill="var(--ember)" fontFamily="var(--font-body)" fontWeight={600}
        fontSize={12} textAnchor="middle" dominantBaseline="middle">{`${fmt(limit)} ${unit}`}</text>

      {/* Mean */}
      <line x1={xm} y1={baseY + 5} x2={xm} y2={baseY - peakH} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <text x={xm} y={baseY + 18} fill="var(--gray-500)" fontFamily="var(--font-body)"
        fontSize={12} textAnchor="middle" dominantBaseline="middle">{`μ = ${fmt(mean)} ${unit}`}</text>

      <text x={(L + R) / 2} y={baseY + 38} fill="var(--gray-500)" fontFamily="var(--font-body)"
        fontSize={11.5} textAnchor="middle" dominantBaseline="middle">{axisTitle}</text>
    </svg>
  );
}

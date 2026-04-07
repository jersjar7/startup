import React from 'react';
import { Label } from './primitives';

/**
 * Sampling distribution with rejection region for a one-tailed hypothesis test.
 * Shows: t-distribution curve, critical value, shaded rejection region, test statistic position.
 * Does NOT show: the conclusion (that's the answer).
 */
export function HypothesisRegion({ alpha = 0.05, tCrit = 1.753, tStat = 2.4 }) {
  const W = 460;
  const H = 250;
  const pad = 36;

  const baseY = H - pad - 30;
  const peakH = baseY - 36;

  // Visual range: -3.5 to 4.5 on t-axis (extra room on right for labels)
  const tMin = -3.5;
  const tMax = 4.5;
  const toSvgX = (t) => pad + ((t - tMin) / (tMax - tMin)) * (W - 2 * pad);

  // t-distribution approximation (using normal for visual)
  const pdf = (t) => Math.exp(-0.5 * t * t);

  // Generate full curve points
  const N = 100;
  const curvePoints = [];
  const rejectFill = [];

  for (let i = 0; i <= N; i++) {
    const frac = i / N;
    const t = tMin + frac * (tMax - tMin);
    const svgX = toSvgX(t);
    const svgY = baseY - pdf(t) * peakH;
    curvePoints.push(`${svgX.toFixed(1)},${svgY.toFixed(1)}`);

    // Collect points in the rejection region (right tail beyond tCrit)
    if (t >= tCrit) {
      rejectFill.push(`${svgX.toFixed(1)},${svgY.toFixed(1)}`);
    }
  }

  // Close rejection polygon
  const critSvgX = toSvgX(tCrit);
  const critSvgY = baseY - pdf(tCrit) * peakH;
  const rejectPolygon = [
    `${critSvgX.toFixed(1)},${baseY}`,
    `${critSvgX.toFixed(1)},${critSvgY.toFixed(1)}`,
    ...rejectFill,
    `${toSvgX(tMax).toFixed(1)},${baseY}`,
  ].join(' ');

  // Test statistic position
  const tStatSvgX = toSvgX(tStat);
  const tStatSvgY = baseY - pdf(tStat) * peakH;

  // Zero line
  const zeroSvgX = toSvgX(0);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Hypothesis test: t-critical ${tCrit}, t-statistic ${tStat}, alpha ${alpha}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Rejection region shading */}
      <polygon points={rejectPolygon}
        fill="var(--ember-bg)" stroke="none" />

      {/* Full curve */}
      <polyline points={curvePoints.join(' ')}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Baseline */}
      <line x1={pad} y1={baseY} x2={W - pad} y2={baseY}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Center line (t = 0) */}
      <line x1={zeroSvgX} y1={baseY} x2={zeroSvgX} y2={baseY - peakH}
        stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />
      <Label x={zeroSvgX} y={baseY + 16} fontSize={10} color="var(--gray-400)">
        0
      </Label>

      {/* Critical value line */}
      <line x1={critSvgX} y1={baseY} x2={critSvgX} y2={critSvgY}
        stroke="var(--ember)" strokeWidth={1.5} strokeDasharray="4,3" />

      {/* t_crit label below baseline */}
      <text x={critSvgX} y={baseY + 16}
        fill="var(--ember)" fontFamily="var(--font-body)" fontWeight={600}
        fontSize={10} textAnchor="middle" dominantBaseline="auto">
        t<tspan fontSize={7} dy={2}>crit</tspan><tspan dy={-2}> = {tCrit}</tspan>
      </text>

      {/* Test statistic marker */}
      <line x1={tStatSvgX} y1={baseY} x2={tStatSvgX} y2={tStatSvgY - 4}
        stroke="var(--forest)" strokeWidth={2} />
      <circle cx={tStatSvgX} cy={tStatSvgY} r={4.5}
        fill="var(--forest)" stroke="white" strokeWidth={1.5} />
      <Label x={tStatSvgX} y={tStatSvgY - 16} fontSize={11} color="var(--forest)" bold>
        t = {tStat}
      </Label>

      {/* "reject H0" label above rejection region */}
      <text x={(critSvgX + toSvgX(tMax)) / 2} y={critSvgY - 24}
        fill="var(--ember)" fontFamily="var(--font-body)" fontWeight={500}
        fontSize={10} textAnchor="middle" dominantBaseline="auto">
        reject H<tspan fontSize={7} dy={2}>0</tspan>
      </text>

      {/* Alpha label above rejection region */}
      <Label x={(critSvgX + toSvgX(tMax)) / 2} y={critSvgY - 8} fontSize={10} color="var(--ember)" italic>
        {'\u03b1'} = {alpha}
      </Label>
    </svg>
  );
}

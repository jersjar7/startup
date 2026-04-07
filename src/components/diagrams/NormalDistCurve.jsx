import React from 'react';
import { Label } from './primitives';

/**
 * Normal distribution (bell curve) with shaded tail area.
 * Shows: bell curve centered at mean, shaded region below threshold, labels for mean and threshold.
 * Does NOT show: the percentage/probability (that's the answer).
 */
export function NormalDistCurve({ mean = 4500, sd = 300, threshold = 4000 }) {
  const W = 360;
  const H = 200;
  const pad = 30;

  // Data-space range: mean +/- 3.5 sd
  const xMin = mean - 3.5 * sd;
  const xMax = mean + 3.5 * sd;
  const toSvgX = (val) => pad + ((val - xMin) / (xMax - xMin)) * (W - 2 * pad);

  // Normal PDF (unnormalized, peak = 1)
  const pdf = (x) => Math.exp(-0.5 * Math.pow((x - mean) / sd, 2));

  const baseY = H - pad - 24;
  const peakH = baseY - 30;

  // Generate full curve points
  const N = 100;
  const curvePoints = [];
  const fillPoints = [];

  for (let i = 0; i <= N; i++) {
    const t = i / N;
    const x = xMin + t * (xMax - xMin);
    const svgX = toSvgX(x);
    const svgY = baseY - pdf(x) * peakH;
    curvePoints.push(`${svgX.toFixed(1)},${svgY.toFixed(1)}`);

    if (x <= threshold) {
      fillPoints.push(`${svgX.toFixed(1)},${svgY.toFixed(1)}`);
    }
  }

  // Close shaded polygon along baseline
  const threshSvgX = toSvgX(threshold);
  const threshSvgY = baseY - pdf(threshold) * peakH;
  const fillPolygon = [
    `${toSvgX(xMin).toFixed(1)},${baseY}`,
    ...fillPoints,
    `${threshSvgX.toFixed(1)},${threshSvgY.toFixed(1)}`,
    `${threshSvgX.toFixed(1)},${baseY}`,
  ].join(' ');

  const meanSvgX = toSvgX(mean);

  // Format numbers for labels
  const fmtThreshold = threshold >= 1000 ? `${(threshold / 1000).toFixed(0)},000` : threshold;
  const fmtMean = mean >= 1000 ? `${(mean / 1000).toFixed(0)},${String(mean % 1000).padStart(3, '0')}` : mean;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Normal distribution: mean ${mean}, threshold ${threshold}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Shaded tail area (fail region) */}
      <polygon points={fillPolygon}
        fill="var(--ember-bg)" stroke="none" />

      {/* Full bell curve */}
      <polyline points={curvePoints.join(' ')}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Baseline */}
      <line x1={pad} y1={baseY} x2={W - pad} y2={baseY}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Threshold vertical line */}
      <line x1={threshSvgX} y1={baseY} x2={threshSvgX} y2={threshSvgY}
        stroke="var(--ember)" strokeWidth={1.5} strokeDasharray="4,3" />

      {/* Mean vertical line (dashed, subtle) */}
      <line x1={meanSvgX} y1={baseY} x2={meanSvgX} y2={baseY - peakH}
        stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />

      {/* Threshold label */}
      <Label x={threshSvgX} y={baseY + 14} fontSize={10} color="var(--ember)" bold>
        {fmtThreshold}
      </Label>

      {/* Mean label */}
      <Label x={meanSvgX} y={baseY + 14} fontSize={10} color="var(--gray-500)">
        {fmtMean}
      </Label>

      {/* mu label at peak */}
      <Label x={meanSvgX} y={baseY - peakH - 8} fontSize={10} color="var(--gray-400)" italic>
        {'\u03bc'}
      </Label>

      {/* "Fail" annotation in shaded region */}
      <Label x={(toSvgX(xMin) + threshSvgX) / 2} y={baseY - 16} fontSize={9} color="var(--ember)" italic>
        fail
      </Label>
    </svg>
  );
}

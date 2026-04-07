import React from 'react';
import { Label } from './primitives';

/**
 * Right-skewed distribution curve with mode, median, and mean positions marked.
 * Shows: skewed bell curve, vertical markers for mode/median/mean in correct order.
 * Does NOT show: the skewness direction label (that's the answer).
 */
export function SkewnessChart({ mean = 50, median = 45, mode = 42 }) {
  const W = 360;
  const H = 180;
  const pad = 24;

  const baseY = H - pad - 20;
  const peakH = baseY - 30;

  // Determine order: for right-skew, mode < median < mean
  const dataMin = mode - (mean - mode) * 0.5;
  const dataMax = mean + (mean - mode) * 1.8;
  const range = dataMax - dataMin;

  const toSvgX = (val) => pad + 10 + ((val - dataMin) / range) * (W - 2 * pad - 20);

  // Generate a right-skewed curve using a gamma-like shape
  // Peak near the mode, tail stretching toward the mean
  const N = 80;
  const curvePoints = [];

  for (let i = 0; i <= N; i++) {
    const t = i / N;
    const x = dataMin + t * range;
    const svgX = toSvgX(x);

    // Skewed shape: rises fast to mode, falls slowly after
    const normX = (x - mode) / (mean - mode);
    let y;
    if (x < mode) {
      // Left side: steep rise
      const leftNorm = (x - dataMin) / (mode - dataMin);
      y = Math.pow(Math.max(0, leftNorm), 2.5);
    } else {
      // Right side: gradual fall (exponential decay)
      y = Math.exp(-0.8 * normX);
    }
    y = Math.max(0, y);

    const svgY = baseY - y * peakH;
    curvePoints.push(`${svgX.toFixed(1)},${svgY.toFixed(1)}`);
  }

  // Key positions
  const modeSvgX = toSvgX(mode);
  const medianSvgX = toSvgX(median);
  const meanSvgX = toSvgX(mean);

  // Heights at each position for dashed lines
  const modeTopY = baseY - peakH; // peak is at mode
  const medianNorm = (median - mode) / (mean - mode);
  const medianH = Math.exp(-0.8 * medianNorm) * peakH;
  const medianTopY = baseY - medianH;
  const meanNorm = 1;
  const meanH = Math.exp(-0.8 * meanNorm) * peakH;
  const meanTopY = baseY - meanH;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Distribution with mean ${mean}, median ${median}, mode ${mode}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Curve */}
      <polyline points={curvePoints.join(' ')}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Baseline */}
      <line x1={pad} y1={baseY} x2={W - pad} y2={baseY}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Mode marker */}
      <line x1={modeSvgX} y1={baseY} x2={modeSvgX} y2={modeTopY}
        stroke="var(--forest)" strokeWidth={1.5} strokeDasharray="4,3" />
      <Label x={modeSvgX} y={baseY + 14} fontSize={9} color="var(--forest)" bold>
        mode
      </Label>
      <Label x={modeSvgX} y={baseY + 25} fontSize={9} color="var(--forest)">
        {mode}
      </Label>

      {/* Median marker */}
      <line x1={medianSvgX} y1={baseY} x2={medianSvgX} y2={medianTopY}
        stroke="var(--info)" strokeWidth={1.5} strokeDasharray="4,3" />
      <Label x={medianSvgX} y={baseY + 14} fontSize={9} color="var(--info)" bold>
        median
      </Label>
      <Label x={medianSvgX} y={baseY + 25} fontSize={9} color="var(--info)">
        {median}
      </Label>

      {/* Mean marker */}
      <line x1={meanSvgX} y1={baseY} x2={meanSvgX} y2={meanTopY}
        stroke="var(--ember)" strokeWidth={1.5} strokeDasharray="4,3" />
      <Label x={meanSvgX} y={baseY + 14} fontSize={9} color="var(--ember)" bold>
        mean
      </Label>
      <Label x={meanSvgX} y={baseY + 25} fontSize={9} color="var(--ember)">
        {mean}
      </Label>

      {/* Tail direction indicator (subtle arrow-like shape) */}
      <Label x={W - pad - 30} y={baseY - 8} fontSize={9} color="var(--gray-300)" italic>
        tail
      </Label>
    </svg>
  );
}

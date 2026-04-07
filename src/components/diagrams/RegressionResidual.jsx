import React from 'react';
import { ArrowMarkerDefs, Label } from './primitives';

/**
 * Scatter plot with regression line and highlighted residual.
 * Shows: data points, regression line, one highlighted point below/above the line,
 *        vertical arrow measuring the residual distance.
 * Does NOT show: the interpretation (that's the answer).
 */
export function RegressionResidual({ residual = -1.8 }) {
  const W = 360;
  const H = 220;
  const pad = 30;

  // Plot area
  const plotL = pad + 20;
  const plotR = W - pad - 10;
  const plotT = pad + 10;
  const plotB = H - pad - 20;
  const plotW = plotR - plotL;
  const plotH = plotB - plotT;

  // Fixed scatter data (normalized 0-1 range, representing pavement age vs IRI)
  const data = [
    { x: 0.08, y: 0.12 },
    { x: 0.18, y: 0.28 },
    { x: 0.25, y: 0.22 },
    { x: 0.35, y: 0.38 },
    { x: 0.42, y: 0.52 },
    { x: 0.55, y: 0.48 },
    { x: 0.62, y: 0.58 },
    { x: 0.72, y: 0.72 },
    { x: 0.85, y: 0.78 },
    { x: 0.92, y: 0.88 },
  ];

  // Regression line (approximate): y = 0.05 + 0.88x
  const lineSlope = 0.88;
  const lineIntercept = 0.05;
  const regY = (x) => lineIntercept + lineSlope * x;

  // The highlighted point (below the line for negative residual)
  const highlightIdx = 5; // data[5] = (0.55, 0.48), regY(0.55) = 0.534
  const hp = data[highlightIdx];
  const hpPredicted = regY(hp.x);

  // Convert to SVG coords (y is inverted)
  const toSvgX = (nx) => plotL + nx * plotW;
  const toSvgY = (ny) => plotB - ny * plotH;

  // Line endpoints in SVG
  const lineX1 = toSvgX(0);
  const lineY1 = toSvgY(regY(0));
  const lineX2 = toSvgX(1);
  const lineY2 = toSvgY(regY(1));

  // Highlighted point SVG coords
  const hpSvgX = toSvgX(hp.x);
  const hpSvgY = toSvgY(hp.y);
  const hpPredSvgY = toSvgY(hpPredicted);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Scatter plot with regression line showing residual of ${residual}`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowResid" color="var(--ember)" size={6} />

      {/* Axes */}
      <line x1={plotL} y1={plotB} x2={plotR} y2={plotB}
        stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={plotL} y1={plotB} x2={plotL} y2={plotT}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Axis labels */}
      <Label x={(plotL + plotR) / 2} y={plotB + 18} fontSize={10} color="var(--gray-400)">
        x
      </Label>
      <Label x={plotL - 12} y={(plotT + plotB) / 2} fontSize={10} color="var(--gray-400)" italic rotate={-90}>
        y
      </Label>

      {/* Regression line */}
      <line x1={lineX1} y1={lineY1} x2={lineX2} y2={lineY2}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Data points (regular) */}
      {data.map((d, i) => i !== highlightIdx && (
        <circle key={i} cx={toSvgX(d.x)} cy={toSvgY(d.y)} r={3.5}
          fill="var(--gray-400)" stroke="white" strokeWidth={1} />
      ))}

      {/* Horizontal dashed line from point to regression line (visual guide) */}
      <line x1={hpSvgX} y1={hpPredSvgY} x2={hpSvgX} y2={hpSvgY}
        stroke="var(--ember)" strokeWidth={1.5} strokeDasharray="4,3" />

      {/* Residual arrow: from regression line down to point */}
      <line x1={hpSvgX} y1={hpPredSvgY} x2={hpSvgX} y2={hpSvgY - 2}
        stroke="var(--ember)" strokeWidth={2}
        markerEnd="url(#arrowResid)" />

      {/* Highlighted data point */}
      <circle cx={hpSvgX} cy={hpSvgY} r={5}
        fill="var(--ember)" stroke="white" strokeWidth={2} />

      {/* Predicted point on line (small dot) */}
      <circle cx={hpSvgX} cy={hpPredSvgY} r={2.5}
        fill="var(--gray-400)" />

      {/* Residual label (subscript via tspan) */}
      <text x={hpSvgX + 14} y={(hpSvgY + hpPredSvgY) / 2}
        fill="var(--ember)" fontFamily="var(--font-body)" fontWeight={600}
        fontStyle="italic" fontSize={12} textAnchor="start" dominantBaseline="middle">
        e<tspan fontSize={8} dy={3}>i</tspan>
      </text>

      {/* Regression line label */}
      <Label x={lineX2 - 4} y={lineY2 - 10} fontSize={10}
        color="var(--gray-500)" italic anchor="end">
        {'\u0177'} = a + bx
      </Label>
    </svg>
  );
}

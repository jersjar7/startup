import React from 'react';
import { DimensionLine, Label } from './primitives';

/**
 * Reinforced concrete column cross-section.
 *
 * Shows: concrete rectangle (or circle), longitudinal bars distributed
 *        around the perimeter, tie/stirrup outline (dashed).
 *
 * shape = 'square' | 'rectangular' — uses w and h
 * shape = 'circular' — uses diameter
 *
 * Does NOT show: capacity, strain, or interaction diagram (student solves).
 */
export function RCColumnSection({
  w = 16,
  h: colH = 16,
  diameter = 20,
  numBars = 8,
  shape = 'square',
  unit = 'in.',
}) {
  const W = 300;
  const HH = 300;
  const cx = W / 2;
  const cy = 130;

  if (shape === 'circular') {
    return renderCircular({ W, HH, cx, cy, diameter, numBars, unit });
  }

  // Rectangular / square
  const maxDim = Math.max(w, colH);
  const scale = 150 / maxDim;
  const secW = w * scale;
  const secH = colH * scale;

  const secLeft = cx - secW / 2;
  const secRight = cx + secW / 2;
  const secTop = cy - secH / 2;
  const secBot = cy + secH / 2;

  // Tie inset
  const tieInset = 10;

  // Bar positions around perimeter (inside the tie)
  const barR = 5;
  const barInset = tieInset + barR + 2;
  const bars = distributeRectBars(secLeft + barInset, secTop + barInset,
    secW - 2 * barInset, secH - 2 * barInset, numBars);

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`RC column section, ${w}x${colH} ${unit}, ${numBars} bars`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Concrete fill */}
      <rect x={secLeft} y={secTop} width={secW} height={secH}
        fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} rx={2} />

      {/* 2. Tie (dashed inset rectangle) */}
      <rect x={secLeft + tieInset} y={secTop + tieInset}
        width={secW - 2 * tieInset} height={secH - 2 * tieInset}
        fill="none" stroke="var(--gray-400)" strokeWidth={1.5}
        strokeDasharray="4,3" rx={2} />

      {/* 3. Longitudinal bars */}
      {bars.map((bar, i) => (
        <circle key={i} cx={bar.x} cy={bar.y} r={barR}
          fill="var(--charcoal)" />
      ))}

      {/* 4. Dimension: width (below) */}
      <DimensionLine x1={secLeft} y1={secBot + 20} x2={secRight} y2={secBot + 20}
        label={`${w} ${unit}`} offset={12} fontSize={9} />

      {/* 5. Dimension: height (right side) — only if rectangular */}
      {w !== colH && (
        <DimensionLine x1={secRight + 20} y1={secBot} x2={secRight + 20} y2={secTop}
          label={`${colH} ${unit}`} offset={22} fontSize={9} />
      )}

      {/* 6. Bar count label */}
      <Label x={cx} y={secBot + 50} fontSize={8} color="var(--gray-500)">
        {numBars} bars
      </Label>
    </svg>
  );
}

function renderCircular({ W, HH, cx, cy, diameter, numBars, unit }) {
  const scale = 150 / diameter;
  const r = (diameter * scale) / 2;

  // Spiral/tie inset
  const tieInset = 10;
  const tieR = r - tieInset;

  // Bar positions around circle
  const barR = 5;
  const barCircleR = tieR - barR - 2;
  const bars = Array.from({ length: numBars }, (_, i) => {
    const angle = (i / numBars) * 2 * Math.PI - Math.PI / 2;
    return {
      x: cx + barCircleR * Math.cos(angle),
      y: cy + barCircleR * Math.sin(angle),
    };
  });

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`RC circular column, diameter ${diameter} ${unit}, ${numBars} bars`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Concrete circle */}
      <circle cx={cx} cy={cy} r={r}
        fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* 2. Spiral/tie (dashed circle) */}
      <circle cx={cx} cy={cy} r={tieR}
        fill="none" stroke="var(--gray-400)" strokeWidth={1.5}
        strokeDasharray="4,3" />

      {/* 3. Longitudinal bars */}
      {bars.map((bar, i) => (
        <circle key={i} cx={bar.x} cy={bar.y} r={barR}
          fill="var(--charcoal)" />
      ))}

      {/* 4. Diameter dimension */}
      <DimensionLine x1={cx - r} y1={cy + r + 20} x2={cx + r} y2={cy + r + 20}
        label={`${diameter} ${unit} dia.`} offset={12} fontSize={9} />

      {/* 5. Bar count label */}
      <Label x={cx} y={cy + r + 50} fontSize={8} color="var(--gray-500)">
        {numBars} bars
      </Label>
    </svg>
  );
}

/**
 * Distribute numBars around the perimeter of a rectangle.
 * Corners always get bars, then remaining bars are distributed along edges.
 */
function distributeRectBars(x, y, w, h, numBars) {
  if (numBars <= 0) return [];
  if (numBars <= 4) {
    // Corners only
    return [
      { x, y },
      { x: x + w, y },
      { x: x + w, y: y + h },
      { x, y: y + h },
    ].slice(0, numBars);
  }

  const bars = [];
  // 4 corners
  bars.push({ x, y });
  bars.push({ x: x + w, y });
  bars.push({ x: x + w, y: y + h });
  bars.push({ x, y: y + h });

  const remaining = numBars - 4;
  // Distribute remaining along edges (prioritize long edges for rectangular)
  const perimeter = 2 * (w + h);
  const wBars = Math.round((w / perimeter) * remaining);
  const hBars = Math.round((h / perimeter) * remaining);

  // Adjust to match total
  let wCount = wBars;
  let hCount = remaining - 2 * wBars;
  if (hCount < 0) { hCount = 0; wCount = Math.floor(remaining / 2); }

  // Top and bottom edges
  for (let i = 1; i <= wCount; i++) {
    const frac = i / (wCount + 1);
    bars.push({ x: x + w * frac, y }); // top
    bars.push({ x: x + w * frac, y: y + h }); // bottom
  }

  // Left and right edges
  for (let i = 1; i <= hCount; i++) {
    const frac = i / (hCount + 1);
    bars.push({ x, y: y + h * frac }); // left
    bars.push({ x: x + w, y: y + h * frac }); // right
  }

  return bars.slice(0, numBars);
}

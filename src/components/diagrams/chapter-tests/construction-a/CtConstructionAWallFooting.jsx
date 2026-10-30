import React from 'react';

/**
 * Cross section of a cast-in-place wall centered on a continuous footing.
 * Drawn to scale. Shows: footing width and thickness, wall thickness and height.
 * Does NOT show: any volume.
 */
export function CtConstructionAWallFooting({
  footingWidthIn = 30, footingThickIn = 12, wallThickIn = 10, wallHeightIn = 60,
}) {
  const s = 3.4; // px per inch
  const fw = footingWidthIn * s; const ft = footingThickIn * s;
  const ww = wallThickIn * s; const wh = wallHeightIn * s;
  const left = 70; const top = 40;
  const cx = left + fw / 2;
  const fTop = top + wh;
  const fBot = fTop + ft;
  const ftin = (inch) => {
    const f = Math.floor(inch / 12); const i = inch - f * 12;
    return f ? `${f} ft ${i} in` : `${i} in`;
  };
  const dimC = 'var(--gray-500)';
  const tick = (x, y) => <line x1={x - 4} y1={y + 4} x2={x + 4} y2={y - 4} stroke={dimC} strokeWidth={1.2} />;
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle', fill: 'var(--charcoal)', fontSize: 12 };
  const rx = left + fw + 26; // right dimension line x
  const W = rx + 70;
  const H = fBot + 52;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Section through a concrete wall on a continuous footing with its dimensions"
      style={{ width: '100%', height: 'auto' }}>
      {/* Concrete */}
      <path d={`M ${cx - ww / 2} ${top} H ${cx + ww / 2} V ${fTop} H ${left + fw} V ${fBot} H ${left} V ${fTop} H ${cx - ww / 2} Z`}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      {/* Soil under footing */}
      {Array.from({ length: 11 }, (_, i) => (
        <line key={i} x1={left - 16 + i * 12} y1={fBot} x2={left - 24 + i * 12} y2={fBot + 8} stroke="var(--gray-400)" strokeWidth={1} />
      ))}
      <line x1={left - 20} y1={fBot} x2={left + fw + 14} y2={fBot} stroke="var(--charcoal)" strokeWidth={1} />

      {/* Wall thickness (top) */}
      <line x1={cx - ww / 2} y1={top - 4} x2={cx - ww / 2} y2={top - 22} stroke={dimC} strokeWidth={0.8} />
      <line x1={cx + ww / 2} y1={top - 4} x2={cx + ww / 2} y2={top - 22} stroke={dimC} strokeWidth={0.8} />
      <line x1={cx - ww / 2 - 14} y1={top - 16} x2={cx + ww / 2 + 14} y2={top - 16} stroke={dimC} strokeWidth={1} />
      {tick(cx - ww / 2, top - 16)}{tick(cx + ww / 2, top - 16)}
      <text x={cx + ww / 2 + 20} y={top - 16} {...font} textAnchor="start">{ftin(wallThickIn)}</text>

      {/* Wall height and footing thickness (right) */}
      <line x1={cx + ww / 2 + 4} y1={top} x2={rx + 6} y2={top} stroke={dimC} strokeWidth={0.8} />
      <line x1={left + fw + 4} y1={fTop} x2={rx + 6} y2={fTop} stroke={dimC} strokeWidth={0.8} />
      <line x1={left + fw + 4} y1={fBot} x2={rx + 6} y2={fBot} stroke={dimC} strokeWidth={0.8} />
      <line x1={rx} y1={top} x2={rx} y2={fBot} stroke={dimC} strokeWidth={1} />
      {tick(rx, top)}{tick(rx, fTop)}{tick(rx, fBot)}
      <text x={rx + 8} y={top + wh / 2} {...font} textAnchor="start">{ftin(wallHeightIn)}</text>
      <text x={rx + 8} y={fTop + ft / 2} {...font} textAnchor="start">{ftin(footingThickIn)}</text>

      {/* Footing width (bottom) */}
      <line x1={left} y1={fBot + 12} x2={left} y2={fBot + 30} stroke={dimC} strokeWidth={0.8} />
      <line x1={left + fw} y1={fBot + 12} x2={left + fw} y2={fBot + 30} stroke={dimC} strokeWidth={0.8} />
      <line x1={left} y1={fBot + 24} x2={left + fw} y2={fBot + 24} stroke={dimC} strokeWidth={1} />
      {tick(left, fBot + 24)}{tick(left + fw, fBot + 24)}
      <text x={cx} y={fBot + 40} {...font} textAnchor="middle">{ftin(footingWidthIn)}</text>

      {/* Callouts */}
      <text x={cx - ww / 2 - 10} y={top + wh * 0.4} {...font} textAnchor="end">wall</text>
      <text x={left - 8} y={fTop + ft / 2} {...font} textAnchor="end">footing</text>
    </svg>
  );
}

import React from 'react';

/**
 * Cross section of a vertical-wall pipe trench, drawn to scale: bedding layer,
 * pipe resting on it, backfill to the ground surface.
 * Shows: trench width, total depth (ground to trench bottom), bedding depth, pipe outside diameter.
 * Does NOT show: any volume.
 */
export function CtConstructionBTrenchSection({
  widthFt = 5, depthFt = 9, beddingIn = 6, pipeOdFt = 3, pipeLabel = '30 in. RCP',
}) {
  const s = 22; // px per ft
  const tw = widthFt * s; const td = depthFt * s; const bd = (beddingIn / 12) * s;
  const r = (pipeOdFt / 2) * s;
  const x0 = 120; const y0 = 46; // trench top-left
  const xR = x0 + tw; const yB = y0 + td;
  const cx = x0 + tw / 2; const cy = yB - bd - r;
  const dimC = 'var(--gray-500)';
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle', fontSize: 12 };
  const tick = (x, y) => <line x1={x - 4} y1={y + 4} x2={x + 4} y2={y - 4} stroke={dimC} strokeWidth={1.2} />;
  const groundL = x0 - 70; const groundR = xR + 30;
  const rx = xR + 46;
  const ox = rx + 44; // outer dimension line for the full depth
  const W = ox + 54;
  const H = yB + 22;
  const stones = [];
  for (let i = 0; i < Math.floor(tw / 9); i += 1) {
    for (let j = 0; j < 2; j += 1) {
      const sx = x0 + 6 + i * 9 + (j % 2) * 4;
      const sy = yB - bd * (0.3 + 0.4 * j);
      if (Math.abs(sx - cx) < r * 0.55 && j === 1) continue;
      stones.push(<circle key={`${i}-${j}`} cx={sx} cy={sy} r={2} fill="none" stroke="var(--gray-500)" strokeWidth={0.9} />);
    }
  }
  const hatch = (xa, xb, y) => Array.from({ length: Math.floor((xb - xa) / 10) }, (_, i) => (
    <line key={`${xa}-${i}`} x1={xa + i * 10 + 8} y1={y} x2={xa + i * 10} y2={y + 8} stroke="var(--gray-400)" strokeWidth={1} />
  ));
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Cross section of a pipe trench with bedding, pipe and backfill"
      style={{ width: '100%', height: 'auto' }}>
      {/* Backfill zone */}
      <rect x={x0} y={y0} width={tw} height={td - bd} fill="var(--cream-dark)" />
      {/* Ground surface and trench walls */}
      <path d={`M ${groundL} ${y0} H ${x0} V ${yB} H ${xR} V ${y0} H ${groundR}`} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      {hatch(groundL, x0 - 2, y0)}
      {hatch(xR + 2, groundR, y0)}
      {/* Bedding */}
      <line x1={x0} y1={yB - bd} x2={xR} y2={yB - bd} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="4,3" />
      {stones}
      {/* Pipe */}
      <circle cx={cx} cy={cy} r={r} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={cx} cy={cy} r={r - 5} fill="none" stroke="var(--charcoal)" strokeWidth={1} />
      {/* Labels (left) */}
      <line x1={x0 + 10} y1={y0 + (cy - r - y0) * 0.45} x2={x0 - 8} y2={y0 + (cy - r - y0) * 0.45} stroke="var(--charcoal)" strokeWidth={1} />
      <text x={x0 - 12} y={y0 + (cy - r - y0) * 0.45} {...font} fill="var(--charcoal)" textAnchor="end">backfill</text>
      <line x1={cx - r * 0.94} y1={cy + r * 0.34} x2={x0 - 8} y2={cy + r * 0.34} stroke="var(--charcoal)" strokeWidth={1} />
      <text x={x0 - 12} y={cy + r * 0.35 - 8} {...font} fill="var(--charcoal)" textAnchor="end">{pipeLabel}</text>
      <text x={x0 - 12} y={cy + r * 0.35 + 8} {...font} fill="var(--charcoal)" textAnchor="end">{`OD ${pipeOdFt.toFixed(1)} ft`}</text>
      <line x1={x0 + 6} y1={yB - bd / 2} x2={x0 - 8} y2={yB - bd / 2} stroke="var(--charcoal)" strokeWidth={1} />
      <text x={x0 - 12} y={yB - bd / 2} {...font} fill="var(--charcoal)" textAnchor="end">stone bedding</text>

      {/* Width (top) */}
      <line x1={x0} y1={y0 - 4} x2={x0} y2={y0 - 28} stroke={dimC} strokeWidth={0.8} />
      <line x1={xR} y1={y0 - 4} x2={xR} y2={y0 - 28} stroke={dimC} strokeWidth={0.8} />
      <line x1={x0} y1={y0 - 20} x2={xR} y2={y0 - 20} stroke={dimC} strokeWidth={1} />
      {tick(x0, y0 - 20)}{tick(xR, y0 - 20)}
      <rect x={cx - 22} y={y0 - 28} width={44} height={16} fill="#fff" />
      <text x={cx} y={y0 - 20} {...font} fill="var(--charcoal)" textAnchor="middle">{`${widthFt} ft`}</text>

      {/* Depth (outer line, ground to trench bottom) and bedding (inner line) */}
      <line x1={xR + 6} y1={yB} x2={ox + 6} y2={yB} stroke={dimC} strokeWidth={0.8} />
      <line x1={xR + 6} y1={yB - bd} x2={rx + 6} y2={yB - bd} stroke={dimC} strokeWidth={0.8} />
      <line x1={groundR + 4} y1={y0} x2={ox + 6} y2={y0} stroke={dimC} strokeWidth={0.8} />
      <line x1={rx} y1={yB - bd} x2={rx} y2={yB} stroke={dimC} strokeWidth={1} />
      {tick(rx, yB - bd)}{tick(rx, yB)}
      <text x={rx + 12} y={yB - bd / 2} {...font} fill="var(--charcoal)" textAnchor="start">{`${beddingIn} in.`}</text>
      <line x1={ox} y1={y0} x2={ox} y2={yB} stroke={dimC} strokeWidth={1} />
      {tick(ox, y0)}{tick(ox, yB)}
      <text x={ox + 8} y={y0 + td / 2} {...font} fill="var(--charcoal)" textAnchor="start">{`${depthFt} ft`}</text>
    </svg>
  );
}

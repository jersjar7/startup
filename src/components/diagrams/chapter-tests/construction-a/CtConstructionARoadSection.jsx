import React from 'react';

/**
 * Half typical section of a two-lane road from the centerline to the ditch.
 * Horizontal to scale; vertical exaggerated (noted on the drawing).
 * Shows: centerline elevation, widths, cross slopes, foreslope ratio, point D.
 * Does NOT show: any other elevation.
 */
export function CtConstructionARoadSection({
  clElev = 482.6, lane = 12, laneSlope = 2.0, shoulder = 8, shoulderSlope = 4.0, foreslopeH = 10, foreslopeRatio = 4,
}) {
  const sx = 11; const sy = 30;
  const x0 = 34; const y0 = 76;
  const p1 = { x: x0 + lane * sx, y: y0 + lane * laneSlope / 100 * sy };
  const p2 = { x: p1.x + shoulder * sx, y: p1.y + shoulder * shoulderSlope / 100 * sy };
  const drop = foreslopeH / foreslopeRatio;
  const p3 = { x: p2.x + foreslopeH * sx, y: p2.y + drop * sy };
  const p4 = { x: p3.x + 6 * sx, y: p3.y - 2 * sy }; // 3H:1V backslope, context only
  const dimY = p3.y + 26;
  const W = p4.x + 16;
  const H = dimY + 42;
  const dimC = 'var(--gray-500)';
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle', fontSize: 12 };
  const tick = (x, y) => <line key={`t${x}`} x1={x - 4} y1={y + 4} x2={x + 4} y2={y - 4} stroke={dimC} strokeWidth={1.2} />;
  const mid = (a, b) => ({ x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 });
  const m1 = mid({ x: x0, y: y0 }, p1); const m2 = mid(p1, p2); const m3 = mid(p2, p3);
  const fmt = (v) => v.toFixed(1);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Half road section: centerline elevation ${clElev} ft, ${lane} ft lane at ${laneSlope} percent, ${shoulder} ft shoulder at ${shoulderSlope} percent, ${foreslopeRatio}H:1V foreslope ${foreslopeH} ft wide to point D`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctConARoadArrow" markerWidth={7} markerHeight={7} refX={6.5} refY={3.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 7,3.5 L 0,7 Z" fill="var(--charcoal)" />
        </marker>
      </defs>
      {/* Centerline */}
      <line x1={x0} y1={y0 - 50} x2={x0} y2={dimY + 6} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="10,3,2,3" />
      <text x={x0 + 6} y={y0 - 56} fill="var(--charcoal)" {...font} textAnchor="start">
        <tspan fontWeight={700}>CL</tspan>{`  EL ${clElev.toFixed(2)} ft`}</text>

      {/* Surface: lane (pavement), shoulder, foreslope, backslope */}
      <line x1={x0} y1={y0} x2={p1.x} y2={p1.y} stroke="var(--charcoal)" strokeWidth={4} strokeLinecap="round" />
      <line x1={p1.x} y1={p1.y} x2={p2.x} y2={p2.y} stroke="var(--charcoal)" strokeWidth={2.4} />
      <polyline points={`${p2.x},${p2.y} ${p3.x},${p3.y} ${p4.x},${p4.y}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.8} strokeLinejoin="round" />
      {[p1, p2].map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={2.6} fill="var(--charcoal)" />)}
      <circle cx={p3.x} cy={p3.y} r={3.4} fill="var(--ember)" />
      <text x={p3.x} y={p3.y + 14} fill="var(--ember)" {...font} fontWeight={700} textAnchor="middle">D</text>

      {/* Slope callouts with down-slope arrows */}
      {[[m1, `${fmt(laneSlope)}%`, 'lane'], [m2, `${fmt(shoulderSlope)}%`, 'shoulder']].map(([m, t, name]) => (
        <g key={name}>
          <text x={m.x} y={m.y - 30} fill="var(--charcoal)" {...font} textAnchor="middle">{name}</text>
          <text x={m.x - 4} y={m.y - 15} fill="var(--charcoal)" {...font} fontWeight={600} textAnchor="end">{t}</text>
          <line x1={m.x + 2} y1={m.y - 15} x2={m.x + 30} y2={m.y - 15} stroke="var(--charcoal)" strokeWidth={1.2} markerEnd="url(#ctConARoadArrow)" />
        </g>
      ))}
      <text x={m3.x + 12} y={m3.y - 10} fill="var(--charcoal)" {...font} fontWeight={600} textAnchor="start">{`${foreslopeRatio}H:1V`}</text>

      {/* Horizontal dimensions */}
      {[[x0, p1.x, `${lane} ft`], [p1.x, p2.x, `${shoulder} ft`], [p2.x, p3.x, `${foreslopeH} ft`]].map(([a, b, t]) => (
        <g key={t}>
          <line x1={a} y1={dimY} x2={b} y2={dimY} stroke={dimC} strokeWidth={1} />
          {tick(a, dimY)}{tick(b, dimY)}
          <text x={(a + b) / 2} y={dimY + 13} fill="var(--charcoal)" {...font} textAnchor="middle">{t}</text>
        </g>
      ))}
      {[p1, p2, p3].map((p, i) => (
        <line key={i} x1={p.x} y1={p.y + (i === 2 ? 22 : 6)} x2={p.x} y2={dimY + 6} stroke={dimC} strokeWidth={0.8} />
      ))}
      <text x={x0} y={dimY + 32} fill="var(--gray-500)" {...font} fontSize={11} textAnchor="start">Vertical scale exaggerated</text>
    </svg>
  );
}

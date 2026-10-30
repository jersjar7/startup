import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Square reinforced concrete pier section with eight longitudinal bars
// (corners and mid-sides).
export function CtMechanicsMaterialsBPierSection({ b = 16, bars = '8 #9 bars', cover = 2.5 }) {
  const ppi = 10;
  const x0 = 68;
  const y0 = 24;
  const s = b * ppi;
  const c = cover * ppi;
  const xs = [x0 + c, x0 + s / 2, x0 + s - c];
  const ys = [y0 + c, y0 + s / 2, y0 + s - c];
  const pts = [];
  xs.forEach((x, i) => ys.forEach((y, j) => { if (!(i === 1 && j === 1)) pts.push([x, y]); }));
  const tag = pts.find((p) => p[0] === xs[2] && p[1] === ys[0]);

  return (
    <svg viewBox="0 0 330 228" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Square concrete pier section ${b} in. by ${b} in. with ${bars}`}
      style={{ width: '100%', height: 'auto' }}>
      <rect x={x0} y={y0} width={s} height={s} rx={2} fill="var(--gray-400)" fillOpacity={0.2} stroke="var(--charcoal)" strokeWidth={2} />
      {pts.map((p, i) => <circle key={i} cx={p[0]} cy={p[1]} r={5.6} fill="var(--charcoal)" />)}
      {/* Bar callout */}
      <line x1={tag[0] + 5} y1={tag[1] - 4} x2={x0 + s + 26} y2={y0 + 6} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={x0 + s + 30} y={y0 + 4} anchor="start" color="var(--charcoal)">{bars}</Label>
      {/* Dimensions */}
      <line x1={x0} y1={y0 + s + 4} x2={x0} y2={y0 + s + 28} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={x0 + s} y1={y0 + s + 4} x2={x0 + s} y2={y0 + s + 28} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={x0} y1={y0 + s + 22} x2={x0 + s} y2={y0 + s + 22} label={`${b} in.`} offset={13} fontSize={12} />
      <line x1={x0 - 4} y1={y0} x2={x0 - 28} y2={y0} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={x0 - 4} y1={y0 + s} x2={x0 - 28} y2={y0 + s} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={x0 - 22} y1={y0} x2={x0 - 22} y2={y0 + s} label={`${b} in.`} offset={22} fontSize={12} />
    </svg>
  );
}

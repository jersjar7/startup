import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan view: a straight fence with perpendicular offsets taped at equal
 * intervals to the bank of a creek. Same scale both ways. Offsets and the
 * interval come from props.
 */
export function CtSurveyingBCreekOffsets({ w = 30, offsets = [12.5, 30.8, 26.4, 34.6, 28.1, 21.7, 7.9] }) {
  const n = offsets.length;
  const s = 340 / (w * (n - 1)) * 0.92;
  const ox = 30;
  const maxH = Math.max(...offsets);
  const top = 24;
  const fy = top + maxH * s + 8; // fence line
  const xs = offsets.map((_, i) => ox + i * w * s);
  const pts = offsets.map((h, i) => ({ x: xs[i], y: fy - h * s }));
  // Catmull-Rom through the offset ends, extended a little past each end
  const first = { x: pts[0].x - 18, y: pts[0].y + (pts[0].y - pts[1].y) * 0.3 };
  const last = { x: pts[n - 1].x + 18, y: pts[n - 1].y + (pts[n - 1].y - pts[n - 2].y) * 0.3 };
  const all = [first, ...pts, last];
  let d = `M ${all[0].x},${all[0].y}`;
  for (let i = 0; i < all.length - 1; i++) {
    const p0 = all[Math.max(i - 1, 0)];
    const p1 = all[i];
    const p2 = all[i + 1];
    const p3 = all[Math.min(i + 2, all.length - 1)];
    d += ` C ${p1.x + (p2.x - p0.x) / 6},${p1.y + (p2.y - p0.y) / 6} ${p2.x - (p3.x - p1.x) / 6},${p2.y - (p3.y - p1.y) / 6} ${p2.x},${p2.y}`;
  }
  const dimY = fy + 22;
  const W = Math.ceil(xs[n - 1] + 64);
  const H = Math.ceil(dimY + 24);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Offsets at ${w} ft intervals from a fence to a creek bank: ${offsets.join(', ')} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {/* area between fence and creek, only between the first and last offsets */}
      <defs>
        <clipPath id="ctSurvBCreekArea"><rect x={xs[0]} y={0} width={xs[n - 1] - xs[0]} height={fy} /></clipPath>
      </defs>
      <path d={`${d} L ${last.x},${fy} L ${first.x},${fy} Z`} fill="var(--cream-dark)" stroke="none" clipPath="url(#ctSurvBCreekArea)" />
      {/* creek bank */}
      <path d={d} fill="none" stroke="var(--info)" strokeWidth={2.2} />
      <Label x={xs[0] - 8} y={pts[1].y - 12} anchor="start" color="var(--info)" fontSize={12}>Creek bank</Label>
      {/* fence with posts */}
      <line x1={first.x} y1={fy} x2={last.x} y2={fy} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: Math.floor((last.x - first.x) / 14) + 1 }, (_, i) => first.x + i * 14).map((x, i) => (
        <g key={i}>
          <line x1={x - 3} y1={fy - 3} x2={x + 3} y2={fy + 3} stroke="var(--charcoal)" strokeWidth={1} />
          <line x1={x - 3} y1={fy + 3} x2={x + 3} y2={fy - 3} stroke="var(--charcoal)" strokeWidth={1} />
        </g>
      ))}
      <Label x={last.x + 6} y={fy} anchor="start" color="var(--charcoal)" fontSize={12}>Fence</Label>
      {/* offsets */}
      {pts.map((p, i) => (
        <g key={i}>
          <line x1={p.x} y1={fy} x2={p.x} y2={p.y} stroke="var(--gray-500)" strokeWidth={1.2} />
          <circle cx={p.x} cy={p.y} r={2.4} fill="var(--charcoal)" />
          {offsets[i] * s >= 18
            ? <Label x={p.x + 5} y={(fy + p.y) / 2} anchor="start" color="var(--charcoal)" fontSize={11}>{offsets[i].toFixed(1)}</Label>
            : <Label x={p.x + 6} y={p.y - 11} anchor="start" color="var(--charcoal)" fontSize={11}>{offsets[i].toFixed(1)}</Label>}
        </g>
      ))}
      {/* interval dimensions */}
      <line x1={xs[0]} y1={dimY} x2={xs[n - 1]} y2={dimY} stroke="var(--gray-500)" strokeWidth={1} />
      {xs.map((x, i) => <line key={i} x1={x} y1={dimY - 5} x2={x} y2={dimY + 5} stroke="var(--gray-500)" strokeWidth={1} />)}
      {xs.slice(0, -1).map((x, i) => <Label key={i} x={x + (w * s) / 2} y={dimY + 13} color="var(--gray-500)" fontSize={11}>{`${w} ft`}</Label>)}
      <Label x={W - 8} y={top - 6} anchor="end" color="var(--gray-500)" fontSize={11}>Offsets in ft</Label>
    </svg>
  );
}

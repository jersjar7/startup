import React from 'react';
import { Label } from '../../primitives';

/**
 * Five-sided parcel in plan, to scale, with a north arrow and a
 * coordinate table (E, N in ft). Corner letters sit outside the boundary.
 */
export function CtSurveyingAParcelCoords({ points = [] }) {
  const es = points.map((p) => p.e);
  const ns = points.map((p) => p.n);
  const eMin = Math.min(...es);
  const nMax = Math.max(...ns);
  const span = Math.max(Math.max(...es) - eMin, nMax - Math.min(...ns));
  const s = 196 / span;
  const ox = 46;
  const oy = 26;
  const P = (p) => ({ x: ox + (p.e - eMin) * s, y: oy + (nMax - p.n) * s });
  const pts = points.map(P);
  const cx = pts.reduce((a, p) => a + p.x, 0) / pts.length;
  const cy = pts.reduce((a, p) => a + p.y, 0) / pts.length;
  const fmt = (v) => v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

  const tx = 286; // table left
  const colE = 376;
  const colN = 452;
  const row0 = 40;
  const rowH = 22;
  const W = 466;
  const H = Math.max(oy + 196 + 26, row0 + rowH * (points.length + 1) + 10);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Five-sided parcel with corner coordinates in a table"
      style={{ width: '100%', height: 'auto' }}>
      <polygon points={pts.map((p) => `${p.x},${p.y}`).join(' ')}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      {pts.map((p, i) => {
        const dx = p.x - cx;
        const dy = p.y - cy;
        const L = Math.hypot(dx, dy) || 1;
        return (
          <g key={i}>
            <circle cx={p.x} cy={p.y} r={3} fill="var(--charcoal)" />
            <Label x={p.x + (dx / L) * 15} y={p.y + (dy / L) * 15} color="var(--charcoal)" fontSize={13} bold>
              {points[i].name}
            </Label>
          </g>
        );
      })}

      {/* north arrow */}
      <g>
        <line x1={20} y1={70} x2={20} y2={32} stroke="var(--charcoal)" strokeWidth={1.5} />
        <path d="M 20,24 L 15,36 L 20,33 L 25,36 Z" fill="var(--charcoal)" />
        <Label x={20} y={14} color="var(--charcoal)" fontSize={12} bold>N</Label>
      </g>

      {/* coordinate table */}
      <g fontFamily="var(--font-mono)">
        <text x={tx} y={row0} fontSize={12} fontWeight={600} fill="var(--charcoal)" fontFamily="var(--font-body)">Point</text>
        <text x={colE} y={row0} fontSize={12} fontWeight={600} fill="var(--charcoal)" textAnchor="end" fontFamily="var(--font-body)">E (ft)</text>
        <text x={colN} y={row0} fontSize={12} fontWeight={600} fill="var(--charcoal)" textAnchor="end" fontFamily="var(--font-body)">N (ft)</text>
        <line x1={tx} y1={row0 + 7} x2={colN} y2={row0 + 7} stroke="var(--gray-400)" strokeWidth={1} />
        {points.map((p, i) => (
          <g key={i}>
            <text x={tx + 14} y={row0 + rowH * (i + 1)} fontSize={12} fill="var(--charcoal)" fontWeight={600} fontFamily="var(--font-body)">{p.name}</text>
            <text x={colE} y={row0 + rowH * (i + 1)} fontSize={12} fill="var(--charcoal)" textAnchor="end">{fmt(p.e)}</text>
            <text x={colN} y={row0 + rowH * (i + 1)} fontSize={12} fill="var(--charcoal)" textAnchor="end">{fmt(p.n)}</text>
          </g>
        ))}
      </g>
    </svg>
  );
}

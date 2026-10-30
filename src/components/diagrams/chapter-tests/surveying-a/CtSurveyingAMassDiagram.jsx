import React from 'react';
import { Label } from '../../primitives';

/**
 * Mass haul diagram: cumulative ordinate (yd3) against station.
 * Ordinate values are written at each plotted station.
 */
export function CtSurveyingAMassDiagram({ points = [] }) {
  const x0 = 64;
  const plotW = 340;
  const top = 18;
  const plotH = 190;
  const staMax = Math.max(...points.map((p) => p.sta));
  const mMax = 5000;
  const mMin = -4000;
  const X = (sta) => x0 + (sta / staMax) * plotW;
  const Y = (m) => top + ((mMax - m) / (mMax - mMin)) * plotH;
  const grid = [-4000, -2000, 0, 2000, 4000];
  const W = x0 + plotW + 50;
  const bottom = top + plotH;
  const H = bottom + 44;
  const fmt = (m) => (m > 0 ? '+' : m < 0 ? '−' : '') + Math.abs(m).toLocaleString('en-US');

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Mass haul diagram, ordinate in cubic yards against station"
      style={{ width: '100%', height: 'auto' }}>
      {/* frame and grid */}
      <rect x={x0} y={top} width={plotW} height={plotH} fill="none" stroke="var(--gray-400)" strokeWidth={1} />
      {grid.map((g) => (
        <g key={g}>
          <line x1={x0} y1={Y(g)} x2={x0 + plotW} y2={Y(g)}
            stroke={g === 0 ? 'var(--charcoal)' : 'var(--gray-400)'} strokeWidth={g === 0 ? 1.3 : 0.8}
            strokeDasharray={g === 0 ? undefined : '3,4'} />
          <Label x={x0 - 7} y={Y(g)} anchor="end" color="var(--gray-500)" fontSize={11}>{g.toLocaleString('en-US').replace('-', '−')}</Label>
        </g>
      ))}
      {points.map((p) => (
        <g key={p.label}>
          {p.sta > 0 && p.sta < staMax && (
            <line x1={X(p.sta)} y1={top} x2={X(p.sta)} y2={bottom} stroke="var(--gray-400)" strokeWidth={0.8} strokeDasharray="3,4" />
          )}
          <Label x={X(p.sta)} y={bottom + 13} color="var(--gray-500)" fontSize={11}>{p.label}</Label>
        </g>
      ))}

      {/* mass curve */}
      <polyline points={points.map((p) => `${X(p.sta)},${Y(p.m)}`).join(' ')}
        fill="none" stroke="var(--ember)" strokeWidth={2.2} strokeLinejoin="round" />
      {points.map((p, i) => {
        const prev = points[i - 1];
        const next = points[i + 1];
        const isPeak = (!prev || p.m >= prev.m) && (!next || p.m >= next.m);
        const isLow = (!prev || p.m <= prev.m) && (!next || p.m <= next.m);
        let dx = 0;
        let dy = -12;
        let anchor = 'middle';
        if (isLow && !isPeak) dy = 14;
        else if (!isPeak && !isLow) {
          // on a slope: put the label on the open side
          const rising = next ? next.m > p.m : p.m > prev.m;
          dx = rising ? -8 : 8;
          anchor = rising ? 'end' : 'start';
          dy = -8;
        }
        if (!next) { dx = 8; anchor = 'start'; dy = 0; }
        if (p.m === 0 && i === 0) return <circle key={p.label} cx={X(p.sta)} cy={Y(p.m)} r={3} fill="var(--ember)" />;
        return (
          <g key={p.label}>
            <circle cx={X(p.sta)} cy={Y(p.m)} r={3} fill="var(--ember)" />
            <Label x={X(p.sta) + dx} y={Y(p.m) + dy} anchor={anchor} color="var(--charcoal)" fontSize={12}>{fmt(p.m)}</Label>
          </g>
        );
      })}

      <Label x={x0 + plotW / 2} y={bottom + 32} color="var(--gray-500)" fontSize={12}>Station</Label>
      <Label x={14} y={top + plotH / 2} color="var(--gray-500)" fontSize={12} rotate={-90}>Mass ordinate (yd³)</Label>
    </svg>
  );
}

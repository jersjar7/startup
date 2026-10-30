import React from 'react';
import { Label } from '../../primitives';

/**
 * 1-hour unit hydrograph: discharge per inch of rainfall excess at hourly
 * points, joined by straight lines, each ordinate labelled.
 * Shows: the ordinates (cfs per in.) at t = 0, 1, 2 ... hr on a gridded axis.
 * Does NOT show: the storm, the lagged copies or the direct runoff peak.
 */
export function CtWaterResourcesBUnitHydrograph({ ordinates = [0, 80, 240, 180, 100, 40, 0], yMax = 300, step = 50 }) {
  const left = 62;
  const top = 14;
  const plotW = 324;
  const plotH = 190;
  const bottom = top + plotH;
  const n = ordinates.length - 1;
  const dx = plotW / n;
  const X = (i) => left + i * dx;
  const Y = (v) => bottom - (v / yMax) * plotH;
  const ticks = [];
  for (let v = 0; v <= yMax + 1e-9; v += step) ticks.push(v);
  const pts = ordinates.map((q, i) => `${X(i)},${Y(q)}`).join(' ');
  const peak = Math.max(...ordinates);

  return (
    <svg viewBox={`0 0 ${left + plotW + 14} ${bottom + 46}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`1-hour unit hydrograph with ordinates ${ordinates.join(', ')} cfs per inch at hourly intervals`}
      style={{ width: '100%', height: 'auto' }}>
      {ticks.map((v) => (
        <g key={v}>
          <line x1={left} y1={Y(v)} x2={left + plotW} y2={Y(v)} stroke="var(--gray-400)" strokeOpacity={v === 0 ? 1 : 0.4} strokeWidth={1} />
          <Label x={left - 8} y={Y(v)} color="var(--gray-500)" fontSize={11} anchor="end">{v}</Label>
        </g>
      ))}
      {Array.from({ length: n + 1 }, (_, i) => (
        <line key={i} x1={X(i)} y1={top} x2={X(i)} y2={bottom} stroke="var(--gray-400)" strokeOpacity={0.25} strokeWidth={1} />
      ))}
      <Label x={14} y={(top + bottom) / 2} color="var(--charcoal)" fontSize={12} rotate={-90}>U (cfs per in. of excess)</Label>

      <polygon points={`${X(0)},${bottom} ${pts} ${X(n)},${bottom}`} fill="var(--info)" fillOpacity={0.12} />
      <polyline points={pts} fill="none" stroke="var(--info)" strokeWidth={2.2} strokeLinejoin="round" />
      {ordinates.map((q, i) => (q > 0 ? (
        <g key={i}>
          <circle cx={X(i)} cy={Y(q)} r={3.5} fill="var(--info)" />
          <Label
            x={X(i) + (q === peak ? 0 : (ordinates[i + 1] ?? 0) > q ? -10 : 10)}
            y={Y(q) - 12}
            color="var(--charcoal)" fontSize={12} bold
            anchor={q === peak ? 'middle' : (ordinates[i + 1] ?? 0) > q ? 'end' : 'start'}
          >
            {q}
          </Label>
        </g>
      ) : null))}

      <line x1={left} y1={bottom} x2={left + plotW} y2={bottom} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={left} y1={top} x2={left} y2={bottom} stroke="var(--charcoal)" strokeWidth={1.5} />
      {Array.from({ length: n + 1 }, (_, i) => (
        <g key={i}>
          <line x1={X(i)} y1={bottom} x2={X(i)} y2={bottom + 5} stroke="var(--charcoal)" strokeWidth={1} />
          <Label x={X(i)} y={bottom + 16} color="var(--gray-500)" fontSize={11}>{i}</Label>
        </g>
      ))}
      <Label x={left + plotW / 2} y={bottom + 35} color="var(--charcoal)" fontSize={12}>Time (hr)</Label>
    </svg>
  );
}

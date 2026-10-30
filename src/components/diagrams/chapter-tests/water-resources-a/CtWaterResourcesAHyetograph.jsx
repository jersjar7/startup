import React from 'react';
import { Label } from '../../primitives';

/**
 * Storm hyetograph: rainfall depth in each hour of a storm, as bars.
 * Shows: hourly rainfall depths (in.), labelled on each bar, with a gridded
 * depth axis.
 * Does NOT show: the phi-index, the excess rainfall or the runoff depth.
 */
export function CtWaterResourcesAHyetograph({ depths = [0.4, 1.1, 1.6, 0.9, 0.3], yMax = 2.0, step = 0.5 }) {
  const left = 58;
  const top = 16;
  const plotW = 330;
  const plotH = 180;
  const bottom = top + plotH;
  const n = depths.length;
  const bw = plotW / n;
  const y = (v) => bottom - (v / yMax) * plotH;
  const ticks = [];
  for (let v = 0; v <= yMax + 1e-9; v += step) ticks.push(Math.round(v * 100) / 100);

  return (
    <svg viewBox={`0 0 ${left + plotW + 16} ${bottom + 48}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Hyetograph with hourly rainfall depths ${depths.join(', ')} in.`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Grid and depth axis */}
      {ticks.map((v) => (
        <g key={v}>
          <line x1={left} y1={y(v)} x2={left + plotW} y2={y(v)} stroke="var(--gray-400)" strokeOpacity={v === 0 ? 1 : 0.45} strokeWidth={1} />
          <Label x={left - 8} y={y(v)} color="var(--gray-500)" fontSize={11} anchor="end">{v.toFixed(1)}</Label>
        </g>
      ))}
      <Label x={14} y={(top + bottom) / 2} color="var(--charcoal)" fontSize={12} rotate={-90}>Rainfall depth (in.)</Label>

      {/* Bars */}
      {depths.map((d, i) => {
        const x = left + i * bw + 8;
        return (
          <g key={i}>
            <rect x={x} y={y(d)} width={bw - 16} height={bottom - y(d)} fill="var(--info)" fillOpacity={0.28} stroke="var(--info)" strokeWidth={1.5} />
            <Label x={x + (bw - 16) / 2} y={y(d) - 10} color="var(--charcoal)" fontSize={12} bold>{d.toFixed(1)}</Label>
          </g>
        );
      })}

      {/* Time axis */}
      <line x1={left} y1={bottom} x2={left + plotW} y2={bottom} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={left} y1={top} x2={left} y2={bottom} stroke="var(--charcoal)" strokeWidth={1.5} />
      {Array.from({ length: n + 1 }, (_, i) => (
        <g key={i}>
          <line x1={left + i * bw} y1={bottom} x2={left + i * bw} y2={bottom + 5} stroke="var(--charcoal)" strokeWidth={1} />
          <Label x={left + i * bw} y={bottom + 16} color="var(--gray-500)" fontSize={11}>{i}</Label>
        </g>
      ))}
      <Label x={left + plotW / 2} y={bottom + 36} color="var(--charcoal)" fontSize={12}>Time (hr)</Label>
    </svg>
  );
}

import React from 'react';
import { Label } from '../../primitives';

/**
 * Triangular inflow hydrograph to a detention pond and the pond's outflow
 * hydrograph, on a gridded chart. The outflow peaks where it meets the
 * inflow's falling limb.
 * Shows: both hydrographs, peak values and times on a readable grid.
 * Does NOT show: the storage volume.
 */
export function CtWaterResourcesADetentionHydrographs({ qIn = 60, tPeak = 30, tBase = 90, qOut = 20, tMax = 100, qMax = 70 }) {
  const left = 56;
  const top = 14;
  const pw = 320;
  const ph = 196;
  const bottom = top + ph;
  const X = (t) => left + (t / tMax) * pw;
  const Y = (q) => bottom - (q / qMax) * ph;
  const tOutPeak = tBase - (qOut / qIn) * (tBase - tPeak); // where outflow meets the falling limb

  const grid = [];
  for (let t = 0; t <= tMax; t += 10) grid.push(<line key={`t${t}`} x1={X(t)} y1={top} x2={X(t)} y2={bottom} stroke="var(--gray-400)" strokeOpacity={0.35} strokeWidth={1} />);
  for (let q = 0; q <= qMax; q += 10) grid.push(<line key={`q${q}`} x1={left} y1={Y(q)} x2={left + pw} y2={Y(q)} stroke="var(--gray-400)" strokeOpacity={0.35} strokeWidth={1} />);

  return (
    <svg viewBox={`0 0 ${left + pw + 14} ${bottom + 46}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Inflow hydrograph peaking at ${qIn} cfs at ${tPeak} min and ending at ${tBase} min; outflow peaking at ${qOut} cfs`}
      style={{ width: '100%', height: 'auto' }}>
      {grid}

      {/* Axes */}
      <line x1={left} y1={bottom} x2={left + pw} y2={bottom} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={left} y1={top} x2={left} y2={bottom} stroke="var(--charcoal)" strokeWidth={1.5} />
      {Array.from({ length: tMax / 10 + 1 }, (_, i) => (
        <Label key={i} x={X(i * 10)} y={bottom + 14} color="var(--gray-500)" fontSize={11}>{i * 10}</Label>
      ))}
      {Array.from({ length: qMax / 10 + 1 }, (_, i) => (
        <Label key={i} x={left - 8} y={Y(i * 10)} color="var(--gray-500)" fontSize={11} anchor="end">{i * 10}</Label>
      ))}
      <Label x={left + pw / 2} y={bottom + 34} color="var(--charcoal)" fontSize={12}>Time (min)</Label>
      <Label x={14} y={(top + bottom) / 2} color="var(--charcoal)" fontSize={12} rotate={-90}>Flow (cfs)</Label>

      {/* Inflow */}
      <polyline points={`${X(0)},${Y(0)} ${X(tPeak)},${Y(qIn)} ${X(tBase)},${Y(0)}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.2} strokeLinejoin="round" />
      {/* Outflow */}
      <polyline points={`${X(0)},${Y(0)} ${X(tOutPeak)},${Y(qOut)} ${X(tBase)},${Y(0)}`} fill="none" stroke="var(--info)" strokeWidth={2.2} strokeDasharray="7,4" strokeLinejoin="round" />
      <circle cx={X(tPeak)} cy={Y(qIn)} r={3.5} fill="var(--charcoal)" />
      <circle cx={X(tOutPeak)} cy={Y(qOut)} r={3.5} fill="var(--info)" />

      {/* Legend-style labels next to each curve */}
      <Label x={X(tPeak) + 10} y={Y(qIn) - 2} color="var(--charcoal)" fontSize={12} anchor="start" bold>inflow</Label>
      <Label x={X(tOutPeak) + 8} y={Y(qOut) - 14} color="var(--info)" fontSize={12} anchor="start" bold>outflow</Label>
    </svg>
  );
}

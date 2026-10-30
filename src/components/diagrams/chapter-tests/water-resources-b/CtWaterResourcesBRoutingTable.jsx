import React from 'react';
import { Label } from '../../primitives';

/**
 * Storage-outflow table for a reservoir (the routing relation).
 * Shows: storage (acre-ft) and the outflow (cfs) that goes with it.
 * Does NOT show: the 2S/dt + O column or any routed value.
 */
export function CtWaterResourcesBRoutingTable({ storage = [0, 5, 10, 15, 20], outflow = [0, 20, 50, 85, 125] }) {
  const x0 = 8;
  const w = 344;
  const colW = w / 2;
  const headH = 34;
  const rowH = 26;
  const y0 = 8;
  const h = headH + rowH * storage.length;

  return (
    <svg viewBox={`0 0 360 ${y0 + h + 8}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Storage-outflow table: storage ${storage.join(', ')} acre-ft with outflow ${outflow.join(', ')} cfs`}
      style={{ width: '100%', height: 'auto' }}>
      <rect x={x0} y={y0} width={w} height={headH} rx={6} fill="var(--cream-dark)" />
      <rect x={x0} y={y0 + headH - 6} width={w} height={6} fill="var(--cream-dark)" />
      {storage.map((_, i) => (i % 2 === 1 ? (
        <rect key={i} x={x0} y={y0 + headH + i * rowH} width={w} height={rowH} fill="var(--gray-100)" fillOpacity={0.6} />
      ) : null))}
      <rect x={x0} y={y0} width={w} height={h} rx={6} fill="none" stroke="var(--gray-400)" strokeWidth={1.2} />
      <line x1={x0 + colW} y1={y0} x2={x0 + colW} y2={y0 + h} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={x0} y1={y0 + headH} x2={x0 + w} y2={y0 + headH} stroke="var(--charcoal)" strokeWidth={1.2} />

      <Label x={x0 + colW / 2} y={y0 + headH / 2} color="var(--charcoal)" fontSize={12} bold>Storage S (acre-ft)</Label>
      <Label x={x0 + colW * 1.5} y={y0 + headH / 2} color="var(--charcoal)" fontSize={12} bold>Outflow O (cfs)</Label>
      {storage.map((s, i) => (
        <g key={i}>
          <Label x={x0 + colW / 2} y={y0 + headH + i * rowH + rowH / 2} color="var(--charcoal)" fontSize={12}>{s}</Label>
          <Label x={x0 + colW * 1.5} y={y0 + headH + i * rowH + rowH / 2} color="var(--charcoal)" fontSize={12}>{outflow[i]}</Label>
        </g>
      ))}
    </svg>
  );
}

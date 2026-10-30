import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Solid rectangular beam section with its neutral axis and a point a at a
// given distance below the neutral axis.
export function CtMechanicsMaterialsBRectSection({ b = 6, h = 12, ya = 3 }) {
  const ppi = 14;
  const w = b * ppi;
  const H = h * ppi;
  const x0 = 100;
  const y0 = 20;
  const na = y0 + H / 2;
  const yA = na + ya * ppi;
  const xc = x0 + w / 2;

  return (
    <svg viewBox="0 0 320 236" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Rectangular section ${b} in. wide by ${h} in. deep, point a ${ya} in. below the neutral axis`}
      style={{ width: '100%', height: 'auto' }}>
      <rect x={x0} y={y0} width={w} height={H} rx={2} fill="var(--gray-400)" fillOpacity={0.2} stroke="var(--charcoal)" strokeWidth={2} />
      {/* Neutral axis */}
      <line x1={x0 - 10} y1={na} x2={x0 + w + 10} y2={na} stroke="var(--gray-500)" strokeWidth={1.25} strokeDasharray="6,3" />
      <Label x={x0 - 14} y={na} anchor="end" color="var(--gray-500)">N.A.</Label>
      {/* Point a */}
      <line x1={x0} y1={yA} x2={x0 + w} y2={yA} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <circle cx={xc} cy={yA} r={4} fill="var(--ember)" />
      <Label x={xc + 10} y={yA - 10} anchor="start" bold color="var(--ember)">a</Label>
      {/* ya */}
      <line x1={x0 + w + 4} y1={yA} x2={x0 + w + 30} y2={yA} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={x0 + w + 24} y1={na} x2={x0 + w + 24} y2={yA} label={`${ya} in.`} offset={-24} fontSize={12} />
      {/* Depth */}
      <line x1={x0 + w + 4} y1={y0} x2={x0 + w + 84} y2={y0} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={x0 + w + 4} y1={y0 + H} x2={x0 + w + 84} y2={y0 + H} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={x0 + w + 78} y1={y0} x2={x0 + w + 78} y2={y0 + H} label={`${h} in.`} offset={-26} fontSize={12} />
      {/* Width */}
      <line x1={x0} y1={y0 + H + 4} x2={x0} y2={y0 + H + 28} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={x0 + w} y1={y0 + H + 4} x2={x0 + w} y2={y0 + H + 28} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={x0} y1={y0 + H + 22} x2={x0 + w} y2={y0 + H + 22} label={`${b} in.`} offset={13} fontSize={12} />
    </svg>
  );
}

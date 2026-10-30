import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Open-top water standpipe in elevation, drawn to scale.
export function CtMechanicsMaterialsAStandpipe({ diameter = 30, depth = 80, height = 86, t = '0.50 in.' }) {
  const ppf = 2.6;
  const xL = 120;
  const xR = xL + diameter * ppf;
  const base = 288;
  const topY = base - height * ppf;
  const ws = base - depth * ppf;

  return (
    <svg viewBox="0 0 250 284" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Standpipe ${diameter} ft in diameter holding water ${depth} ft deep, wall ${t} thick at the base`}
      style={{ width: '100%', height: 'auto' }}>
      <g transform="translate(-50,-24)">
      {/* Water */}
      <rect x={xL} y={ws} width={xR - xL} height={base - ws} fill="var(--info)" fillOpacity={0.14} />
      <line x1={xL} y1={ws} x2={xR} y2={ws} stroke="var(--info)" strokeWidth={1.75} />
      <polygon points={`${xR - 22},${ws - 12} ${xR - 10},${ws - 12} ${xR - 16},${ws - 2}`} fill="none" stroke="var(--info)" strokeWidth={1.5} />
      <Label x={(xL + xR) / 2} y={(ws + base) / 2} color="var(--info)">water</Label>
      {/* Walls */}
      <line x1={xL} y1={topY} x2={xL} y2={base} stroke="var(--charcoal)" strokeWidth={3} />
      <line x1={xR} y1={topY} x2={xR} y2={base} stroke="var(--charcoal)" strokeWidth={3} />
      {/* Ground */}
      <line x1={80} y1={base} x2={xR + 40} y2={base} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 11 }, (_, i) => (
        <line key={i} x1={86 + i * 14} y1={base} x2={78 + i * 14} y2={base + 9} stroke="var(--charcoal)" strokeWidth={1.25} />
      ))}
      {/* Diameter */}
      <DimensionLine x1={xL} y1={topY - 12} x2={xR} y2={topY - 12} label={`${diameter} ft`} offset={-11} fontSize={12} />
      {/* Water depth */}
      <DimensionLine x1={xR + 22} y1={ws} x2={xR + 22} y2={base} label={`${depth} ft`} offset={-24} fontSize={12} />
      <line x1={xR + 4} y1={ws} x2={xR + 27} y2={ws} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      {/* Thickness callout */}
      <Label x={xL - 14} y={base - 34} anchor="end" color="var(--charcoal)">t = {t}</Label>
      <line x1={xL - 12} y1={base - 27} x2={xL - 3} y2={base - 10} stroke="var(--gray-500)" strokeWidth={1} />
    </g>
    </svg>
  );
}

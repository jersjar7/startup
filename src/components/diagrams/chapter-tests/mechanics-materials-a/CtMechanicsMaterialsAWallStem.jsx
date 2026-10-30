import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Retaining wall stem as a vertical cantilever with triangular lateral load.
export function CtMechanicsMaterialsAWallStem({ height = 10, w0 = 0.6 }) {
  const top = 24;
  const ppf = 20;
  const base = top + height * ppf;
  const sx1 = 110;
  const sx2 = 128;
  const wmax = 84;
  const ys = [0.2, 0.4, 0.6, 0.8, 1.0].map((f) => top + f * height * ppf);
  const len = (y) => ((y - top) / (base - top)) * wmax;

  return (
    <svg viewBox="0 0 272 262" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Retaining wall stem ${height} ft tall with lateral load rising from zero to ${w0} kip/ft at the base`}
      style={{ width: '100%', height: 'auto' }}>
      <g transform="translate(-40,0)">
      <defs>
        <marker id="ctMmAStemHead" markerWidth={7} markerHeight={7} refX={6} refY={3.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 7,3.5 L 0,7 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* Stem */}
      <rect x={sx1} y={top} width={sx2 - sx1} height={base - top} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* Fixed base: footing ground line with hatching */}
      <line x1={70} y1={base} x2={250} y2={base} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 12 }, (_, i) => (
        <line key={i} x1={74 + i * 15} y1={base} x2={66 + i * 15} y2={base + 10} stroke="var(--charcoal)" strokeWidth={1.25} />
      ))}
      {/* Triangular load */}
      <line x1={sx2 + 2} y1={top} x2={sx2 + 2 + wmax} y2={base - 1} stroke="var(--ember)" strokeWidth={1.5} />
      {ys.map((y, i) => {
        const yy = i === ys.length - 1 ? base - 3 : y;
        return (
          <line key={i} x1={sx2 + 2 + len(yy)} y1={yy} x2={sx2 + 3} y2={yy}
            stroke="var(--ember)" strokeWidth={1.5} markerEnd="url(#ctMmAStemHead)" />
        );
      })}
      <Label x={sx2 + wmax + 10} y={base - 14} anchor="start" bold color="var(--ember)">{w0.toFixed(2)} kip/ft</Label>
      <Label x={sx2 + 10} y={top - 2} anchor="start" color="var(--ember)">0</Label>
      {/* Height */}
      <DimensionLine x1={84} y1={top} x2={84} y2={base} label={`${height} ft`} offset={18} fontSize={12} />
      <Label x={(sx1 + sx2) / 2} y={base + 24} color="var(--charcoal)">footing (fixed)</Label>
    </g>
    </svg>
  );
}

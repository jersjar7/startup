import React from 'react';
import { FixedSupport, DimensionLine, Label } from '../../primitives';

// Cantilever bracket built from an inverted tee (flange at the bottom, stem
// up), fixed to a wall at the left with a tip load; section to the right.
export function CtMechanicsMaterialsBTeeBracket({ L = 4, P = 5, bf = 6, tf = 1, hs = 8, ts = 1 }) {
  // Elevation (to scale: 4 px per inch)
  const ex = 40;
  const epi = 4;
  const len = L * 12 * epi;
  const depth = (tf + hs) * epi;
  const ey = 78;
  const xTip = ex + len;

  // Section (8 px per inch)
  const spi = 8;
  const scx = 336;
  const sTop = 60;
  const stemB = sTop + hs * spi;
  const flB = stemB + tf * spi;
  const fw = bf * spi;
  const sw = ts * spi;

  return (
    <svg viewBox="0 0 420 200" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Cantilever inverted tee bracket, ${L} ft long, ${P} kip tip load; section flange ${bf} by ${tf} in., stem ${ts} by ${hs} in.`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMmBTeeHead" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* Elevation */}
      <FixedSupport x={ex} y={ey - 22} height={depth + 44} side="left" />
      <rect x={ex} y={ey} width={len} height={depth} fill="var(--gray-400)" fillOpacity={0.15} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={ex} y1={ey + hs * epi} x2={xTip} y2={ey + hs * epi} stroke="var(--charcoal)" strokeWidth={1} />
      <line x1={xTip} y1={ey - 50} x2={xTip} y2={ey - 3} stroke="var(--ember)" strokeWidth={2.25} markerEnd="url(#ctMmBTeeHead)" />
      <Label x={xTip - 8} y={ey - 44} anchor="end" bold color="var(--ember)">{`${P} kips`}</Label>
      <line x1={xTip} y1={ey + depth + 6} x2={xTip} y2={ey + depth + 34} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={ex} y1={ey + depth + 28} x2={xTip} y2={ey + depth + 28} label={`${L} ft`} offset={13} fontSize={12} />
      <Label x={(ex + xTip) / 2} y={ey - 14} color="var(--charcoal)">elevation</Label>

      {/* Section */}
      <path
        d={`M ${scx - sw / 2},${sTop} H ${scx + sw / 2} V ${stemB} H ${scx + fw / 2} V ${flB} H ${scx - fw / 2} V ${stemB} H ${scx - sw / 2} Z`}
        fill="var(--gray-400)" fillOpacity={0.3} stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="miter" />
      <Label x={scx} y={sTop - 46} color="var(--charcoal)">section</Label>
      {/* stem thickness */}
      <DimensionLine x1={scx - sw / 2} y1={sTop - 12} x2={scx + sw / 2} y2={sTop - 12} label={`${ts} in.`} offset={-12} fontSize={12} />
      {/* stem height */}
      <line x1={scx - sw / 2 - 4} y1={sTop} x2={scx - 44} y2={sTop} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={scx - 38} y1={sTop} x2={scx - 38} y2={stemB} label={`${hs} in.`} offset={20} fontSize={12} />
      {/* flange thickness */}
      <line x1={scx + fw / 2 + 4} y1={stemB} x2={scx + fw / 2 + 22} y2={stemB} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={scx + fw / 2 + 4} y1={flB} x2={scx + fw / 2 + 22} y2={flB} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={scx + fw / 2 + 16} y1={stemB} x2={scx + fw / 2 + 16} y2={flB} />
      <Label x={scx + fw / 2 + 28} y={(stemB + flB) / 2} anchor="start" color="var(--gray-500)">{`${tf} in.`}</Label>
      {/* flange width */}
      <DimensionLine x1={scx - fw / 2} y1={flB + 18} x2={scx + fw / 2} y2={flB + 18} label={`${bf} in.`} offset={13} fontSize={12} />
    </svg>
  );
}

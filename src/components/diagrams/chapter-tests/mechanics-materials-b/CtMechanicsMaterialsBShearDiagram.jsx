import React from 'react';
import { PinSupport, RollerSupport, DimensionLine, DashedLine, Label } from '../../primitives';

// Simply supported beam A-C (pin A, roller C) with an interior point B, and
// its shear diagram: constant from A to B, a jump at B, then a straight
// sloped line from B to C. The loads themselves are not drawn.
export function CtMechanicsMaterialsBShearDiagram({ segs = [6, 12], v = [16, 4, -20], unit = 'kips' }) {
  const x0 = 70;
  const L = segs[0] + segs[1];
  const ppf = 290 / L;
  const xA = x0;
  const xB = x0 + segs[0] * ppf;
  const xC = x0 + L * ppf;
  const by = 36;
  const base = 152;
  const vmax = Math.max(...v.map(Math.abs));
  const vs = 54 / vmax;
  const yv = (val) => base - val * vs;
  const pts = [[xA, base], [xA, yv(v[0])], [xB, yv(v[0])], [xB, yv(v[1])], [xC, yv(v[2])], [xC, base]];
  const poly = pts.map((p) => p.join(',')).join(' ');
  const fmt = (val) => (val > 0 ? `+${val}` : `−${Math.abs(val)}`);
  const dimY = yv(v[2]) + 26;

  return (
    <svg viewBox="0 0 400 260" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Simply supported beam A to C with point B, and its shear diagram"
      style={{ width: '100%', height: 'auto' }}>
      {/* Beam */}
      <line x1={xA} y1={by} x2={xC} y2={by} stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />
      <PinSupport x={xA} y={by + 1.5} />
      <RollerSupport x={xC} y={by + 1.5} />
      <circle cx={xB} cy={by} r={2.5} fill="var(--charcoal)" />
      <Label x={xA} y={by - 15} bold color="var(--charcoal)">A</Label>
      <Label x={xB} y={by - 15} bold color="var(--charcoal)">B</Label>
      <Label x={xC} y={by - 15} bold color="var(--charcoal)">C</Label>

      {/* Alignment lines */}
      <DashedLine x1={xA} y1={by + 28} x2={xA} y2={yv(v[0]) - 4} strokeWidth={1} />
      <DashedLine x1={xB} y1={by + 8} x2={xB} y2={yv(v[0]) - 4} strokeWidth={1} />
      <DashedLine x1={xC} y1={by + 34} x2={xC} y2={base - 4} strokeWidth={1} />

      {/* Shear diagram */}
      <line x1={xA - 6} y1={base} x2={xC + 8} y2={base} stroke="var(--gray-500)" strokeWidth={1} />
      <polygon points={poly} fill="var(--ember)" fillOpacity={0.12} stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="miter" />
      <Label x={xA - 10} y={base} anchor="end" italic color="var(--charcoal)">{`V (${unit})`}</Label>
      <Label x={(xA + xB) / 2} y={yv(v[0]) - 11} bold color="var(--charcoal)">{fmt(v[0])}</Label>
      <Label x={xB + 8} y={yv(v[1]) - 12} anchor="start" bold color="var(--charcoal)">{fmt(v[1])}</Label>
      <Label x={xC + 8} y={yv(v[2])} anchor="start" bold color="var(--charcoal)">{fmt(v[2])}</Label>

      {/* Segment lengths */}
      <line x1={xA} y1={base + 6} x2={xA} y2={dimY + 6} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={xB} y1={base + 6} x2={xB} y2={dimY + 6} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={xC} y1={yv(v[2]) + 6} x2={xC} y2={dimY + 6} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={xA} y1={dimY} x2={xB} y2={dimY} label={`${segs[0]} ft`} offset={13} fontSize={12} />
      <DimensionLine x1={xB} y1={dimY} x2={xC} y2={dimY} label={`${segs[1]} ft`} offset={13} fontSize={12} />
    </svg>
  );
}

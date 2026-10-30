import React from 'react';
import { Label } from '../../primitives';

/**
 * Existing flexible pavement with a new asphalt overlay on top. Existing layers
 * are drawn to a common thickness scale; the overlay, whose thickness is the
 * unknown, is drawn dashed at a schematic thickness (noted on the figure).
 *
 * Shows: each existing layer's thickness, layer coefficient and drainage
 * coefficient, and the overlay's layer coefficient.
 * Does NOT show: the overlay thickness or any structural number.
 */
export function CtTransportationBOverlay({
  overlay = { name: 'New asphalt overlay', a: 0.44 },
  layers = [
    { name: 'Existing asphalt (cracked)', a: 0.25, D: 3.5 },
    { name: 'Crushed stone base', a: 0.14, m: 1.0, D: 8 },
    { name: 'Granular subbase', a: 0.11, m: 0.8, D: 10 },
  ],
}) {
  const W = 440;
  const px = 7; // px per inch for the existing layers
  const stackL = 78;
  const stackW = 168;
  const stackR = stackL + stackW;
  const top = 10;
  const ovH = 3.5 * px; // schematic; not the answer
  const sub = ['₂', '₃', '₄'];
  const fills = ['var(--gray-300)', 'var(--cream-dark)', 'var(--gray-100)'];

  let y = top + ovH;
  const rows = layers.map((l, i) => {
    const hgt = Math.max(l.D * px, 24);
    const r = { ...l, i, y0: y, y1: y + hgt };
    y += hgt;
    return r;
  });
  const subgradeY = y;
  const H = subgradeY + 44;

  const dim = (y0, y1, text, color, bold) => (
    <g>
      <line x1={stackL - 22} y1={y0 + 1} x2={stackL - 22} y2={y1 - 1} stroke={color} strokeWidth={1} />
      <line x1={stackL - 28} y1={y0} x2={stackL - 16} y2={y0} stroke={color} strokeWidth={1} />
      <line x1={stackL - 28} y1={y1} x2={stackL - 16} y2={y1} stroke={color} strokeWidth={1} />
      <Label x={stackL - 30} y={(y0 + y1) / 2} color={color} fontSize={12} bold={bold} anchor="end">{text}</Label>
    </g>
  );

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Existing flexible pavement section with an asphalt overlay of unknown thickness"
      style={{ width: '100%', height: 'auto' }}>

      {/* Overlay */}
      <rect x={stackL} y={top} width={stackW} height={ovH} fill="var(--white, #fff)" stroke="var(--ember)" strokeWidth={1.6} strokeDasharray="6,3" />
      <Label x={stackL + stackW / 2} y={top + ovH / 2} color="var(--ember)" fontSize={11}>{overlay.name}</Label>
      {dim(top, top + ovH, 'D₁ = ?', 'var(--ember)', true)}
      <Label x={stackR + 12} y={top + ovH / 2} color="var(--charcoal)" fontSize={12} anchor="start">{`a₁ = ${overlay.a.toFixed(2)}`}</Label>

      {rows.map((r) => {
        const midY = (r.y0 + r.y1) / 2;
        const coef = `a${sub[r.i]} = ${r.a.toFixed(2)}` + (r.m != null ? `,  m${sub[r.i]} = ${r.m.toFixed(2)}` : '');
        return (
          <g key={r.i}>
            <rect x={stackL} y={r.y0} width={stackW} height={r.y1 - r.y0} fill={fills[r.i % 3]} stroke="var(--charcoal)" strokeWidth={1.5} />
            <Label x={stackL + stackW / 2} y={midY} color="var(--charcoal)" fontSize={11}>{r.name}</Label>
            {dim(r.y0, r.y1, `${r.D} in.`, 'var(--gray-500)', false)}
            <Label x={stackR + 12} y={midY} color="var(--charcoal)" fontSize={12} anchor="start">{coef}</Label>
          </g>
        );
      })}

      {/* Subgrade */}
      <line x1={stackL - 10} y1={subgradeY} x2={stackR + 10} y2={subgradeY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 15 }, (_, i) => (
        <line key={i} x1={stackL - 4 + i * 13} y1={subgradeY} x2={stackL - 12 + i * 13} y2={subgradeY + 9} stroke="var(--gray-400)" strokeWidth={1} />
      ))}
      <Label x={stackL + stackW / 2} y={subgradeY + 22} color="var(--charcoal)" fontSize={11}>Subgrade</Label>
      <Label x={W - 6} y={H - 8} color="var(--gray-500)" fontSize={11} anchor="end">OVERLAY NOT TO SCALE</Label>
    </svg>
  );
}

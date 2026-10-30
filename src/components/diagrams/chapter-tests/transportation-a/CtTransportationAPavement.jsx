import React from 'react';
import { Label } from '../../primitives';

/**
 * Flexible pavement section: surface, base and subbase on the subgrade, with
 * each layer's thickness dimensioned on the left and its coefficients on the
 * right. A layer whose thickness is asked shows "?" and is drawn at a neutral
 * thickness (the section is marked not to scale when one is unknown).
 *
 * Shows: a, m and D of every layer that the question gives.
 * Does NOT show: the unknown thickness or any structural number.
 */
export function CtTransportationAPavement({
  layers = [
    { name: 'Asphalt surface', a: 0.42, D: 4 },
    { name: 'Crushed stone base', a: 0.13, m: 1.1, D: null },
    { name: 'Granular subbase', a: 0.1, m: 0.9, D: 10 },
  ],
  neutralD = 9,
}) {
  const W = 430;
  const px = 6.5; // px per inch
  const stackL = 74;
  const stackW = 150;
  const stackR = stackL + stackW;
  const top = 14;
  const sub = ['₁', '₂', '₃', '₄'];
  const unknown = layers.some((l) => l.D == null);

  let y = top;
  const rows = layers.map((l, i) => {
    const h = Math.max((l.D ?? neutralD) * px, 30);
    const r = { ...l, i, y0: y, y1: y + h };
    y += h;
    return r;
  });
  const subgradeY = y;
  const H = subgradeY + 46;
  const fills = ['var(--gray-300)', 'var(--cream-dark)', 'var(--gray-100)'];

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Flexible pavement section with layer coefficients and thicknesses"
      style={{ width: '100%', height: 'auto' }}>

      {rows.map((r) => {
        const mid = (r.y0 + r.y1) / 2;
        const dText = r.D == null ? `D${sub[r.i]} = ?` : `${r.D} in.`;
        const coef = `a${sub[r.i]} = ${r.a.toFixed(2)}` + (r.m != null ? `,  m${sub[r.i]} = ${r.m.toFixed(2)}` : '');
        return (
          <g key={r.i}>
            <rect x={stackL} y={r.y0} width={stackW} height={r.y1 - r.y0} fill={fills[r.i % 3]} stroke="var(--charcoal)" strokeWidth={1.5} />
            <Label x={stackL + stackW / 2} y={mid} color="var(--charcoal)" fontSize={11}>{r.name}</Label>
            {/* thickness dimension */}
            <line x1={stackL - 22} y1={r.y0 + 1} x2={stackL - 22} y2={r.y1 - 1} stroke="var(--gray-500)" strokeWidth={1} />
            <line x1={stackL - 28} y1={r.y0} x2={stackL - 16} y2={r.y0} stroke="var(--gray-500)" strokeWidth={1} />
            <line x1={stackL - 28} y1={r.y1} x2={stackL - 16} y2={r.y1} stroke="var(--gray-500)" strokeWidth={1} />
            <Label x={stackL - 30} y={mid} color={r.D == null ? 'var(--ember)' : 'var(--gray-500)'} fontSize={12} bold={r.D == null} anchor="end">{dText}</Label>
            <Label x={stackR + 12} y={mid} color="var(--charcoal)" fontSize={12} anchor="start">{coef}</Label>
          </g>
        );
      })}

      {/* Subgrade */}
      <line x1={stackL - 10} y1={subgradeY} x2={stackR + 10} y2={subgradeY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 13 }, (_, i) => (
        <line key={i} x1={stackL - 4 + i * 13} y1={subgradeY} x2={stackL - 12 + i * 13} y2={subgradeY + 9} stroke="var(--gray-400)" strokeWidth={1} />
      ))}
      <Label x={stackL + stackW / 2} y={subgradeY + 22} color="var(--charcoal)" fontSize={11}>Subgrade</Label>
      {unknown && <Label x={W - 6} y={H - 8} color="var(--gray-500)" fontSize={11} anchor="end">NOT TO SCALE</Label>}
    </svg>
  );
}

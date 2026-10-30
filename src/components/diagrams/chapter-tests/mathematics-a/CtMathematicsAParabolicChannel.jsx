import React from 'react';
import { DimensionLine, Label } from '../../primitives';

/**
 * Parabolic channel section y = x^2 / a with water at a given depth.
 * Shows: the bottom equation, the x and y axes with the vertex at the
 * origin, the water depth. Does NOT show the top width or the flow area.
 */
export function CtMathematicsAParabolicChannel({ a = 8, depth = 2, bank = 3.125 }) {
  const xBank = Math.sqrt(a * bank);
  const xw = Math.sqrt(a * depth);
  const s = 130 / xBank;                // px per ft, both axes
  const cx = 64 + xBank * s, vy = 30 + bank * s;
  const X = (u) => cx + u * s;
  const Y = (v) => vy - v * s;
  const curve = (lo, hi) => {
    const p = [];
    for (let i = 0; i <= 60; i++) { const u = lo + ((hi - lo) * i) / 60; p.push(`${X(u).toFixed(1)},${Y((u * u) / a).toFixed(1)}`); }
    return p;
  };
  const water = curve(-xw, xw);
  const hatch = [];
  for (let i = 1; i < 18; i++) {
    const u = -xBank + (2 * xBank * i) / 18;
    const v = (u * u) / a;
    const nx = (2 * u) / a, ny = 1;     // outward normal in screen coords
    const nl = Math.hypot(nx, ny);
    hatch.push(<line key={i} x1={X(u)} y1={Y(v)} x2={X(u) + (nx / nl) * 8} y2={Y(v) + (ny / nl) * 8} stroke="var(--gray-400)" strokeWidth={1} />);
  }
  const W = X(xBank) + 72, H = vy + 22;
  const tri = { x: X(xw * 0.45), y: Y(depth) };
  const dimX = X(-xBank) - 24;

  return (
    <svg viewBox={`0 0 ${W.toFixed(0)} ${H.toFixed(0)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Parabolic channel y = x²/${a}, water depth ${depth} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {/* water */}
      <polygon points={water.join(' ')} fill="var(--info)" fillOpacity={0.14} />
      <line x1={X(-xw)} y1={Y(depth)} x2={X(xw)} y2={Y(depth)} stroke="var(--info)" strokeWidth={1.8} />
      <polygon points={`${tri.x - 6},${tri.y - 11} ${tri.x + 6},${tri.y - 11} ${tri.x},${tri.y - 1}`} fill="none" stroke="var(--info)" strokeWidth={1.5} />
      {/* axes through the vertex */}
      <line x1={X(-xBank) - 6} y1={vy} x2={X(xBank) + 18} y2={vy} stroke="var(--gray-400)" strokeWidth={1} />
      <Label x={X(xBank) + 24} y={vy} anchor="start" italic>x</Label>
      <line x1={cx} y1={vy + 8} x2={cx} y2={Y(bank) - 10} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="8,3,2,3" />
      <Label x={cx} y={Y(bank) - 18} italic>y</Label>
      {/* channel bottom */}
      {hatch}
      <polyline points={curve(-xBank, xBank).join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} strokeLinejoin="round" />
      <Label x={X(xBank * 0.72) + 14} y={Y((xBank * 0.72) ** 2 / a) + 4} anchor="start" color="var(--charcoal)" fontSize={12}>y = x²/{a}</Label>
      {/* depth */}
      <line x1={X(-xw) - 4} y1={Y(depth)} x2={dimX - 5} y2={Y(depth)} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={dimX} y1={vy} x2={dimX} y2={Y(depth)} />
      <Label x={dimX - 8} y={(vy + Y(depth)) / 2} anchor="end" fontSize={12}>{depth} ft</Label>
      <Label x={cx + 9} y={vy + 14} anchor="start" fontSize={11}>O</Label>
    </svg>
  );
}

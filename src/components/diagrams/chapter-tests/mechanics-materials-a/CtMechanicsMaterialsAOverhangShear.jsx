import React from 'react';
import { PinSupport, RollerSupport, DimensionLine, DashedLine, Label } from '../../primitives';

// Beam with an overhang (pin A, roller B, free end C) and its shear diagram.
// The loads are not drawn: the question is read from the shear diagram.
// Short hatched ground strip under a support base at (x, y).
function Ground({ x, y, half = 13 }) {
  const ticks = [];
  for (let t = x - half + 4; t <= x + half; t += 5) {
    ticks.push(<line key={t} x1={t} y1={y} x2={t - 5} y2={y + 6} stroke="var(--charcoal)" strokeWidth={1} />);
  }
  return (
    <g>
      <line x1={x - half} y1={y} x2={x + half} y2={y} stroke="var(--charcoal)" strokeWidth={1.5} />
      {ticks}
    </g>
  );
}

export function CtMechanicsMaterialsAOverhangShear({ segments = [6, 6, 4], shears = [5.5, -9.5, 6.0], unit = 'kips' }) {
  const x0 = 78;
  const total = segments.reduce((a, b) => a + b, 0);
  const ppf = 300 / total;
  const xs = [x0];
  segments.forEach((s) => xs.push(xs[xs.length - 1] + s * ppf));
  const xA = xs[0];
  const xB = xs[2];
  const xC = xs[3];
  const by = 40;

  const base = 150;
  const vmax = Math.max(...shears.map(Math.abs));
  const vs = 46 / vmax;
  const yv = (v) => base - v * vs;

  const pts = [[xs[0], base]];
  shears.forEach((v, i) => { pts.push([xs[i], yv(v)]); pts.push([xs[i + 1], yv(v)]); });
  pts.push([xs[3], base]);
  const poly = pts.map((p) => p.join(',')).join(' ');
  const fmt = (v) => (v > 0 ? `+${v.toFixed(1)}` : `−${Math.abs(v).toFixed(1)}`);
  const lowest = Math.max(...shears.map((v) => yv(v)));
  const dimY = lowest + 26;

  return (
    <svg viewBox="0 0 400 246" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Overhanging beam with pin at A, roller at B, free end C, and its shear diagram"
      style={{ width: '100%', height: 'auto' }}>
      <g transform="translate(0,-8)">
      {/* Beam */}
      <line x1={xA} y1={by} x2={xC} y2={by} stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />
      <PinSupport x={xA} y={by} />
      <Ground x={xA} y={by + 16} half={12} />
      <RollerSupport x={xB} y={by} />
      <Ground x={xB} y={by + 26} />
      <Label x={xA} y={by - 16} bold color="var(--charcoal)">A</Label>
      <Label x={xB} y={by - 16} bold color="var(--charcoal)">B</Label>
      <Label x={xC} y={by - 16} bold color="var(--charcoal)">C</Label>

      {/* Alignment lines */}
      <DashedLine x1={xA} y1={by + 28} x2={xA} y2={yv(shears[0]) - 4} color="var(--gray-400)" strokeWidth={1} />
      <DashedLine x1={xB} y1={by + 38} x2={xB} y2={yv(shears[2]) - 4} color="var(--gray-400)" strokeWidth={1} />
      <DashedLine x1={xC} y1={by + 6} x2={xC} y2={yv(shears[2]) - 4} color="var(--gray-400)" strokeWidth={1} />

      {/* Shear diagram */}
      <line x1={xA - 6} y1={base} x2={xC + 6} y2={base} stroke="var(--gray-500)" strokeWidth={1} />
      <polygon points={poly} fill="var(--ember)" fillOpacity={0.12} stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="miter" />
      <Label x={xA - 12} y={base} anchor="end" italic color="var(--charcoal)">V ({unit})</Label>
      {shears.map((v, i) => {
        const cx = (xs[i] + xs[i + 1]) / 2;
        const y = v > 0 ? yv(v) - 11 : yv(v) + 13;
        return <Label key={i} x={cx} y={y} bold color="var(--charcoal)">{fmt(v)}</Label>;
      })}

      {/* Segment lengths */}
      {segments.map((s, i) => (
        <DimensionLine key={i} x1={xs[i]} y1={dimY} x2={xs[i + 1]} y2={dimY} label={`${s} ft`} offset={13} fontSize={12} />
      ))}
    </g>
    </svg>
  );
}

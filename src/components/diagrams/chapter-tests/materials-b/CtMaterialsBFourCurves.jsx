import React from 'react';
import { Label } from '../../primitives';

/**
 * Engineering stress-strain curves of four metals, each to fracture (x).
 * Each curve: elastic line to the yield stress, hardening to the ultimate
 * stress, then necking down to the fracture point.
 * Shows: the curves, labels A to D, a reading grid.
 * Does NOT show: areas, toughness values or which one is toughest.
 */
export function CtMaterialsBFourCurves({ curves = [], epsMax = 0.45, sMax = 100 }) {
  const W = 450, H = 300;
  const x0 = 54, x1 = 436, yB = 252, yT = 12;
  const X = (e) => x0 + (e / epsMax) * (x1 - x0);
  const Y = (s) => yB - (s / sMax) * (yB - yT);

  const path = (c) => {
    const ey = c.sy / c.E;
    const p = [[0, 0], [ey, c.sy]];
    for (let i = 1; i <= 30; i++) {
      const t = i / 30;
      p.push([ey + t * (c.eu - ey), c.sy + (c.su - c.sy) * (1 - (1 - t) ** 2)]);
    }
    for (let i = 1; i <= 15; i++) {
      const t = i / 15;
      p.push([c.eu + t * (c.ef - c.eu), c.su - (c.su - c.sf) * t ** 2]);
    }
    return p;
  };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Stress-strain curves of four metals labelled A to D"
      style={{ width: '100%', height: 'auto' }}>
      {Array.from({ length: 10 }, (_, i) => (i + 1) * 0.05).filter((e) => e <= epsMax + 1e-9).map((e) => (
        <line key={`gx${e}`} x1={X(e)} y1={yT} x2={X(e)} y2={yB} stroke="var(--gray-400)" strokeWidth={0.6} opacity={0.55} />
      ))}
      {Array.from({ length: sMax / 10 }, (_, i) => (i + 1) * 10).map((s) => (
        <line key={`gy${s}`} x1={x0} y1={Y(s)} x2={x1} y2={Y(s)} stroke="var(--gray-400)" strokeWidth={0.6} opacity={0.55} />
      ))}
      <line x1={x0} y1={yT} x2={x0} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={x0} y1={yB} x2={x1} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />
      {Array.from({ length: Math.floor(epsMax / 0.1) + 1 }, (_, i) => i * 0.1).map((e) => (
        <Label key={`lx${e}`} x={X(e)} y={yB + 13} color="var(--charcoal)" fontSize={11}>{e === 0 ? '0' : e.toFixed(1)}</Label>
      ))}
      {Array.from({ length: sMax / 20 + 1 }, (_, i) => i * 20).map((s) => (
        <Label key={`ly${s}`} x={x0 - 7} y={Y(s)} color="var(--charcoal)" fontSize={11} anchor="end">{String(s)}</Label>
      ))}

      {curves.map((c) => {
        const p = path(c);
        const [fe, fs] = p[p.length - 1];
        return (
          <g key={c.name}>
            <polyline points={p.map(([e, s]) => `${X(e).toFixed(1)},${Y(s).toFixed(1)}`).join(' ')}
              fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
            <g stroke="var(--charcoal)" strokeWidth={1.8}>
              <line x1={X(fe) - 4} y1={Y(fs) - 4} x2={X(fe) + 4} y2={Y(fs) + 4} />
              <line x1={X(fe) - 4} y1={Y(fs) + 4} x2={X(fe) + 4} y2={Y(fs) - 4} />
            </g>
            <Label x={X(fe) + (c.dx ?? 12)} y={Y(fs) + (c.dy ?? 0)} color="var(--ember)" fontSize={13} bold>{c.name}</Label>
          </g>
        );
      })}

      <Label x={(x0 + x1) / 2} y={H - 12} color="var(--gray-500)" fontSize={12}>Strain, ε (in./in.)</Label>
      <Label x={16} y={(yT + yB) / 2} color="var(--gray-500)" fontSize={12} rotate={-90}>Stress, σ (ksi)</Label>
    </svg>
  );
}

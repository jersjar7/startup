import React from 'react';
import { Label } from '../../primitives';

/**
 * Stress-strain curve of a steel rod with gradual (rounded) yielding,
 * ε = σ/E + 0.002(σ/σy)^n, with the overload point P marked.
 * Shows: the curve, point P with its stress and strain, a reading grid.
 * Does NOT show: the unloading line or any permanent strain.
 */
export function CtMaterialsBOverloadCurve({ E = 29000, sy = 41.86, n = 12, pStrain = 0.012, pStress = 48, epsMax = 0.02, sMax = 60 }) {
  const W = 440, H = 290;
  const x0 = 54, x1 = 424, yB = 242, yT = 12;
  const X = (e) => x0 + (e / epsMax) * (x1 - x0);
  const Y = (s) => yB - (s / sMax) * (yB - yT);
  const pts = [];
  for (let s = 0; s <= sMax; s += 0.05) {
    const e = s / E + 0.002 * (s / sy) ** n;
    if (e > epsMax) break;
    pts.push(`${X(e).toFixed(1)},${Y(s).toFixed(1)}`);
  }
  const xt = Array.from({ length: Math.round(epsMax / 0.002) + 1 }, (_, i) => i * 0.002);
  const yt = Array.from({ length: sMax / 10 + 1 }, (_, i) => i * 10);
  const px = X(pStrain), py = Y(pStress);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Stress-strain curve of a steel rod with the overload point P marked"
      style={{ width: '100%', height: 'auto' }}>
      {xt.map((e, i) => <line key={`gx${i}`} x1={X(e)} y1={yT} x2={X(e)} y2={yB} stroke="var(--gray-400)" strokeWidth={0.6} opacity={0.55} />)}
      {yt.map((s) => <line key={`gy${s}`} x1={x0} y1={Y(s)} x2={x1} y2={Y(s)} stroke="var(--gray-400)" strokeWidth={0.6} opacity={0.55} />)}
      <line x1={x0} y1={yT} x2={x0} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={x0} y1={yB} x2={x1} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />
      {xt.filter((_, i) => i % 2 === 0).map((e) => (
        <Label key={`lx${e}`} x={X(e)} y={yB + 13} color="var(--charcoal)" fontSize={11}>{e === 0 ? '0' : e.toFixed(3)}</Label>
      ))}
      {yt.map((s) => <Label key={`ly${s}`} x={x0 - 7} y={Y(s)} color="var(--charcoal)" fontSize={11} anchor="end">{String(s)}</Label>)}

      <polyline points={pts.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.2} strokeLinejoin="round" />
      <line x1={x0} y1={py} x2={px} y2={py} stroke="var(--ember)" strokeWidth={1.2} strokeDasharray="4,3" />
      <line x1={px} y1={py} x2={px} y2={yB} stroke="var(--ember)" strokeWidth={1.2} strokeDasharray="4,3" />
      <circle cx={px} cy={py} r={4.5} fill="var(--ember)" />
      <Label x={px + 10} y={py - 16} color="var(--ember)" fontSize={12} anchor="start" bold>{`P (${pStrain.toFixed(4)}, ${pStress} ksi)`}</Label>

      <Label x={(x0 + x1) / 2} y={H - 10} color="var(--gray-500)" fontSize={12}>Strain, ε (in./in.)</Label>
      <Label x={16} y={(yT + yB) / 2} color="var(--gray-500)" fontSize={12} rotate={-90}>Stress, σ (ksi)</Label>
    </svg>
  );
}

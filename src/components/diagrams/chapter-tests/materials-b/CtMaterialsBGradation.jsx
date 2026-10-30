import React from 'react';
import { Label } from '../../primitives';

/**
 * Gradation curve of a dense aggregate blend: percent passing against sieve
 * opening on a log scale, coarse sieves on the left.
 * Shows: every sieve as a gridline with its designation, the measured points.
 * Does NOT show: percent retained, any size definition or the NMAS.
 */
export function CtMaterialsBGradation({ sieves = [] }) {
  const W = 460, H = 312;
  const x0 = 56, x1 = 446, yT = 14, yB = 236;
  const mmMax = Math.max(...sieves.map((s) => s.mm));
  const mmMin = Math.min(...sieves.map((s) => s.mm));
  const lMax = Math.log10(mmMax), lMin = Math.log10(mmMin);
  const X = (mm) => x0 + 8 + ((lMax - Math.log10(mm)) / (lMax - lMin)) * (x1 - x0 - 16);
  const Y = (p) => yB - (p / 100) * (yB - yT);
  const pts = sieves.map((s) => `${X(s.mm).toFixed(1)},${Y(s.pass).toFixed(1)}`).join(' ');

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Aggregate gradation curve, percent passing against sieve size"
      style={{ width: '100%', height: 'auto' }}>
      {Array.from({ length: 11 }, (_, i) => i * 10).map((p) => (
        <g key={p}>
          <line x1={x0} y1={Y(p)} x2={x1} y2={Y(p)} stroke="var(--gray-400)" strokeWidth={p % 50 === 0 ? 0.9 : 0.6} opacity={0.6} />
          <Label x={x0 - 7} y={Y(p)} color="var(--charcoal)" fontSize={11} anchor="end">{String(p)}</Label>
        </g>
      ))}
      {sieves.map((s) => (
        <g key={s.label}>
          <line x1={X(s.mm)} y1={yT} x2={X(s.mm)} y2={yB} stroke="var(--gray-400)" strokeWidth={0.6} opacity={0.6} />
          <text x={X(s.mm)} y={yB + 8} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={11}
            textAnchor="end" dominantBaseline="middle" transform={`rotate(-75, ${X(s.mm)}, ${yB + 8})`}>{s.label}</text>
        </g>
      ))}
      <line x1={x0} y1={yT} x2={x0} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={x0} y1={yB} x2={x1} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />

      <polyline points={pts} fill="none" stroke="var(--ember)" strokeWidth={2.2} strokeLinejoin="round" />
      {sieves.map((s) => <circle key={`p${s.label}`} cx={X(s.mm)} cy={Y(s.pass)} r={3.4} fill="var(--cream)" stroke="var(--ember)" strokeWidth={1.8} />)}

      <Label x={(x0 + x1) / 2} y={H - 10} color="var(--gray-500)" fontSize={12}>Sieve (coarse to fine)</Label>
      <Label x={14} y={(yT + yB) / 2} color="var(--gray-500)" fontSize={12} rotate={-90}>Percent passing (%)</Label>
    </svg>
  );
}

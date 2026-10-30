import React from 'react';
import { Label } from '../../primitives';

/**
 * A supplier's trial-batch curves: 28-day compressive strength against the
 * water-cementitious materials ratio, with and without entrained air.
 * Each curve is f = fRef * exp(-k (w - wRef)).
 * Shows: both curves, a reading grid, labelled axes with units.
 * Does NOT show: the design strength line or the ratio read from it.
 */
export function CtMaterialsAStrengthWc({
  air = { fRef: 4500, wRef: 0.45, k: 2.79 },
  nonAir = { fRef: 4500, wRef: 0.55, k: 2.6 },
  wMin = 0.35, wMax = 0.75, fMin = 2000, fMax = 8000,
}) {
  const W = 440, H = 310;
  const x0 = 64, x1 = 424, yB = 258, yT = 14;
  const X = (w) => x0 + ((w - wMin) / (wMax - wMin)) * (x1 - x0);
  const Y = (f) => yB - ((f - fMin) / (fMax - fMin)) * (yB - yT);

  const curve = ({ fRef, wRef, k }) => {
    const pts = [];
    for (let w = wMin; w <= wMax + 1e-9; w += 0.0025) {
      const f = fRef * Math.exp(-k * (w - wRef));
      if (f < fMin || f > fMax) continue;
      pts.push(`${X(w).toFixed(1)},${Y(f).toFixed(1)}`);
    }
    return pts.join(' ');
  };

  const wTicks = Array.from({ length: Math.round((wMax - wMin) / 0.05) + 1 }, (_, i) => wMin + i * 0.05);
  const fTicks = Array.from({ length: (fMax - fMin) / 500 + 1 }, (_, i) => fMin + i * 500);
  const fmt = (v) => v.toLocaleString('en-US');

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Compressive strength against water-cementitious ratio for air-entrained and non-air-entrained trial batches"
      style={{ width: '100%', height: 'auto' }}>
      {/* Grid */}
      {wTicks.map((w, i) => (
        <line key={`gx${i}`} x1={X(w)} y1={yT} x2={X(w)} y2={yB}
          stroke="var(--gray-400)" strokeWidth={0.6} opacity={0.6} />
      ))}
      {fTicks.map((f, i) => (
        <line key={`gy${i}`} x1={x0} y1={Y(f)} x2={x1} y2={Y(f)}
          stroke="var(--gray-400)" strokeWidth={i % 2 === 0 ? 0.8 : 0.5} opacity={i % 2 === 0 ? 0.7 : 0.45} />
      ))}

      {/* Axes */}
      <line x1={x0} y1={yT} x2={x0} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={x0} y1={yB} x2={x1} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />

      {wTicks.map((w) => (
        <Label key={`lx${w}`} x={X(w)} y={yB + 13} color="var(--charcoal)" fontSize={11}>{w.toFixed(2)}</Label>
      ))}
      {fTicks.filter((_, i) => i % 2 === 0).map((f) => (
        <Label key={`ly${f}`} x={x0 - 7} y={Y(f)} color="var(--charcoal)" fontSize={11} anchor="end">{fmt(f)}</Label>
      ))}

      {/* Curves */}
      <polyline points={curve(nonAir)} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} strokeLinecap="round" />
      <polyline points={curve(air)} fill="none" stroke="var(--ember)" strokeWidth={2.5} strokeLinecap="round" strokeDasharray="9,5" />

      {/* Curve names, set in clear grid cells beside each curve */}
      <Label x={X(0.555)} y={Y(6750)} color="var(--charcoal)" bold fontSize={12} anchor="start">Non-air-entrained</Label>
      <Label x={X(0.365)} y={Y(3750)} color="var(--ember)" bold fontSize={12} anchor="start">Air-entrained</Label>

      {/* Axis titles */}
      <Label x={(x0 + x1) / 2} y={H - 12} color="var(--gray-500)" fontSize={12}>Water-cementitious materials ratio, w/cm (by weight)</Label>
      <Label x={14} y={(yT + yB) / 2} color="var(--gray-500)" fontSize={12} rotate={-90}>28-day compressive strength (psi)</Label>
    </svg>
  );
}

import React from 'react';
import { Label } from '../../primitives';

/**
 * Engineering stress-strain curve of an aluminum alloy tension test, zoomed
 * to the first 1% strain so the 0.2% offset construction can be read.
 * The curve is ε = σ/E + 0.002(σ/σy)^n (Ramberg-Osgood).
 * Shows: the curve, a reading grid, labelled axes with units.
 * Does NOT show: the offset line, the yield point or any stress value on it.
 */
export function CtMaterialsAOffsetCurve({ E = 10000, sy = 40, n = 10, epsMax = 0.010, sMax = 50 }) {
  const W = 440, H = 300;
  const x0 = 62, x1 = 424, yB = 252, yT = 14;
  const X = (e) => x0 + (e / epsMax) * (x1 - x0);
  const Y = (s) => yB - (s / sMax) * (yB - yT);
  const epsOf = (s) => s / E + 0.002 * Math.pow(s / sy, n);

  const pts = [];
  for (let s = 0; s <= sMax; s += 0.1) {
    const e = epsOf(s);
    if (e > epsMax) break;
    pts.push(`${X(e).toFixed(1)},${Y(s).toFixed(1)}`);
  }

  const xMinor = Array.from({ length: Math.round(epsMax / 0.001) + 1 }, (_, i) => i * 0.001);
  const yMinor = Array.from({ length: sMax / 5 + 1 }, (_, i) => i * 5);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Stress-strain curve of an aluminum alloy for the first 1 percent of strain"
      style={{ width: '100%', height: 'auto' }}>
      {/* Grid */}
      {xMinor.map((e, i) => (
        <line key={`gx${i}`} x1={X(e)} y1={yT} x2={X(e)} y2={yB}
          stroke="var(--gray-400)" strokeWidth={i % 2 === 0 ? 0.8 : 0.5} opacity={i % 2 === 0 ? 0.7 : 0.45} />
      ))}
      {yMinor.map((s, i) => (
        <line key={`gy${i}`} x1={x0} y1={Y(s)} x2={x1} y2={Y(s)}
          stroke="var(--gray-400)" strokeWidth={i % 2 === 0 ? 0.8 : 0.5} opacity={i % 2 === 0 ? 0.7 : 0.45} />
      ))}

      {/* Axes */}
      <line x1={x0} y1={yT} x2={x0} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={x0} y1={yB} x2={x1} y2={yB} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Tick labels */}
      {xMinor.filter((_, i) => i % 2 === 0).map((e) => (
        <Label key={`lx${e}`} x={X(e)} y={yB + 13} color="var(--charcoal)" fontSize={11}>
          {e === 0 ? '0' : e.toFixed(3)}
        </Label>
      ))}
      {yMinor.filter((_, i) => i % 2 === 0).map((s) => (
        <Label key={`ly${s}`} x={x0 - 7} y={Y(s)} color="var(--charcoal)" fontSize={11} anchor="end">{String(s)}</Label>
      ))}

      {/* Curve */}
      <polyline points={pts.join(' ')} fill="none" stroke="var(--ember)" strokeWidth={2.5}
        strokeLinejoin="round" strokeLinecap="round" />

      {/* Axis titles */}
      <Label x={(x0 + x1) / 2} y={H - 12} color="var(--gray-500)" fontSize={12}>Strain, ε (in./in.)</Label>
      <Label x={16} y={(yT + yB) / 2} color="var(--gray-500)" fontSize={12} rotate={-90}>Stress, σ (ksi)</Label>
    </svg>
  );
}

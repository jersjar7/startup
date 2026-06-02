import React from 'react';
import { Label } from './primitives';

/**
 * Sieve-analysis stack: nested sieves from coarse (top) to fine (bottom)
 * over a pan, used to determine gradation and fineness modulus.
 * Shows: stacked sieves with decreasing openings, retained particles, labels.
 * Does NOT show: the gradation result or fineness modulus (the answer).
 */
export function SieveStack() {
  const left = 60, right = 210, x = left, w = right - left;
  const sieves = [
    { label: 'No. 4', gap: 9 },
    { label: 'No. 16', gap: 6 },
    { label: 'No. 50', gap: 4 },
    { label: 'No. 200', gap: 2.5 },
  ];
  const trayH = 34, top = 24;

  return (
    <svg viewBox="0 0 270 250" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Stack of sieves from coarse to fine over a pan"
      style={{ width: '100%', height: 'auto' }}>

      {sieves.map((s, i) => {
        const y = top + i * trayH;
        const meshY = y + trayH - 4;
        // mesh: vertical ticks spaced by gap (coarser at top)
        const ticks = [];
        for (let tx = x + 6; tx < x + w - 4; tx += s.gap) ticks.push(tx);
        return (
          <g key={s.label}>
            {/* tray walls */}
            <rect x={x} y={y} width={w} height={trayH} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
            {/* mesh (bottom screen) */}
            {ticks.map((tx) => (
              <line key={tx} x1={tx} y1={meshY} x2={tx} y2={meshY + 4} stroke="var(--gray-500)" strokeWidth={1} />
            ))}
            <line x1={x} y1={meshY} x2={x + w} y2={meshY} stroke="var(--gray-500)" strokeWidth={1} />
            {/* a few retained particles on the top sieve */}
            {i === 0 && [85, 110, 135, 160].map((px, k) => (
              <circle key={px} cx={px} cy={meshY - 6 - (k % 2) * 4} r={3.5 - (k % 2)} fill="rgba(120,110,95,0.6)" />
            ))}
            {/* label */}
            <Label x={x + w + 12} y={y + trayH / 2} color="var(--gray-500)" fontSize={10} anchor="start">{s.label}</Label>
          </g>
        );
      })}

      {/* Pan */}
      <rect x={x} y={top + sieves.length * trayH} width={w} height={trayH - 6}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={x + w + 12} y={top + sieves.length * trayH + (trayH - 6) / 2} color="var(--gray-500)" fontSize={10} anchor="start">pan</Label>

      {/* coarse / fine annotation */}
      <Label x={x - 12} y={top + 8} color="var(--gray-400)" italic fontSize={9} anchor="end" rotate={-90}>coarse</Label>
      <Label x={x - 12} y={top + sieves.length * trayH} color="var(--gray-400)" italic fontSize={9} anchor="end" rotate={-90}>fine</Label>
    </svg>
  );
}

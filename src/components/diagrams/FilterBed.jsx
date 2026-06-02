import React from 'react';
import { ArrowMarkerDefs, Label } from './primitives';

/**
 * Rapid sand filter: water ponded over a granular bed, flowing down through
 * sand and a gravel support layer to an underdrain.
 * Shows: filter box, water layer, sand and gravel media, underdrain,
 * downward flow arrows, plan-area note.
 * Does NOT show: the loading-rate value (that is the answer).
 */
export function FilterBed() {
  const left = 70, right = 250, W = 320, H = 250;
  const waterTop = 50, sandTop = 105, gravelTop = 165, drainTop = 195, boxBot = 215;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Rapid sand filter with water over sand and gravel and an underdrain"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowInfo2" color="var(--info)" size={6} />

      {/* Water layer */}
      <rect x={left} y={waterTop} width={right - left} height={sandTop - waterTop} fill="rgba(59,130,184,0.14)" />
      <Label x={(left + right) / 2} y={(waterTop + sandTop) / 2} color="var(--info)" italic fontSize={10}>water</Label>

      {/* Sand media */}
      <rect x={left} y={sandTop} width={right - left} height={gravelTop - sandTop} fill="rgba(180,160,130,0.20)" />
      <Label x={(left + right) / 2} y={(sandTop + gravelTop) / 2} color="var(--gray-500)" fontSize={10}>sand</Label>

      {/* Gravel support */}
      <rect x={left} y={gravelTop} width={right - left} height={drainTop - gravelTop} fill="rgba(120,110,95,0.22)" />
      <Label x={(left + right) / 2} y={(gravelTop + drainTop) / 2} color="var(--gray-500)" fontSize={9}>gravel</Label>

      {/* Underdrain */}
      <rect x={left} y={drainTop} width={right - left} height={boxBot - drainTop} fill="var(--cream-dark)" />
      <Label x={(left + right) / 2} y={(drainTop + boxBot) / 2 + 1} color="var(--gray-500)" fontSize={9}>underdrain</Label>

      {/* Filter box walls */}
      <rect x={left} y={waterTop} width={right - left} height={boxBot - waterTop}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={left} y1={sandTop} x2={right} y2={sandTop} stroke="var(--info)" strokeWidth={1.2} />

      {/* Downward flow arrows */}
      {[110, 160, 210].map((x) => (
        <line key={x} x1={x} y1={waterTop + 10} x2={x} y2={waterTop + 40}
          stroke="var(--info)" strokeWidth={1.5} markerEnd="url(#arrowInfo2)" />
      ))}

      {/* Plan-area note (A = L x W) */}
      <line x1={left} y1={boxBot + 16} x2={right} y2={boxBot + 16} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={left} y1={boxBot + 12} x2={left} y2={boxBot + 20} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={right} y1={boxBot + 12} x2={right} y2={boxBot + 20} stroke="var(--gray-400)" strokeWidth={1} />
      <Label x={(left + right) / 2} y={boxBot + 30} color="var(--gray-500)" fontSize={10}>plan area A</Label>

      {/* Effluent out the bottom */}
      <line x1={(left + right) / 2} y1={boxBot} x2={(left + right) / 2} y2={boxBot + 8}
        stroke="var(--info)" strokeWidth={1.5} markerEnd="url(#arrowInfo2)" />
    </svg>
  );
}

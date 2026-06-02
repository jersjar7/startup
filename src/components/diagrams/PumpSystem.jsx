import React from 'react';
import { ArrowMarkerDefs, ForceArrow, DimensionLine, Label } from './primitives';

/**
 * Pump lifting water from a lower sump to a higher delivery point.
 * Shows: sump, pump symbol, discharge pipe, delivery tank, the total static
 * head H between the two water surfaces, and the flow Q.
 * Does NOT show: power, efficiency, or NPSH values.
 */
export function PumpSystem() {
  const W = 380, H = 240;
  const sumpY = 185, deliverY = 80;
  const pump = { x: 150, y: 150, r: 15 };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Pump lifting water from a sump to a higher delivery tank"
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowInfo" color="var(--info)" size={7} />

      {/* Sump (lower reservoir) */}
      <rect x={20} y={sumpY} width={110} height={45} fill="rgba(59,130,184,0.14)" />
      <line x1={20} y1={sumpY} x2={130} y2={sumpY} stroke="var(--info)" strokeWidth={1.5} />
      <Label x={45} y={sumpY + 24} color="var(--gray-500)" italic fontSize={10}>sump</Label>

      {/* Delivery tank (upper reservoir) */}
      <rect x={250} y={deliverY} width={110} height={40} fill="rgba(59,130,184,0.14)" />
      <line x1={250} y1={deliverY} x2={360} y2={deliverY} stroke="var(--info)" strokeWidth={1.5} />
      <Label x={325} y={deliverY + 22} color="var(--gray-500)" italic fontSize={10}>delivery</Label>

      {/* Pipe: suction up to pump, then discharge up to delivery */}
      <polyline points={`90,${sumpY} 90,${pump.y} ${pump.x - pump.r},${pump.y}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={3} strokeLinejoin="round" />
      <polyline points={`${pump.x + pump.r},${pump.y} 270,${pump.y} 270,${deliverY + 18}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={3} strokeLinejoin="round" />

      {/* Flow arrow on discharge pipe */}
      <ForceArrow x1={270} y1={pump.y - 6} x2={270} y2={deliverY + 26}
        color="var(--info)" strokeWidth={1.5} markerId="arrowInfo" />
      <Label x={282} y={(pump.y + deliverY) / 2} color="var(--info)" bold fontSize={11} anchor="start">Q</Label>

      {/* Pump symbol (circle + impeller triangle) */}
      <circle cx={pump.x} cy={pump.y} r={pump.r} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <polygon points={`${pump.x - 7},${pump.y - 7} ${pump.x - 7},${pump.y + 7} ${pump.x + 8},${pump.y}`}
        fill="var(--charcoal)" />
      <Label x={pump.x} y={pump.y + pump.r + 14} color="var(--charcoal)" bold fontSize={10}>pump</Label>

      {/* Total static head H */}
      <DimensionLine x1={362} y1={deliverY} x2={362} y2={sumpY} label="H" offset={12} color="var(--charcoal)" />
    </svg>
  );
}

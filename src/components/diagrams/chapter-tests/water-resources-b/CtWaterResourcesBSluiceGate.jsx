import React from 'react';
import { Label } from '../../primitives';

/**
 * Profile of flow under a vertical sluice gate in a rectangular channel.
 * Shows: the gate, the upstream depth y1 with its value, the downstream
 * contracted depth marked y2 (no value), the flow direction and discharge.
 * Does NOT show: the value of y2, critical depth or specific energy.
 */
export function CtWaterResourcesBSluiceGate({ y1 = 5.0, q = 180, y2Draw = 1.1, openDraw = 1.6 }) {
  const s = 22; // px per ft
  const bedY = 168;
  const wsUp = bedY - y1 * s;
  const gateX = 196;
  const gateW = 7;
  const openY = bedY - openDraw * s;
  const wsDn = bedY - y2Draw * s;
  const vcX = gateX + gateW + 46;
  const x0 = 16;
  const x1 = 404;
  const water = `M ${x0},${wsUp} L ${gateX},${wsUp} L ${gateX},${openY} L ${gateX + gateW},${openY}
    C ${gateX + gateW + 18},${openY} ${vcX - 20},${wsDn} ${vcX},${wsDn} L ${x1},${wsDn} L ${x1},${bedY} L ${x0},${bedY} Z`;
  const dimUp = 52;
  const dimDn = 318;

  return (
    <svg viewBox={`0 0 420 ${bedY + 22}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Sluice gate in a rectangular channel, upstream depth ${y1} ft, downstream depth y2 unknown, discharge ${q} cfs`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctWrbSluiceArrow" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--charcoal)" />
        </marker>
      </defs>

      {/* Water */}
      <path d={water} fill="var(--info)" fillOpacity={0.18} />
      <path d={`M ${x0},${wsUp} L ${gateX},${wsUp}`} stroke="var(--info)" strokeWidth={1.6} />
      <path d={`M ${gateX + gateW},${openY} C ${gateX + gateW + 18},${openY} ${vcX - 20},${wsDn} ${vcX},${wsDn} L ${x1},${wsDn}`} fill="none" stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={`${118},${wsUp - 11} ${130},${wsUp - 11} ${124},${wsUp - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />
      <polygon points={`${370},${wsDn - 11} ${382},${wsDn - 11} ${376},${wsDn - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />

      {/* Gate */}
      <rect x={gateX} y={wsUp - 40} width={gateW} height={openY - (wsUp - 40)} fill="var(--charcoal)" />
      <Label x={gateX + gateW + 8} y={wsUp - 30} color="var(--charcoal)" fontSize={12} anchor="start">sluice gate</Label>

      {/* Channel bed */}
      <line x1={x0 - 6} y1={bedY} x2={x1 + 6} y2={bedY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 29 }, (_, i) => (
        <line key={i} x1={x0 + i * 14} y1={bedY + 2} x2={x0 - 6 + i * 14} y2={bedY + 9} stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Flow */}
      <line x1={92} y1={128} x2={158} y2={128} stroke="var(--charcoal)" strokeWidth={1.6} markerEnd="url(#ctWrbSluiceArrow)" />
      <Label x={125} y={146} color="var(--charcoal)" fontSize={12}>{`Q = ${q} cfs`}</Label>

      {/* Upstream depth */}
      <line x1={dimUp} y1={wsUp} x2={dimUp} y2={bedY} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={dimUp - 4} y1={wsUp + 4} x2={dimUp + 4} y2={wsUp - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={dimUp - 4} y1={bedY + 4} x2={dimUp + 4} y2={bedY - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={dimUp + 8} y={(wsUp + bedY) / 2 - 20} color="var(--charcoal)" fontSize={12} anchor="start" italic>
        y₁
      </Label>
      <Label x={dimUp + 8} y={(wsUp + bedY) / 2 - 4} color="var(--charcoal)" fontSize={12} anchor="start">{`${y1.toFixed(1)} ft`}</Label>

      {/* Downstream depth (unknown) */}
      <line x1={dimDn} y1={wsDn} x2={dimDn} y2={bedY} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={dimDn - 4} y1={wsDn + 4} x2={dimDn + 4} y2={wsDn - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={dimDn - 4} y1={bedY + 4} x2={dimDn + 4} y2={bedY - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={dimDn + 8} y={(wsDn + bedY) / 2} color="var(--ember)" fontSize={13} anchor="start" italic bold>y₂</Label>
    </svg>
  );
}

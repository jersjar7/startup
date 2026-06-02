import React from 'react';
import { DimensionLine, Label } from './primitives';

/**
 * Seepage under a sheet-pile wall (flow-net schematic).
 * Shows: soil, impervious base, sheet pile, head difference H between the
 * upstream (headwater) and downstream (tailwater) levels, and flow lines
 * passing under the wall tip, with a couple of equipotential lines.
 * Does NOT show: the seepage quantity or a countable Nf/Nd grid.
 */
export function FlowNet() {
  const W = 380, H = 240;
  const soilTop = 95, baseY = 205;
  const wallX = 190, wallTop = 68, wallTip = 160;
  const hwY = 75, twY = 88;        // headwater / tailwater levels

  // nested flow lines (cubic, symmetric) passing under the wall tip
  const flow = [
    [150, 185, 230],
    [120, 200, 260],
    [95, 212, 285],
  ];

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Seepage flow net under a sheet pile wall"
      style={{ width: '100%', height: 'auto' }}>

      {/* Soil body */}
      <rect x={20} y={soilTop} width={W - 40} height={baseY - soilTop} fill="rgba(180,160,130,0.14)" />

      {/* Headwater (left, higher) and tailwater (right, lower) */}
      <rect x={20} y={hwY} width={wallX - 20} height={soilTop - hwY} fill="rgba(59,130,184,0.14)" />
      <rect x={wallX} y={twY} width={W - 20 - wallX} height={soilTop - twY} fill="rgba(59,130,184,0.14)" />
      <line x1={20} y1={hwY} x2={wallX} y2={hwY} stroke="var(--info)" strokeWidth={1.5} />
      <line x1={wallX} y1={twY} x2={W - 20} y2={twY} stroke="var(--info)" strokeWidth={1.5} />

      {/* Flow lines (under the wall tip) */}
      {flow.map(([xl, d, xr], i) => (
        <path key={i}
          d={`M ${xl},${soilTop} C ${xl},${d} ${xr},${d} ${xr},${soilTop}`}
          fill="none" stroke="var(--info)" strokeWidth={1.4} />
      ))}

      {/* A couple of equipotential lines (dashed) */}
      <path d={`M 135,${soilTop} C 150,140 168,150 175,158`} fill="none" stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <path d={`M 245,${soilTop} C 230,140 212,150 205,158`} fill="none" stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />

      {/* Soil surface (river bed) */}
      <line x1={20} y1={soilTop} x2={W - 20} y2={soilTop} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Sheet pile wall */}
      <line x1={wallX} y1={wallTop} x2={wallX} y2={wallTip} stroke="var(--charcoal)" strokeWidth={3.5} strokeLinecap="round" />
      <Label x={wallX} y={wallTop - 8} color="var(--charcoal)" bold fontSize={10}>sheet pile</Label>

      {/* Impervious base + hatching */}
      <line x1={20} y1={baseY} x2={W - 20} y2={baseY} stroke="var(--charcoal)" strokeWidth={2.5} />
      {Array.from({ length: 16 }, (_, i) => 30 + i * 21).map((x) => (
        <line key={x} x1={x} y1={baseY} x2={x - 8} y2={baseY + 9} stroke="var(--charcoal)" strokeWidth={1} />
      ))}
      <Label x={W / 2} y={baseY + 22} color="var(--gray-500)" italic fontSize={10}>impervious</Label>

      {/* Head difference H */}
      <DimensionLine x1={212} y1={hwY} x2={212} y2={twY} label="H" offset={10} color="var(--charcoal)" />

      {/* Flow-line annotation */}
      <Label x={wallX} y={196} color="var(--info)" italic fontSize={10}>flow lines</Label>
    </svg>
  );
}

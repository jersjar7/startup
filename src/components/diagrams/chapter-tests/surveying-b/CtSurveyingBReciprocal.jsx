import React from 'react';
import { Label } from '../../primitives';

/**
 * Reciprocal leveling across a river, elevation view, two panels: setup 1
 * near A and setup 2 near B. Rod readings come from props; vertical
 * distances are to scale, the river width is not.
 */
export function CtSurveyingBReciprocal({ elevA = 621.48, a1 = 4.826, b1 = 7.418, a2 = 3.105, b2 = 5.587 }) {
  const k = 11; // px per ft, vertical
  const drop = ((a1 - b1) + (a2 - b2)) / 2; // ground B relative to A, for drawing only
  const xA = 70;
  const xB = 390;
  const bank1 = 182;
  const bank2 = 300;
  const W = 460;
  const fmt = (v) => v.toFixed(3);
  const rodLen = (read) => Math.ceil(read) + 1;

  // layout of one panel: title, rods, sight line, ground, river
  const layout = (top, aRead, bRead) => {
    const above = Math.max(rodLen(aRead) - aRead, rodLen(bRead) - bRead);
    const sight = top + 26 + above * k;
    const gA = sight + aRead * k;
    const gB = gA - drop * k;
    const water = Math.max(gA, gB) + 12;
    const bed = water + 14;
    return { sight, gA, gB, water, bed, bottom: bed + 22 };
  };

  const panel = (top, label, aRead, bRead, xInst) => {
    const { sight, gA, gB, water, bed } = layout(top, aRead, bRead);
    const nearA = xInst < (bank1 + bank2) / 2;
    const instGround = nearA ? gA : gB;
    const rod = (x, g, read) => {
      const n = rodLen(read);
      return (
        <g>
          <rect x={x - 3} y={g - n * k} width={6} height={n * k} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.2} />
          {Array.from({ length: n - 1 }, (_, i) => (
            <line key={i} x1={x - 3} y1={g - (i + 1) * k} x2={x} y2={g - (i + 1) * k} stroke="var(--charcoal)" strokeWidth={0.7} />
          ))}
          <line x1={x - 8} y1={g - read * k} x2={x + 8} y2={g - read * k} stroke="var(--ember)" strokeWidth={1.6} />
        </g>
      );
    };
    const midR = (bank1 + bank2) / 2;
    const wl = bank1 + 18 * (water - gA) / (bed - gA);
    const wr = bank2 - 18 * (water - gB) / (bed - gB);
    return (
      <g>
        <Label x={midR} y={top + 8} color="var(--charcoal)" fontSize={12} bold>{label}</Label>
        {/* ground, banks and river */}
        <path d={`M 12,${gA} L ${bank1},${gA} L ${bank1 + 18},${bed} L ${bank2 - 18},${bed} L ${bank2},${gB} L ${W - 12},${gB}`}
          fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
        <line x1={wl} y1={water} x2={wr} y2={water} stroke="var(--info)" strokeWidth={1.4} />
        <path d={`M ${midR - 6},${water - 10} L ${midR + 6},${water - 10} L ${midR},${water - 2} Z`} fill="none" stroke="var(--info)" strokeWidth={1.3} />
        {/* level */}
        <line x1={xInst - 12} y1={instGround} x2={xInst} y2={sight + 5} stroke="var(--charcoal)" strokeWidth={1.4} />
        <line x1={xInst + 12} y1={instGround} x2={xInst} y2={sight + 5} stroke="var(--charcoal)" strokeWidth={1.4} />
        <rect x={xInst - 11} y={sight - 4} width={22} height={8} rx={2} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.4} />
        {/* line of sight */}
        <line x1={xA} y1={sight} x2={xB} y2={sight} stroke="var(--ember)" strokeWidth={1.2} strokeDasharray="6,4" />
        {rod(xA, gA, aRead)}
        {rod(xB, gB, bRead)}
        <Label x={xA - 12} y={sight} anchor="end" color="var(--ember)" fontSize={12}>{fmt(aRead)}</Label>
        <Label x={xB + 12} y={sight} anchor="start" color="var(--ember)" fontSize={12}>{fmt(bRead)}</Label>
        <Label x={xA} y={gA + 14} color="var(--charcoal)" fontSize={12} bold>A</Label>
        <Label x={xA + 12} y={gA + 14} anchor="start" color="var(--gray-500)" fontSize={12}>{`El. ${elevA.toFixed(2)} ft`}</Label>
        <Label x={xB} y={gB + 14} color="var(--charcoal)" fontSize={12} bold>B</Label>
        <Label x={midR} y={bed + 12} color="var(--info)" fontSize={12}>River</Label>
      </g>
    );
  };

  const L1 = layout(4, a1, b1);
  const sep = L1.bottom + 4;
  const top2 = sep + 6;
  const L2 = layout(top2, a2, b2);
  const H = Math.ceil(L2.bottom);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Reciprocal leveling across a river: setup 1 near A reads ${a1} on A and ${b1} on B; setup 2 near B reads ${a2} on A and ${b2} on B`}
      style={{ width: '100%', height: 'auto' }}>
      {panel(4, 'Setup 1: level near A', a1, b1, 126)}
      <line x1={12} y1={sep} x2={W - 12} y2={sep} stroke="var(--gray-300)" strokeWidth={1} />
      {panel(top2, 'Setup 2: level near B', a2, b2, 346)}
    </svg>
  );
}

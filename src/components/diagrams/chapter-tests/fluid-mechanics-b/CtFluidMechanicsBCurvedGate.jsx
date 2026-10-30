import React from 'react';
import { T, Dim, Ext, Leader, WaterSym, Ground } from './CtFluidMechanicsBParts';

/**
 * Quarter-circle gate closing the lower corner of a tank, section view.
 * Center of the arc O sits in the water, level with the top of the gate A;
 * B is where the gate meets the floor. Dry recess behind the gate.
 * Does NOT show: any force (student solves).
 */
export function CtFluidMechanicsBCurvedGate({ R = 1.5, above = 1.0, len = 4 }) {
  const W = 420;
  const s = 70; // px per m
  const wall = 320;
  const surf = 40;
  const yA = surf + above * s;
  const fy = yA + R * s;
  const ox = wall - R * s;
  const left = 24;
  const H = fy + 24;
  const water = `M ${left},${surf} L ${wall},${surf} L ${wall},${yA} A ${R * s},${R * s} 0 0 1 ${ox},${fy} L ${left},${fy} Z`;
  const mx = ox + R * s * Math.cos(Math.PI / 4);
  const my = yA + R * s * Math.sin(Math.PI / 4);
  const dx = 364;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Quarter-circle gate of radius ${R} m, ${len} m long, top ${above} m below the water surface`}
      style={{ width: '100%', height: 'auto' }}>
      <path d={water} fill="var(--info)" fillOpacity={0.15} />
      <line x1={left} y1={surf} x2={wall} y2={surf} stroke="var(--info)" strokeWidth={1.6} />
      <WaterSym x={70} y={surf} />
      {/* structure: wall above the gate, floor, dry recess behind the gate */}
      <line x1={wall} y1={surf - 22} x2={wall} y2={fy} stroke="var(--charcoal)" strokeWidth={2.5} />
      {Array.from({ length: Math.floor((fy - surf + 18) / 10) }, (_, i) => (
        <line key={i} x1={wall + 1} y1={surf - 18 + i * 10} x2={wall + 9} y2={surf - 26 + i * 10} stroke="var(--gray-500)" strokeWidth={1} />
      ))}
      <Ground x1={left} x2={wall} y={fy} />
      {/* gate */}
      <path d={`M ${wall},${yA} A ${R * s},${R * s} 0 0 1 ${ox},${fy}`} fill="none" stroke="var(--ember)" strokeWidth={4} />
      {/* radius lines */}
      <line x1={ox} y1={yA} x2={wall - 3} y2={yA} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="5,3" />
      <line x1={ox} y1={yA} x2={ox} y2={fy - 3} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="5,3" />
      <circle cx={ox} cy={yA} r={2.6} fill="var(--charcoal)" />
      <T x={ox - 8} y={yA - 10} anchor="end" bold>O</T>
      <T x={wall - 10} y={yA - 12} anchor="end" bold>A</T>
      <T x={ox - 10} y={fy - 12} anchor="end" bold>B</T>
      <T x={(ox + wall) / 2 - 8} y={yA - 12}>{`R = ${R.toFixed(1)} m`}</T>
      <T x={ox + 40} y={yA + 40} anchor="middle" color="var(--ember)">gate</T>
      <Leader x1={ox + 54} y1={yA + 46} x2={mx - 3} y2={my - 3} />

      {/* depths */}
      <Ext x1={wall + 12} y1={surf} x2={dx + 6} y2={surf} />
      <Ext x1={wall + 12} y1={yA} x2={dx + 6} y2={yA} />
      <Ext x1={wall + 12} y1={fy} x2={dx + 6} y2={fy} />
      <Dim x1={dx} y1={surf} x2={dx} y2={yA} label={`${above.toFixed(1)} m`} lx={dx + 8} ly={(surf + yA) / 2} anchor="start" />
      <Dim x1={dx} y1={yA} x2={dx} y2={fy} label={`${R.toFixed(1)} m`} lx={dx + 8} ly={(yA + fy) / 2} anchor="start" />
    </svg>
  );
}

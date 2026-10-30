import React from 'react';
import { T, Arrow, Dim, Ext, Leader } from './CtFluidMechanicsAParts';

/**
 * Pitot-static tube on the centerline of a culvert flowing full, read by a
 * U-tube manometer holding a gauge fluid heavier than water.
 * The stagnation leg stands lower (higher pressure).
 * Does NOT show: velocity or pressure difference (student solves).
 */
export function CtFluidMechanicsAPitot({ dh = 9, sg = 1.6, unit = 'in.' }) {
  const W = 420;
  const H = 312;
  const pTop = 26;
  const pBot = 104;
  const cl = (pTop + pBot) / 2;
  const tipX = 112;
  const stemX = 214;
  const lx = 172; // stagnation leg
  const rx = 256; // static leg
  const bore = 12;
  const uTop = 150;
  const Ro = (rx - lx) / 2 + bore / 2;
  const Ri = (rx - lx) / 2 - bore / 2;
  const bendY = H - 14 - Ro; // center of the U bend
  const lowY = bendY - 14; // gauge fluid, stagnation leg
  const highY = lowY - 64; // gauge fluid, static leg
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Pitot-static tube in a culvert connected to a U-tube manometer, gauge fluid SG ${sg}, reading ${dh} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>
      {/* culvert */}
      <rect x={16} y={pTop} width={W - 32} height={pBot - pTop} fill="var(--info)" fillOpacity={0.13} />
      <line x1={16} y1={pTop} x2={W - 16} y2={pTop} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={16} y1={pBot} x2={W - 16} y2={pBot} stroke="var(--charcoal)" strokeWidth={2.5} />
      <Arrow x1={30} y1={cl} x2={84} y2={cl} color="var(--info)" width={2.2} />
      <T x={57} y={cl - 14} color="var(--info)">flow</T>
      <T x={340} y={cl} color="var(--gray-500)">culvert, flowing full</T>

      {/* pitot-static probe: nose faces upstream, two tubes down the stem */}
      <path d={`M ${tipX},${cl - 4} L ${stemX + 4},${cl - 4} L ${stemX + 4},${uTop - 26} M ${tipX},${cl + 4} L ${stemX - 4},${cl + 4} L ${stemX - 4},${uTop - 26}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      {/* open stagnation nose: inner tube runs past the sheath, open end facing upstream */}
      <path d={`M ${tipX - 8},${cl - 1.5} L ${stemX},${cl - 1.5} M ${tipX - 8},${cl + 1.5} L ${stemX - 4},${cl + 1.5}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.2} />
      <path d={`M ${tipX},${cl - 4} L ${tipX - 6},${cl - 1.5} M ${tipX},${cl + 4} L ${tipX - 6},${cl + 1.5}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={150} cy={cl - 4} r={1.6} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1} />
      <circle cx={162} cy={cl - 4} r={1.6} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1} />

      {/* leads to the manometer */}
      <path d={`M ${stemX - 4},${uTop - 26} L ${stemX - 4},${uTop - 14} L ${lx},${uTop - 14} L ${lx},${uTop}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      <path d={`M ${stemX + 4},${uTop - 26} L ${stemX + 4},${uTop - 14} L ${rx},${uTop - 14} L ${rx},${uTop}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      <T x={lx - 8} y={uTop - 14} anchor="end" color="var(--gray-500)">stagnation</T>
      <T x={rx + 8} y={uTop - 14} anchor="start" color="var(--gray-500)">static</T>

      {/* water in the upper legs */}
      <rect x={lx - bore / 2} y={uTop} width={bore} height={lowY - uTop} fill="var(--info)" fillOpacity={0.3} />
      <rect x={rx - bore / 2} y={uTop} width={bore} height={highY - uTop} fill="var(--info)" fillOpacity={0.3} />
      {/* gauge fluid */}
      <path d={`M ${lx - bore / 2},${lowY} L ${lx - bore / 2},${bendY} A ${Ro},${Ro} 0 0 0 ${rx + bore / 2},${bendY} L ${rx + bore / 2},${highY} L ${rx - bore / 2},${highY} L ${rx - bore / 2},${bendY} A ${Ri},${Ri} 0 0 1 ${lx + bore / 2},${bendY} L ${lx + bore / 2},${lowY} Z`}
        fill="var(--gray-500)" fillOpacity={0.55} />
      {/* U-tube walls */}
      <path d={`M ${lx - bore / 2},${uTop} L ${lx - bore / 2},${bendY} A ${Ro},${Ro} 0 0 0 ${rx + bore / 2},${bendY} L ${rx + bore / 2},${uTop}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      <path d={`M ${lx + bore / 2},${uTop} L ${lx + bore / 2},${bendY} A ${Ri},${Ri} 0 0 0 ${rx - bore / 2},${bendY} L ${rx - bore / 2},${uTop}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />

      {/* reading */}
      <line x1={lx + bore / 2 + 2} y1={lowY} x2={rx + 40} y2={lowY} stroke="var(--gray-400)" strokeWidth={0.8} strokeDasharray="4,3" />
      <Ext x1={rx + bore / 2 + 3} y1={highY} x2={rx + 40} y2={highY} />
      <Dim x1={rx + 34} y1={highY} x2={rx + 34} y2={lowY} label={`${dh} ${unit}`} lx={rx + 42} ly={(highY + lowY) / 2} anchor="start" />

      {/* labels */}
      <T x={118} y={bendY + 18} anchor="end" color="var(--gray-500)">gauge fluid</T>
      <T x={118} y={bendY + 35} anchor="end" color="var(--gray-500)">{`SG = ${sg.toFixed(2)}`}</T>
      <Leader x1={122} y1={bendY + 26} x2={(lx + rx) / 2 - Math.sqrt(Ro * Ro - 26 * 26) + 6} y2={bendY + 26} />
      <T x={118} y={uTop + 36} anchor="end" color="var(--gray-500)">water</T>
      <Leader x1={122} y1={uTop + 36} x2={lx - 2} y2={uTop + 36} />
    </svg>
  );
}

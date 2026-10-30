import React from 'react';
import { T, Arrow, Leader } from './CtFluidMechanicsBParts';

/**
 * Pitot-static probe on the centerline of a water pipe, its two leads going
 * to a differential pressure transducer.
 * Does NOT show: the velocity (student solves).
 */
export function CtFluidMechanicsBPitot({ dp = 0.8, pipe = 24 }) {
  const W = 420;
  const pTop = 76;
  const pBot = 166;
  const cl = (pTop + pBot) / 2;
  const tipX = 130;
  const stemX = 236;
  const boxY = 14;
  const boxH = 32;
  const H = pBot + 14;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Pitot-static probe in a ${pipe}-in. water pipe; transducer reads ${dp} psi`}
      style={{ width: '100%', height: 'auto' }}>
      <rect x={14} y={pTop} width={W - 28} height={pBot - pTop} fill="var(--info)" fillOpacity={0.13} />
      <line x1={14} y1={pTop} x2={W - 14} y2={pTop} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={14} y1={pBot} x2={W - 14} y2={pBot} stroke="var(--charcoal)" strokeWidth={2.5} />
      <Arrow x1={30} y1={cl + 22} x2={92} y2={cl + 22} color="var(--info)" width={2.2} />
      <T x={61} y={cl + 38} color="var(--info)">flow</T>
      <T x={340} y={cl + 24} color="var(--gray-500)">{`${pipe}-in. water pipe`}</T>

      {/* probe: nose faces upstream, two passages up the stem */}
      <path d={`M ${tipX},${cl - 4} L ${stemX + 4},${cl - 4} L ${stemX + 4},${pTop - 14} M ${tipX},${cl + 4} L ${stemX - 4},${cl + 4} L ${stemX - 4},${pTop - 14}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <path d={`M ${tipX},${cl - 4} Q ${tipX - 6},${cl} ${tipX},${cl + 4}`} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={170} cy={cl - 4} r={1.6} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1} />
      <circle cx={182} cy={cl - 4} r={1.6} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1} />
      <T x={tipX - 10} y={cl} anchor="end" color="var(--gray-500)">nose</T>
      <T x={176} y={cl - 22} color="var(--gray-500)">static holes</T>
      <Leader x1={176} y1={cl - 15} x2={176} y2={cl - 7} />

      {/* leads to the transducer */}
      <path d={`M ${stemX - 4},${pTop - 14} L ${stemX - 4},${boxY + boxH + 10} L ${stemX - 20},${boxY + boxH + 10} L ${stemX - 20},${boxY + boxH}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      <path d={`M ${stemX + 4},${pTop - 14} L ${stemX + 4},${boxY + boxH + 10} L ${stemX + 20},${boxY + boxH + 10} L ${stemX + 20},${boxY + boxH}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      <rect x={stemX - 62} y={boxY} width={124} height={boxH} rx={6} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={2} />
      <T x={stemX} y={boxY + boxH / 2} color="var(--ember)" bold>{`Δp = ${dp.toFixed(2)} psi`}</T>
      <T x={stemX + 70} y={boxY + boxH / 2} anchor="start" color="var(--gray-500)">transducer</T>
    </svg>
  );
}

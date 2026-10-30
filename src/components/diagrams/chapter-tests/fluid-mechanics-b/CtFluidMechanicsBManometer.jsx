import React from 'react';
import { T, Dim, Ext, Leader } from './CtFluidMechanicsBParts';

/**
 * Inverted U-tube manometer with oil in the bend, joining two water pipes
 * at different elevations. All heights are measured up from the center of
 * pipe A.
 * Does NOT show: the pressure difference (student solves).
 */
export function CtFluidMechanicsBManometer({ hA = 1.2, hB = 0.3, hBi = 0.95, sg = 0.8 }) {
  const W = 460;
  const s = 140; // px per m
  const yA = 236;
  const xA = 120;
  const xB = 290;
  const pr = 18;
  const bore = 10;
  const yAi = yA - hA * s;
  const yB = yA - hB * s;
  const yBi = yA - hBi * s;
  const yTop = Math.min(yAi, yBi) - 34; // centerline of the top tube
  const H = yA + pr + 34;
  const b = bore / 2;
  const rc = 14; // bend radius of the centerline
  const ro = rc + b;
  const ri = rc - b;
  // outer and inner walls of the inverted U
  const outer = `M ${xA - b},${yA - pr} L ${xA - b},${yTop + rc} A ${ro},${ro} 0 0 1 ${xA + rc},${yTop - b} L ${xB - rc},${yTop - b} A ${ro},${ro} 0 0 1 ${xB + b},${yTop + rc} L ${xB + b},${yB - pr}`;
  const inner = `M ${xA + b},${yA - pr} L ${xA + b},${yTop + rc} A ${ri},${ri} 0 0 1 ${xA + rc},${yTop + b} L ${xB - rc},${yTop + b} A ${ri},${ri} 0 0 1 ${xB - b},${yTop + rc} L ${xB - b},${yB - pr}`;
  const oilPath = `${outer.replace(`M ${xA - b},${yA - pr}`, `M ${xA - b},${yAi}`).replace(`L ${xB + b},${yB - pr}`, `L ${xB + b},${yBi}`)} L ${xB - b},${yBi} L ${xB - b},${yTop + rc} A ${ri},${ri} 0 0 0 ${xB - rc},${yTop + b} L ${xA + rc},${yTop + b} A ${ri},${ri} 0 0 0 ${xA + b},${yTop + rc} L ${xA + b},${yAi} Z`;
  const dx1 = 352;
  const dx2 = 410;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Inverted U-tube manometer with oil of SG ${sg} between water pipes A and B`}
      style={{ width: '100%', height: 'auto' }}>
      {/* water in the legs */}
      <rect x={xA - b} y={yAi} width={bore} height={yA - pr - yAi + 2} fill="var(--info)" fillOpacity={0.35} />
      <rect x={xB - b} y={yBi} width={bore} height={yB - pr - yBi + 2} fill="var(--info)" fillOpacity={0.35} />
      {/* oil in the bend */}
      <path d={oilPath} fill="var(--gray-500)" fillOpacity={0.5} />
      <path d={outer} fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      <path d={inner} fill="none" stroke="var(--charcoal)" strokeWidth={1.6} />
      {/* pipes in section */}
      <circle cx={xA} cy={yA} r={pr} fill="var(--info)" fillOpacity={0.2} stroke="var(--charcoal)" strokeWidth={2.5} />
      <circle cx={xB} cy={yB} r={pr} fill="var(--info)" fillOpacity={0.2} stroke="var(--charcoal)" strokeWidth={2.5} />
      <circle cx={xA} cy={yA} r={1.8} fill="var(--charcoal)" />
      <circle cx={xB} cy={yB} r={1.8} fill="var(--charcoal)" />
      <T x={xA} y={yA + pr + 16} bold>A</T>
      <T x={xB - pr - 8} y={yB + 2} anchor="end" bold>B</T>

      <T x={(xA + xB) / 2} y={yTop - 18} color="var(--gray-500)">{`oil, SG = ${sg.toFixed(2)}`}</T>
      <T x={xA + 52} y={yA - 70} anchor="start" color="var(--gray-500)">water</T>
      <Leader x1={xA + 48} y1={yA - 70} x2={xA + b + 2} y2={yA - 70} />
      <T x={xB - 44} y={yB - 50} anchor="end" color="var(--gray-500)">water</T>
      <Leader x1={xB - 40} y1={yB - 50} x2={xB - b - 2} y2={yB - 50} />

      {/* heights above the center of A */}
      <Ext x1={xA - b - 3} y1={yAi} x2={xA - 66} y2={yAi} />
      <Ext x1={xA - pr - 3} y1={yA} x2={xA - 66} y2={yA} />
      <Dim x1={xA - 58} y1={yAi} x2={xA - 58} y2={yA} label={`${hA.toFixed(2)} m`} lx={xA - 64} ly={(yAi + yA) / 2} anchor="end" />

      <line x1={xA + pr + 3} y1={yA} x2={dx2 + 6} y2={yA} stroke="var(--gray-400)" strokeWidth={0.8} strokeDasharray="5,3" />
      <Ext x1={xB + pr + 3} y1={yB} x2={dx1 + 6} y2={yB} />
      <Ext x1={xB + b + 3} y1={yBi} x2={dx2 + 6} y2={yBi} />
      <Dim x1={dx1} y1={yB} x2={dx1} y2={yA} label={`${hB.toFixed(2)} m`} lx={dx1 + 6} ly={(yB + yA) / 2} anchor="start" />
      <Dim x1={dx2} y1={yBi} x2={dx2} y2={yA} label={`${hBi.toFixed(2)} m`} lx={dx2 + 6} ly={(yBi + yA) / 2 - 20} anchor="start" />
    </svg>
  );
}

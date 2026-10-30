import React from 'react';
import { Arrowhead, T, Dim, Ext, Wall, INK, LOAD, DIM } from './CtStructuralBParts';

/**
 * Two-member wall bracket: horizontal tie A-C and inclined strut B-C, both
 * pinned to the wall at A and B. A load hangs from C. Member areas are
 * written along each member. Drawn to scale.
 */
export function CtStructuralBBracketTruss({ reach = 12, rise = 9, load = 20, aTie = 2.0, aStrut = 4.0 }) {
  const s = 17;
  const ox = 30;
  const yA = 52;
  const yB = yA + rise * s;
  const xC = ox + reach * s;
  const mk = 'ctStrBBracketArrow';
  const hDimX = xC + 52;
  const W = hDimX + 42;
  const H = yB + 26;
  const ang = (Math.atan2(rise, reach) * 180) / Math.PI;
  const rad = (ang * Math.PI) / 180;
  const mid = { x: (ox + xC) / 2, y: (yA + yB) / 2 };
  const off = 21;
  const fmt = (a) => a.toFixed(1);

  // pin on the wall: triangle with its base on the wall and apex at the joint
  const wallPin = (y) => (
    <polygon points={`${ox + 14},${y} ${ox},${y - 8} ${ox},${y + 8}`} fill="none" stroke={INK} strokeWidth={1.8} strokeLinejoin="round" />
  );

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Wall bracket: tie ${reach} ft, rise ${rise} ft, ${load} kips hanging at C`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={LOAD} size={8} /></defs>

      <Wall x={ox} y1={yA - 30} y2={yB + 16} side="left" />
      {wallPin(yA)}
      {wallPin(yB)}

      <line x1={ox + 14} y1={yA} x2={xC} y2={yA} stroke={INK} strokeWidth={2.4} />
      <line x1={ox + 14} y1={yB} x2={xC} y2={yA} stroke={INK} strokeWidth={2.4} />
      {[[ox + 14, yA], [ox + 14, yB], [xC, yA]].map(([x, y], i) => <circle key={i} cx={x} cy={y} r={3} fill={INK} />)}

      <line x1={xC} y1={yA + 5} x2={xC} y2={yA + 56} stroke={LOAD} strokeWidth={2.2} markerEnd={`url(#${mk})`} />
      <T x={xC + 8} y={yA + 44} anchor="start" color={LOAD} bold>{`${load} kips`}</T>

      <T x={ox + 22} y={yA - 12} anchor="start" bold>A</T>
      <T x={ox + 22} y={yB + 12} anchor="start" bold>B</T>
      <T x={xC + 9} y={yA - 11} anchor="start" bold>C</T>

      <T x={(ox + xC) / 2 + 6} y={yA + 13} size={11.5} color={DIM}>{`area ${fmt(aTie)} in.²`}</T>
      <g transform={`translate(${mid.x + off * Math.sin(rad) + 4}, ${mid.y + off * Math.cos(rad)}) rotate(${-ang})`}>
        <T x={0} y={0} size={11.5} color={DIM}>{`area ${fmt(aStrut)} in.²`}</T>
      </g>

      {/* reach, measured above the tie */}
      <Ext x1={ox + 14} y1={yA - 12} x2={ox + 14} y2={yA - 33} />
      <Ext x1={xC} y1={yA - 22} x2={xC} y2={yA - 33} />
      <Dim x1={ox + 14} y1={yA - 28} x2={xC} y2={yA - 28} label={`${reach} ft`} side="above" />

      {/* rise */}
      <Ext x1={xC + 6} y1={yA} x2={hDimX + 5} y2={yA} />
      <Ext x1={ox + 40} y1={yB} x2={hDimX + 5} y2={yB} />
      <Dim x1={hDimX} y1={yA} x2={hDimX} y2={yB} label={`${rise} ft`} side="right" />
    </svg>
  );
}

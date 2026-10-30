import React from 'react';
import { Arrowhead, T, Pin, Roller, Dim, Ext, Udl, INK, LOAD, DIM } from './CtStructuralAParts';

/**
 * Elevation of a simply supported steel beam under uniform load, with the
 * points where the compression flange is braced laterally marked with an X.
 * Span and beam depth drawn to scale.
 */
export function CtStructuralABracedBeam({ span = 24, braces = [0, 12, 24], depthIn = 18, shape = 'W18×50', fy = 50 }) {
  const s = 336 / span;
  const ox = 34;
  const top = 64;
  const dpx = (depthIn / 12) * s;
  const bot = top + dpx;
  const xR = ox + span * s;
  const xs = [...new Set(braces)].sort((a, b) => a - b);
  const dimY = bot + 48;
  const legY = dimY + 30;
  const W = xR + 34;
  const H = legY + 16;
  const mk = 'ctStrABracedArrow';
  const X = ({ x, y, k = 5.5 }) => (
    <g>
      <line x1={x - k} y1={y - k} x2={x + k} y2={y + k} stroke={LOAD} strokeWidth={2} />
      <line x1={x - k} y1={y + k} x2={x + k} y2={y - k} stroke={LOAD} strokeWidth={2} />
    </g>
  );

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`${shape} beam, ${span} ft span, braced at ${xs.join(', ')} ft`}
      style={{ width: '100%', height: 'auto' }}>
      <defs><Arrowhead id={mk} color={INK} size={7} /></defs>
      <Udl x1={ox} x2={xR} y={top - 30} len={26} markerId={mk} count={15} color={INK} />
      <T x={(ox + xR) / 2} y={top - 43}>uniform load</T>

      {/* beam elevation: flanges and web outline */}
      <rect x={ox} y={top} width={xR - ox} height={dpx} fill="var(--gray-100)" stroke={INK} strokeWidth={1.8} />
      <line x1={ox} y1={top + 3} x2={xR} y2={top + 3} stroke={INK} strokeWidth={1} />
      <line x1={ox} y1={bot - 3} x2={xR} y2={bot - 3} stroke={INK} strokeWidth={1} />
      {xs.map((b) => <X key={b} x={ox + b * s} y={(top + bot) / 2} />)}

      <Pin x={ox} y={bot + 1} />
      <Roller x={xR} y={bot + 1} />

      {xs.map((b) => <Ext key={`e${b}`} x1={ox + b * s} y1={bot + (b === 0 || b === span ? 28 : 6)} x2={ox + b * s} y2={dimY + 5} />)}
      {xs.slice(0, -1).map((b, i) => (
        <Dim key={`d${b}`} x1={ox + b * s} y1={dimY} x2={ox + xs[i + 1] * s} y2={dimY} label={`${xs[i + 1] - b} ft`} />
      ))}

      <X x={ox + 6} y={legY} k={5} />
      <T x={ox + 18} y={legY} anchor="start" size={12} color={DIM}>lateral brace to compression flange</T>
      <T x={xR} y={legY} anchor="end" size={12} bold>{`${shape}, Fy = ${fy} ksi`}</T>
    </svg>
  );
}

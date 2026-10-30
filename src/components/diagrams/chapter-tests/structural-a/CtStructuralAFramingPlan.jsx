import React from 'react';
import { T, Dim, Ext, INK, LOAD, SEC } from './CtStructuralAParts';

/**
 * Floor framing plan: column grid lettered A, B, C... left to right and
 * numbered 1, 2, 3... top to bottom, equal bays. One column is marked in
 * ember (the column the question asks about). Drawn to scale.
 */
export function CtStructuralAFramingPlan({ nx = 3, ny = 2, bayX = 25, bayY = 30, col = 'B2' }) {
  const s = Math.min(300 / (nx * bayX), 200 / (ny * bayY));
  const ox = 48;
  const oy = 46;
  const xs = Array.from({ length: nx + 1 }, (_, i) => ox + i * bayX * s);
  const ys = Array.from({ length: ny + 1 }, (_, j) => oy + j * bayY * s);
  const xEnd = xs[nx];
  const yEnd = ys[ny];
  const dimY = yEnd + 34;
  const dimX = xEnd + 34;
  const W = dimX + 50;
  const H = dimY + 24;
  const letters = 'ABCDEFGH';
  const ci = letters.indexOf(col[0]);
  const cj = Number(col.slice(1)) - 1;
  const bubble = 10;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Framing plan, ${nx} by ${ny} bays of ${bayX} ft by ${bayY} ft, column ${col} marked`}
      style={{ width: '100%', height: 'auto' }}>
      {/* grid lines */}
      {xs.map((x, i) => <line key={`gx${i}`} x1={x} y1={oy - 16} x2={x} y2={yEnd + 8} stroke={SEC} strokeWidth={0.9} strokeDasharray="6,3" />)}
      {ys.map((y, j) => <line key={`gy${j}`} x1={ox - 16} y1={y} x2={xEnd + 8} y2={y} stroke={SEC} strokeWidth={0.9} strokeDasharray="6,3" />)}
      {/* beams along both directions */}
      {ys.map((y, j) => <line key={`by${j}`} x1={xs[0]} y1={y} x2={xEnd} y2={y} stroke={INK} strokeWidth={1.6} />)}
      {xs.map((x, i) => <line key={`bx${i}`} x1={x} y1={ys[0]} x2={x} y2={yEnd} stroke={INK} strokeWidth={1.6} />)}
      {/* grid bubbles */}
      {xs.map((x, i) => (
        <g key={`bxl${i}`}>
          <circle cx={x} cy={oy - 16 - bubble} r={bubble} fill="#fff" stroke={INK} strokeWidth={1.2} />
          <T x={x} y={oy - 16 - bubble + 0.5} size={12} bold>{letters[i]}</T>
        </g>
      ))}
      {ys.map((y, j) => (
        <g key={`byl${j}`}>
          <circle cx={ox - 16 - bubble} cy={y} r={bubble} fill="#fff" stroke={INK} strokeWidth={1.2} />
          <T x={ox - 16 - bubble} y={y + 0.5} size={12} bold>{String(j + 1)}</T>
        </g>
      ))}
      {/* columns */}
      {xs.map((x, i) => ys.map((y, j) => {
        const hit = i === ci && j === cj;
        const k = hit ? 6 : 4.5;
        return <rect key={`c${i}${j}`} x={x - k} y={y - k} width={2 * k} height={2 * k} fill={hit ? LOAD : INK} />;
      }))}
      <T x={xs[ci] + 10} y={ys[cj] - 12} anchor="start" size={12} color={LOAD} bold>{`column ${col}`}</T>

      {/* bay dimensions */}
      {xs.map((x, i) => <Ext key={`ex${i}`} x1={x} y1={yEnd + 12} x2={x} y2={dimY + 5} />)}
      {xs.slice(0, nx).map((x, i) => <Dim key={`dx${i}`} x1={x} y1={dimY} x2={xs[i + 1]} y2={dimY} label={`${bayX} ft`} />)}
      {ys.map((y, j) => <Ext key={`ey${j}`} x1={xEnd + 12} y1={y} x2={dimX + 5} y2={y} />)}
      {ys.slice(0, ny).map((y, j) => <Dim key={`dy${j}`} x1={dimX} y1={y} x2={dimX} y2={ys[j + 1]} label={`${bayY} ft`} side="right" />)}
    </svg>
  );
}

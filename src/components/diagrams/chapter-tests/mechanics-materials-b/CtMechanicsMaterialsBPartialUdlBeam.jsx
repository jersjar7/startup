import React from 'react';
import { PinSupport, RollerSupport, DimensionLine, Label } from '../../primitives';

// Simply supported beam (pin A, roller B) with a concentrated load at a
// from A and a uniform load over the last `wLen` of the span.
export function CtMechanicsMaterialsBPartialUdlBeam({ L = 20, a = 5, P = 10, wLen = 10, w = 4 }) {
  const x0 = 40;
  const ppf = 320 / L;
  const xA = x0;
  const xB = x0 + L * ppf;
  const xP = x0 + a * ppf;
  const xW = xB - wLen * ppf;
  const by = 84;
  const top = 48;
  const count = Math.max(3, Math.round(wLen / 1.25) + 1);
  const sp = (xB - xW) / (count - 1);
  const dimY = 134;
  const marks = [xA, xP, xW, xB].filter((v, i, arr) => arr.indexOf(v) === i).sort((p, q) => p - q);

  return (
    <svg viewBox="0 0 400 156" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Simply supported beam, ${L} ft span, ${P} kip load ${a} ft from A, ${w} kip/ft over the last ${wLen} ft`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMmBUdlHead" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* Beam */}
      <line x1={xA} y1={by} x2={xB} y2={by} stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />
      <PinSupport x={xA} y={by + 1.5} />
      <RollerSupport x={xB} y={by + 1.5} />
      <Label x={xA - 18} y={by + 12} anchor="end" bold color="var(--charcoal)">A</Label>
      <Label x={xB + 18} y={by + 12} anchor="start" bold color="var(--charcoal)">B</Label>

      {/* Uniform load */}
      <line x1={xW} y1={top} x2={xB} y2={top} stroke="var(--ember)" strokeWidth={1.5} />
      {Array.from({ length: count }, (_, i) => (
        <line key={i} x1={xW + i * sp} y1={top} x2={xW + i * sp} y2={by - 3} stroke="var(--ember)" strokeWidth={1.5} markerEnd="url(#ctMmBUdlHead)" />
      ))}
      <Label x={(xW + xB) / 2} y={top - 12} bold color="var(--ember)">{`${w} kip/ft`}</Label>

      {/* Concentrated load */}
      <line x1={xP} y1={top - 34} x2={xP} y2={by - 3} stroke="var(--ember)" strokeWidth={2.25} markerEnd="url(#ctMmBUdlHead)" />
      <Label x={xP + 8} y={top - 28} anchor="start" bold color="var(--ember)">{`${P} kips`}</Label>

      {/* Dimensions */}
      {marks.slice(1).map((m, i) => (
        <line key={`e${i}`} x1={m} y1={i === marks.length - 2 ? by + 40 : by + 8} x2={m} y2={dimY + 6} stroke="var(--gray-400)" strokeWidth={1} />
      ))}
      <line x1={xA} y1={by + 30} x2={xA} y2={dimY + 6} stroke="var(--gray-400)" strokeWidth={1} />
      {marks.slice(0, -1).map((m, i) => (
        <DimensionLine key={i} x1={m} y1={dimY} x2={marks[i + 1]} y2={dimY}
          label={`${Math.round((marks[i + 1] - m) / ppf * 10) / 10} ft`} offset={-11} fontSize={12} />
      ))}
    </svg>
  );
}

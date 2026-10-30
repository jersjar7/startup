import React from 'react';
import { FixedSupport, DimensionLine, Label } from '../../primitives';

// Steel balcony beam cantilevered from a wall: a uniform load over the full
// length and a concentrated railing load at the free end.
export function CtMechanicsMaterialsBBalcony({ L = 8, w = 0.5, P = 2 }) {
  const x0 = 40;
  const len = 300;
  const xT = x0 + len;
  const by = 112;
  const top = 76;
  const n = 9;
  const uEnd = xT;
  const sp = (uEnd - (x0 + 4)) / (n - 1);

  return (
    <svg viewBox="0 0 400 176" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Cantilever ${L} ft long with ${w} kip/ft uniform load and ${P} kip load at the free end`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMmBBalcHead" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--ember)" />
        </marker>
      </defs>
      <FixedSupport x={x0} y={by - 30} height={60} side="left" />
      <rect x={x0} y={by - 4} width={len} height={8} fill="var(--charcoal)" />
      {/* Uniform load over the full length, out to the free end */}
      <line x1={x0} y1={top} x2={uEnd} y2={top} stroke="var(--ember)" strokeWidth={1.5} />
      {Array.from({ length: n }, (_, i) => (
        <line key={i} x1={x0 + 4 + i * sp} y1={top} x2={x0 + 4 + i * sp} y2={by - 6} stroke="var(--ember)" strokeWidth={1.5} markerEnd="url(#ctMmBBalcHead)" />
      ))}
      <Label x={x0 + len / 2} y={top - 12} bold color="var(--ember)">{`${w} kip/ft`}</Label>
      {/* Tip load: a heavier arrow that lands on the uniform-load line */}
      <line x1={xT} y1={top - 52} x2={xT} y2={top - 4} stroke="var(--ember)" strokeWidth={2.5} markerEnd="url(#ctMmBBalcHead)" />
      <Label x={xT + 9} y={top - 44} anchor="start" bold color="var(--ember)">{`${P} kips`}</Label>
      {/* Length */}
      <line x1={xT} y1={by + 8} x2={xT} y2={by + 42} stroke="var(--gray-400)" strokeWidth={1} />
      <DimensionLine x1={x0} y1={by + 36} x2={xT} y2={by + 36} label={`${L} ft`} offset={13} fontSize={12} />
    </svg>
  );
}

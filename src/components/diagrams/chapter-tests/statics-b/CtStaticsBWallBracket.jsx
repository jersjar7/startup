import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * A two-panel truss bracket pinned to a wall at A (top) and B (bottom),
 * with a load at the tip E.
 * Shows: wall, pins, joint letters, panel and height dimensions, the load.
 * Does NOT show: member forces.
 */
export function CtStaticsBWallBracket({ panel = 4, height = 3, load = 24, unit = 'm', fu = 'kN' }) {
  const S = 30;
  const wx = 46; // wall face
  const yA = 54;
  const yB = yA + height * S;
  const J = {
    A: [wx, yA], B: [wx, yB], C: [wx + panel * S, yA], D: [wx + panel * S, yB], E: [wx + 2 * panel * S, yA],
  };
  const members = ['AC', 'CE', 'BD', 'DE', 'CD', 'BC'];
  const gray = 'var(--gray-500)';
  const dimY = yB + 34;
  const hx = J.E[0] + 72;
  const pin = (x, y) => (
    <g>
      <polygon points={`${x},${y} ${x - 14},${y - 8} ${x - 14},${y + 8}`} fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
    </g>
  );

  return (
    <svg viewBox={`0 0 ${hx + 40} ${dimY + 20}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Wall bracket truss, panels ${panel} ${unit}, depth ${height} ${unit}, ${load} ${fu} at E`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBWallArrow" color="var(--ember)" size={9} />

      {/* Wall */}
      <line x1={wx - 14} y1={yA - 34} x2={wx - 14} y2={yB + 24} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 8 }, (_, i) => (
        <line key={i} x1={wx - 14} y1={yA - 28 + i * 17} x2={wx - 24} y2={yA - 20 + i * 17} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}
      {pin(J.A[0], J.A[1])}
      {pin(J.B[0], J.B[1])}

      {members.map((m) => (
        <line key={m} x1={J[m[0]][0]} y1={J[m[0]][1]} x2={J[m[1]][0]} y2={J[m[1]][1]} stroke="var(--charcoal)" strokeWidth={2.2} strokeLinecap="round" />
      ))}
      {Object.entries(J).map(([k, [x, y]]) => (
        <circle key={k} cx={x} cy={y} r={3.2} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      ))}
      <Label x={J.A[0] + 4} y={J.A[1] - 13} color="var(--charcoal)" bold>A</Label>
      <Label x={J.B[0] + 4} y={J.B[1] + 14} color="var(--charcoal)" bold>B</Label>
      <Label x={J.C[0]} y={J.C[1] - 13} color="var(--charcoal)" bold>C</Label>
      <Label x={J.D[0]} y={J.D[1] + 14} color="var(--charcoal)" bold>D</Label>
      <Label x={J.E[0]} y={J.E[1] - 13} color="var(--charcoal)" bold>E</Label>

      {/* Load at E */}
      <line x1={J.E[0]} y1={yA + 4} x2={J.E[0]} y2={yA + 50} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBWallArrow)" />
      <Label x={J.E[0] + 8} y={yA + 42} color="var(--ember)" bold anchor="start">{`${load} ${fu}`}</Label>

      {/* Panel dimensions */}
      <line x1={J.A[0]} y1={dimY} x2={J.E[0]} y2={dimY} stroke={gray} strokeWidth={1} />
      {[J.A[0], J.C[0], J.E[0]].map((x) => <line key={x} x1={x} y1={dimY - 5} x2={x} y2={dimY + 5} stroke={gray} strokeWidth={1} />)}
      <Label x={(J.A[0] + J.C[0]) / 2} y={dimY + 13}>{`${panel} ${unit}`}</Label>
      <Label x={(J.C[0] + J.E[0]) / 2} y={dimY + 13}>{`${panel} ${unit}`}</Label>
      <line x1={J.E[0]} y1={yA + 56} x2={J.E[0]} y2={dimY - 7} stroke="var(--gray-300)" strokeWidth={1} />

      {/* Height dimension, right of the tip */}
      <line x1={hx} y1={yA} x2={hx} y2={yB} stroke={gray} strokeWidth={1} />
      <line x1={hx - 5} y1={yA} x2={hx + 5} y2={yA} stroke={gray} strokeWidth={1} />
      <line x1={hx - 5} y1={yB} x2={hx + 5} y2={yB} stroke={gray} strokeWidth={1} />
      <line x1={J.E[0] + 8} y1={yA} x2={hx - 6} y2={yA} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={J.D[0] + 8} y1={yB} x2={hx - 6} y2={yB} stroke="var(--gray-300)" strokeWidth={1} />
      <Label x={hx + 8} y={(yA + yB) / 2} anchor="start">{`${height} ${unit}`}</Label>
    </svg>
  );
}

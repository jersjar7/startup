import React from 'react';
import { ArrowMarkerDefs, PinSupport, RollerSupport, Label } from '../../primitives';

/**
 * Four-panel parallel-chord truss with inclined end posts and a single
 * load at the bottom middle joint C.
 * Shows: joint letters, panel size, height, supports, the load.
 * Does NOT show: member forces or which members are zero-force.
 */
export function CtStaticsAZeroForceTruss({ panel = 4, height = 3, unit = 'm', loadLabel = 'P' }) {
  const S = 22;
  const x0 = 40;
  const y0 = height * S + 32; // bottom chord
  const yt = y0 - height * S;
  const px = (i) => x0 + i * panel * S;
  const J = {
    A: [px(0), y0], B: [px(1), y0], C: [px(2), y0], D: [px(3), y0], E: [px(4), y0],
    F: [px(1), yt], G: [px(2), yt], H: [px(3), yt],
  };
  const members = ['AB', 'BC', 'CD', 'DE', 'FG', 'GH', 'AF', 'HE', 'BF', 'CG', 'DH', 'FC', 'HC'];
  const gray = 'var(--gray-500)';
  const dimY = y0 + 74;
  const W = px(4) + 70;

  return (
    <svg viewBox={`0 0 ${W} ${dimY + 20}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Four-panel truss, panels ${panel} ${unit}, height ${height} ${unit}, load ${loadLabel} at joint C`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStAZfArrow" color="var(--ember)" size={9} />

      {members.map((m) => (
        <line key={m} x1={J[m[0]][0]} y1={J[m[0]][1]} x2={J[m[1]][0]} y2={J[m[1]][1]} stroke="var(--charcoal)" strokeWidth={2.2} strokeLinecap="round" />
      ))}
      {Object.entries(J).map(([k, [x, y]]) => (
        <circle key={k} cx={x} cy={y} r={3.2} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      ))}

      {/* Joint letters */}
      <Label x={J.A[0] - 14} y={J.A[1] - 8} color="var(--charcoal)" bold>A</Label>
      <Label x={J.B[0] - 10} y={J.B[1] + 13} color="var(--charcoal)" bold>B</Label>
      <Label x={J.C[0] - 12} y={J.C[1] + 13} color="var(--charcoal)" bold>C</Label>
      <Label x={J.D[0] + 10} y={J.D[1] + 13} color="var(--charcoal)" bold>D</Label>
      <Label x={J.E[0] + 14} y={J.E[1] - 8} color="var(--charcoal)" bold>E</Label>
      <Label x={J.F[0]} y={J.F[1] - 13} color="var(--charcoal)" bold>F</Label>
      <Label x={J.G[0]} y={J.G[1] - 13} color="var(--charcoal)" bold>G</Label>
      <Label x={J.H[0]} y={J.H[1] - 13} color="var(--charcoal)" bold>H</Label>

      {/* Supports */}
      <PinSupport x={J.A[0]} y={J.A[1] + 3} />
      <RollerSupport x={J.E[0]} y={J.E[1] + 3} />

      {/* Load at C, hanging below the joint */}
      <line x1={J.C[0]} y1={y0 + 4} x2={J.C[0]} y2={y0 + 46} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStAZfArrow)" />
      <Label x={J.C[0] + 9} y={y0 + 38} color="var(--ember)" bold anchor="start" italic>{loadLabel}</Label>

      {/* Panel dimensions */}
      {[0, 1, 2, 3, 4].map((i) => (
        <line key={i} x1={px(i)} y1={dimY - 6} x2={px(i)} y2={dimY + 6} stroke={gray} strokeWidth={1} />
      ))}
      <line x1={px(0)} y1={dimY} x2={px(4)} y2={dimY} stroke={gray} strokeWidth={1} />
      <Label x={(px(0) + px(4)) / 2} y={dimY + 13}>{`4 panels at ${panel} ${unit}`}</Label>

      {/* Height dimension */}
      <line x1={px(4) + 34} y1={yt} x2={px(4) + 34} y2={y0} stroke={gray} strokeWidth={1} />
      <line x1={px(4) + 29} y1={yt} x2={px(4) + 39} y2={yt} stroke={gray} strokeWidth={1} />
      <line x1={px(4) + 29} y1={y0} x2={px(4) + 39} y2={y0} stroke={gray} strokeWidth={1} />
      <line x1={J.H[0] + 6} y1={yt} x2={px(4) + 26} y2={yt} stroke="var(--gray-300)" strokeWidth={1} />
      <Label x={px(4) + 42} y={(yt + y0) / 2} anchor="start">{`${height} ${unit}`}</Label>
    </svg>
  );
}

import React from 'react';
import { ArrowMarkerDefs, PinSupport, RollerSupport, Label } from '../../primitives';

/**
 * Symmetric pitched roof truss, four bottom panels, loads at the three top
 * joints.
 * Shows: joint letters, panel width, heights, supports, loads.
 * Does NOT show: member forces.
 */
export function CtStaticsARoofTruss({ panel = 6, rise = 8, load = 3, unit = 'kips' }) {
  const S = 13;
  const x0 = 34;
  const y0 = 170;
  const px = (i) => x0 + i * panel * S;
  const yAt = (i) => y0 - (rise * S * (i <= 2 ? i : 4 - i)) / 2;
  const J = {
    A: [px(0), y0], B: [px(1), y0], C: [px(2), y0], D: [px(3), y0], E: [px(4), y0],
    F: [px(1), yAt(1)], G: [px(2), yAt(2)], H: [px(3), yAt(3)],
  };
  const members = ['AB', 'BC', 'CD', 'DE', 'AF', 'FG', 'GH', 'HE', 'BF', 'CG', 'DH', 'FC', 'HC'];
  const gray = 'var(--gray-500)';
  const dimY = y0 + 50;
  const W = px(4) + 66;
  const top = yAt(2) - 56;
  const H = dimY + 20 - top;

  const loadArrow = (k) => {
    const [x, y] = J[k];
    const left = k === 'F';
    return (
      <g key={k}>
        <line x1={x} y1={y - 46} x2={x} y2={y - 5} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStARoofArrow)" />
        <Label x={left ? x - 7 : x + 7} y={y - 36} color="var(--ember)" bold anchor={left ? 'end' : 'start'}>{`${load} ${unit}`}</Label>
      </g>
    );
  };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Roof truss, 4 panels of ${panel} ft, rise ${rise} ft, ${load} ${unit} at joints F, G and H`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStARoofArrow" color="var(--ember)" size={9} />
      <g transform={`translate(0,${-top})`}>

      {members.map((m) => (
        <line key={m} x1={J[m[0]][0]} y1={J[m[0]][1]} x2={J[m[1]][0]} y2={J[m[1]][1]} stroke="var(--charcoal)" strokeWidth={2.2} strokeLinecap="round" />
      ))}
      {Object.entries(J).map(([k, [x, y]]) => (
        <circle key={k} cx={x} cy={y} r={3.2} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      ))}

      <Label x={J.A[0] - 14} y={J.A[1] - 6} color="var(--charcoal)" bold>A</Label>
      <Label x={J.B[0]} y={J.B[1] + 14} color="var(--charcoal)" bold>B</Label>
      <Label x={J.C[0]} y={J.C[1] + 14} color="var(--charcoal)" bold>C</Label>
      <Label x={J.D[0]} y={J.D[1] + 14} color="var(--charcoal)" bold>D</Label>
      <Label x={J.E[0] + 14} y={J.E[1] - 6} color="var(--charcoal)" bold>E</Label>
      <Label x={J.F[0] - 14} y={J.F[1] - 8} color="var(--charcoal)" bold>F</Label>
      <Label x={J.G[0] - 14} y={J.G[1] - 8} color="var(--charcoal)" bold>G</Label>
      <Label x={J.H[0] + 14} y={J.H[1] - 8} color="var(--charcoal)" bold>H</Label>

      {['F', 'G', 'H'].map(loadArrow)}

      <PinSupport x={J.A[0]} y={J.A[1] + 3} />
      <RollerSupport x={J.E[0]} y={J.E[1] + 3} />

      {/* Panel dimensions */}
      {[0, 1, 2, 3, 4].map((i) => (
        <line key={i} x1={px(i)} y1={dimY - 6} x2={px(i)} y2={dimY + 6} stroke={gray} strokeWidth={1} />
      ))}
      <line x1={px(0)} y1={dimY} x2={px(4)} y2={dimY} stroke={gray} strokeWidth={1} />
      <Label x={(px(0) + px(4)) / 2} y={dimY + 13}>{`4 panels at ${panel} ft`}</Label>

      {/* Heights at the right: H above D, G above C */}
      <line x1={J.G[0] + 6} y1={J.G[1]} x2={px(4) + 34} y2={J.G[1]} stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={px(4) + 30} y1={J.G[1]} x2={px(4) + 30} y2={y0} stroke={gray} strokeWidth={1} />
      <line x1={px(4) + 25} y1={J.G[1]} x2={px(4) + 35} y2={J.G[1]} stroke={gray} strokeWidth={1} />
      <line x1={px(4) + 25} y1={y0} x2={px(4) + 35} y2={y0} stroke={gray} strokeWidth={1} />
      <Label x={px(4) + 38} y={(J.G[1] + y0) / 2} anchor="start">{`${rise} ft`}</Label>
      </g>
    </svg>
  );
}

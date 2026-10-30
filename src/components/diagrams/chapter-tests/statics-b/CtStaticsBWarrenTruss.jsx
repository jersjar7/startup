import React from 'react';
import { ArrowMarkerDefs, PinSupport, RollerSupport, Label } from '../../primitives';

/** Ground line with short hatch strokes under a support. */
function Ground({ x, y }) {
  return (
    <g>
      <line x1={x - 13} y1={y} x2={x + 13} y2={y} stroke="var(--charcoal)" strokeWidth={2} />
      {[0, 1, 2, 3, 4].map((i) => (
        <line key={i} x1={x - 8 + i * 5} y1={y} x2={x - 13 + i * 5} y2={y + 5} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}
    </g>
  );
}

/**
 * Three-panel Warren truss (no verticals), top joints centered over the
 * bottom panels. Loads at bottom joints B and C.
 * Shows: joint letters, supports, loads, panel, half-panel and depth dimensions.
 * Does NOT show: member forces or the section cut.
 */
export function CtStaticsBWarrenTruss({ panel = 6, height = 4, loadB = 30, loadC = 60, unit = 'm', fu = 'kN' }) {
  const S = 17;
  const x0 = 30;
  const y0 = 128;
  const yt = y0 - height * S;
  const bx = (i) => x0 + i * panel * S;
  const tx = (i) => x0 + (i + 0.5) * panel * S;
  const J = {
    A: [bx(0), y0], B: [bx(1), y0], C: [bx(2), y0], D: [bx(3), y0],
    E: [tx(0), yt], F: [tx(1), yt], G: [tx(2), yt],
  };
  const members = ['AB', 'BC', 'CD', 'EF', 'FG', 'AE', 'EB', 'BF', 'FC', 'CG', 'GD'];
  const gray = 'var(--gray-500)';
  const dimY = y0 + 70;
  const topDimY = yt - 30;
  const hx = bx(3) + 30;

  return (
    <svg viewBox={`0 0 ${hx + 40} ${dimY + 20}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Warren truss, three ${panel} ${unit} panels, ${height} ${unit} deep, ${loadB} ${fu} at B and ${loadC} ${fu} at C`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBWarArrow" color="var(--ember)" size={9} />

      {members.map((m) => (
        <line key={m} x1={J[m[0]][0]} y1={J[m[0]][1]} x2={J[m[1]][0]} y2={J[m[1]][1]} stroke="var(--charcoal)" strokeWidth={2.2} strokeLinecap="round" />
      ))}
      {Object.entries(J).map(([k, [x, y]]) => (
        <circle key={k} cx={x} cy={y} r={3.2} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      ))}
      <Label x={J.A[0] - 13} y={J.A[1] - 9} color="var(--charcoal)" bold>A</Label>
      <Label x={J.B[0] - 11} y={J.B[1] + 13} color="var(--charcoal)" bold>B</Label>
      <Label x={J.C[0] - 11} y={J.C[1] + 13} color="var(--charcoal)" bold>C</Label>
      <Label x={J.D[0] + 13} y={J.D[1] - 9} color="var(--charcoal)" bold>D</Label>
      <Label x={J.E[0]} y={J.E[1] - 12} color="var(--charcoal)" bold>E</Label>
      <Label x={J.F[0]} y={J.F[1] - 12} color="var(--charcoal)" bold>F</Label>
      <Label x={J.G[0]} y={J.G[1] - 12} color="var(--charcoal)" bold>G</Label>

      <PinSupport x={J.A[0]} y={J.A[1] + 3} />
      <Ground x={J.A[0]} y={J.A[1] + 19} />
      <RollerSupport x={J.D[0]} y={J.D[1] + 3} />
      <Ground x={J.D[0]} y={J.D[1] + 29} />

      {/* Loads hanging below B and C */}
      <line x1={J.B[0]} y1={y0 + 4} x2={J.B[0]} y2={y0 + 50} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBWarArrow)" />
      <Label x={J.B[0] + 8} y={y0 + 42} color="var(--ember)" bold anchor="start">{`${loadB} ${fu}`}</Label>
      <line x1={J.C[0]} y1={y0 + 4} x2={J.C[0]} y2={y0 + 50} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBWarArrow)" />
      <Label x={J.C[0] + 8} y={y0 + 42} color="var(--ember)" bold anchor="start">{`${loadC} ${fu}`}</Label>

      {/* Bottom panel dimensions */}
      <line x1={bx(0)} y1={dimY} x2={bx(3)} y2={dimY} stroke={gray} strokeWidth={1} />
      {[0, 1, 2, 3].map((i) => <line key={i} x1={bx(i)} y1={dimY - 5} x2={bx(i)} y2={dimY + 5} stroke={gray} strokeWidth={1} />)}
      {[0, 1, 2].map((i) => <Label key={i} x={(bx(i) + bx(i + 1)) / 2} y={dimY + 13}>{`${panel} ${unit}`}</Label>)}

      {/* Half-panel offset of E */}
      <line x1={bx(0)} y1={topDimY} x2={tx(0)} y2={topDimY} stroke={gray} strokeWidth={1} />
      <line x1={bx(0)} y1={topDimY - 5} x2={bx(0)} y2={topDimY + 5} stroke={gray} strokeWidth={1} />
      <line x1={tx(0)} y1={topDimY - 5} x2={tx(0)} y2={topDimY + 5} stroke={gray} strokeWidth={1} />
      <line x1={bx(0)} y1={topDimY + 6} x2={bx(0)} y2={y0 - 24} stroke="var(--gray-300)" strokeWidth={1} />
      <Label x={(bx(0) + tx(0)) / 2} y={topDimY - 11}>{`${panel / 2} ${unit}`}</Label>

      {/* Depth dimension */}
      <line x1={hx} y1={yt} x2={hx} y2={y0} stroke={gray} strokeWidth={1} />
      <line x1={hx - 5} y1={yt} x2={hx + 5} y2={yt} stroke={gray} strokeWidth={1} />
      <line x1={hx - 5} y1={y0} x2={hx + 5} y2={y0} stroke={gray} strokeWidth={1} />
      <line x1={J.G[0] + 8} y1={yt} x2={hx - 6} y2={yt} stroke="var(--gray-300)" strokeWidth={1} />
      <Label x={hx + 8} y={(yt + y0) / 2} anchor="start">{`${height} ${unit}`}</Label>
    </svg>
  );
}

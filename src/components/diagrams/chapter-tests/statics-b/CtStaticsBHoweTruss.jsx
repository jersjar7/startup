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
 * Four-panel Howe truss with vertical end posts. Diagonals rise toward
 * mid-span. Single load P at top joint G.
 * Shows: joint letters, supports, the load, panel and height dimensions.
 * Does NOT show: which members are zero-force.
 */
export function CtStaticsBHoweTruss({ panel = 15, height = 12, unit = 'ft', loadLabel = 'P' }) {
  const S = 4.8;
  const x0 = 34;
  const y0 = 120;
  const yt = y0 - height * S;
  const px = (i) => x0 + i * panel * S;
  const J = {
    A: [px(0), y0], B: [px(1), y0], C: [px(2), y0], D: [px(3), y0], E: [px(4), y0],
    F: [px(0), yt], G: [px(1), yt], H: [px(2), yt], I: [px(3), yt], J: [px(4), yt],
  };
  const members = ['AB', 'BC', 'CD', 'DE', 'FG', 'GH', 'HI', 'IJ', 'AF', 'BG', 'CH', 'DI', 'EJ', 'AG', 'BH', 'DH', 'EI'];
  const gray = 'var(--gray-500)';
  const dimY = y0 + 52;
  const hx = px(4) + 32;

  return (
    <svg viewBox={`0 0 ${hx + 44} ${dimY + 20}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Howe truss, four ${panel} ${unit} panels, ${height} ${unit} deep, load ${loadLabel} at G`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBHoweArrow" color="var(--ember)" size={9} />

      {members.map((m) => (
        <line key={m} x1={J[m[0]][0]} y1={J[m[0]][1]} x2={J[m[1]][0]} y2={J[m[1]][1]} stroke="var(--charcoal)" strokeWidth={2.2} strokeLinecap="round" />
      ))}
      {Object.entries(J).map(([k, [x, y]]) => (
        <circle key={k} cx={x} cy={y} r={3.2} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      ))}

      {['A', 'B', 'C', 'D', 'E'].map((k, i) => (
        <Label key={k} x={J[k][0] + (i === 0 ? -13 : i === 4 ? 13 : 10)} y={J[k][1] + (i === 0 || i === 4 ? -9 : 13)} color="var(--charcoal)" bold>{k}</Label>
      ))}
      {['F', 'H', 'I', 'J'].map((k) => (
        <Label key={k} x={J[k][0]} y={J[k][1] - 13} color="var(--charcoal)" bold>{k}</Label>
      ))}
      <Label x={J.G[0] - 12} y={J.G[1] - 12} color="var(--charcoal)" bold>G</Label>

      <PinSupport x={J.A[0]} y={J.A[1] + 3} />
      <Ground x={J.A[0]} y={J.A[1] + 19} />
      <RollerSupport x={J.E[0]} y={J.E[1] + 3} />
      <Ground x={J.E[0]} y={J.E[1] + 29} />

      {/* Load at G */}
      <line x1={J.G[0]} y1={yt - 44} x2={J.G[0]} y2={yt - 5} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBHoweArrow)" />
      <Label x={J.G[0] + 9} y={yt - 36} color="var(--ember)" bold italic anchor="start">{loadLabel}</Label>

      {/* Panel dimension */}
      <line x1={px(0)} y1={dimY} x2={px(4)} y2={dimY} stroke={gray} strokeWidth={1} />
      {[0, 1, 2, 3, 4].map((i) => <line key={i} x1={px(i)} y1={dimY - 5} x2={px(i)} y2={dimY + 5} stroke={gray} strokeWidth={1} />)}
      <Label x={(px(0) + px(4)) / 2} y={dimY + 13}>{`4 panels at ${panel} ${unit}`}</Label>

      {/* Height dimension */}
      <line x1={hx} y1={yt} x2={hx} y2={y0} stroke={gray} strokeWidth={1} />
      <line x1={hx - 5} y1={yt} x2={hx + 5} y2={yt} stroke={gray} strokeWidth={1} />
      <line x1={hx - 5} y1={y0} x2={hx + 5} y2={y0} stroke={gray} strokeWidth={1} />
      <line x1={J.J[0] + 16} y1={yt} x2={hx - 6} y2={yt} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={J.E[0] + 22} y1={y0} x2={hx - 6} y2={y0} stroke="var(--gray-300)" strokeWidth={1} />
      <Label x={hx + 8} y={(yt + y0) / 2} anchor="start">{`${height} ${unit}`}</Label>
    </svg>
  );
}

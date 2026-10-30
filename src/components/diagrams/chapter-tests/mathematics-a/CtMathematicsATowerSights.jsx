import React from 'react';
import { DimensionLine, Label } from '../../primitives';
import { arcPath, polar } from '../../geo';

/**
 * Two-station sighting of a tower top on level ground.
 * Shows: stations A and B, the distance AB, the vertical angle at each
 * station, the unknown height h. Does NOT show h or the distance B to tower.
 */
export function CtMathematicsATowerSights({ d = 150, alphaDeg = 18.5, betaDeg = 31.25, alphaLabel = '18°30′', betaLabel = '31°15′', dLabel = '150.0 ft' }) {
  const ta = Math.tan((alphaDeg * Math.PI) / 180);
  const tb = Math.tan((betaDeg * Math.PI) / 180);
  const h = (d * ta * tb) / (tb - ta);
  const xb = h / tb;                    // B to tower, ft (drawn, never labelled)
  const s = 330 / (d + xb);             // px per ft, true proportions
  const ax = 22, gy = 20 + h * s;
  const bx = ax + d * s, tx = bx + xb * s, ty = gy - h * s;
  const W = tx + 44, H = gy + 50;
  const ra = 54, rb = 38;
  const la = polar(ax, gy, ra + 5, alphaDeg / 2);
  const lb = polar(bx, gy, rb + 5, betaDeg / 2);
  const hatch = [];
  for (let x = 8; x < W - 8; x += 10) hatch.push(<line key={x} x1={x} y1={gy} x2={x - 6} y2={gy + 6} stroke="var(--gray-400)" strokeWidth={1} />);

  return (
    <svg viewBox={`0 0 ${W.toFixed(0)} ${H.toFixed(0)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Tower sighted from A and from B, ${dLabel} apart, vertical angles ${alphaLabel} and ${betaLabel}`}
      style={{ width: '100%', height: 'auto' }}>
      {/* ground */}
      <line x1={4} y1={gy} x2={W - 4} y2={gy} stroke="var(--charcoal)" strokeWidth={1.5} />
      {hatch}
      {/* tower: tapered lattice */}
      <polygon points={`${tx - 7},${gy} ${tx - 2},${ty} ${tx + 2},${ty} ${tx + 7},${gy}`} fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      {[0, 1, 2, 3].map((i) => {
        const y1 = gy - (i * h * s) / 4, y2 = gy - ((i + 1) * h * s) / 4;
        const w1 = 7 - (5 * i) / 4, w2 = 7 - (5 * (i + 1)) / 4;
        return <g key={i}><line x1={tx - w1} y1={y1} x2={tx + w2} y2={y2} stroke="var(--charcoal)" strokeWidth={1} /><line x1={tx + w1} y1={y1} x2={tx - w2} y2={y2} stroke="var(--charcoal)" strokeWidth={1} /></g>;
      })}
      {/* lines of sight */}
      <line x1={ax} y1={gy} x2={tx} y2={ty} stroke="var(--gray-500)" strokeWidth={1.3} />
      <line x1={bx} y1={gy} x2={tx} y2={ty} stroke="var(--gray-500)" strokeWidth={1.3} />
      {/* angles */}
      <path d={arcPath(ax, gy, ra, 0, alphaDeg)} fill="none" stroke="var(--ember)" strokeWidth={1.5} />
      <path d={arcPath(bx, gy, rb, 0, betaDeg)} fill="none" stroke="var(--ember)" strokeWidth={1.5} />
      <Label x={la.x} y={la.y - 1} anchor="start" color="var(--ember)" fontSize={11}>{alphaLabel}</Label>
      <Label x={lb.x} y={lb.y - 1} anchor="start" color="var(--ember)" fontSize={11}>{betaLabel}</Label>
      {/* stations */}
      <circle cx={ax} cy={gy} r={3.5} fill="var(--charcoal)" />
      <circle cx={bx} cy={gy} r={3.5} fill="var(--charcoal)" />
      <Label x={ax} y={gy + 16} bold color="var(--charcoal)">A</Label>
      <Label x={bx} y={gy + 16} bold color="var(--charcoal)">B</Label>
      {/* AB */}
      <DimensionLine x1={ax} y1={gy + 32} x2={bx} y2={gy + 32} />
      <Label x={(ax + bx) / 2} y={gy + 43} fontSize={12}>{dLabel}</Label>
      {/* tower height, unknown */}
      <DimensionLine x1={tx + 22} y1={gy} x2={tx + 22} y2={ty} />
      <line x1={tx + 4} y1={ty} x2={tx + 27} y2={ty} stroke="var(--gray-400)" strokeWidth={1} />
      <Label x={tx + 30} y={(gy + ty) / 2} anchor="start" italic bold color="var(--charcoal)" fontSize={13}>h</Label>
    </svg>
  );
}

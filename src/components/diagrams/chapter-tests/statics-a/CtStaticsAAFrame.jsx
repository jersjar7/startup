import React from 'react';
import { ArrowMarkerDefs, PinSupport, Label } from '../../primitives';

/**
 * A-frame: legs AC and BC pinned together at C and pinned to the ground at
 * A and B. A load hangs from D, the midpoint of leg AC.
 * Shows: geometry, the load, the pins.
 * Does NOT show: pin forces or reactions.
 */
export function CtStaticsAAFrame({ halfSpan = 3, height = 4, load = 10, unit = 'kN' }) {
  const S = 40;
  const ax = 70;
  const ay = 196;
  const bx = ax + 2 * halfSpan * S;
  const cx = ax + halfSpan * S;
  const cy = ay - height * S;
  const dx = (ax + cx) / 2;
  const dy = (ay + cy) / 2;
  const gray = 'var(--gray-500)';
  const dimY = ay + 46;
  const W = bx + 80;

  return (
    <svg viewBox={`0 0 ${W} ${dimY + 20}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`A-frame ${2 * halfSpan} m wide and ${height} m tall with ${load} ${unit} hanging from the midpoint of leg AC`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStAAfArrow" color="var(--ember)" size={9} />

      {/* Legs */}
      <line x1={ax} y1={ay} x2={cx} y2={cy} stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />
      <line x1={bx} y1={ay} x2={cx} y2={cy} stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Pins */}
      <PinSupport x={ax} y={ay} size={18} />
      <PinSupport x={bx} y={ay} size={18} />
      {[[ax, ay], [bx, ay], [cx, cy]].map(([x, y], i) => (
        <circle key={i} cx={x} cy={y} r={4.5} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.8} />
      ))}
      <circle cx={dx} cy={dy} r={3} fill="var(--charcoal)" />

      <Label x={ax - 18} y={ay - 6} color="var(--charcoal)" bold>A</Label>
      <Label x={bx + 18} y={ay - 6} color="var(--charcoal)" bold>B</Label>
      <Label x={cx} y={cy - 16} color="var(--charcoal)" bold>C</Label>
      <Label x={dx - 14} y={dy - 8} color="var(--charcoal)" bold>D</Label>

      {/* Load hanging from D */}
      <line x1={dx} y1={dy + 3} x2={dx} y2={dy + 56} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctStAAfArrow)" />
      <Label x={dx + 8} y={dy + 44} color="var(--ember)" bold anchor="start">{`${load} ${unit}`}</Label>

      {/* Horizontal dimensions */}
      <line x1={cx} y1={cy + 8} x2={cx} y2={dimY + 6} stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={ax} y1={dimY} x2={bx} y2={dimY} stroke={gray} strokeWidth={1} />
      {[ax, cx, bx].map((x) => (
        <line key={x} x1={x} y1={dimY - 5} x2={x} y2={dimY + 5} stroke={gray} strokeWidth={1} />
      ))}
      <Label x={(ax + cx) / 2} y={dimY + 12}>{`${halfSpan} m`}</Label>
      <Label x={(cx + bx) / 2} y={dimY + 12}>{`${halfSpan} m`}</Label>

      {/* Height dimension */}
      <line x1={cx + 8} y1={cy} x2={bx + 44} y2={cy} stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={bx + 38} y1={cy} x2={bx + 38} y2={ay} stroke={gray} strokeWidth={1} />
      <line x1={bx + 33} y1={cy} x2={bx + 43} y2={cy} stroke={gray} strokeWidth={1} />
      <line x1={bx + 33} y1={ay} x2={bx + 43} y2={ay} stroke={gray} strokeWidth={1} />
      <Label x={bx + 46} y={(cy + ay) / 2} anchor="start">{`${height} m`}</Label>
    </svg>
  );
}

import React from 'react';
import { arcPath, deg } from '../../geo';
import { Label } from '../../primitives';

/**
 * Circular curve with its center O, the two radii to PC and PT, the long
 * chord, and the segment between arc and chord shaded. To scale.
 */
export function CtSurveyingACurveSegment({ R = 720, I = 48 }) {
  const rp = 260;
  const half = deg(I / 2);
  const W = 380;
  const O = { x: W / 2, y: 22 + rp };
  const pc = { x: O.x - rp * Math.sin(half), y: O.y - rp * Math.cos(half) };
  const pt = { x: O.x + rp * Math.sin(half), y: pc.y };
  const H = O.y + 26;
  const radMid = { x: (O.x + pc.x) / 2, y: (O.y + pc.y) / 2 };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Circular curve, radius ${R} ft, central angle ${I} degrees, with the segment between arc and long chord shaded`}
      style={{ width: '100%', height: 'auto' }}>
      <path d={`M ${pc.x},${pc.y} A ${rp},${rp} 0 0 1 ${pt.x},${pt.y} Z`}
        fill="var(--ember)" fillOpacity={0.18} stroke="none" />
      <line x1={O.x} y1={O.y} x2={pc.x} y2={pc.y} stroke="var(--gray-500)" strokeWidth={1.3} strokeDasharray="6,4" />
      <line x1={O.x} y1={O.y} x2={pt.x} y2={pt.y} stroke="var(--gray-500)" strokeWidth={1.3} strokeDasharray="6,4" />
      <line x1={pc.x} y1={pc.y} x2={pt.x} y2={pt.y} stroke="var(--charcoal)" strokeWidth={1.5} />
      <path d={`M ${pc.x},${pc.y} A ${rp},${rp} 0 0 1 ${pt.x},${pt.y}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <path d={arcPath(O.x, O.y, rp * 0.22, 90 - I / 2, 90 + I / 2)} fill="none" stroke="var(--gray-500)" strokeWidth={1.3} />

      {[pc, pt, O].map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={3.2} fill="var(--charcoal)" />)}
      <Label x={pc.x - 10} y={pc.y} anchor="end" color="var(--charcoal)" fontSize={12} bold>PC</Label>
      <Label x={pt.x + 10} y={pt.y} anchor="start" color="var(--charcoal)" fontSize={12} bold>PT</Label>
      <Label x={O.x} y={O.y + 15} color="var(--charcoal)" fontSize={12} bold>O</Label>
      <Label x={O.x} y={O.y - rp * 0.22 - 14} color="var(--charcoal)" fontSize={12}>{`I = ${I}°`}</Label>
      <Label x={radMid.x - 8} y={radMid.y} anchor="end" color="var(--gray-500)" fontSize={12}>{`R = ${R} ft`}</Label>
      <Label x={O.x} y={pc.y + 16} color="var(--gray-500)" fontSize={12}>Long chord</Label>
    </svg>
  );
}

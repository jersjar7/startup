import React from 'react';
import { arcPath } from '../../geo';
import { Label } from '../../primitives';

/**
 * Corner lot at a curved street, plan view, to scale. Back tangent runs
 * east from the PC to the PI, the forward tangent turns right by I to the
 * PT. Radii from the center O to the PC and PT. The strip between the
 * tangents and the arc is shaded.
 */
export function CtSurveyingBFilletArea({ R = 350, I = 72 }) {
  const rad = (d) => (d * Math.PI) / 180;
  const T = R * Math.tan(rad(I / 2));
  const s = 250 / R;
  const O = { x: 84, y: 34 + R * s };
  const pc = { x: O.x, y: O.y - R * s };
  const pi = { x: pc.x + T * s, y: pc.y };
  const ptAng = 90 - I; // math angle of the PT seen from O
  const pt = { x: O.x + R * s * Math.cos(rad(ptAng)), y: O.y - R * s * Math.sin(rad(ptAng)) };
  const ext = 40;
  const fwd = { x: Math.cos(rad(I)), y: Math.sin(rad(I)) };
  const after = { x: pt.x + fwd.x * ext, y: pt.y + fwd.y * ext };
  const W = Math.ceil(Math.max(after.x, pi.x + 60) + 16);
  const H = Math.ceil(O.y + 26);
  const rLab = { x: O.x - 8, y: (O.y + pc.y) / 2 };
  const sq = 9;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Curve of radius ${R} ft and intersection angle ${I} degrees; the strip between the tangents and the curve is shaded`}
      style={{ width: '100%', height: 'auto' }}>
      {/* shaded strip */}
      <path d={`M ${pc.x},${pc.y} L ${pi.x},${pi.y} L ${pt.x},${pt.y} A ${R * s},${R * s} 0 0 0 ${pc.x},${pc.y} Z`}
        fill="var(--ember)" fillOpacity={0.2} stroke="none" />
      {/* tangent lines */}
      <line x1={pc.x - 30} y1={pc.y} x2={pi.x} y2={pi.y} stroke="var(--charcoal)" strokeWidth={1.6} />
      <line x1={pi.x} y1={pi.y} x2={after.x} y2={after.y} stroke="var(--charcoal)" strokeWidth={1.6} />
      {/* curve */}
      <path d={`M ${pc.x},${pc.y} A ${R * s},${R * s} 0 0 1 ${pt.x},${pt.y}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* radii */}
      <line x1={O.x} y1={O.y} x2={pc.x} y2={pc.y} stroke="var(--gray-500)" strokeWidth={1.2} strokeDasharray="6,4" />
      <line x1={O.x} y1={O.y} x2={pt.x} y2={pt.y} stroke="var(--gray-500)" strokeWidth={1.2} strokeDasharray="6,4" />
      {/* right angles at PC and PT */}
      <polyline points={`${pc.x},${pc.y + sq} ${pc.x + sq},${pc.y + sq} ${pc.x + sq},${pc.y}`} fill="none" stroke="var(--gray-500)" strokeWidth={1} />
      {(() => {
        const u = { x: (O.x - pt.x) / (R * s), y: (O.y - pt.y) / (R * s) }; // toward O
        const a = { x: pt.x + u.x * sq, y: pt.y + u.y * sq };
        const b = { x: a.x - fwd.x * sq, y: a.y - fwd.y * sq };
        const c = { x: pt.x - fwd.x * sq, y: pt.y - fwd.y * sq };
        return <polyline points={`${a.x},${a.y} ${b.x},${b.y} ${c.x},${c.y}`} fill="none" stroke="var(--gray-500)" strokeWidth={1} />;
      })()}
      {/* central angle */}
      <path d={arcPath(O.x, O.y, 46, ptAng, 90)} fill="none" stroke="var(--gray-500)" strokeWidth={1.3} />
      <Label x={O.x + 30} y={O.y - 58} anchor="start" color="var(--charcoal)" fontSize={12}>{`I = ${I}°`}</Label>

      {[pc, pi, pt].map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={3.2} fill="var(--charcoal)" />)}
      <circle cx={O.x} cy={O.y} r={3} fill="var(--charcoal)" />
      <Label x={pc.x} y={pc.y - 14} color="var(--charcoal)" fontSize={12} bold>PC</Label>
      <Label x={pi.x} y={pi.y - 14} color="var(--charcoal)" fontSize={12} bold>PI</Label>
      <Label x={pt.x + 12} y={pt.y + 4} anchor="start" color="var(--charcoal)" fontSize={12} bold>PT</Label>
      <Label x={O.x - 10} y={O.y + 4} anchor="end" color="var(--charcoal)" fontSize={12} bold>O</Label>
      <Label x={rLab.x} y={rLab.y} anchor="end" color="var(--gray-500)" fontSize={12}>{`R = ${R} ft`}</Label>
    </svg>
  );
}

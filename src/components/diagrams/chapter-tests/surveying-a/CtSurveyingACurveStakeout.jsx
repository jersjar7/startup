import React from 'react';
import { arcPath, deg } from '../../geo';
import { Label } from '../../primitives';

/**
 * Horizontal curve stakeout, plan view, NOT to scale. The real deflection
 * (under 5 degrees) would be unreadable, so the sketch exaggerates the
 * curve: it draws I at 60 degrees and the arc PC to P at 36 degrees.
 * Back tangent runs east to the PI, the curve turns right. Shows R (on the
 * radius O to PC), I, the PI station, point P with its station, and the
 * deflection angle at the PC (marked, not valued). PC station is not shown.
 */
const DRAW_I = 60;
const DRAW_P = 36; // drawn central angle PC to P; the deflection is half

export function CtSurveyingACurveStakeout({ R = 850, I = 28, piSta = '34+20.00', pSta = '33+50.00' }) {
  const rp = 260;
  const T = rp * Math.tan(deg(DRAW_I / 2));
  const pc = { x: 80, y: 50 };
  const O = { x: pc.x, y: pc.y + rp };
  const pi = { x: pc.x + T, y: pc.y };
  const pt = { x: pi.x + T * Math.cos(deg(DRAW_I)), y: pi.y + T * Math.sin(deg(DRAW_I)) };
  const phi = deg(DRAW_P);
  const P = { x: pc.x + rp * Math.sin(phi), y: pc.y + rp * (1 - Math.cos(phi)) };
  const ext = 34;
  const after = { x: pt.x + ext * Math.cos(deg(DRAW_I)), y: pt.y + ext * Math.sin(deg(DRAW_I)) };
  const dAng = DRAW_P / 2; // drawn deflection, degrees below east
  const dLab = { x: pc.x + 64 * Math.cos(deg(dAng + 11)), y: pc.y + 64 * Math.sin(deg(dAng + 11)) };
  const W = 360;
  const H = Math.ceil(O.y + 30);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Horizontal curve sketch, not to scale: R ${R} ft, I ${I} degrees, PI at station ${piSta}, point P at station ${pSta}`}
      style={{ width: '100%', height: 'auto' }}>
      {/* approach and departure (road centerline) */}
      <line x1={pc.x - 56} y1={pc.y} x2={pc.x} y2={pc.y} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={pt.x} y1={pt.y} x2={after.x} y2={after.y} stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* tangents and back-tangent extension */}
      <line x1={pc.x} y1={pc.y} x2={pi.x + 64} y2={pi.y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="6,4" />
      <line x1={pi.x} y1={pi.y} x2={pt.x} y2={pt.y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="6,4" />
      {/* radius O to PC */}
      <line x1={O.x} y1={O.y} x2={pc.x} y2={pc.y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="6,4" />
      {/* the curve */}
      <path d={`M ${pc.x},${pc.y} A ${rp},${rp} 0 0 1 ${pt.x},${pt.y}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* line of sight PC to P and the deflection angle */}
      <line x1={pc.x} y1={pc.y} x2={P.x} y2={P.y} stroke="var(--ember)" strokeWidth={1.3} strokeDasharray="4,3" />
      <path d={arcPath(pc.x, pc.y, 60, -dAng, 0)} fill="none" stroke="var(--ember)" strokeWidth={1.5} />
      <Label x={dLab.x} y={dLab.y} color="var(--ember)" fontSize={13} italic>δ</Label>
      {/* intersection angle */}
      <path d={arcPath(pi.x, pi.y, 40, -DRAW_I, 0)} fill="none" stroke="var(--gray-500)" strokeWidth={1.3} />
      <Label x={pi.x + 50} y={pi.y + 17} anchor="start" color="var(--charcoal)" fontSize={12}>{`I = ${I}°`}</Label>

      {[pc, pi, pt, O].map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={3.2} fill="var(--charcoal)" />)}
      <circle cx={P.x} cy={P.y} r={3.6} fill="var(--ember)" />

      <Label x={pc.x} y={pc.y - 14} color="var(--charcoal)" fontSize={12} bold>PC</Label>
      <Label x={pi.x} y={pi.y - 28} color="var(--charcoal)" fontSize={12} bold>PI</Label>
      <Label x={pi.x} y={pi.y - 13} color="var(--gray-500)" fontSize={12}>{`Sta ${piSta}`}</Label>
      <Label x={pt.x + 10} y={pt.y - 10} anchor="start" color="var(--charcoal)" fontSize={12} bold>PT</Label>
      <Label x={P.x - 8} y={P.y + 18} anchor="end" color="var(--ember)" fontSize={12}>{`P, Sta ${pSta}`}</Label>
      <Label x={O.x + 10} y={O.y + 2} anchor="start" color="var(--charcoal)" fontSize={12} bold>O</Label>
      <Label x={O.x - 8} y={(O.y + pc.y) / 2} anchor="end" color="var(--gray-500)" fontSize={12}>{`R = ${R} ft`}</Label>
      <Label x={14} y={H - 10} anchor="start" color="var(--gray-500)" fontSize={11}>NOT TO SCALE</Label>
    </svg>
  );
}

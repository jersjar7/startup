import React from 'react';
import { Label } from '../../primitives';
import { polar, arcPath } from '../../geo';

/**
 * Wrecking ball pulled back from a crane boom tip and about to be released.
 * Shows: cable length to the ball centre, release angle from vertical,
 * ball weight, the vertical through the pin and the lowest point.
 * Does NOT show: the height drop, the speed or the tension.
 */
export function CtDynamicsBWreckingBall({ length = 8.0, angle = 40, weight = 9.0 }) {
  const S = 25; // px per metre
  const L = length * S;
  const O = { x: 176, y: 20 };
  const ballR = 15;
  const P = polar(O.x, O.y, L, -90 + angle); // released position
  const Q = { x: O.x, y: O.y + L }; // lowest point
  const boomFoot = { x: O.x - 156, y: O.y + 112 };
  const bx = O.x - boomFoot.x;
  const by = O.y - boomFoot.y;
  const bl = Math.hypot(bx, by);
  const bn = { x: (-by / bl) * 5, y: (bx / bl) * 5 };
  const arcR = 46;
  const angLbl = polar(O.x, O.y, arcR + 14, -90 + angle / 2);
  const mid = polar(O.x, O.y, L * 0.5, -90 + angle);
  const perp = polar(0, 0, 12, angle); // toward the upper right of the cable

  return (
    <svg viewBox={`0 0 ${P.x + ballR + 92} ${Q.y + ballR + 14}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Wrecking ball weighing ${weight} kN on a ${length} m cable, pulled back ${angle} degrees from vertical`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Boom tip */}
      <polygon points={`${boomFoot.x + bn.x},${boomFoot.y + bn.y} ${O.x + bn.x},${O.y + bn.y} ${O.x - bn.x},${O.y - bn.y} ${boomFoot.x - bn.x},${boomFoot.y - bn.y}`}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.8} strokeLinejoin="round" />
      <Label x={boomFoot.x + 0.35 * bx + bn.x * 4} y={boomFoot.y + 0.35 * by + bn.y * 4} color="var(--charcoal)" fontSize={12} anchor="start">crane boom</Label>

      {/* Vertical through the pin, the ball's path and its lowest position */}
      <line x1={O.x} y1={O.y} x2={Q.x} y2={Q.y - ballR - 2} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="4,3" />
      <path d={arcPath(O.x, O.y, L, -90 + angle, -90)} fill="none" stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="4,3" />
      <circle cx={Q.x} cy={Q.y} r={ballR} fill="none" stroke="var(--gray-400)" strokeWidth={1.4} strokeDasharray="4,3" />
      <Label x={Q.x - ballR - 8} y={Q.y} color="var(--gray-500)" fontSize={12} anchor="end">lowest point</Label>

      {/* Angle from vertical */}
      <path d={arcPath(O.x, O.y, arcR, -90, -90 + angle)} fill="none" stroke="var(--gray-500)" strokeWidth={1.4} />
      <Label x={angLbl.x} y={angLbl.y} color="var(--gray-500)" fontSize={12}>{`${angle}°`}</Label>

      {/* Cable and ball at release */}
      <line x1={O.x} y1={O.y} x2={P.x} y2={P.y} stroke="var(--charcoal)" strokeWidth={1.8} />
      <Label x={mid.x + perp.x} y={mid.y + perp.y} color="var(--charcoal)" fontSize={12} anchor="start">{`${length.toFixed(1)} m`}</Label>
      <circle cx={P.x} cy={P.y} r={ballR} fill="var(--charcoal)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <Label x={P.x + ballR + 8} y={P.y} color="var(--ember)" fontSize={12} anchor="start">{`W = ${weight.toFixed(1)} kN`}</Label>

      {/* Pin at the boom tip */}
      <circle cx={O.x} cy={O.y} r={5} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.8} />
    </svg>
  );
}

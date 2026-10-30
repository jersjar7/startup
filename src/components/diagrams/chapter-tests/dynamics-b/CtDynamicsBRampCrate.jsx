import React from 'react';
import { Label } from '../../primitives';
import { polar, arcPath } from '../../geo';

/**
 * Crate pulled up a rough ramp by a rope held at an angle above the ramp.
 * Shows: crate mass, ramp angle, rope angle measured from the ramp, rope
 * tension, kinetic friction coefficient.
 * Does NOT show: normal force, friction force or the acceleration.
 */
export function CtDynamicsBRampCrate({ mass = 40, rampAngle = 20, ropeAngle = 15, pull = 300, mu = 0.25 }) {
  const th = (rampAngle * Math.PI) / 180;
  const V = { x: 20, y: 214 }; // toe of the ramp
  const run = 380;
  const rise = run * Math.tan(th);
  const top = { x: V.x + run, y: V.y - rise };
  const u = { x: Math.cos(th), y: -Math.sin(th) }; // up the ramp
  const n = { x: -Math.sin(th), y: -Math.cos(th) }; // out of the ramp surface
  const at = (d, h = 0) => ({ x: V.x + d * u.x + h * n.x, y: V.y + d * u.y + h * n.y });

  const d0 = 150; // crate starts this far up the slope
  const cw = 72;
  const ch = 52;
  const A = at(d0);
  const B = at(d0 + cw);
  const C = at(d0 + cw, ch);
  const D = at(d0, ch);
  const mid = at(d0 + cw / 2, ch / 2);

  const S = at(d0 + cw, ch / 2); // rope leaves the crate face here
  const ropeLen = 104;
  const E = polar(S.x, S.y, ropeLen, rampAngle + ropeAngle);
  const ref = polar(S.x, S.y, 58, rampAngle);
  const arcR = 48;
  const angLbl = polar(S.x, S.y, arcR + 14, rampAngle + ropeAngle / 2 + 2);

  const baseLbl = polar(V.x, V.y, 66, rampAngle / 2);
  const muPt = at(d0 + cw / 2, -20);
  const y0 = Math.floor(E.y - 24); // top of the drawing

  return (
    <svg viewBox={`0 0 ${top.x + 16} ${V.y + 14 - y0}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${mass} kg crate on a ${rampAngle} degree ramp pulled by a ${pull} N rope held ${ropeAngle} degrees above the ramp; kinetic friction ${mu}`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctDynBRampArrow" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>
      <g transform={`translate(0, ${-y0})`}>

      {/* Ramp */}
      <polygon points={`${V.x},${V.y} ${top.x},${top.y} ${top.x},${V.y}`} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      {Array.from({ length: 24 }, (_, i) => (
        <line key={i} x1={V.x + 8 + i * 16} y1={V.y} x2={V.x + i * 16} y2={V.y + 8} stroke="var(--gray-400)" strokeWidth={1} />
      ))}
      <path d={arcPath(V.x, V.y, 56, 0, rampAngle)} fill="none" stroke="var(--gray-500)" strokeWidth={1.4} />
      <Label x={baseLbl.x} y={baseLbl.y} color="var(--gray-500)" fontSize={12} anchor="start">{`${rampAngle}°`}</Label>

      {/* Crate */}
      <polygon points={`${A.x},${A.y} ${B.x},${B.y} ${C.x},${C.y} ${D.x},${D.y}`} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <Label x={mid.x} y={mid.y} color="var(--charcoal)" fontSize={12}>{`${mass} kg`}</Label>
      <text x={muPt.x} y={muPt.y} fill="var(--gray-500)" fontFamily="var(--font-body)" fontSize={12} fontStyle="italic" textAnchor="middle" dominantBaseline="middle">
        {'μ'}<tspan fontSize={9} dy={3}>k</tspan><tspan dy={-3}>{` = ${mu.toFixed(2)}`}</tspan>
      </text>

      {/* Rope with its tension, and the angle from the ramp direction */}
      <line x1={S.x} y1={S.y} x2={ref.x} y2={ref.y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="4,3" />
      <path d={arcPath(S.x, S.y, arcR, rampAngle, rampAngle + ropeAngle)} fill="none" stroke="var(--gray-500)" strokeWidth={1.4} />
      <Label x={angLbl.x} y={angLbl.y} color="var(--gray-500)" fontSize={12} anchor="start">{`${ropeAngle}°`}</Label>
      <line x1={S.x} y1={S.y} x2={E.x} y2={E.y} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctDynBRampArrow)" />
      <Label x={E.x - 4} y={E.y - 13} color="var(--ember)" fontSize={12} anchor="end">{`P = ${pull} N`}</Label>
      </g>
    </svg>
  );
}

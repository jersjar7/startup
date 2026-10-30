import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan of a horizontal curve whose PI falls on a transmission tower. Drawn to
 * the true shape for the given deflection angle: the external distance E is
 * the true fraction of R (it is small, as it is on the ground).
 *
 * Shows: road centerline, back and forward tangents, PC, PI, PT, the deflection
 * angle I at the PI, the tower at the PI, the required clearance E, center O
 * and the radius marked "R = ?".
 * Does NOT show: the radius value, the tangent length or any station.
 */
export function CtTransportationBCurveTower({ angle = 38, minE = 85 }) {
  const W = 440;
  const cx = W / 2;
  const y0 = 46; // PI
  const Rp = 260; // drawing radius (px); the figure has no length scale
  const h = ((angle / 2) * Math.PI) / 180;
  const T = Rp * Math.tan(h);
  const Epx = Rp * (1 / Math.cos(h) - 1);
  const O = { x: cx, y: y0 + Rp / Math.cos(h) };
  const PI = { x: cx, y: y0 };
  const PC = { x: cx - T * Math.cos(h), y: y0 + T * Math.sin(h) };
  const PT = { x: cx + T * Math.cos(h), y: y0 + T * Math.sin(h) };
  const mid = { x: cx, y: y0 + Epx };
  const ext = 118; // tangent length drawn beyond PC and PT
  const back = { x: PC.x - ext * Math.cos(h), y: PC.y + ext * Math.sin(h) };
  const fwd = { x: PT.x + ext * Math.cos(h), y: PT.y + ext * Math.sin(h) };
  const prolong = { x: PI.x + 74 * Math.cos(h), y: PI.y - 74 * Math.sin(h) };
  const H = Math.ceil(O.y + 24);

  // Deflection-angle arc at the PI, from the prolonged back tangent to the forward tangent
  const ra = 40;
  const a1 = { x: PI.x + ra * Math.cos(h), y: PI.y - ra * Math.sin(h) };
  const a2 = { x: PI.x + ra * Math.cos(h), y: PI.y + ra * Math.sin(h) };

  // Radius label along the left radius, outside it
  const rm = { x: (O.x + PC.x) / 2, y: (O.y + PC.y) / 2 };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Horizontal curve with deflection angle ${angle} degrees and a tower at the PI`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Tangents through the PI (construction lines) */}
      <line x1={PC.x} y1={PC.y} x2={PI.x} y2={PI.y} stroke="var(--gray-400)" strokeWidth={1.2} />
      <line x1={PI.x} y1={PI.y} x2={PT.x} y2={PT.y} stroke="var(--gray-400)" strokeWidth={1.2} />
      <line x1={PI.x} y1={PI.y} x2={prolong.x} y2={prolong.y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="5,4" />

      {/* Radii and center */}
      <line x1={O.x} y1={O.y} x2={PC.x} y2={PC.y} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="6,4" />
      <line x1={O.x} y1={O.y} x2={PT.x} y2={PT.y} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="6,4" />
      <circle cx={O.x} cy={O.y} r={3} fill="var(--charcoal)" />
      <Label x={O.x} y={O.y + 13} color="var(--charcoal)" fontSize={12} bold>O</Label>
      <Label x={rm.x - 14} y={rm.y} color="var(--charcoal)" fontSize={12} bold anchor="end">R = ?</Label>

      {/* Road centerline: tangents and circular arc */}
      <line x1={back.x} y1={back.y} x2={PC.x} y2={PC.y} stroke="var(--charcoal)" strokeWidth={2.6} />
      <path d={`M ${PC.x.toFixed(1)},${PC.y.toFixed(1)} A ${Rp},${Rp} 0 0 1 ${PT.x.toFixed(1)},${PT.y.toFixed(1)}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.6} />
      <line x1={PT.x} y1={PT.y} x2={fwd.x} y2={fwd.y} stroke="var(--charcoal)" strokeWidth={2.6} />
      <Label x={back.x + 4} y={back.y + 16} color="var(--gray-500)" fontSize={11} anchor="start">road centerline</Label>

      {[PC, PT].map((p, i) => (
        <circle key={i} cx={p.x} cy={p.y} r={3.5} fill="var(--charcoal)" />
      ))}
      <Label x={PC.x - 2} y={PC.y - 15} color="var(--charcoal)" fontSize={12} bold>PC</Label>
      <Label x={PT.x + 2} y={PT.y - 15} color="var(--charcoal)" fontSize={12} bold>PT</Label>

      {/* Deflection angle */}
      <path d={`M ${a1.x.toFixed(1)},${a1.y.toFixed(1)} A ${ra},${ra} 0 0 1 ${a2.x.toFixed(1)},${a2.y.toFixed(1)}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.2} />
      <Label x={PI.x + ra + 8} y={PI.y} color="var(--charcoal)" fontSize={12} anchor="start">{`I = ${angle}°`}</Label>

      {/* Tower at the PI (lattice tower footprint) */}
      <rect x={PI.x - 6} y={PI.y - 6} width={12} height={12} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={PI.x - 6} y1={PI.y - 6} x2={PI.x + 6} y2={PI.y + 6} stroke="var(--charcoal)" strokeWidth={1.2} />
      <line x1={PI.x + 6} y1={PI.y - 6} x2={PI.x - 6} y2={PI.y + 6} stroke="var(--charcoal)" strokeWidth={1.2} />
      <Label x={PI.x} y={PI.y - 20} color="var(--charcoal)" fontSize={12} bold>PI</Label>
      <Label x={PI.x - 16} y={PI.y - 20} color="var(--charcoal)" fontSize={12} anchor="end">tower</Label>

      {/* Required clearance from the tower to the curve: the external distance */}
      <line x1={mid.x} y1={PI.y + 6} x2={mid.x} y2={mid.y} stroke="var(--ember)" strokeWidth={1.4} />
      <line x1={mid.x - 6} y1={mid.y} x2={mid.x + 6} y2={mid.y} stroke="var(--ember)" strokeWidth={1.4} />
      <Label x={mid.x} y={mid.y + 16} color="var(--ember)" fontSize={12} bold>{`E ≥ ${minE} ft`}</Label>
    </svg>
  );
}

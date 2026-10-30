import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan of a simple circular curve joining two tangents, drawn to scale from
 * the radius and the intersection angle: back tangent, PI with its station,
 * forward tangent, the arc from PC to PT and the two radii heading to the
 * centre (cut short).
 *
 * Shows: PI station, I at the PI, R, the points PC and PT.
 * Does NOT show: T, L or any PC/PT station.
 */
export function CtTransportationACurvePlan({ radius = 1500, angle = 32, piStation = '25+40.00' }) {
  const W = 384;
  const s = 0.29; // px per ft (to scale)
  const I = (angle * Math.PI) / 180;
  const R = radius * s;
  const T = radius * Math.tan(I / 2) * s;

  // Engineering axes: x east, y north; PC at origin, centre at (0, R).
  const x0 = 70;
  const baseY = 160; // svg y of the back tangent
  const P = (x, y) => ({ x: x0 + x, y: baseY - y });
  const pc = P(0, 0);
  const pi = P(T, 0);
  const pt = P(T + T * Math.cos(I), T * Math.sin(I));
  const ctr = (f) => P(0 + (0 - 0) * f, R * f); // along PC radius toward the centre
  const radLen = 0.3; // fraction of R drawn

  const arcPts = Array.from({ length: 41 }, (_, i) => {
    const phi = (I * i) / 40;
    const q = P(R * Math.sin(phi), R - R * Math.cos(phi));
    return `${q.x.toFixed(1)},${q.y.toFixed(1)}`;
  }).join(' ');

  // Radius from PT toward the centre
  const ptR = { x: pt.x - Math.sin(I) * R * radLen, y: pt.y - Math.cos(I) * R * radLen };
  const pcR = ctr(radLen);

  // Tangent extensions
  const backStart = P(-58, 0);
  const fwdEnd = P(T + (T + 64) * Math.cos(I), (T + 64) * Math.sin(I));
  const piExt = P(T + 70, 0);

  // Angle arc for I at the PI
  const ar = 34;
  const arcI = `M ${pi.x + ar},${pi.y} A ${ar},${ar} 0 0 0 ${(pi.x + ar * Math.cos(I)).toFixed(1)},${(pi.y - ar * Math.sin(I)).toFixed(1)}`;
  const iLab = { x: pi.x + (ar + 14) * Math.cos(I / 2), y: pi.y - (ar + 14) * Math.sin(I / 2) };

  const H = baseY + 34;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Horizontal curve, radius ${radius} ft, intersection angle ${angle} degrees, PI at station ${piStation}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Tangents (construction lines) */}
      <line x1={backStart.x} y1={backStart.y} x2={pi.x} y2={pi.y} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="5,4" />
      <line x1={pi.x} y1={pi.y} x2={fwdEnd.x} y2={fwdEnd.y} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="5,4" />
      <line x1={pi.x} y1={pi.y} x2={piExt.x} y2={piExt.y} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />

      {/* Roadway centerline along the curve */}
      <line x1={backStart.x} y1={backStart.y} x2={pc.x} y2={pc.y} stroke="var(--charcoal)" strokeWidth={2.6} />
      <polyline points={arcPts} fill="none" stroke="var(--charcoal)" strokeWidth={2.6} />
      <line x1={pt.x} y1={pt.y} x2={fwdEnd.x} y2={fwdEnd.y} stroke="var(--charcoal)" strokeWidth={2.6} />

      {/* Radii toward the centre (cut) */}
      <line x1={pc.x} y1={pc.y} x2={pcR.x} y2={pcR.y} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="6,4" />
      <line x1={pt.x} y1={pt.y} x2={ptR.x} y2={ptR.y} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="6,4" />
      <Label x={pcR.x - 8} y={(pc.y + pcR.y) / 2} color="var(--charcoal)" fontSize={12} anchor="end">{`R = ${radius.toLocaleString('en-US')} ft`}</Label>

      {/* Points */}
      {[pc, pi, pt].map((p, i) => (
        <circle key={i} cx={p.x} cy={p.y} r={3.5} fill={i === 1 ? '#fff' : 'var(--charcoal)'} stroke="var(--charcoal)" strokeWidth={1.5} />
      ))}
      <Label x={pc.x} y={pc.y + 17} color="var(--charcoal)" fontSize={12} bold>PC</Label>
      <Label x={pi.x} y={pi.y + 17} color="var(--charcoal)" fontSize={12} bold>PI</Label>
      <Label x={pi.x} y={pi.y + 31} color="var(--charcoal)" fontSize={12}>{`Sta ${piStation}`}</Label>
      <Label x={pt.x - 12} y={pt.y - 10} color="var(--charcoal)" fontSize={12} bold anchor="end">PT</Label>

      {/* Intersection angle */}
      <path d={arcI} fill="none" stroke="var(--ember)" strokeWidth={1.5} />
      <Label x={iLab.x + 4} y={iLab.y} color="var(--ember)" fontSize={12} bold anchor="start">{`I = ${angle}°`}</Label>
    </svg>
  );
}

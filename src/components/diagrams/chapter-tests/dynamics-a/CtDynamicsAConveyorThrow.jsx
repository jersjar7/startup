import React from 'react';
import { ArrowMarkerDefs, DimensionLine, Label } from '../../primitives';
import { polar, arcPath } from '../../geo';

/**
 * Gravel leaving the head of an inclined conveyor and falling to the ground.
 * Shows: belt at its angle, discharge speed and angle, discharge height,
 * the trajectory and the unknown horizontal distance x.
 * Does NOT show: the value of x or the flight time.
 */
export function CtDynamicsAConveyorThrow({ speed = 4.0, angle = 20, height = 6.0, g = 9.81 }) {
  const S = 32; // px per metre
  const D = { x: 128, y: 44 }; // discharge point
  const groundY = D.y + height * S;

  // Trajectory (true to scale)
  const th = (angle * Math.PI) / 180;
  const vx = speed * Math.cos(th);
  const vy = speed * Math.sin(th);
  const tLand = (vy + Math.sqrt(vy * vy + 2 * g * height)) / g;
  const pts = [];
  for (let i = 0; i <= 40; i++) {
    const t = (tLand * i) / 40;
    pts.push(`${(D.x + vx * t * S).toFixed(1)},${(D.y - (vy * t - (g * t * t) / 2) * S).toFixed(1)}`);
  }
  const landX = D.x + vx * tLand * S;

  // Belt running down-left from the discharge point at the same angle
  const beltStart = polar(D.x, D.y, 112, 180 + angle);
  const pulleyR = 7;
  const pulley = polar(D.x, D.y, pulleyR + 2, angle - 90);
  const vEnd = polar(D.x, D.y, 72, angle);
  const lbl = polar(D.x, D.y, 64, angle / 2);

  const right = Math.max(landX + 34, D.x + 190);
  const W = right + 20;
  const H = groundY + 40;

  return (
    <svg viewBox={`0 0 ${Math.round(W)} ${Math.round(H)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Gravel leaves a conveyor at ${speed} m/s, ${angle} degrees above horizontal, ${height} m above the ground`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctDynAConvArrow" color="var(--ember)" size={8} />

      {/* Ground */}
      <line x1={12} y1={groundY} x2={W - 10} y2={groundY} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: Math.floor((W - 30) / 16) }, (_, i) => (
        <line key={i} x1={20 + i * 16} y1={groundY} x2={12 + i * 16} y2={groundY + 8}
          stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Belt */}
      <line x1={beltStart.x} y1={beltStart.y} x2={D.x} y2={D.y} stroke="var(--charcoal)" strokeWidth={3} />
      <circle cx={pulley.x} cy={pulley.y} r={pulleyR} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.5} />
      {/* Head frame down to the ground */}
      <line x1={pulley.x} y1={pulley.y + pulleyR} x2={pulley.x} y2={groundY} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={pulley.x - 10} y1={groundY} x2={pulley.x + 10} y2={groundY} stroke="var(--charcoal)" strokeWidth={3} />
      <Label x={beltStart.x + 4} y={beltStart.y + 18} color="var(--gray-500)" fontSize={11} anchor="start">conveyor</Label>

      {/* Trajectory */}
      <polyline points={pts.join(' ')} fill="none" stroke="var(--gray-500)" strokeWidth={1.5} strokeDasharray="5,4" />
      <circle cx={landX} cy={groundY} r={3} fill="var(--charcoal)" />

      {/* Horizontal reference, angle and launch velocity */}
      <line x1={D.x} y1={D.y} x2={D.x + 92} y2={D.y} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <path d={arcPath(D.x, D.y, 48, 0, angle)} fill="none" stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={lbl.x + 4} y={lbl.y} color="var(--gray-500)" fontSize={12} anchor="start">{`${angle}°`}</Label>
      <line x1={D.x} y1={D.y} x2={vEnd.x} y2={vEnd.y} stroke="var(--ember)" strokeWidth={2.2} markerEnd="url(#ctDynAConvArrow)" />
      <Label x={vEnd.x + 6} y={vEnd.y - 4} color="var(--ember)" fontSize={12} bold anchor="start">{`${speed.toFixed(1)} m/s`}</Label>

      {/* Height dimension (right side) */}
      <line x1={D.x + 96} y1={D.y} x2={right + 6} y2={D.y} stroke="var(--gray-300)" strokeWidth={1} />
      <DimensionLine x1={right} y1={D.y} x2={right} y2={groundY} label="" />
      <Label x={right - 6} y={(D.y + groundY) / 2} color="var(--gray-500)" fontSize={12} anchor="end">{`${height.toFixed(1)} m`}</Label>

      {/* Unknown horizontal distance */}
      <DimensionLine x1={D.x} y1={groundY + 22} x2={landX} y2={groundY + 22} label="" />
      <Label x={(D.x + landX) / 2} y={groundY + 33} color="var(--charcoal)" fontSize={12} italic>x</Label>
    </svg>
  );
}

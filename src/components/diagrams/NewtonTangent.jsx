import React from 'react';
import { Label } from './primitives';

/**
 * One iteration of Newton's method.
 * Shows: a curve f(x), the point at x₀, the tangent line, and where it crosses
 * the axis at the improved estimate x₁, approaching the root.
 * Does NOT show: numeric values of the estimates.
 */
export function NewtonTangent() {
  const W = 360, H = 230, pad = 30;
  const axisY = H - 40;
  const x0Val = 2.6, rootVal = 1.6;          // schematic
  const toX = (v) => pad + (v / 3.4) * (W - 2 * pad);

  // f(x) = curve crossing axis at rootVal (use (x-root)*scale shape)
  const fy = (v) => axisY - 22 * (v - rootVal) - 6 * Math.pow(Math.max(0, v - rootVal), 1.6);
  const pts = [];
  for (let i = 0; i <= 60; i++) { const v = 0.6 + (i / 60) * 2.7; pts.push(`${toX(v).toFixed(1)},${fy(v).toFixed(1)}`); }

  const x0x = toX(x0Val), x0y = fy(x0Val);
  // tangent slope ~ derivative; draw tangent down to axis at x1
  const x1Val = 1.95;
  const x1x = toX(x1Val);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Newton's method: tangent at x0 crosses the axis at the improved estimate x1"
      style={{ width: '100%', height: 'auto' }}>

      {/* Axes */}
      <line x1={pad} y1={axisY} x2={W - 12} y2={axisY} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={pad} y1={28} x2={pad} y2={axisY + 6} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Curve f(x) */}
      <polyline points={pts.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <Label x={toX(0.95) - 4} y={fy(0.95) - 8} color="var(--gray-500)" italic fontSize={11}>f(x)</Label>

      {/* Tangent line at x0 down to x1 on the axis */}
      <line x1={x0x} y1={x0y} x2={x1x} y2={axisY} stroke="var(--ember)" strokeWidth={1.8} />
      <line x1={x0x} y1={x0y} x2={x0x} y2={axisY} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />

      {/* Points */}
      <circle cx={x0x} cy={x0y} r={3.5} fill="var(--ember)" />
      <circle cx={x1x} cy={axisY} r={3.5} fill="var(--ember)" />

      {/* Labels on the axis */}
      <Label x={x0x} y={axisY + 14} color="var(--charcoal)" bold fontSize={11}>x₀</Label>
      <Label x={x1x} y={axisY + 14} color="var(--ember)" bold fontSize={11}>x₁</Label>
      <Label x={toX(rootVal)} y={axisY + 14} color="var(--gray-500)" fontSize={10}>root</Label>
      <Label x={(x0x + x1x) / 2 + 6} y={(x0y + axisY) / 2 - 6} color="var(--ember)" italic fontSize={9} anchor="start">tangent</Label>
    </svg>
  );
}

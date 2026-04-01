import React from 'react';
import { Label } from './primitives';

export function ZeroForceJoint() {
  const cx = 180;
  const cy = 100;
  const memberLen = 80;

  const ax = cx - memberLen;
  const ay = cy;
  const ex = cx + memberLen;
  const ey = cy;
  const dx = cx;
  const dy = cy + memberLen;

  return (
    <svg viewBox="0 0 360 220" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Zero-force member at joint C"
      style={{ width: '100%', height: 'auto' }}>

      {/* Member AC (collinear left) */}
      <line x1={ax} y1={ay} x2={cx} y2={cy}
        stroke="var(--charcoal)" strokeWidth={2.5} />
      <Label x={ax - 10} y={ay} bold>A</Label>

      {/* Member CE (collinear right) */}
      <line x1={cx} y1={cy} x2={ex} y2={ey}
        stroke="var(--charcoal)" strokeWidth={2.5} />
      <Label x={ex + 10} y={ey} bold>E</Label>

      {/* Member CD (non-collinear, vertical) */}
      <line x1={cx} y1={cy} x2={dx} y2={dy}
        stroke="var(--charcoal)" strokeWidth={2.5} />
      <Label x={dx + 14} y={dy} bold>D</Label>

      {/* Joint C */}
      <circle cx={cx} cy={cy} r={5} fill="var(--charcoal)" />
      <Label x={cx} y={cy - 16} bold color="var(--charcoal)" fontSize={13}>C</Label>

    </svg>
  );
}

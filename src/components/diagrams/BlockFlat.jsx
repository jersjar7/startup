import React from 'react';
import {
  ArrowMarkerDefs, ForceArrow, Label,
} from './primitives';

export function BlockFlat({ weight = 500, mu = 0.40 }) {
  const bx = 120;
  const by = 100;
  const bw = 80;
  const bh = 60;
  const cx = bx + bw / 2;
  const cy = by + bh / 2;
  const groundY = by + bh;

  return (
    <svg viewBox="0 0 360 220" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Block on flat surface, W = ${weight} N, mu = ${mu}`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />
      <ArrowMarkerDefs id="arrowEmber" color="var(--ember)" size={7} />

      {/* Ground */}
      <line x1={40} y1={groundY} x2={320} y2={groundY}
        stroke="var(--charcoal)" strokeWidth={2} />
      {/* Hatching */}
      {Array.from({ length: 8 }, (_, i) => (
        <line key={i}
          x1={60 + i * 30} y1={groundY}
          x2={48 + i * 30} y2={groundY + 12}
          stroke="var(--charcoal)" strokeWidth={1} />
      ))}

      {/* Block */}
      <rect x={bx} y={by} width={bw} height={bh}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} rx={2} />

      {/* Weight (down) */}
      <ForceArrow x1={cx} y1={cy - 4} x2={cx} y2={groundY - 6}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={cx} y={cy - 18} color="var(--charcoal)" bold fontSize={11}>
        W = {weight} N
      </Label>

      {/* Applied force P (right) */}
      <ForceArrow x1={bx - 50} y1={cy} x2={bx - 4} y2={cy}
        color="var(--ember)" strokeWidth={2} markerId="arrowEmber" />
      <Label x={bx - 58} y={cy} color="var(--ember)" bold fontSize={11} anchor="end">
        P
      </Label>

    </svg>
  );
}

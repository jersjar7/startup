import React from 'react';
import { polar } from './geo';
import { Label } from './primitives';

/**
 * The three MUTCD sign categories by shape and color.
 * Shows: red octagon (regulatory / STOP), yellow diamond (warning),
 * green rectangle (guide), each labeled with its category.
 * Does NOT show: which category a quiz item belongs to (that is the answer).
 */
export function SignShapes() {
  const cy = 62, r = 34;
  const oct = Array.from({ length: 8 }, (_, k) => polar(70, cy, r, 22.5 + 45 * k))
    .map((p) => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' ');

  return (
    <svg viewBox="0 0 380 150" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Three traffic-sign categories: regulatory octagon, warning diamond, guide rectangle"
      style={{ width: '100%', height: 'auto' }}>

      {/* Regulatory — red octagon (STOP) */}
      <polygon points={oct} fill="var(--error)" stroke="white" strokeWidth={2} />
      <Label x={70} y={cy} color="white" bold fontSize={13}>STOP</Label>
      <Label x={70} y={cy + r + 18} color="var(--gray-500)" fontSize={10}>regulatory</Label>

      {/* Warning — yellow diamond */}
      <polygon points={`190,${cy - r} ${190 + r},${cy} 190,${cy + r} ${190 - r},${cy}`}
        fill="var(--sunbeam)" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={190} y={cy + 1} color="var(--charcoal)" bold fontSize={20}>!</Label>
      <Label x={190} y={cy + r + 18} color="var(--gray-500)" fontSize={10}>warning</Label>

      {/* Guide — green rectangle */}
      <rect x={310 - r} y={cy - r * 0.62} width={r * 2} height={r * 1.24}
        fill="var(--forest)" stroke="white" strokeWidth={2} rx={2} />
      <Label x={310} y={cy} color="white" bold fontSize={15}>{'→'}</Label>
      <Label x={310} y={cy + r + 18} color="var(--gray-500)" fontSize={10}>guide</Label>
    </svg>
  );
}

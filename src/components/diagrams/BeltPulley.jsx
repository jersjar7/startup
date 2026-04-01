import React from 'react';
import { arcPath, K } from './geo';
import {
  ArrowMarkerDefs, ForceArrow, Label,
} from './primitives';

export function BeltPulley({ mu = 0.30, slackT = 200, wrapDeg = 180 }) {
  const cx = 180;
  const cy = 120;
  const r = 50;
  const beltLen = 80;  // belt extension below pulley

  return (
    <svg viewBox="0 0 360 240" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Belt and pulley, mu = ${mu}, wrap = ${wrapDeg} degrees`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" size={6} />
      <ArrowMarkerDefs id="arrowEmber" color="var(--ember)" size={7} />

      {/* Pulley circle */}
      <circle cx={cx} cy={cy} r={r}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <circle cx={cx} cy={cy} r={4} fill="var(--charcoal)" />

      {/* Belt wrap arc (top half — 180° contact) */}
      <path
        d={arcPath(cx, cy, r, 0, 180)}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Belt — left side (slack, going down) */}
      <line x1={cx - r} y1={cy} x2={cx - r} y2={cy + beltLen}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Belt — right side (tight, going down) */}
      <line x1={cx + r} y1={cy} x2={cx + r} y2={cy + beltLen}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Slack side tension F2 (downward arrow) */}
      <ForceArrow x1={cx - r} y1={cy + 30} x2={cx - r} y2={cy + beltLen - 4}
        color="var(--ember)" strokeWidth={2} markerId="arrowEmber" />
      <Label x={cx - r - K.LABEL_OFFSET} y={cy + 50}
        color="var(--ember)" bold fontSize={11} anchor="end">
        F2
      </Label>
      <Label x={cx - r - K.LABEL_OFFSET} y={cy + 64}
        color="var(--gray-500)" fontSize={10} anchor="end">
        {slackT} N
      </Label>
      <Label x={cx - r} y={cy + beltLen + 14}
        color="var(--gray-400)" fontSize={9}>
        (slack)
      </Label>

      {/* Tight side tension F1 (upward arrow — resists slip) */}
      <ForceArrow x1={cx + r} y1={cy + beltLen - 4} x2={cx + r} y2={cy + 30}
        color="var(--ember)" strokeWidth={2} markerId="arrowEmber" />
      <Label x={cx + r + K.LABEL_OFFSET} y={cy + 50}
        color="var(--ember)" bold fontSize={11} anchor="start">
        F1
      </Label>
      <Label x={cx + r} y={cy + beltLen + 14}
        color="var(--gray-400)" fontSize={9}>
        (tight)
      </Label>

    </svg>
  );
}

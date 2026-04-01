import React from 'react';
import { PinSupport, FixedSupport, DimensionLine, Label } from './primitives';

export function ColumnSupports({
  length = 4,
  topCondition = 'pin',
  bottomCondition = 'pin',
}) {
  const cx = 160;
  const topY = 40;
  const colH = 160;
  const botY = topY + colH;

  /* Support rendering offsets */
  const pinBelow = 0;

  return (
    <svg viewBox="0 0 320 260" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Column, ${length} m, ${bottomCondition} bottom, ${topCondition} top`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Column member */}
      <line x1={cx} y1={topY} x2={cx} y2={botY}
        stroke="var(--charcoal)" strokeWidth={3} strokeLinecap="round" />

      {/* Top support */}
      {topCondition === 'pin' && (
        <>
          <g transform={`rotate(180, ${cx}, ${topY})`}>
            <PinSupport x={cx} y={topY} />
          </g>
          <Label x={cx + 24} y={topY - 14} anchor="start" fontSize={10}
            color="var(--gray-500)" italic>pin</Label>
        </>
      )}
      {topCondition === 'fixed' && (
        <>
          <line x1={cx - 30} y1={topY} x2={cx + 30} y2={topY}
            stroke="var(--charcoal)" strokeWidth={2} />
          {Array.from({ length: 5 }, (_, i) => {
            const hx = cx - 24 + i * 12;
            return (
              <line key={i}
                x1={hx} y1={topY}
                x2={hx - 6} y2={topY - 8}
                stroke="var(--charcoal)" strokeWidth={1.5} />
            );
          })}
          <Label x={cx + 36} y={topY - 6} anchor="start" fontSize={10}
            color="var(--gray-500)" italic>fixed</Label>
        </>
      )}
      {topCondition === 'free' && (
        <Label x={cx + 14} y={topY} anchor="start" fontSize={10}
          color="var(--gray-500)" italic>free</Label>
      )}

      {/* Bottom support */}
      {bottomCondition === 'pin' && (
        <>
          <PinSupport x={cx} y={botY} />
          <Label x={cx + 24} y={botY + 14} anchor="start" fontSize={10}
            color="var(--gray-500)" italic>pin</Label>
        </>
      )}
      {bottomCondition === 'fixed' && (
        <>
          <line x1={cx - 30} y1={botY} x2={cx + 30} y2={botY}
            stroke="var(--charcoal)" strokeWidth={2} />
          {Array.from({ length: 5 }, (_, i) => {
            const hx = cx - 24 + i * 12;
            return (
              <line key={i}
                x1={hx} y1={botY}
                x2={hx + 6} y2={botY + 8}
                stroke="var(--charcoal)" strokeWidth={1.5} />
            );
          })}
          <Label x={cx + 36} y={botY + 6} anchor="start" fontSize={10}
            color="var(--gray-500)" italic>fixed</Label>
        </>
      )}

      {/* Length dimension (right side, bottom-to-top) */}
      <DimensionLine x1={cx + 50} y1={botY} x2={cx + 50} y2={topY}
        label={`${length} m`} offset={18} />

      {/* Column label */}
      <Label x={cx - 14} y={topY + colH / 2} anchor="end" fontSize={11}
        color="var(--charcoal)" italic rotate={-90}>
        column
      </Label>
    </svg>
  );
}

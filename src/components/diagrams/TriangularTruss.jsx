import React from 'react';
import {
  ArrowMarkerDefs, ForceArrow, PinSupport, RollerSupport, Label,
} from './primitives';

/**
 * Simple triangular truss (A pin, B roller, C apex) with a load at the apex.
 * The viewBox is fitted to the content so nothing clips at any span/height.
 */
export function TriangularTruss({ span = 6, height = 4, load = 10 }) {
  const ax = 60;
  const ay = 180;
  const bx = ax + span * 25;
  const by = ay;
  const cxPos = ax + (span / 2) * 25;
  const cy = ay - height * 25;

  // content-fitted viewBox
  const minX = ax - 26;
  const maxX = bx + 74;            // height dimension label sits at bx+46 (+ text)
  const minY = cy - 80;            // load label at cy-68
  const maxY = ay + 70;            // span label at ay+58 (+ text height)

  return (
    <svg viewBox={`${minX} ${minY} ${maxX - minX} ${maxY - minY}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Triangular truss, ${span} m span, ${load} kN load at apex`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Members */}
      <line x1={ax} y1={ay} x2={bx} y2={by} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={ax} y1={ay} x2={cxPos} y2={cy} stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={bx} y1={by} x2={cxPos} y2={cy} stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Joints */}
      <circle cx={ax} cy={ay} r={3} fill="var(--charcoal)" />
      <circle cx={bx} cy={by} r={3} fill="var(--charcoal)" />
      <circle cx={cxPos} cy={cy} r={3} fill="var(--charcoal)" />
      <Label x={ax - 18} y={ay + 10} bold>A</Label>
      <Label x={bx + 18} y={by + 10} bold>B</Label>
      <Label x={cxPos - 20} y={cy - 30} bold>C</Label>

      {/* Supports */}
      <PinSupport x={ax} y={ay} />
      <RollerSupport x={bx} y={ay} />

      {/* Load at apex */}
      <ForceArrow x1={cxPos} y1={cy - 60} x2={cxPos} y2={cy - 6}
        color="var(--charcoal)" strokeWidth={2} markerId="arrowMain" />
      <Label x={cxPos} y={cy - 68} color="var(--charcoal)" bold>{load} kN</Label>

      {/* Span dimension */}
      <line x1={ax} y1={ay + 44} x2={bx} y2={ay + 44} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={ax} y1={ay + 38} x2={ax} y2={ay + 50} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={bx} y1={ay + 38} x2={bx} y2={ay + 50} stroke="var(--gray-400)" strokeWidth={1} />
      <Label x={(ax + bx) / 2} y={ay + 58} fontSize={11}>{span} m</Label>

      {/* Height dimension */}
      <line x1={bx + 30} y1={ay} x2={bx + 30} y2={cy} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={bx + 24} y1={ay} x2={bx + 36} y2={ay} stroke="var(--gray-400)" strokeWidth={1} />
      <line x1={bx + 24} y1={cy} x2={bx + 36} y2={cy} stroke="var(--gray-400)" strokeWidth={1} />
      <Label x={bx + 46} y={(ay + cy) / 2} fontSize={11}>{height} m</Label>
    </svg>
  );
}

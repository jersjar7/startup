import React from 'react';
import { DashedLine, DimensionLine, Label, RightAngleMarker } from './primitives';

/**
 * Profile view of sloped road — right triangle showing run, rise, and slope.
 * Shows: horizontal ground (run), vertical rise, sloped road surface, station labels, elevations.
 * Does NOT show: grade percentage (that's the answer).
 */
export function RoadGrade({ run = 300, rise = 6 }) {
  const pad = 30;
  const W = 360;
  const H = 200;

  // Layout: triangle bottom-left anchored
  const ax = pad + 30;        // left station point
  const ay = H - pad - 30;    // ground level
  const bx = W - pad - 30;    // right station point
  const by = ay;               // same ground level

  // Rise is small relative to run — exaggerate for visibility
  const riseVis = Math.min(70, Math.max(30, (rise / run) * 800));
  const cx = bx;
  const cy = ay - riseVis;

  // Station labels
  const staA = `Sta ${Math.round(0).toString()}+00`;
  const staB = `Sta ${Math.round(run / 100).toString()}+00`;

  // Elevation labels
  const elevA = (120).toFixed(1);
  const elevB = (120 + rise).toFixed(1);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Road grade profile: ${rise} ft rise over ${run} ft run`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Ground line (horizontal run) */}
      <line x1={ax} y1={ay} x2={bx} y2={by}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Vertical rise line */}
      <line x1={bx} y1={by} x2={cx} y2={cy}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* Sloped road surface */}
      <line x1={ax} y1={ay} x2={cx} y2={cy}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Right angle marker at bottom-right */}
      <RightAngleMarker x={bx} y={by} size={12} rotation={-90} />

      {/* Horizontal run dimension */}
      <DimensionLine x1={ax} y1={ay + 20} x2={bx} y2={ay + 20}
        label={`${run} ft`} offset={12} />

      {/* Vertical rise dimension */}
      <DimensionLine x1={bx + 16} y1={ay} x2={bx + 16} y2={cy}
        label={`${rise.toFixed(1)} ft`} offset={14} />

      {/* Station labels */}
      <Label x={ax} y={ay + 46} fontSize={10} color="var(--gray-500)">
        {staA}
      </Label>
      <Label x={bx} y={ay + 46} fontSize={10} color="var(--gray-500)">
        {staB}
      </Label>

      {/* Elevation labels */}
      <Label x={ax - 4} y={ay - 10} fontSize={10} color="var(--gray-500)" anchor="end">
        {elevA} ft
      </Label>
      <Label x={cx + 4} y={cy - 10} fontSize={10} color="var(--gray-500)" anchor="start">
        {elevB} ft
      </Label>

      {/* Endpoint dots */}
      <circle cx={ax} cy={ay} r={3} fill="var(--charcoal)" />
      <circle cx={cx} cy={cy} r={3} fill="var(--charcoal)" />
    </svg>
  );
}

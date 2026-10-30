import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan of a four-leg intersection of two two-lane roads, with the entering
 * ADT of each approach shown by an arrow in its entering lane (traffic keeps
 * to the right).
 *
 * Shows: the entering ADT of every approach, street names, north arrow.
 * Does NOT show: crash counts or any crash rate.
 */
export function CtTransportationBIntersection({
  east = 6200, // westbound traffic entering from the east leg
  west = 5800, // eastbound traffic entering from the west leg
  north = 3400, // southbound traffic entering from the north leg
  south = 2600, // northbound traffic entering from the south leg
  major = 'STATE ROUTE 9',
  minor = 'MILL ROAD',
}) {
  const W = 440;
  const cx = 220;
  const cy = 150;
  const hw = 24; // half road width (two 12 ft lanes at 2 px/ft)
  const r = 12; // curb return radius
  const xL = 14;
  const xR = W - 14;
  const yT = 12;
  const yB = 288;
  const H = 300;
  const c = 'var(--charcoal)';
  const fmt = (n) => n.toLocaleString('en-US');

  const curb = (
    <g fill="none" stroke={c} strokeWidth={2}>
      {/* NW */}
      <path d={`M ${xL},${cy - hw} H ${cx - hw - r} A ${r},${r} 0 0 0 ${cx - hw},${cy - hw - r} V ${yT}`} />
      {/* NE */}
      <path d={`M ${cx + hw},${yT} V ${cy - hw - r} A ${r},${r} 0 0 0 ${cx + hw + r},${cy - hw} H ${xR}`} />
      {/* SW */}
      <path d={`M ${xL},${cy + hw} H ${cx - hw - r} A ${r},${r} 0 0 1 ${cx - hw},${cy + hw + r} V ${yB}`} />
      {/* SE */}
      <path d={`M ${cx + hw},${yB} V ${cy + hw + r} A ${r},${r} 0 0 1 ${cx + hw + r},${cy + hw} H ${xR}`} />
    </g>
  );

  const cl = { stroke: 'var(--gray-500)', strokeWidth: 1.2, strokeDasharray: '10,7' };
  const arrow = { stroke: 'var(--ember)', strokeWidth: 2, markerEnd: 'url(#ctTrBIntArrow)' };
  const stop = 10; // arrows stop this far short of the intersection box

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Four-leg intersection with entering ADT ${east}, ${west}, ${north} and ${south} vehicles per day`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctTrBIntArrow" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>

      {curb}

      {/* Centerlines */}
      <line x1={xL} y1={cy} x2={cx - hw - r - 4} y2={cy} {...cl} />
      <line x1={cx + hw + r + 4} y1={cy} x2={xR} y2={cy} {...cl} />
      <line x1={cx} y1={yT} x2={cx} y2={cy - hw - r - 4} {...cl} />
      <line x1={cx} y1={cy + hw + r + 4} x2={cx} y2={yB} {...cl} />

      {/* Entering approaches */}
      {/* West leg, eastbound in the south lane */}
      <line x1={xL + 40} y1={cy + hw / 2} x2={cx - hw - stop} y2={cy + hw / 2} {...arrow} />
      <Label x={xL + 40} y={cy + hw + 16} color="var(--ember)" fontSize={12} bold anchor="start">{`${fmt(west)} veh/day`}</Label>
      {/* East leg, westbound in the north lane */}
      <line x1={xR - 40} y1={cy - hw / 2} x2={cx + hw + stop} y2={cy - hw / 2} {...arrow} />
      <Label x={xR - 40} y={cy - hw - 16} color="var(--ember)" fontSize={12} bold anchor="end">{`${fmt(east)} veh/day`}</Label>
      {/* North leg, southbound in the west lane */}
      <line x1={cx - hw / 2} y1={yT + 22} x2={cx - hw / 2} y2={cy - hw - stop} {...arrow} />
      <Label x={cx - hw - 8} y={yT + 40} color="var(--ember)" fontSize={12} bold anchor="end">{`${fmt(north)} veh/day`}</Label>
      {/* South leg, northbound in the east lane */}
      <line x1={cx + hw / 2} y1={yB - 22} x2={cx + hw / 2} y2={cy + hw + stop} {...arrow} />
      <Label x={cx + hw + 8} y={yB - 40} color="var(--ember)" fontSize={12} bold anchor="start">{`${fmt(south)} veh/day`}</Label>

      {/* Street names */}
      <Label x={xL + 2} y={cy - hw - 14} color="var(--gray-500)" fontSize={11} anchor="start">{major}</Label>
      <Label x={cx + hw + 8} y={yT + 10} color="var(--gray-500)" fontSize={11} anchor="start">{minor}</Label>

      {/* Legend */}
      <Label x={xL + 2} y={yT + 6} color="var(--gray-500)" fontSize={11} anchor="start">Entering ADT per approach</Label>

      {/* North arrow */}
      <g>
        <line x1={xR - 14} y1={yT + 40} x2={xR - 14} y2={yT + 14} stroke={c} strokeWidth={1.6} />
        <path d={`M ${xR - 14},${yT + 6} L ${xR - 20},${yT + 18} L ${xR - 8},${yT + 18} Z`} fill={c} />
        <Label x={xR - 28} y={yT + 14} color={c} fontSize={12} bold>N</Label>
      </g>
    </svg>
  );
}

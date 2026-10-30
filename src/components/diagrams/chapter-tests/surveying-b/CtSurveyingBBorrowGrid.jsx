import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan view of a borrow pit grid of equal squares. rows[r][c] is the depth
 * of cut at grid corner (c, r); a shorter row means the grid steps in
 * (an L-shaped pit). A square exists where all four corners exist.
 */
export function CtSurveyingBBorrowGrid({ size = 40, rows = [[3.2, 4.1, 4.6, 3.8], [2.7, 3.9, 4.4, 3.5], [2.1, 3.0, 3.6]] }) {
  const k = 96; // px per square side
  const ox = 66;
  const oy = 58;
  const has = (c, r) => r >= 0 && r < rows.length && c >= 0 && c < rows[r].length;
  const squares = [];
  for (let r = 0; r < rows.length - 1; r++) {
    for (let c = 0; c < rows[r].length - 1; c++) {
      if (has(c, r) && has(c + 1, r) && has(c, r + 1) && has(c + 1, r + 1)) squares.push({ c, r });
    }
  }
  const X = (c) => ox + c * k;
  const Y = (r) => oy + r * k;
  const maxC = Math.max(...rows.map((row) => row.length)) - 1;
  const W = X(maxC) + 44;
  const H = Y(rows.length - 1) + 26;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Borrow pit grid of ${size} ft squares with depths of cut at each corner`}
      style={{ width: '100%', height: 'auto' }}>
      {squares.map(({ c, r }, i) => (
        <rect key={i} x={X(c)} y={Y(r)} width={k} height={k} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.6} />
      ))}
      {rows.map((row, r) => row.map((h, c) => (
        <g key={`${r}-${c}`}>
          <circle cx={X(c)} cy={Y(r)} r={3} fill="var(--charcoal)" />
          <Label x={X(c) + 6} y={Y(r) - 10} anchor="start" color="var(--ember)" fontSize={12}>{h.toFixed(1)}</Label>
        </g>
      )))}
      {/* square size dimensions */}
      <line x1={X(0)} y1={oy - 34} x2={X(1)} y2={oy - 34} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={X(0)} y1={oy - 39} x2={X(0)} y2={oy - 29} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={X(1)} y1={oy - 39} x2={X(1)} y2={oy - 29} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={(X(0) + X(1)) / 2} y={oy - 46} color="var(--gray-500)" fontSize={12}>{`${size} ft`}</Label>
      <line x1={ox - 22} y1={Y(0)} x2={ox - 22} y2={Y(1)} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={ox - 27} y1={Y(0)} x2={ox - 17} y2={Y(0)} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={ox - 27} y1={Y(1)} x2={ox - 17} y2={Y(1)} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={ox - 30} y={(Y(0) + Y(1)) / 2} anchor="middle" color="var(--gray-500)" fontSize={12} rotate={-90}>{`${size} ft`}</Label>
      <Label x={X(maxC) + 30} y={Y(rows.length - 1) + 8} anchor="end" color="var(--gray-500)" fontSize={12}>Depths of cut in ft</Label>
    </svg>
  );
}

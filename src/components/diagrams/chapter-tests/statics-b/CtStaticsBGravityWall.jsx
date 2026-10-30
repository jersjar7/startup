import React from 'react';
import { Label } from '../../primitives';

/**
 * Gravity retaining wall section: a right triangle at the front (toe side,
 * left) against a rectangle at the back, with backfill behind the heel.
 * Shows: the two parts, base widths, height, toe and heel.
 * Does NOT show: the centroid.
 */
export function CtStaticsBGravityWall({ stem = 2, toe = 4, height = 12 }) {
  const S = 16;
  const x0 = 96;
  const yb = 214;
  const xa = x0 + toe * S;
  const x1 = xa + stem * S;
  const yt = yb - height * S;
  const gray = 'var(--gray-500)';
  const dimY = yb + 26;
  const hx = x0 - 46;
  const fill = yt + 12; // backfill surface
  const bfEnd = x1 + 120;

  return (
    <svg viewBox={`0 0 ${bfEnd + 12} ${dimY + 22}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Gravity wall section: triangle ${toe} ft wide and rectangle ${stem} ft wide, both ${height} ft tall`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Backfill surface behind the wall */}
      <line x1={x1} y1={fill} x2={bfEnd} y2={fill} stroke="var(--gray-500)" strokeWidth={1.4} />
      {Array.from({ length: 7 }, (_, i) => (
        <line key={i} x1={x1 + 12 + i * 16} y1={fill} x2={x1 + 4 + i * 16} y2={fill + 8} stroke="var(--gray-400)" strokeWidth={1.1} />
      ))}
      <Label x={x1 + 64} y={(fill + yb) / 2} color="var(--gray-500)">backfill</Label>

      <polygon points={`${x0},${yb} ${xa},${yb} ${xa},${yt}`} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <rect x={xa} y={yt} width={x1 - xa} height={yb - yt} fill="var(--gray-200)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Ground at the base */}
      <line x1={x0 - 30} y1={yb} x2={bfEnd} y2={yb} stroke="var(--charcoal)" strokeWidth={1.4} />

      <Label x={x0 - 4} y={yb + 13} color="var(--charcoal)" bold anchor="end">toe</Label>
      <Label x={x1 + 6} y={yb + 13} color="var(--charcoal)" bold anchor="start">heel</Label>

      {/* Base dimensions */}
      <line x1={x0} y1={dimY} x2={x1} y2={dimY} stroke={gray} strokeWidth={1} />
      {[x0, xa, x1].map((x) => <line key={x} x1={x} y1={yb + 6} x2={x} y2={dimY + 5} stroke={gray} strokeWidth={1} />)}
      <Label x={(x0 + xa) / 2} y={dimY + 13}>{`${toe} ft`}</Label>
      <Label x={(xa + x1) / 2} y={dimY + 13}>{`${stem} ft`}</Label>

      {/* Height, on the toe side */}
      <line x1={hx} y1={yt} x2={hx} y2={yb} stroke={gray} strokeWidth={1} />
      <line x1={hx - 5} y1={yt} x2={xa - 6} y2={yt} stroke={gray} strokeWidth={1} />
      <line x1={hx - 5} y1={yb} x2={hx + 5} y2={yb} stroke={gray} strokeWidth={1} />
      <Label x={hx - 8} y={(yt + yb) / 2} anchor="end">{`${height} ft`}</Label>
    </svg>
  );
}

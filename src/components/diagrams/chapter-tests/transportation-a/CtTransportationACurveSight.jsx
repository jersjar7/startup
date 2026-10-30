import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan view of a two-lane horizontal curve with a building on the inside.
 * The sight line is a chord along the inside lane centerline; the clearance
 * is measured from that centerline at the middle of the curve.
 *
 * Shows: lanes and edges, inside lane centerline with its radius, the sight
 * line from driver to object, the building, and the unknown offset "HSO = ?".
 * Does NOT show: the sight distance (the student finds it) or the offset value.
 */
export function CtTransportationACurveSight({ radius = 1200, laneWidth = 12 }) {
  const W = 440;
  const cx = W / 2;
  const Rc = 330; // px radius of the inside lane centerline (drawing only)
  const lw = 16; // px lane width
  const top = 30;
  const rIn = Rc - lw / 2; // inside edge
  const rMid = Rc + lw / 2; // road centerline
  const rOut = Rc + 1.5 * lw; // outside edge
  const cy = top + rOut;
  const half = 34; // half-angle of the visible arc (deg)
  const sight = 28; // half-angle subtended by the sight line (deg)

  const pt = (r, a) => ({ x: cx + r * Math.sin((a * Math.PI) / 180), y: cy - r * Math.cos((a * Math.PI) / 180) });
  const arc = (r) => {
    const s = pt(r, -half);
    const e = pt(r, half);
    return `M ${s.x.toFixed(1)},${s.y.toFixed(1)} A ${r},${r} 0 0 1 ${e.x.toFixed(1)},${e.y.toFixed(1)}`;
  };

  const a = pt(Rc, -sight);
  const b = pt(Rc, sight);
  const chordY = a.y;
  const laneY = cy - Rc; // inside lane centerline at mid-curve
  const edgeY = cy - rIn; // inside edge at mid-curve

  const bW = 130;
  const bH = 44;
  const bTop = chordY + 1; // building face on the sight line (minimum clearance)
  const H = Math.ceil(bTop + bH + 10);

  const rp = pt(Rc, 17); // radius callout point
  const lanesAt = pt(rOut, -21);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Horizontal curve, inside lane centerline radius ${radius} ft, building on the inside of the curve`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Road edges and lane lines */}
      <path d={arc(rOut)} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <path d={arc(rIn)} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <path d={arc(rMid)} fill="none" stroke="var(--gray-500)" strokeWidth={1.2} strokeDasharray="10,7" />
      <path d={arc(Rc)} fill="none" stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="2,4" />

      {/* Sight line: driver to object along the inside lane centerline */}
      <line x1={a.x} y1={a.y} x2={b.x} y2={b.y} stroke="var(--ember)" strokeWidth={1.6} strokeDasharray="7,4" />
      <circle cx={a.x} cy={a.y} r={4} fill="var(--ember)" />
      <circle cx={b.x} cy={b.y} r={4} fill="var(--ember)" />
      <Label x={a.x} y={a.y + 30} color="var(--charcoal)" fontSize={12}>driver</Label>
      <Label x={b.x} y={b.y + 30} color="var(--charcoal)" fontSize={12}>object</Label>
      <line x1={cx - 100} y1={chordY + 24} x2={cx - 92} y2={chordY + 2} stroke="var(--ember)" strokeWidth={0.9} />
      <Label x={cx - 74} y={chordY + 34} color="var(--ember)" fontSize={12} anchor="end">sight line</Label>

      {/* Building on the inside of the curve */}
      <rect x={cx - bW / 2} y={bTop} width={bW} height={bH} rx={2} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.6} />
      <Label x={cx} y={bTop + bH / 2} color="var(--charcoal)" fontSize={12}>building</Label>

      {/* Offset from the inside lane centerline to the sight line, at mid-curve */}
      <line x1={cx - 8} y1={laneY} x2={cx - 8} y2={chordY} stroke="var(--charcoal)" strokeWidth={1} />
      <line x1={cx - 14} y1={laneY} x2={cx - 2} y2={laneY} stroke="var(--charcoal)" strokeWidth={1} />
      <line x1={cx - 14} y1={chordY} x2={cx - 2} y2={chordY} stroke="var(--charcoal)" strokeWidth={1} />
      <Label x={cx + 2} y={(edgeY + chordY) / 2 + 1} color="var(--charcoal)" fontSize={12} bold anchor="start">HSO = ?</Label>

      {/* Radius callout, outside the road */}
      <circle cx={rp.x} cy={rp.y} r={2.2} fill="var(--gray-500)" />
      <line x1={rp.x} y1={rp.y} x2={rp.x + 34} y2={top + 6} stroke="var(--gray-500)" strokeWidth={0.9} />
      <Label x={W - 8} y={top - 20} color="var(--charcoal)" fontSize={12} anchor="end">{`R = ${radius.toLocaleString('en-US')} ft`}</Label>
      <Label x={W - 8} y={top - 5} color="var(--gray-500)" fontSize={11} anchor="end">to inside lane centerline</Label>

      {/* Lanes note and scale note */}
      <Label x={lanesAt.x - 6} y={lanesAt.y - 20} color="var(--gray-500)" fontSize={11} anchor="middle">{`two ${laneWidth} ft lanes`}</Label>
      <Label x={8} y={H - 10} color="var(--gray-500)" fontSize={11} anchor="start">NOT TO SCALE</Label>
    </svg>
  );
}

import React from 'react';
import { Label } from '../../primitives';

/**
 * Rolled W-shape with a cover plate welded to the top flange (cross
 * section, to scale).
 * Shows: beam depth, plate width and thickness, the beam designation.
 * Does NOT show: the centroid or any moment of inertia.
 */
export function CtStaticsACoverPlateBeam({
  shape = 'W16×50', d = 16.3, bf = 7.07, tf = 0.63, tw = 0.38, pb = 10, pt = 1,
}) {
  const S = 11; // px per in.
  const cx = 150;
  const top = 40; // top of plate
  const pTop = top;
  const bTop = top + pt * S;
  const bBot = bTop + d * S;
  const hb = (bf * S) / 2;
  const ht = (tw * S) / 2;
  const tF = tf * S;
  const gray = 'var(--gray-500)';
  const I = [
    [cx - hb, bTop], [cx + hb, bTop], [cx + hb, bTop + tF], [cx + ht, bTop + tF],
    [cx + ht, bBot - tF], [cx + hb, bBot - tF], [cx + hb, bBot], [cx - hb, bBot],
    [cx - hb, bBot - tF], [cx - ht, bBot - tF], [cx - ht, bTop + tF], [cx - hb, bTop + tF],
  ].map((p) => p.join(',')).join(' ');
  const pl = (pb * S) / 2;
  const dimX = cx + pl + 28;

  return (
    <svg viewBox={`0 0 330 ${Math.round(bBot + 20)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${shape} with a ${pb} by ${pt} inch cover plate on the top flange`}
      style={{ width: '100%', height: 'auto' }}>
      <polygon points={I} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.8} strokeLinejoin="round" />
      <rect x={cx - pl} y={pTop} width={2 * pl} height={pt * S} fill="var(--ember)" fillOpacity={0.25} stroke="var(--charcoal)" strokeWidth={1.8} />

      {/* Plate width, above */}
      <line x1={cx - pl} y1={pTop - 16} x2={cx + pl} y2={pTop - 16} stroke={gray} strokeWidth={1} />
      <line x1={cx - pl} y1={pTop - 21} x2={cx - pl} y2={pTop - 4} stroke={gray} strokeWidth={1} />
      <line x1={cx + pl} y1={pTop - 21} x2={cx + pl} y2={pTop - 4} stroke={gray} strokeWidth={1} />
      <Label x={cx} y={pTop - 27}>{`${pb} in.`}</Label>

      {/* Plate thickness, left */}
      <line x1={cx - pl - 6} y1={pTop} x2={cx - pl - 30} y2={pTop} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={cx - pl - 6} y1={bTop} x2={cx - pl - 30} y2={bTop} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={cx - pl - 22} y1={pTop} x2={cx - pl - 22} y2={bTop} stroke={gray} strokeWidth={1} />
      <line x1={cx - pl - 26} y1={pTop + 4} x2={cx - pl - 18} y2={pTop - 4} stroke={gray} strokeWidth={1.4} />
      <line x1={cx - pl - 26} y1={bTop + 4} x2={cx - pl - 18} y2={bTop - 4} stroke={gray} strokeWidth={1.4} />
      <Label x={cx - pl - 34} y={(pTop + bTop) / 2} anchor="end">{`${pt} in.`}</Label>

      {/* Beam depth, right */}
      <line x1={cx + hb + 4} y1={bBot} x2={dimX + 6} y2={bBot} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={cx + pl + 4} y1={bTop} x2={dimX + 6} y2={bTop} stroke="var(--gray-300)" strokeWidth={1} />
      <line x1={dimX} y1={bTop} x2={dimX} y2={bBot} stroke={gray} strokeWidth={1} />
      <line x1={dimX - 4} y1={bTop + 4} x2={dimX + 4} y2={bTop - 4} stroke={gray} strokeWidth={1.4} />
      <line x1={dimX - 4} y1={bBot + 4} x2={dimX + 4} y2={bBot - 4} stroke={gray} strokeWidth={1.4} />
      <Label x={dimX + 8} y={(bTop + bBot) / 2} anchor="start">{`d = ${d} in.`}</Label>

      {/* Labels */}
      <Label x={cx - hb - 10} y={(bTop + bBot) / 2} color="var(--charcoal)" anchor="end" bold>{shape}</Label>
    </svg>
  );
}

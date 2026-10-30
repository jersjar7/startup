import React from 'react';
import { Label } from '../../primitives';

/**
 * Elevation view: level set up under a pedestrian bridge. Backsight on a
 * benchmark, a rod held upside down against the underside of the girder,
 * and a foresight on the road crown. All vertical distances share one scale,
 * so rod lengths to the line of sight match the readings.
 */
export function CtSurveyingAInvertedRod({ bmElev = 412.36, bs = 5.82, inv = 9.47, fs = 6.03 }) {
  const k = 10; // px per ft, vertical: every height comes from this one scale
  const bmBase = 196; // ground surface on the rise where the BM rod stands
  const sight = bmBase - bs * k; // line of sight
  const soffit = sight - inv * k; // underside of the girder
  const crownY = sight + fs * k; // road crown (slightly below the BM ground here)
  const road = Math.max(crownY, bmBase) + 8; // road edge, below the crown
  const girderD = 22;
  const xBM = 96;
  const xInst = 190;
  const xCrown = 290;
  const xInv = 372;
  const rodLen = 12 * k;
  const W = 470;
  const H = road + 30;
  const fmt = (v) => v.toFixed(2);

  const rod = (x, y1, y2) => (
    <g>
      <rect x={x - 3} y={Math.min(y1, y2)} width={6} height={Math.abs(y2 - y1)}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.3} />
      {Array.from({ length: Math.floor(Math.abs(y2 - y1) / k) }, (_, i) => {
        const yy = y1 + Math.sign(y2 - y1) * (i + 1) * k;
        return <line key={i} x1={x - 3} y1={yy} x2={x} y2={yy} stroke="var(--charcoal)" strokeWidth={0.8} />;
      })}
    </g>
  );

  const zig = (x) => `M ${x},${soffit - girderD - 4} L ${x + 4},${soffit - girderD / 2 - 4} L ${x - 4},${soffit - girderD / 2 + 4} L ${x},${soffit + 4}`;
  const gx1 = 236;
  const gx2 = 452;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Level under a bridge: backsight on a benchmark, inverted rod on the girder, foresight on the road crown"
      style={{ width: '100%', height: 'auto' }}>
      {/* ground and road */}
      <path d={`M 14,${bmBase} L 208,${bmBase} L 222,${road} L ${xCrown - 64},${road} Q ${xCrown},${2 * crownY - road} ${xCrown + 64},${road} L ${W - 10},${road}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* bridge girder (continues both ways: break lines) */}
      <rect x={gx1} y={soffit - girderD} width={gx2 - gx1} height={girderD} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={1.8} />
      <path d={zig(gx1)} fill="none" stroke="var(--charcoal)" strokeWidth={1.2} />
      <path d={zig(gx2)} fill="none" stroke="var(--charcoal)" strokeWidth={1.2} />
      <Label x={(gx1 + gx2) / 2 - 30} y={soffit - girderD / 2} color="var(--charcoal)" fontSize={12}>Bridge girder</Label>

      {/* benchmark */}
      <rect x={xBM - 8} y={bmBase} width={16} height={4} rx={1} fill="var(--charcoal)" />
      {rod(xBM, bmBase, bmBase - rodLen)}

      {/* level */}
      <g>
        <line x1={xInst - 14} y1={bmBase} x2={xInst} y2={sight + 5} stroke="var(--charcoal)" strokeWidth={1.5} />
        <line x1={xInst + 14} y1={bmBase} x2={xInst} y2={sight + 5} stroke="var(--charcoal)" strokeWidth={1.5} />
        <line x1={xInst} y1={bmBase} x2={xInst} y2={sight + 5} stroke="var(--charcoal)" strokeWidth={1.5} />
        <rect x={xInst - 12} y={sight - 4} width={24} height={8} rx={2} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.5} />
      </g>

      {/* rods */}
      {rod(xCrown, crownY, crownY - rodLen)}
      {rod(xInv, soffit, soffit + rodLen)}

      {/* line of sight */}
      <line x1={xBM} y1={sight} x2={xInv} y2={sight} stroke="var(--ember)" strokeWidth={1.3} strokeDasharray="6,4" />

      {/* readings */}
      <Label x={xBM - 9} y={sight - 9} anchor="end" color="var(--ember)" fontSize={12}>{`BS ${fmt(bs)}`}</Label>
      <Label x={xCrown + 9} y={sight - 9} anchor="start" color="var(--ember)" fontSize={12}>{`FS ${fmt(fs)}`}</Label>
      <Label x={xInv + 9} y={sight + 11} anchor="start" color="var(--ember)" fontSize={12}>{fmt(inv)}</Label>
      <Label x={xInv + 9} y={soffit + 26} anchor="start" color="var(--charcoal)" fontSize={12}>Rod upside</Label>
      <Label x={xInv + 9} y={soffit + 41} anchor="start" color="var(--charcoal)" fontSize={12}>down</Label>

      <Label x={xBM} y={bmBase + 16} color="var(--charcoal)" fontSize={12} bold>BM</Label>
      <Label x={xBM + 14} y={bmBase + 16} anchor="start" color="var(--gray-500)" fontSize={12}>{`El. ${fmt(bmElev)} ft`}</Label>
      <Label x={xCrown} y={road + 14} color="var(--charcoal)" fontSize={12}>Road crown</Label>
    </svg>
  );
}

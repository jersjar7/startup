import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Sign on a single pipe post fixed at the ground (side view, sign edge-on),
// with the pipe cross section beside it.
export function CtMechanicsMaterialsASignPost({ F = 0.8, h = 10, postHeight = 12.5, od = 6.625, t = 0.28 }) {
  const ground = 262;
  const ppf = 19;
  const px = 120;
  const pw = 10;
  const topY = ground - postHeight * ppf;
  const fy = ground - h * ppf;
  const signH = 3.6 * ppf;

  const scx = 278;
  const scy = 150;
  const ro = 40;
  const ri = ro * (od - 2 * t) / od;

  return (
    <svg viewBox="0 0 350 290" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Sign post fixed at the ground with a ${F} kip wind resultant ${h} ft above the base; pipe ${od} in. outside diameter, ${t} in. wall`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMmASignHead" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* Post */}
      <rect x={px - pw / 2} y={topY} width={pw} height={ground - topY} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      {/* Sign panel, edge-on */}
      <rect x={px - pw / 2 - 6} y={fy - signH / 2} width={6} height={signH} fill="var(--charcoal)" />
      {/* Ground, fixed */}
      <line x1={60} y1={ground} x2={190} y2={ground} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 9 }, (_, i) => (
        <line key={i} x1={66 + i * 14} y1={ground} x2={58 + i * 14} y2={ground + 9} stroke="var(--charcoal)" strokeWidth={1.25} />
      ))}
      {/* Wind resultant */}
      <line x1={22} y1={fy} x2={px - pw / 2 - 8} y2={fy} stroke="var(--ember)" strokeWidth={2.25} markerEnd="url(#ctMmASignHead)" />
      <Label x={60} y={fy - 14} bold color="var(--ember)">{F.toFixed(2)} kip</Label>
      {/* Height to the resultant */}
      <line x1={px + pw / 2 + 4} y1={fy} x2={190} y2={fy} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={180} y1={fy} x2={180} y2={ground} label={`${h} ft`} offset={-20} fontSize={12} />
      <Label x={px - 14} y={fy - signH / 2 - 8} anchor="end" color="var(--charcoal)">sign (edge view)</Label>

      {/* Section */}
      <Label x={scx} y={scy - ro - 16} color="var(--charcoal)" bold>Pipe section</Label>
      <circle cx={scx} cy={scy} r={(ro + ri) / 2} fill="none" stroke="var(--charcoal)" strokeWidth={ro - ri} />
      <Label x={scx} y={scy + ro + 18} color="var(--charcoal)">OD = {od} in.</Label>
      <Label x={scx} y={scy + ro + 36} color="var(--charcoal)">wall t = {t.toFixed(3)} in.</Label>
    </svg>
  );
}

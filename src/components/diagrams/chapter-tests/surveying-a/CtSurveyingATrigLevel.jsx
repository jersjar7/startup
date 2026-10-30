import React from 'react';
import { arcPath } from '../../geo';
import { Label } from '../../primitives';

/**
 * Trigonometric leveling, elevation view, NOT TO SCALE.
 * Total station over A (instrument height hi), prism pole on B (hr),
 * slope distance along the line of sight and the zenith angle from vertical.
 */
export function CtSurveyingATrigLevel({ elevA = 1286.42, hi = 5.12, hr = 6.5, sd = 1245.8, zenith = '86°24′10″' }) {
  const A = { x: 104, y: 166 };
  const B = { x: 392, y: 82 };
  const instH = 50;
  const poleH = 62;
  const inst = { x: A.x, y: A.y - instH };
  const prism = { x: B.x, y: B.y - poleH };
  const W = 480;
  const H = A.y + 34;
  const losAng = (Math.atan2(inst.y - prism.y, prism.x - inst.x) * 180) / Math.PI;
  const mid = { x: (inst.x + prism.x) / 2, y: (inst.y + prism.y) / 2 };
  const fmt = (v) => v.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const dim = (x, y1, y2) => (
    <g stroke="var(--gray-500)" strokeWidth={1}>
      <line x1={x} y1={y1} x2={x} y2={y2} />
      <line x1={x - 4} y1={y1} x2={x + 4} y2={y1} />
      <line x1={x - 4} y1={y2} x2={x + 4} y2={y2} />
    </g>
  );

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Trigonometric leveling from A to B: slope distance ${fmt(sd)} ft, zenith angle ${zenith}, instrument height ${hi} ft, prism height ${hr} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {/* ground */}
      <path d={`M 14,${A.y} L ${A.x + 40},${A.y} C ${A.x + 140},${A.y} ${B.x - 120},${B.y} ${B.x},${B.y} L ${W - 12},${B.y - 4}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* total station on tripod */}
      <line x1={A.x - 14} y1={A.y} x2={A.x} y2={inst.y + 6} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={A.x + 14} y1={A.y} x2={A.x} y2={inst.y + 6} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={A.x} y1={A.y} x2={A.x} y2={inst.y + 6} stroke="var(--charcoal)" strokeWidth={1.5} />
      <rect x={A.x - 8} y={inst.y - 6} width={16} height={12} rx={2} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* prism pole */}
      <line x1={B.x} y1={B.y} x2={B.x} y2={prism.y} stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={prism.x} cy={prism.y} r={5} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* vertical reference and zenith angle */}
      <line x1={inst.x} y1={inst.y} x2={inst.x} y2={inst.y - 86} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <path d={arcPath(inst.x, inst.y, 46, losAng, 90)} fill="none" stroke="var(--ember)" strokeWidth={1.4} />
      <Label x={inst.x + 22} y={inst.y - 64} anchor="start" color="var(--ember)" fontSize={12}>{`z = ${zenith}`}</Label>

      {/* line of sight */}
      <line x1={inst.x} y1={inst.y} x2={prism.x} y2={prism.y} stroke="var(--ember)" strokeWidth={1.5} />
      <Label x={mid.x + 18} y={mid.y + 16} color="var(--charcoal)" fontSize={12} rotate={-losAng}>{`S = ${fmt(sd)} ft`}</Label>

      {/* heights */}
      {dim(A.x - 30, A.y, inst.y)}
      <Label x={A.x - 38} y={(A.y + inst.y) / 2 - 8} anchor="end" color="var(--gray-500)" fontSize={12}>hi =</Label>
      <Label x={A.x - 38} y={(A.y + inst.y) / 2 + 8} anchor="end" color="var(--gray-500)" fontSize={12}>{`${hi.toFixed(2)} ft`}</Label>
      {dim(B.x + 22, B.y, prism.y)}
      <Label x={B.x + 30} y={(B.y + prism.y) / 2 - 8} anchor="start" color="var(--gray-500)" fontSize={12}>hr =</Label>
      <Label x={B.x + 30} y={(B.y + prism.y) / 2 + 8} anchor="start" color="var(--gray-500)" fontSize={12}>{`${hr.toFixed(2)} ft`}</Label>

      <circle cx={A.x} cy={A.y} r={3} fill="var(--charcoal)" />
      <circle cx={B.x} cy={B.y} r={3} fill="var(--charcoal)" />
      <Label x={A.x} y={A.y + 15} color="var(--charcoal)" fontSize={12} bold>A</Label>
      <Label x={A.x + 12} y={A.y + 15} anchor="start" color="var(--gray-500)" fontSize={12}>{`El. ${fmt(elevA)} ft`}</Label>
      <Label x={B.x} y={B.y + 15} color="var(--charcoal)" fontSize={12} bold>B</Label>
      <Label x={W - 12} y={A.y + 15} anchor="end" color="var(--gray-500)" fontSize={11}>NOT TO SCALE</Label>
    </svg>
  );
}

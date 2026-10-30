import React from 'react';
import { Label, ArrowMarkerDefs } from '../../primitives';
import { makeIsometric } from './iso';

/**
 * A flat sloping roof panel spanned by two edge vectors a and b from corner O.
 * Shows: axes, the panel, a and b with their components.
 * Does NOT show: the normal vector (the answer).
 */
export function CtMathematicsBRoofPanel({ a = [3, 0, 0], b = [0, 2, 1], unit = 'm' }) {
  const P0 = makeIsometric(0, 0, 48);
  const far = [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
  const axes = { x: [a[0] + 1.3, 0, 0], y: [0, b[1] + 1.3, 0], z: [0, 0, Math.max(a[2], b[2], 1) + 1.0] };
  const raw = [[0, 0, 0], a, b, far, axes.x, axes.y, axes.z].map(P0);
  const minX = Math.min(...raw.map((p) => p.x)) - 40;
  const maxX = Math.max(...raw.map((p) => p.x)) + 30;
  const minY = Math.min(...raw.map((p) => p.y)) - 18;
  const maxY = Math.max(...raw.map((p) => p.y)) + 24;
  const W = Math.round(maxX - minX);
  const H = Math.round(maxY - minY);
  const Q = (v) => { const p = P0(v); return { x: p.x - minX, y: p.y - minY }; };
  const O = Q([0, 0, 0]);
  const pa = Q(a);
  const pb = Q(b);
  const pf = Q(far);
  const ax = Q(axes.x);
  const ay = Q(axes.y);
  const az = Q(axes.z);
  const comp = (v) => {
    const parts = [['i', v[0]], ['j', v[1]], ['k', v[2]]].filter(([, c]) => c !== 0);
    return parts.map(([u, c], i) => {
      const mag = Math.abs(c) === 1 ? '' : `${Math.abs(c)}`;
      const sign = c < 0 ? '−' : i === 0 ? '' : '+';
      return `${i === 0 ? sign : ` ${sign} `}${mag}${u}`;
    }).join('');
  };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Roof panel with edge vectors a = ${comp(a)} and b = ${comp(b)} (${unit}) from corner O`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctMathBRoofAxis" color="var(--gray-400)" size={7} />
      <ArrowMarkerDefs id="ctMathBRoofVec" color="var(--ember)" size={9} />

      <line x1={O.x} y1={O.y} x2={ax.x} y2={ax.y} stroke="var(--gray-400)" strokeWidth={1.2} markerEnd="url(#ctMathBRoofAxis)" />
      <line x1={O.x} y1={O.y} x2={ay.x} y2={ay.y} stroke="var(--gray-400)" strokeWidth={1.2} markerEnd="url(#ctMathBRoofAxis)" />
      <line x1={O.x} y1={O.y} x2={az.x} y2={az.y} stroke="var(--gray-400)" strokeWidth={1.2} markerEnd="url(#ctMathBRoofAxis)" />
      <Label x={ax.x - 8} y={ax.y + 10} color="var(--gray-500)" fontSize={12} italic>x</Label>
      <Label x={ay.x + 8} y={ay.y + 10} color="var(--gray-500)" fontSize={12} italic>y</Label>
      <Label x={az.x - 10} y={az.y + 2} color="var(--gray-500)" fontSize={12} italic>z</Label>

      {/* Footprint on the xy-plane, dashed, so the slope of the panel reads */}
      {(() => {
        const g = (v) => Q([v[0], v[1], 0]);
        const gb = g(b);
        const gf = g(far);
        const ga = g(a);
        const d = { stroke: 'var(--gray-400)', strokeWidth: 1.1, strokeDasharray: '4,3' };
        return (
          <g>
            <line x1={pb.x} y1={pb.y} x2={gb.x} y2={gb.y} {...d} />
            <line x1={pf.x} y1={pf.y} x2={gf.x} y2={gf.y} {...d} />
            <line x1={ga.x} y1={ga.y} x2={gf.x} y2={gf.y} {...d} />
            <line x1={O.x} y1={O.y} x2={gb.x} y2={gb.y} {...d} />
          </g>
        );
      })()}

      {/* Panel: opaque, so the ground-level axes and footprint behind it are hidden */}
      <polygon points={`${O.x},${O.y} ${pa.x},${pa.y} ${pf.x},${pf.y} ${pb.x},${pb.y}`}
        fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={1.6} strokeLinejoin="round" />

      {/* Edge vectors */}
      <line x1={O.x} y1={O.y} x2={pa.x} y2={pa.y} stroke="var(--ember)" strokeWidth={2.6} markerEnd="url(#ctMathBRoofVec)" />
      <line x1={O.x} y1={O.y} x2={pb.x} y2={pb.y} stroke="var(--ember)" strokeWidth={2.6} markerEnd="url(#ctMathBRoofVec)" />
       <Label x={(O.x + pa.x) / 2 - 8} y={(O.y + pa.y) / 2 - 12} anchor="end" color="var(--ember)" fontSize={12} bold>
        {`a = ${comp(a)}`}
      </Label>
      <Label x={(O.x + pb.x) / 2} y={(O.y + pb.y) / 2 - 14} anchor="middle" color="var(--ember)" fontSize={12} bold>
        {`b = ${comp(b)}`}
      </Label>

      <circle cx={O.x} cy={O.y} r={3} fill="var(--charcoal)" />
      <Label x={O.x - 10} y={O.y - 10} color="var(--charcoal)" fontSize={12} bold>O</Label>
      <Label x={W - 8} y={H - 8} anchor="end" color="var(--gray-500)" fontSize={11}>{`components in ${unit}`}</Label>
    </svg>
  );
}

import React from 'react';
import { Label } from '../../primitives';

// Butt splice: two main plates end to end, a splice plate on each face,
// one bolt on each side of the joint. Side elevation.
export function CtMechanicsMaterialsAButtSplice({ P = 18, bolt = '3/4 in.' }) {
  const cy = 86;
  const mainH = 14;
  const spH = 8;
  const mTop = cy - mainH / 2;
  const mBot = cy + mainH / 2;
  const left = [50, 214];
  const right = [226, 390];
  const sp = [124, 316];
  const bolts = [168, 272];

  const boltShape = (x) => (
    <g key={x}>
      <rect x={x - 9} y={mTop - spH - 7} width={18} height={7} rx={1.5} fill="none" stroke="var(--charcoal)" strokeWidth={1.75} />
      <rect x={x - 4.5} y={mTop - spH} width={9} height={mainH + 2 * spH} fill="var(--gray-400)" fillOpacity={0.35} stroke="var(--charcoal)" strokeWidth={1.5} />
      <rect x={x - 9} y={mBot + spH} width={18} height={7} rx={1.5} fill="none" stroke="var(--charcoal)" strokeWidth={1.75} />
    </g>
  );

  return (
    <svg viewBox="0 0 440 156" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Butt splice with two splice plates and one ${bolt} bolt on each side, tension ${P} kips`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctMmASpliceHead" markerWidth={9} markerHeight={9} refX={8} refY={4.5} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 9,4.5 L 0,9 Z" fill="var(--ember)" />
        </marker>
      </defs>
      {/* Main plates */}
      <rect x={left[0]} y={mTop} width={left[1] - left[0]} height={mainH} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <rect x={right[0]} y={mTop} width={right[1] - right[0]} height={mainH} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      {/* Splice plates */}
      <rect x={sp[0]} y={mTop - spH} width={sp[1] - sp[0]} height={spH} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <rect x={sp[0]} y={mBot} width={sp[1] - sp[0]} height={spH} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      {bolts.map(boltShape)}

      {/* Loads */}
      <line x1={left[0] - 2} y1={cy} x2={12} y2={cy} stroke="var(--ember)" strokeWidth={2.25} markerEnd="url(#ctMmASpliceHead)" />
      <line x1={right[1] + 2} y1={cy} x2={428} y2={cy} stroke="var(--ember)" strokeWidth={2.25} markerEnd="url(#ctMmASpliceHead)" />
      <Label x={10} y={cy + 22} anchor="start" bold color="var(--ember)">{P} kips</Label>
      <Label x={430} y={cy + 22} anchor="end" bold color="var(--ember)">{P} kips</Label>

      {/* Callouts */}
      <Label x={220} y={20} color="var(--charcoal)">{bolt} bolt, one each side of joint</Label>
      <line x1={204} y1={29} x2={bolts[0] + 4} y2={mTop - spH - 9} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={236} y1={29} x2={bolts[1] - 4} y2={mTop - spH - 9} stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={220} y={mBot + spH + 32} color="var(--charcoal)">splice plate each face</Label>
      <line x1={220} y1={mBot + spH + 24} x2={220} y2={mBot + spH + 1} stroke="var(--gray-500)" strokeWidth={1} />
    </svg>
  );
}

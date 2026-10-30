import React from 'react';
import { Label } from '../../primitives';

/**
 * Slump test result: the lifted slump cone (dashed, to scale) beside the
 * concrete, one side of which has sheared off and slid down an inclined plane.
 * Shows: mold dimensions, base plate, the concrete shape.
 * Does NOT show: a slump value or the name of the result.
 */
export function CtMaterialsBSlumpShear({ height = 12, top = 4, base = 8 }) {
  const s = 15; // px per inch
  const yB = 216; // top of base plate
  const mx = 112; // mold centre x
  const cx = 300; // concrete centre x
  const X = (cxx, xin) => cxx + xin * s;
  const Y = (yin) => yB - yin * s;

  // Concrete body: left side slumped a little, right side is the shear face.
  const body = [[-4.4, 0], [-2.7, 9.6], [-1.6, 10.1], [0.5, 10.0], [4.3, 0]];
  // The sheared piece, resting against the lower part of the shear face.
  const wedge = [[2.05, 5.9], [3.4, 5.6], [5.3, 2.8], [6.9, 0], [4.3, 0]];
  const pts = (arr) => arr.map(([a, b]) => `${X(cx, a).toFixed(1)},${Y(b).toFixed(1)}`).join(' ');
  const dots = [[-2.6, 2.0], [-1.0, 4.5], [0.8, 1.8], [-3.1, 5.6], [-1.8, 7.9], [0.3, 7.2], [1.9, 3.6], [-0.2, 2.9], [4.0, 3.0], [5.2, 1.2], [3.2, 1.5]];

  const ht = top / 2, hb = base / 2;
  const mold = `${X(mx, -hb)},${Y(0)} ${X(mx, -ht)},${Y(height)} ${X(mx, ht)},${Y(height)} ${X(mx, hb)},${Y(0)}`;

  return (
    <svg viewBox="0 0 440 262" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Slump test: lifted cone beside the concrete, one side of which has sheared off"
      style={{ width: '100%', height: 'auto' }}>
      {/* Base plate */}
      <rect x={20} y={yB} width={408} height={8} rx={2} fill="var(--gray-400)" opacity={0.35} stroke="var(--charcoal)" strokeWidth={1.2} />

      {/* Lifted mold, drawn dashed in its original position next to the sample */}
      <polygon points={mold} fill="none" stroke="var(--charcoal)" strokeWidth={1.6} strokeDasharray="6,4" />

      {/* Concrete */}
      <polygon points={pts(body)} fill="var(--gray-400)" fillOpacity={0.3} stroke="var(--charcoal)" strokeWidth={1.8} strokeLinejoin="round" />
      <polygon points={pts(wedge)} fill="var(--gray-400)" fillOpacity={0.3} stroke="var(--charcoal)" strokeWidth={1.8} strokeLinejoin="round" />
      {dots.map(([a, b], i) => <circle key={i} cx={X(cx, a)} cy={Y(b)} r={2.2} fill="var(--gray-500)" />)}

      {/* Mold dimensions */}
      <g stroke="var(--gray-500)" strokeWidth={1}>
        <line x1={X(mx, -ht)} y1={Y(height) - 12} x2={X(mx, ht)} y2={Y(height) - 12} />
        <line x1={X(mx, -ht)} y1={Y(height) - 17} x2={X(mx, -ht)} y2={Y(height) - 7} />
        <line x1={X(mx, ht)} y1={Y(height) - 17} x2={X(mx, ht)} y2={Y(height) - 7} />
        <line x1={X(mx, -hb)} y1={yB + 22} x2={X(mx, hb)} y2={yB + 22} />
        <line x1={X(mx, -hb)} y1={yB + 17} x2={X(mx, -hb)} y2={yB + 27} />
        <line x1={X(mx, hb)} y1={yB + 17} x2={X(mx, hb)} y2={yB + 27} />
        <line x1={X(mx, -hb) - 16} y1={Y(height)} x2={X(mx, -hb) - 16} y2={Y(0)} />
        <line x1={X(mx, -hb) - 21} y1={Y(height)} x2={X(mx, -hb) - 11} y2={Y(height)} />
        <line x1={X(mx, -hb) - 21} y1={Y(0)} x2={X(mx, -hb) - 11} y2={Y(0)} />
        <line x1={X(mx, -ht) - 4} y1={Y(height)} x2={X(mx, -hb) - 23} y2={Y(height)} strokeDasharray="2,2" />
      </g>
      <Label x={mx} y={Y(height) - 24} color="var(--gray-500)" fontSize={11}>{`${top} in.`}</Label>
      <Label x={mx} y={yB + 36} color="var(--gray-500)" fontSize={11}>{`${base} in.`}</Label>
      <Label x={X(mx, -hb) - 24} y={(Y(height) + Y(0)) / 2} color="var(--gray-500)" fontSize={11} rotate={-90}>{`${height} in.`}</Label>

      <Label x={mx} y={Y(height / 2)} color="var(--charcoal)" fontSize={12}>Lifted</Label>
      <Label x={mx} y={Y(height / 2) + 15} color="var(--charcoal)" fontSize={12}>cone</Label>
      <Label x={cx + 10} y={Y(height) - 22} color="var(--charcoal)" fontSize={12}>Concrete after lifting</Label>
    </svg>
  );
}

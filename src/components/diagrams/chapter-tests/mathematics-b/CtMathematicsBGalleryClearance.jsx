import React from 'react';
import { Label, ArrowMarkerDefs } from '../../primitives';
import { makeProjector, fmt } from './iso';

/**
 * A straight conveyor gallery centerline through A with direction d, and the
 * top P of a light pole near it. The shortest distance D from P to the line
 * is marked but not valued.
 * Shows: axes, A, d, P with coordinates, the pole, the perpendicular D.
 * Does NOT show: the value of D or the foot of the perpendicular's coordinates.
 */
export function CtMathematicsBGalleryClearance({ A = [0, 0, 12], d = [2, -1, 2], P = [8, 0, 10], unit = 'm' }) {
  const P0 = makeProjector(0, 0, 13, 0.6);
  const dd = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
  const AP = [P[0] - A[0], P[1] - A[1], P[2] - A[2]];
  const tF = (AP[0] * d[0] + AP[1] * d[1] + AP[2] * d[2]) / dd;
  const at = (t) => [A[0] + t * d[0], A[1] + t * d[1], A[2] + t * d[2]];
  const L0 = at(-1.6);
  const L1 = at(tF + 2.2);
  const F = at(tF);
  const ground = [P[0], P[1], 0];
  const axEnd = { x: [P[0] + 3, 0, 0], y: [0, 9, 0], z: [0, 0, Math.max(L1[2], L0[2]) + 2] };
  const raw = [[0, 0, 0], A, P, L0, L1, ground, axEnd.x, axEnd.y, axEnd.z].map(P0);
  const minX = Math.min(...raw.map((p) => p.x)) - 30;
  // The y-axis tip and its label set the right edge; the note sits inside, above the y axis.
  const maxX = Math.max(...raw.map((p) => p.x)) + 24;
  const minY = Math.min(...raw.map((p) => p.y)) - 18;
  const maxY = Math.max(...raw.map((p) => p.y)) + 22;
  const W = Math.round(maxX - minX);
  const H = Math.round(maxY - minY);
  const Q = (v) => { const p = P0(v); return { x: p.x - minX, y: p.y - minY }; };
  const O = Q([0, 0, 0]);
  const pA = Q(A);
  const pP = Q(P);
  const pF = Q(F);
  const pG = Q(ground);
  const l0 = Q(L0);
  const l1 = Q(L1);
  const ax = Q(axEnd.x);
  const ay = Q(axEnd.y);
  const az = Q(axEnd.z);
  const dTip = Q(at(-0.9));
  const dTail = Q(at(-1.6));
  const co = (v) => `(${v.map(fmt).join(', ')})`;
  const comp = (v) => [['i', v[0]], ['j', v[1]], ['k', v[2]]].filter(([, c]) => c !== 0)
    .map(([u, c], i) => {
      const mag = Math.abs(c) === 1 ? '' : `${Math.abs(c)}`;
      const sign = c < 0 ? '−' : i === 0 ? '' : '+';
      return `${i === 0 ? sign : ` ${sign} `}${mag}${u}`;
    }).join('');

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Gallery centerline through A ${co(A)} with direction ${comp(d)}; light pole top P ${co(P)}; shortest distance D marked`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctMathBGalAxis" color="var(--gray-400)" size={7} />
      <ArrowMarkerDefs id="ctMathBGalDir" color="var(--charcoal)" size={8} />

      {/* Axes */}
      <line x1={O.x} y1={O.y} x2={ax.x} y2={ax.y} stroke="var(--gray-400)" strokeWidth={1.2} markerEnd="url(#ctMathBGalAxis)" />
      <line x1={O.x} y1={O.y} x2={ay.x} y2={ay.y} stroke="var(--gray-400)" strokeWidth={1.2} markerEnd="url(#ctMathBGalAxis)" />
      <line x1={O.x} y1={O.y} x2={az.x} y2={az.y} stroke="var(--gray-400)" strokeWidth={1.2} markerEnd="url(#ctMathBGalAxis)" />
      <Label x={ax.x - 8} y={ax.y + 10} color="var(--gray-500)" fontSize={12} italic>x</Label>
      <Label x={ay.x + 10} y={ay.y} color="var(--gray-500)" fontSize={12} italic>y</Label>
      <Label x={az.x + 10} y={az.y + 4} color="var(--gray-500)" fontSize={12} italic>z</Label>
      <circle cx={O.x} cy={O.y} r={2.5} fill="var(--gray-500)" />
      <Label x={O.x + 10} y={O.y + 10} color="var(--gray-500)" fontSize={11}>O</Label>

      {/* Gallery centerline */}
      <line x1={l0.x} y1={l0.y} x2={l1.x} y2={l1.y} stroke="var(--charcoal)" strokeWidth={2.4} />
      {(() => {
        // Direction arrow d, drawn parallel to the centerline and offset below it.
        const ux = dTip.x - dTail.x;
        const uy = dTip.y - dTail.y;
        const ul = Math.hypot(ux, uy);
        // Offset to the lower-left side of the line (the line runs up-left).
        const ox = (uy / ul) * 14;
        const oy = (-ux / ul) * 14;
        return (
          <g>
            <line x1={dTail.x + ox} y1={dTail.y + oy} x2={dTip.x + ox} y2={dTip.y + oy} stroke="var(--charcoal)" strokeWidth={1.6} markerEnd="url(#ctMathBGalDir)" />
            <Label x={(dTail.x + dTip.x) / 2 + ox * 2} y={(dTail.y + dTip.y) / 2 + oy * 2} color="var(--charcoal)" fontSize={13} bold italic>d</Label>
          </g>
        );
      })()}
      <Label x={l1.x + 8} y={l1.y - 8} anchor="start" color="var(--charcoal)" fontSize={11}>centerline</Label>

      {/* Light pole */}
      <line x1={pG.x} y1={pG.y} x2={pP.x} y2={pP.y} stroke="var(--gray-500)" strokeWidth={3} />
      <circle cx={pG.x} cy={pG.y} r={2.5} fill="var(--gray-500)" />

      {/* Shortest distance */}
      <line x1={pP.x} y1={pP.y} x2={pF.x} y2={pF.y} stroke="var(--ember)" strokeWidth={2} strokeDasharray="5,3" />
      <Label x={(pP.x + pF.x) / 2 + 8} y={(pP.y + pF.y) / 2 + 10} anchor="start" color="var(--ember)" fontSize={13} bold italic>D</Label>

      <circle cx={pA.x} cy={pA.y} r={3.5} fill="var(--charcoal)" />
      <Label x={pA.x + 10} y={pA.y - 14} anchor="start" color="var(--charcoal)" fontSize={12}>
        <tspan fontWeight={600}>A</tspan>{` ${co(A)}`}
      </Label>
      <circle cx={pP.x} cy={pP.y} r={3.5} fill="var(--charcoal)" />
      <Label x={pP.x - 10} y={pP.y + 4} anchor="end" color="var(--charcoal)" fontSize={12}>
        <tspan fontWeight={600}>P</tspan>{` ${co(P)}`}
      </Label>
      <Label x={ay.x - 4} y={ay.y - 30} anchor="end" color="var(--gray-500)" fontSize={11}>{`d = ${comp(d)}`}</Label>
      <Label x={ay.x - 4} y={ay.y - 15} anchor="end" color="var(--gray-500)" fontSize={11}>{`coordinates in ${unit}`}</Label>
    </svg>
  );
}

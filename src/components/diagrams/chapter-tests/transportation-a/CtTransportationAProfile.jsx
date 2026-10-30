import React from 'react';
import { Label } from '../../primitives';

/**
 * Highway profile through a vertical curve (crest or sag), drawn as the exam
 * draws it: dashed tangents meeting at the PVI, the parabola from PVC to PVT,
 * drop lines to a datum and the curve length dimensioned under the datum.
 * Horizontal distances are to scale; vertical is exaggerated (marked).
 *
 * Shows: the two grades, PVC/PVI/PVT, curve length (or "L = ?"), and the PVI
 * station and elevation when given.
 * Does NOT show: the high or low point, any curve elevation, or K.
 */
export function CtTransportationAProfile({
  g1 = 3.2,
  g2 = -1.8,
  L = 800,
  lLabel,
  pviStation,
  pviElev,
  note = 'VERTICAL SCALE EXAGGERATED',
}) {
  const W = 440;
  const fmt = (g) => `${g > 0 ? '+' : g < 0 ? '−' : ''}${Math.abs(g).toFixed(1)}%`;
  const crest = g1 > g2;
  const g1d = g1 / 100;
  const g2d = g2 / 100;
  const ext = 0.45 * L;

  // Engineering coordinates: x from the PVI (ft), y relative to the PVI elevation (ft).
  const yT = (x) => (x <= 0 ? g1d * x : g2d * x);
  const yC = (x) => {
    const u = x + L / 2;
    return -g1d * L / 2 + g1d * u + ((g2d - g1d) / (2 * L)) * u * u;
  };
  const xs = [-L / 2 - ext, L / 2 + ext];
  const ys = [yT(xs[0]), yT(xs[1]), 0, yC(-L / 2), yC(L / 2), yC(0)];
  const yMin = Math.min(...ys);
  const yMax = Math.max(...ys);

  const left = 34;
  const right = W - 34;
  const hs = (right - left) / (L + 2 * ext);
  const plotH = 92;
  const vs = plotH / (yMax - yMin || 1);
  const top = crest ? (pviStation ? 66 : 40) : 20;
  const X = (x) => left + (x + L / 2 + ext) * hs;
  const Y = (y) => top + (yMax - y) * vs;

  const pvc = { x: X(-L / 2), y: Y(yC(-L / 2)) };
  const pvi = { x: X(0), y: Y(0) };
  const pvt = { x: X(L / 2), y: Y(yC(L / 2)) };
  const datumY = top + plotH + (crest ? 34 : 46);

  const curvePts = Array.from({ length: 41 }, (_, i) => {
    const x = -L / 2 + (L * i) / 40;
    return `${X(x).toFixed(1)},${Y(yC(x)).toFixed(1)}`;
  }).join(' ');

  // Grade labels run along the solid tangent extensions, on the side away
  // from the curve (above for a crest, below for a sag).
  const gradeLabel = (xa, xb) => {
    const p1 = { x: X(xa), y: Y(yT(xa)) };
    const p2 = { x: X(xb), y: Y(yT(xb)) };
    const ang = (Math.atan2(p2.y - p1.y, p2.x - p1.x) * 180) / Math.PI;
    const len = Math.hypot(p2.x - p1.x, p2.y - p1.y);
    let nx = -(p2.y - p1.y) / len;
    let ny = (p2.x - p1.x) / len;
    if ((crest && ny > 0) || (!crest && ny < 0)) { nx = -nx; ny = -ny; }
    return { x: (p1.x + p2.x) / 2 + nx * 11, y: (p1.y + p2.y) / 2 + ny * 11, ang };
  };
  const gl1 = gradeLabel(-L / 2 - ext, -L / 2);
  const gl2 = gradeLabel(L / 2, L / 2 + ext);

  const H = datumY + 40;
  const lText = lLabel || `L = ${L.toLocaleString('en-US')} ft`;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${crest ? 'Crest' : 'Sag'} vertical curve, back grade ${g1}%, forward grade ${g2}%`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Datum and drop lines */}
      <line x1={left - 8} y1={datumY} x2={right + 8} y2={datumY} stroke="var(--gray-400)" strokeWidth={1} />
      {[pvc, pvi, pvt].map((p, i) => (
        <line key={i} x1={p.x} y1={p.y + ((i === 1) !== crest ? 28 : 5)} x2={p.x} y2={datumY} stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />
      ))}

      {/* Tangent extensions inside the curve (dashed) */}
      <line x1={pvc.x} y1={pvc.y} x2={pvi.x} y2={pvi.y} stroke="var(--gray-400)" strokeWidth={1.3} strokeDasharray="5,4" />
      <line x1={pvi.x} y1={pvi.y} x2={pvt.x} y2={pvt.y} stroke="var(--gray-400)" strokeWidth={1.3} strokeDasharray="5,4" />

      {/* Roadway: tangents and parabola */}
      <line x1={X(xs[0])} y1={Y(yT(xs[0]))} x2={pvc.x} y2={pvc.y} stroke="var(--charcoal)" strokeWidth={2.4} />
      <polyline points={curvePts} fill="none" stroke="var(--charcoal)" strokeWidth={2.4} />
      <line x1={pvt.x} y1={pvt.y} x2={X(xs[1])} y2={Y(yT(xs[1]))} stroke="var(--charcoal)" strokeWidth={2.4} />

      {[pvc, pvi, pvt].map((p, i) => (
        <circle key={i} cx={p.x} cy={p.y} r={3.5} fill={i === 1 ? '#fff' : 'var(--charcoal)'} stroke="var(--charcoal)" strokeWidth={1.5} />
      ))}

      {/* Point labels: away from the curve */}
      <Label x={pvc.x} y={pvc.y + (crest ? 18 : -16)} color="var(--charcoal)" fontSize={12} bold>PVC</Label>
      <Label x={pvt.x} y={pvt.y + (crest ? 18 : -16)} color="var(--charcoal)" fontSize={12} bold>PVT</Label>
      <Label x={pvi.x} y={pvi.y + (crest ? -16 : 17)} color="var(--charcoal)" fontSize={12} bold>PVI</Label>
      {pviStation && (
        <>
          <Label x={pvi.x} y={pvi.y + (crest ? -48 : 47)} color="var(--charcoal)" fontSize={12}>{`Sta ${pviStation}`}</Label>
          <Label x={pvi.x} y={pvi.y + (crest ? -32 : 32)} color="var(--charcoal)" fontSize={12}>{`Elev ${pviElev} ft`}</Label>
        </>
      )}

      {/* Grades */}
      <Label x={gl1.x} y={gl1.y} rotate={gl1.ang} color="var(--ember)" fontSize={12} bold>{`g₁ = ${fmt(g1)}`}</Label>
      <Label x={gl2.x} y={gl2.y} rotate={gl2.ang} color="var(--ember)" fontSize={12} bold>{`g₂ = ${fmt(g2)}`}</Label>

      {/* Curve length under the datum */}
      <line x1={pvc.x} y1={datumY + 14} x2={pvt.x} y2={datumY + 14} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={pvc.x} y1={datumY + 8} x2={pvc.x} y2={datumY + 20} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={pvt.x} y1={datumY + 8} x2={pvt.x} y2={datumY + 20} stroke="var(--gray-500)" strokeWidth={1} />
      <rect x={(pvc.x + pvt.x) / 2 - (lText.length * 3.6 + 6)} y={datumY + 7} width={lText.length * 7.2 + 12} height={14} fill="#fff" />
      <Label x={(pvc.x + pvt.x) / 2} y={datumY + 14.5} color="var(--gray-500)" fontSize={12}>{lText}</Label>
      <Label x={right + 6} y={datumY + 32} color="var(--gray-500)" fontSize={11} anchor="end">{note}</Label>
    </svg>
  );
}

import React from 'react';
import { Label } from '../../primitives';

const fmtGrade = (g) => `${g > 0 ? '+' : g < 0 ? '−' : ''}${Math.abs(g).toFixed(1)}%`;
const fmtSta = (s) => `${Math.floor(s / 100)}+${(s % 100).toFixed(2).padStart(5, '0')}`;

/**
 * Highway profile through a vertical curve, crest or sag: solid tangents and
 * parabola, dashed tangent extensions meeting at the PVI, drop lines from the
 * PVC and PVT to a datum, and the curve length dimensioned under the datum.
 * Horizontal distances are to scale; the vertical scale is exaggerated (noted),
 * but every elevation, the bridge included, uses the same vertical scale.
 *
 * Optional `bridge` ({ station, underside }) draws an overpass crossing the
 * road at that station, with its underside elevation and the vertical
 * clearance down to the road marked "clearance = ?".
 *
 * Shows: the two grades, PVC/PVI/PVT, curve length, and the PVI station and
 * elevation when given; the bridge station and underside elevation.
 * Does NOT show: any curve elevation, the high or low point, the clearance
 * value or any sight distance.
 */
export function CtTransportationBProfile({
  g1 = 2.5,
  g2 = -2.0,
  L = 300,
  pviStation, // number of feet, e.g. 3300 for 33+00.00
  pviElev, // ft
  bridge, // { station, underside }
}) {
  const W = 440;
  const crest = g1 > g2;
  const g1d = g1 / 100;
  const g2d = g2 / 100;
  const ext = 0.38 * L;
  const pviZ = pviElev ?? 0;

  // Engineering coordinates: x from the PVI (ft), z elevation (ft).
  const zT = (x) => pviZ + (x <= 0 ? g1d * x : g2d * x);
  const zC = (x) => {
    const u = x + L / 2;
    return pviZ - g1d * L / 2 + g1d * u + ((g2d - g1d) / (2 * L)) * u * u;
  };
  const xs = [-L / 2 - ext, L / 2 + ext];
  const bx = bridge ? bridge.station - pviStation : null;
  const deck = 4.5; // ft, depth of the bridge section as drawn
  const zs = [zT(xs[0]), zT(xs[1]), pviZ, zC(-L / 2), zC(L / 2), zC(0)];
  if (bridge) zs.push(bridge.underside + deck);
  const zMin = Math.min(...zs);
  const zMax = Math.max(...zs);

  const left = 30;
  const right = W - 30;
  const hs = (right - left) / (L + 2 * ext);
  const plotH = bridge ? 150 : 96;
  const vs = plotH / (zMax - zMin || 1);
  const top = bridge ? 34 : crest ? 34 : 22;
  const X = (x) => left + (x + L / 2 + ext) * hs;
  const Y = (z) => top + (zMax - z) * vs;

  const pvc = { x: X(-L / 2), y: Y(zC(-L / 2)) };
  const pvi = { x: X(0), y: Y(pviZ) };
  const pvt = { x: X(L / 2), y: Y(zC(L / 2)) };
  const lowest = Math.max(pvc.y, pvt.y, pvi.y, Y(zT(xs[0])), Y(zT(xs[1])));
  const pviText = pviStation != null && !crest;
  const datumY = lowest + (crest ? 26 : pviText ? 58 : 30);

  const curvePts = Array.from({ length: 49 }, (_, i) => {
    const x = -L / 2 + (L * i) / 48;
    return `${X(x).toFixed(1)},${Y(zC(x)).toFixed(1)}`;
  }).join(' ');

  // Grade labels sit along the outer tangents, on the side away from the curve.
  const gradeLabel = (xa, xb) => {
    const p1 = { x: X(xa), y: Y(zT(xa)) };
    const p2 = { x: X(xb), y: Y(zT(xb)) };
    const ang = (Math.atan2(p2.y - p1.y, p2.x - p1.x) * 180) / Math.PI;
    const len = Math.hypot(p2.x - p1.x, p2.y - p1.y);
    let nx = -(p2.y - p1.y) / len;
    let ny = (p2.x - p1.x) / len;
    if ((crest && ny > 0) || (!crest && ny < 0)) { nx = -nx; ny = -ny; }
    return { x: (p1.x + p2.x) / 2 + nx * 12, y: (p1.y + p2.y) / 2 + ny * 12, ang };
  };
  const gl1 = gradeLabel(-L / 2 - ext, -L / 2);
  const gl2 = gradeLabel(L / 2, L / 2 + ext);

  const lText = `L = ${L.toLocaleString('en-US')} ft`;
  const H = datumY + 42;

  // Bridge geometry
  let br = null;
  if (bridge) {
    const half = 20 * hs; // a 40 ft wide bridge section, to the horizontal scale
    const xb = X(bx);
    const yu = Y(bridge.underside);
    const yt = Y(bridge.underside + deck);
    const yr = Y(zC(bx));
    br = { xb, yu, yt, yr, half: Math.max(half, 7) };
  }

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label={`${crest ? 'Crest' : 'Sag'} vertical curve, grades ${g1}% and ${g2}%, length ${L} ft${bridge ? ', with a bridge over the road' : ''}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Datum and drop lines from PVC and PVT */}
      <line x1={left - 6} y1={datumY} x2={right + 6} y2={datumY} stroke="var(--gray-400)" strokeWidth={1} />
      {[pvc, pvt].map((p, i) => (
        <line key={i} x1={p.x} y1={p.y + (crest ? 26 : 6)} x2={p.x} y2={datumY} stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />
      ))}

      {/* Tangent extensions inside the curve (dashed) */}
      <line x1={pvc.x} y1={pvc.y} x2={pvi.x} y2={pvi.y} stroke="var(--gray-400)" strokeWidth={1.3} strokeDasharray="5,4" />
      <line x1={pvi.x} y1={pvi.y} x2={pvt.x} y2={pvt.y} stroke="var(--gray-400)" strokeWidth={1.3} strokeDasharray="5,4" />

      {/* Roadway: tangents and parabola */}
      <line x1={X(xs[0])} y1={Y(zT(xs[0]))} x2={pvc.x} y2={pvc.y} stroke="var(--charcoal)" strokeWidth={2.4} />
      <polyline points={curvePts} fill="none" stroke="var(--charcoal)" strokeWidth={2.4} />
      <line x1={pvt.x} y1={pvt.y} x2={X(xs[1])} y2={Y(zT(xs[1]))} stroke="var(--charcoal)" strokeWidth={2.4} />

      {[pvc, pvi, pvt].map((p, i) => (
        <circle key={i} cx={p.x} cy={p.y} r={3.5} fill={i === 1 ? '#fff' : 'var(--charcoal)'} stroke="var(--charcoal)" strokeWidth={1.5} />
      ))}

      {/* Point labels, away from the curve */}
      <Label x={pvc.x} y={pvc.y + (crest ? 17 : -15)} color="var(--charcoal)" fontSize={12} bold>PVC</Label>
      <Label x={pvt.x} y={pvt.y + (crest ? 17 : -15)} color="var(--charcoal)" fontSize={12} bold>PVT</Label>
      <Label x={pvi.x} y={pvi.y + (crest ? -15 : 15)} color="var(--charcoal)" fontSize={12} bold>PVI</Label>
      {pviText && (
        <>
          <Label x={pvi.x} y={pvi.y + 30} color="var(--charcoal)" fontSize={12}>{`Sta ${fmtSta(pviStation)}`}</Label>
          <Label x={pvi.x} y={pvi.y + 45} color="var(--charcoal)" fontSize={12}>{`Elev ${pviElev.toFixed(2)} ft`}</Label>
        </>
      )}

      {/* Grades */}
      <Label x={gl1.x} y={gl1.y} rotate={gl1.ang} color="var(--ember)" fontSize={12} bold>{`g₁ = ${fmtGrade(g1)}`}</Label>
      <Label x={gl2.x} y={gl2.y} rotate={gl2.ang} color="var(--ember)" fontSize={12} bold>{`g₂ = ${fmtGrade(g2)}`}</Label>

      {/* Bridge over the road */}
      {br && (
        <g>
          <rect x={br.xb - br.half} y={br.yt} width={2 * br.half} height={br.yu - br.yt}
            fill="var(--gray-200)" stroke="var(--charcoal)" strokeWidth={1.6} />
          {/* rail on top */}
          <line x1={br.xb - br.half - 3} y1={br.yt - 3} x2={br.xb + br.half + 3} y2={br.yt - 3} stroke="var(--charcoal)" strokeWidth={2} />
          <Label x={br.xb - br.half - 8} y={br.yt + 2} color="var(--charcoal)" fontSize={12} anchor="end">railroad bridge</Label>
          <Label x={br.xb - br.half - 8} y={br.yu - 2} color="var(--charcoal)" fontSize={12} anchor="end">{`underside Elev ${bridge.underside.toFixed(2)} ft`}</Label>
          <Label x={br.xb} y={br.yt - 16} color="var(--charcoal)" fontSize={12}>{`Sta ${fmtSta(bridge.station)}`}</Label>
          {/* clearance dimension, from the underside down to the road surface */}
          <line x1={br.xb} y1={br.yu + 1} x2={br.xb} y2={br.yr - 2} stroke="var(--ember)" strokeWidth={1.2} />
          <line x1={br.xb - 6} y1={br.yu} x2={br.xb + 6} y2={br.yu} stroke="var(--ember)" strokeWidth={1.2} />
          <line x1={br.xb - 6} y1={br.yr - 2} x2={br.xb + 6} y2={br.yr - 2} stroke="var(--ember)" strokeWidth={1.2} />
          <Label x={br.xb + 9} y={(br.yu + br.yr) / 2} color="var(--ember)" fontSize={12} bold anchor="start">clearance = ?</Label>
        </g>
      )}

      {/* Curve length under the datum */}
      <line x1={pvc.x} y1={datumY + 14} x2={pvt.x} y2={datumY + 14} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={pvc.x} y1={datumY + 8} x2={pvc.x} y2={datumY + 20} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={pvt.x} y1={datumY + 8} x2={pvt.x} y2={datumY + 20} stroke="var(--gray-500)" strokeWidth={1} />
      <rect x={(pvc.x + pvt.x) / 2 - (lText.length * 3.5 + 5)} y={datumY + 7} width={lText.length * 7 + 10} height={14} fill="#fff" />
      <Label x={(pvc.x + pvt.x) / 2} y={datumY + 14.5} color="var(--gray-500)" fontSize={12}>{lText}</Label>
      <Label x={right + 6} y={datumY + 33} color="var(--gray-500)" fontSize={11} anchor="end">VERTICAL SCALE EXAGGERATED</Label>
    </svg>
  );
}

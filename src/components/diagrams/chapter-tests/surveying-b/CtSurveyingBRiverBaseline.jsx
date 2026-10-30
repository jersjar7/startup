import React from 'react';
import { arcPath } from '../../geo';
import { Label } from '../../primitives';

/**
 * Plan view: baseline AB taped on the near bank of a river, tower C on the
 * far bank. Drawn to scale from AB and the two measured interior angles.
 * Sight lines AC and BC are dashed; AC (the unknown) is marked, not valued.
 */
export function CtSurveyingBRiverBaseline({ ab = 412.36, angA = '71°18′40″', angB = '48°45′10″', aDeg = 71.3111, bDeg = 48.7528 }) {
  const rad = (d) => (d * Math.PI) / 180;
  const cDeg = 180 - aDeg - bDeg;
  const ac = (ab * Math.sin(rad(bDeg))) / Math.sin(rad(cDeg));
  const cx = ac * Math.cos(rad(aDeg));
  const cy = ac * Math.sin(rad(aDeg));
  const s = 300 / ab;
  const ox = 56;
  const top = 40;
  const oy = top + cy * s;
  const P = (x, y) => ({ x: ox + x * s, y: oy - y * s });
  const A = P(0, 0);
  const B = P(ab, 0);
  const C = P(cx, cy);
  const nearBank = oy - 0.17 * cy * s;
  const farBank = oy - 0.8 * cy * s;
  const W = 430;
  const H = oy + 30;
  const wave = (y) => {
    let d = `M 12,${y}`;
    for (let x = 12; x < W - 12; x += 40) d += ` q 10,-4 20,0 t 20,0`;
    return d;
  };
  const wx = ox + 0.86 * ab * s;
  const wy = (nearBank + farBank) / 2;
  const nx = W - 34;
  const ny = 22;

  return (
    <svg viewBox={`0 0 ${W} ${Math.ceil(H)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Baseline AB ${ab} ft on the near bank of a river, interior angles ${angA} at A and ${angB} at B, tower C on the far bank`}
      style={{ width: '100%', height: 'auto' }}>
      {/* river banks */}
      <path d={wave(nearBank)} fill="none" stroke="var(--info)" strokeWidth={1.6} />
      <path d={wave(farBank)} fill="none" stroke="var(--info)" strokeWidth={1.6} />
      <Label x={wx} y={wy} color="var(--info)" fontSize={12}>River</Label>

      {/* sight lines and baseline */}
      <line x1={A.x} y1={A.y} x2={C.x} y2={C.y} stroke="var(--ember)" strokeWidth={1.6} strokeDasharray="6,4" />
      <line x1={B.x} y1={B.y} x2={C.x} y2={C.y} stroke="var(--gray-500)" strokeWidth={1.3} strokeDasharray="6,4" />
      <line x1={A.x} y1={A.y} x2={B.x} y2={B.y} stroke="var(--charcoal)" strokeWidth={2.2} />

      {/* angles */}
      <path d={arcPath(A.x, A.y, 26, 0, aDeg)} fill="none" stroke="var(--charcoal)" strokeWidth={1.3} />
      <path d={arcPath(B.x, B.y, 26, 180 - bDeg, 180)} fill="none" stroke="var(--charcoal)" strokeWidth={1.3} />
      <Label x={A.x + 34} y={A.y - 13} anchor="start" color="var(--charcoal)" fontSize={12}>{angA}</Label>
      <Label x={B.x - 34} y={B.y - 13} anchor="end" color="var(--charcoal)" fontSize={12}>{angB}</Label>

      {[A, B].map((p, i) => <circle key={i} cx={p.x} cy={p.y} r={3.2} fill="var(--charcoal)" />)}
      <circle cx={C.x} cy={C.y} r={4} fill="none" stroke="var(--charcoal)" strokeWidth={1.8} />
      <circle cx={C.x} cy={C.y} r={1.4} fill="var(--charcoal)" />

      <Label x={A.x - 9} y={A.y} anchor="end" color="var(--charcoal)" fontSize={13} bold>A</Label>
      <Label x={B.x + 9} y={B.y} anchor="start" color="var(--charcoal)" fontSize={13} bold>B</Label>
      <Label x={C.x + 10} y={C.y - 6} anchor="start" color="var(--charcoal)" fontSize={13} bold>C</Label>
      <Label x={C.x + 24} y={C.y - 6} anchor="start" color="var(--gray-500)" fontSize={12}>(tower)</Label>
      <Label x={(A.x + B.x) / 2} y={A.y + 16} color="var(--gray-500)" fontSize={12}>{`AB = ${ab.toFixed(2)} ft`}</Label>

      {/* north arrow */}
      <line x1={nx} y1={ny + 26} x2={nx} y2={ny} stroke="var(--charcoal)" strokeWidth={1.5} />
      <path d={`M ${nx},${ny - 4} L ${nx - 5},${ny + 7} L ${nx + 5},${ny + 7} Z`} fill="var(--charcoal)" />
      <Label x={nx + 10} y={ny + 4} anchor="start" color="var(--charcoal)" fontSize={12} bold>N</Label>
    </svg>
  );
}

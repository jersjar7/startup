import React from 'react';
import { ArrowMarkerDefs, PinSupport, Label } from '../../primitives';
import { arcPath, polar } from '../../geo';

/**
 * A tilt-up wall panel pinned at its bottom edge A, at `angle` to the ground,
 * lifted by a cable at B perpendicular to the panel.
 * Shows: weight at mid-length, cable direction, angle, length.
 * Does NOT show: the cable tension value.
 */
export function CtStaticsBTiltUpPanel({ weight = 40, length = 24, angle = 30 }) {
  const S = 10;
  const A = { x: 44, y: 206 };
  const Lp = length * S;
  const B = polar(A.x, A.y, Lp, angle);
  const G = polar(A.x, A.y, Lp / 2, angle);
  const t = 5; // half thickness
  const nUp = { x: -Math.sin((angle * Math.PI) / 180), y: -Math.cos((angle * Math.PI) / 180) };
  const c = (p, s) => `${p.x + nUp.x * t * s},${p.y + nUp.y * t * s}`;
  const Bt = { x: B.x + nUp.x * t, y: B.y + nUp.y * t };
  const cableEnd = { x: Bt.x + nUp.x * 74, y: Bt.y + nUp.y * 74 };
  const gray = 'var(--gray-500)';
  const lab = polar(A.x, A.y, 66, angle / 2);
  const Lm = polar(A.x, A.y, Lp * 0.62, angle);
  const Lbl = { x: Lm.x - nUp.x * 16, y: Lm.y - nUp.y * 16 };
  // right-angle mark at B between panel and cable
  const u = { x: Math.cos((angle * Math.PI) / 180), y: -Math.sin((angle * Math.PI) / 180) };
  const m = 9;
  const ra = [
    { x: Bt.x - u.x * m, y: Bt.y - u.y * m },
    { x: Bt.x - u.x * m + nUp.x * m, y: Bt.y - u.y * m + nUp.y * m },
    { x: Bt.x + nUp.x * m, y: Bt.y + nUp.y * m },
  ];

  return (
    <svg viewBox="0 0 330 252" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Tilt-up panel ${length} ft long weighing ${weight} kips at ${angle} degrees, cable perpendicular to the panel at B`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBTiltArrow" color="var(--ember)" size={9} />

      {/* Ground */}
      <line x1={14} y1={A.y + 16} x2={318} y2={A.y + 16} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 20 }, (_, i) => (
        <line key={i} x1={20 + i * 15} y1={A.y + 16} x2={12 + i * 15} y2={A.y + 24} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}
      <PinSupport x={A.x} y={A.y} />

      {/* Horizontal reference and angle */}
      <line x1={A.x} y1={A.y} x2={A.x + 104} y2={A.y} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="5,4" />
      <path d={arcPath(A.x, A.y, 54, 0, angle)} fill="none" stroke={gray} strokeWidth={1.2} />
      <Label x={lab.x + 4} y={lab.y} color="var(--charcoal)">{`${angle}°`}</Label>

      {/* Panel */}
      <polygon points={`${c(A, 1)} ${c(B, 1)} ${c(B, -1)} ${c(A, -1)}`} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <circle cx={A.x} cy={A.y} r={3.4} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      <Label x={A.x - 14} y={A.y - 8} color="var(--charcoal)" bold>A</Label>
      <Label x={B.x + 12} y={B.y + 6} color="var(--charcoal)" bold anchor="start">B</Label>

      {/* Cable perpendicular to panel */}
      <line x1={Bt.x} y1={Bt.y} x2={cableEnd.x} y2={cableEnd.y} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBTiltArrow)" />
      <polyline points={ra.map((p) => `${p.x},${p.y}`).join(' ')} fill="none" stroke={gray} strokeWidth={1.2} />
      <Label x={cableEnd.x - 8} y={cableEnd.y + 6} color="var(--ember)" bold anchor="end" italic>T</Label>
      <Label x={cableEnd.x + 10} y={cableEnd.y + 6} color="var(--charcoal)" anchor="start">cable</Label>

      {/* Weight at mid-length, drawn from above onto the panel */}
      <circle cx={G.x} cy={G.y} r={2.8} fill="var(--charcoal)" />
      <line x1={G.x} y1={G.y - 70} x2={G.x} y2={G.y - t / Math.cos((angle * Math.PI) / 180) - 2} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBTiltArrow)" />
      <Label x={G.x - 8} y={G.y - 60} color="var(--ember)" bold anchor="end">{`${weight} kips`}</Label>
      <Label x={G.x - 8} y={G.y - 45} color="var(--charcoal)" anchor="end">at mid-length</Label>

      {/* Panel length, written along the panel */}
      <Label x={Lbl.x} y={Lbl.y} rotate={-angle} color="var(--charcoal)">{`panel length ${length} ft`}</Label>
    </svg>
  );
}

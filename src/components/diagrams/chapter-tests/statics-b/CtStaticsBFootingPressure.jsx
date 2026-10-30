import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Wall footing with a linearly varying soil pressure underneath, largest at
 * the toe (left).
 * Shows: footing, stem stub, the trapezoidal pressure diagram with its two
 * end values, the width.
 * Does NOT show: the resultant or its location.
 */
export function CtStaticsBFootingPressure({ width = 8, qToe = 3.0, qHeel = 1.0 }) {
  const S = 30;
  const k = 20; // px per ksf
  const x0 = 70;
  const x1 = x0 + width * S;
  const fTop = 92;
  const fBot = fTop + 40;
  const sx0 = x0 + 2 * S;
  const sx1 = sx0 + 1 * S;
  const dToe = qToe * k;
  const dHeel = qHeel * k;
  const yAt = (x) => fBot + dToe + ((x - x0) / (x1 - x0)) * (dHeel - dToe);
  const gray = 'var(--gray-500)';
  const n = 9;
  const xs = Array.from({ length: n }, (_, i) => x0 + 6 + (i * (x1 - x0 - 12)) / (n - 1));
  const dimY = fBot + dToe + 26;

  return (
    <svg viewBox={`0 0 ${x1 + 70} ${dimY + 22}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Footing ${width} ft wide with soil pressure from ${qToe} ksf at the toe to ${qHeel} ksf at the heel`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBFtgArrow" color="var(--ember)" size={7} />

      {/* Stem stub with break line */}
      <path d={`M ${sx0},${fTop} L ${sx0},${fTop - 62} L ${sx0 + 10},${fTop - 70} L ${sx1 - 10},${fTop - 62} L ${sx1},${fTop - 70} L ${sx1},${fTop}`} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <Label x={sx1 + 8} y={fTop - 40} color="var(--charcoal)" anchor="start">wall stem</Label>

      {/* Footing */}
      <rect x={x0} y={fTop} width={x1 - x0} height={fBot - fTop} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={x0} y={fTop - 12} color="var(--charcoal)" bold anchor="start">toe</Label>
      <Label x={x1} y={fTop - 12} color="var(--charcoal)" bold anchor="end">heel</Label>

      {/* Pressure diagram */}
      <polygon points={`${x0},${fBot} ${x1},${fBot} ${x1},${fBot + dHeel} ${x0},${fBot + dToe}`} fill="var(--ember-bg)" stroke="var(--ember)" strokeWidth={1.4} />
      {xs.map((x) => (
        <line key={x} x1={x} y1={yAt(x) - 1} x2={x} y2={fBot + 2} stroke="var(--ember)" strokeWidth={1.4} markerEnd="url(#ctStBFtgArrow)" />
      ))}
      <Label x={x0 - 8} y={fBot + dToe / 2} color="var(--ember)" bold anchor="end">{`${qToe.toFixed(1)} ksf`}</Label>
      <Label x={x1 + 8} y={fBot + dHeel / 2} color="var(--ember)" bold anchor="start">{`${qHeel.toFixed(1)} ksf`}</Label>

      {/* Width */}
      <line x1={x0} y1={dimY} x2={x1} y2={dimY} stroke={gray} strokeWidth={1} />
      <line x1={x0} y1={fBot + dToe + 4} x2={x0} y2={dimY + 5} stroke={gray} strokeWidth={1} />
      <line x1={x1} y1={fBot + dHeel + 4} x2={x1} y2={dimY + 5} stroke={gray} strokeWidth={1} />
      <Label x={(x0 + x1) / 2} y={dimY + 13}>{`${width} ft`}</Label>
    </svg>
  );
}

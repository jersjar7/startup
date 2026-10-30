import React from 'react';
import { Label } from '../../primitives';

/**
 * Splitting tensile test: a concrete cylinder lying on its side between two
 * bearing strips, loaded along its length. End view and side view, to scale.
 * Shows: diameter, length, the failure load P.
 * Does NOT show: any stress value.
 */
export function CtMaterialsBSplitCylinder({ D = 6, L = 12, P = '42,000 lb' }) {
  const s = 16; // px per inch
  const r = (D / 2) * s;
  const ex = 92, ey = 104; // end-view centre
  const sx = 186, sw = L * s; // side view left edge, width
  const yTop = ey - r, yBot = ey + r;
  const strip = 5;
  const id = 'ctMatBSplitArrow';
  const nArr = 7;
  const arrowsX = Array.from({ length: nArr }, (_, i) => sx + 8 + (i * (sw - 16)) / (nArr - 1));

  return (
    <svg viewBox="0 0 412 246" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Concrete cylinder on its side loaded across its diameter between bearing strips"
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id={id} markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L8,4 L0,8 Z" fill="var(--ember)" />
        </marker>
      </defs>

      {/* End view */}
      <circle cx={ex} cy={ey} r={r} fill="var(--gray-400)" fillOpacity={0.25} stroke="var(--charcoal)" strokeWidth={1.8} />
      <rect x={ex - 10} y={yTop - strip} width={20} height={strip} fill="var(--charcoal)" />
      <rect x={ex - 10} y={yBot} width={20} height={strip} fill="var(--charcoal)" />
      <line x1={ex} y1={yTop - strip - 34} x2={ex} y2={yTop - strip - 2} stroke="var(--ember)" strokeWidth={2.2} markerEnd={`url(#${id})`} />
      <line x1={ex} y1={yBot + strip + 34} x2={ex} y2={yBot + strip + 2} stroke="var(--ember)" strokeWidth={2.2} markerEnd={`url(#${id})`} />
      <Label x={ex + 8} y={yTop - strip - 26} color="var(--ember)" fontSize={12} anchor="start" bold>P</Label>
      <Label x={ex + 8} y={yBot + strip + 26} color="var(--ember)" fontSize={12} anchor="start" bold>P</Label>
      {/* Diameter dimension */}
      <g stroke="var(--gray-500)" strokeWidth={1}>
        <line x1={ex - r - 18} y1={yTop} x2={ex - r - 18} y2={yBot} />
        <line x1={ex - r - 23} y1={yTop} x2={ex - r - 13} y2={yTop} />
        <line x1={ex - r - 23} y1={yBot} x2={ex - r - 13} y2={yBot} />
        <line x1={ex - r - 10} y1={yTop} x2={ex - 12} y2={yTop} strokeDasharray="2,2" />
        <line x1={ex - r - 10} y1={yBot} x2={ex - 12} y2={yBot} strokeDasharray="2,2" />
      </g>
      <Label x={ex - r - 28} y={ey} color="var(--gray-500)" fontSize={11} rotate={-90}>{`D = ${D} in.`}</Label>
      <Label x={ex} y={yBot + strip + 50} color="var(--charcoal)" fontSize={12}>End view</Label>

      {/* Side view */}
      <rect x={sx} y={yTop} width={sw} height={2 * r} rx={3} fill="var(--gray-400)" fillOpacity={0.25} stroke="var(--charcoal)" strokeWidth={1.8} />
      <rect x={sx} y={yTop - strip} width={sw} height={strip} fill="var(--charcoal)" />
      <rect x={sx} y={yBot} width={sw} height={strip} fill="var(--charcoal)" />
      {arrowsX.map((x) => (
        <g key={x}>
          <line x1={x} y1={yTop - strip - 26} x2={x} y2={yTop - strip - 2} stroke="var(--ember)" strokeWidth={1.8} markerEnd={`url(#${id})`} />
          <line x1={x} y1={yBot + strip + 26} x2={x} y2={yBot + strip + 2} stroke="var(--ember)" strokeWidth={1.8} markerEnd={`url(#${id})`} />
        </g>
      ))}
      <line x1={sx + 8} y1={yTop - strip - 26} x2={sx + sw - 8} y2={yTop - strip - 26} stroke="var(--ember)" strokeWidth={1.4} />
      <line x1={sx + 8} y1={yBot + strip + 26} x2={sx + sw - 8} y2={yBot + strip + 26} stroke="var(--ember)" strokeWidth={1.4} />
      <Label x={sx + sw / 2} y={yTop - strip - 40} color="var(--ember)" fontSize={12} bold>{`P = ${P} (total)`}</Label>
      {/* Length dimension */}
      <g stroke="var(--gray-500)" strokeWidth={1}>
        <line x1={sx} y1={yBot + strip + 44} x2={sx + sw} y2={yBot + strip + 44} />
        <line x1={sx} y1={yBot + strip + 39} x2={sx} y2={yBot + strip + 49} />
        <line x1={sx + sw} y1={yBot + strip + 39} x2={sx + sw} y2={yBot + strip + 49} />
      </g>
      <Label x={sx + sw / 2} y={yBot + strip + 58} color="var(--gray-500)" fontSize={11}>{`L = ${L} in.`}</Label>
      <Label x={sx + sw / 2} y={yBot + strip + 76} color="var(--charcoal)" fontSize={12}>Side view</Label>
    </svg>
  );
}

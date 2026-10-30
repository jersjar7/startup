import React from 'react';
import { DimensionLine, Label } from '../../primitives';

// Built-up timber T: flange plank nailed down into a web plank. Cross section.
export function CtMechanicsMaterialsANailedTee({ bf = 8, tf = 2, tw = 2, hw = 10 }) {
  const s = 14;
  const cx = 200;
  const top = 40;
  const fL = cx - (bf * s) / 2;
  const fR = cx + (bf * s) / 2;
  const fB = top + tf * s;
  const wL = cx - (tw * s) / 2;
  const wR = cx + (tw * s) / 2;
  const wB = fB + hw * s;

  return (
    <svg viewBox="0 0 350 256" xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Timber T-beam: ${bf} by ${tf} in. flange nailed to a ${tw} by ${hw} in. web`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Planks */}
      <rect x={fL} y={top} width={fR - fL} height={fB - top} fill="var(--gray-400)" fillOpacity={0.15} stroke="var(--charcoal)" strokeWidth={2} />
      <rect x={wL} y={fB} width={wR - wL} height={wB - fB} fill="var(--gray-400)" fillOpacity={0.15} stroke="var(--charcoal)" strokeWidth={2} />
      {/* Nail */}
      <line x1={cx - 7} y1={top - 3} x2={cx + 7} y2={top - 3} stroke="var(--ember)" strokeWidth={2.5} />
      <line x1={cx} y1={top - 3} x2={cx} y2={fB + 26} stroke="var(--ember)" strokeWidth={2} />
      <Label x={36} y={fB + 40} anchor="start" color="var(--ember)" bold>nail (one row)</Label>
      <line x1={110} y1={fB + 31} x2={cx - 3} y2={fB + 16} stroke="var(--gray-500)" strokeWidth={1} />
      {/* Dimensions */}
      <DimensionLine x1={fL} y1={top - 16} x2={fR} y2={top - 16} label={`${bf} in.`} offset={-11} fontSize={12} />
      <DimensionLine x1={fR + 16} y1={top} x2={fR + 16} y2={fB} label={`${tf} in.`} offset={-20} fontSize={12} />
      <DimensionLine x1={fR + 16} y1={fB} x2={fR + 16} y2={wB} label={`${hw} in.`} offset={-22} fontSize={12} />
      <line x1={wR + 3} y1={wB} x2={fR + 21} y2={wB} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="3,3" />
      <DimensionLine x1={wL} y1={wB + 14} x2={wR} y2={wB + 14} label={`${tw} in.`} offset={13} fontSize={12} />
    </svg>
  );
}

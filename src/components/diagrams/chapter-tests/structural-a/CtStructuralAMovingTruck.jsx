import React from 'react';
import { Arrowhead, T, Pin, Roller, Dim, Ext, INK, LOAD, DIM } from './CtStructuralAParts';

/**
 * Simply supported girder with a two-axle load set that travels across it.
 * The axles are drawn at an arbitrary position near the left end; the
 * spacing between them is fixed. Drawn to scale.
 */
export function CtStructuralAMovingTruck({ span = 30, p1 = 8, p2 = 32, spacing = 14, at = 4 }) {
  const s = 330 / span;
  const ox = 34;
  const by = 106;
  const xR = ox + span * s;
  const x1 = ox + at * s;
  const x2 = x1 + spacing * s;
  const tail = by - 48;
  const dY = by - 66;
  const dimY = by + 46;
  const W = xR + 34;
  const H = dimY + 24;
  const mk = 'ctStrAMovingArrow';
  const mkG = 'ctStrAMovingTravel';

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Two-axle load set, ${p1} and ${p2} kips spaced ${spacing} ft, crossing a ${span} ft simple span`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <Arrowhead id={mk} color={LOAD} />
        <Arrowhead id={mkG} color={DIM} size={7} />
      </defs>

      {/* axle loads */}
      <line x1={x1} y1={tail} x2={x1} y2={by - 3} stroke={LOAD} strokeWidth={2} markerEnd={`url(#${mk})`} />
      <line x1={x2} y1={tail} x2={x2} y2={by - 3} stroke={LOAD} strokeWidth={2.4} markerEnd={`url(#${mk})`} />
      <T x={x1 - 7} y={by - 30} anchor="end" color={LOAD} bold>{`${p1} kips`}</T>
      <T x={x2 + 7} y={by - 30} anchor="start" color={LOAD} bold>{`${p2} kips`}</T>

      {/* axle spacing */}
      <Ext x1={x1} y1={tail - 4} x2={x1} y2={dY - 5} />
      <Ext x1={x2} y1={tail - 4} x2={x2} y2={dY - 5} />
      <Dim x1={x1} y1={dY} x2={x2} y2={dY} label={`${spacing} ft`} side="above" />

      {/* direction of travel */}
      <line x1={x2 + 44} y1={dY} x2={x2 + 110} y2={dY} stroke={DIM} strokeWidth={1.4} markerEnd={`url(#${mkG})`} />
      <T x={x2 + 77} y={dY - 13} color={DIM} size={11}>direction of travel</T>

      {/* girder */}
      <line x1={ox} y1={by} x2={xR} y2={by} stroke={INK} strokeWidth={3.5} />
      <Pin x={ox} y={by + 2} />
      <Roller x={xR} y={by + 2} />
      <T x={ox - 12} y={by} anchor="end" bold>A</T>
      <T x={xR + 12} y={by} anchor="start" bold>B</T>

      <Ext x1={ox} y1={by + 28} x2={ox} y2={dimY + 5} />
      <Ext x1={xR} y1={by + 28} x2={xR} y2={dimY + 5} />
      <Dim x1={ox} y1={dimY} x2={xR} y2={dimY} label={`${span} ft`} />
    </svg>
  );
}

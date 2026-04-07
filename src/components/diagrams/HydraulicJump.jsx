import React from 'react';
import { ArrowMarkerDefs, Label, DimensionLine } from './primitives';

/**
 * Hydraulic jump longitudinal profile — side view of flow transition.
 *
 * Shows: shallow supercritical flow (y1) transitioning to deep subcritical flow (y2),
 *        turbulent zone, flow direction arrows, channel bottom.
 *
 * Does NOT show: y2 value (student solves). Shows y1 and Fr1.
 */
export function HydraulicJump({
  y1 = 0.4,
  Fr1 = 3.0,
}) {
  const W = 420;
  const H = 200;

  // Layout
  const botY = 160;
  const leftX = 40;
  const rightX = 380;
  const jumpX = 180;      // where the jump starts

  // Scale depths — y2 is approximately y1/2 * (-1 + sqrt(1+8Fr^2))
  // We compute it for proportional drawing only
  const y2Est = (y1 / 2) * (-1 + Math.sqrt(1 + 8 * Fr1 * Fr1));
  const maxDepth = Math.max(y2Est, y1);
  const scale = 90 / maxDepth;

  const d1 = y1 * scale;            // y1 in pixels
  const d2 = y2Est * scale;         // y2 in pixels

  const waterY1 = botY - d1;
  const waterY2 = botY - d2;

  // Turbulent zone width
  const turbW = 40;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Hydraulic jump with upstream depth ${y1} m, Froude number ${Fr1}`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="flowArrow" color="var(--info)" size={6} />

      {/* 1. Channel bottom */}
      <line x1={leftX - 10} y1={botY} x2={rightX + 10} y2={botY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 2. Upstream water fill (shallow) */}
      <rect x={leftX} y={waterY1} width={jumpX - leftX} height={d1}
        fill="rgba(160,210,240,0.25)" />

      {/* 3. Downstream water fill (deep) */}
      <rect x={jumpX + turbW} y={waterY2} width={rightX - jumpX - turbW} height={d2}
        fill="rgba(160,210,240,0.25)" />

      {/* 4. Turbulent transition zone */}
      <path d={`M ${jumpX},${waterY1}
        C ${jumpX + 8},${waterY1 - 6} ${jumpX + 14},${waterY2 + 10} ${jumpX + 18},${waterY2 - 4}
        C ${jumpX + 22},${waterY2 + 8} ${jumpX + 28},${waterY2 - 6} ${jumpX + 32},${waterY2 + 2}
        C ${jumpX + 36},${waterY2 - 3} ${jumpX + 38},${waterY2 + 1} ${jumpX + turbW},${waterY2}`}
        fill="none" stroke="var(--info)" strokeWidth={1.5} />
      {/* Turbulent fill */}
      <path d={`M ${jumpX},${waterY1} L ${jumpX},${botY}
        L ${jumpX + turbW},${botY} L ${jumpX + turbW},${waterY2}
        C ${jumpX + 38},${waterY2 + 1} ${jumpX + 36},${waterY2 - 3} ${jumpX + 32},${waterY2 + 2}
        C ${jumpX + 28},${waterY2 - 6} ${jumpX + 22},${waterY2 + 8} ${jumpX + 18},${waterY2 - 4}
        C ${jumpX + 14},${waterY2 + 10} ${jumpX + 8},${waterY1 - 6} ${jumpX},${waterY1} Z`}
        fill="rgba(160,210,240,0.20)" />

      {/* 5. Water surface lines */}
      {/* Upstream */}
      <line x1={leftX} y1={waterY1} x2={jumpX} y2={waterY1}
        stroke="var(--info)" strokeWidth={1.5} />
      {/* Downstream */}
      <line x1={jumpX + turbW} y1={waterY2} x2={rightX} y2={waterY2}
        stroke="var(--info)" strokeWidth={1.5} />

      {/* 6. Flow direction arrows */}
      <line x1={leftX + 20} y1={waterY1 - 10} x2={leftX + 50} y2={waterY1 - 10}
        stroke="var(--info)" strokeWidth={1.5} markerEnd="url(#flowArrow)" />
      <line x1={rightX - 60} y1={waterY2 - 10} x2={rightX - 30} y2={waterY2 - 10}
        stroke="var(--info)" strokeWidth={1.5} markerEnd="url(#flowArrow)" />

      {/* 7. Depth dimension y1 (left) */}
      <DimensionLine x1={leftX + 10} y1={botY} x2={leftX + 10} y2={waterY1}
        label={`y\u2081 = ${y1} m`} offset={-24} fontSize={9} />

      {/* 8. Depth dimension y2 (right) — label only "y₂ = ?" */}
      <DimensionLine x1={rightX - 10} y1={botY} x2={rightX - 10} y2={waterY2}
        label={'y\u2082 = ?'} offset={18} fontSize={9} />

      {/* 9. Froude number label */}
      <Label x={leftX + 60} y={waterY1 - 24}
        fontSize={9} color="var(--ember)" bold>
        Fr{'\u2081'} = {Fr1}
      </Label>

      {/* 10. Flow regime labels */}
      <Label x={(leftX + jumpX) / 2} y={botY + 16}
        fontSize={7} color="var(--gray-400)">
        Supercritical
      </Label>
      <Label x={(jumpX + turbW + rightX) / 2} y={botY + 16}
        fontSize={7} color="var(--gray-400)">
        Subcritical
      </Label>
    </svg>
  );
}

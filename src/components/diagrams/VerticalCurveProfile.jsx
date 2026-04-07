import React from 'react';
import { DashedLine, Label } from './primitives';

/**
 * Vertical curve profile — parabolic transition between two road grades.
 *
 * Shows: datum line, dashed grade (tangent) lines, parabolic curve (Q Bezier),
 *        PVC/PVI/PVT markers, grade annotations, elevation labels.
 *
 * Crest curve: PVI above curve (g1 > 0, g2 < 0 or g2 < g1).
 * Sag curve:   PVI below curve (g1 < 0, g2 > 0 or g2 > g1).
 *
 * Does NOT show: computed elevations at intermediate points, high/low point
 * location, or tangent offsets (student solves).
 */
export function VerticalCurveProfile({
  g1 = 4,
  g2 = -2,
  L = 600,
  elevPVC = 100,
}) {
  const W = 460;
  const H = 240;

  // Convert percent grades to decimal for computation
  const g1d = g1 / 100;
  const g2d = g2 / 100;

  // ── Key elevations ──
  const elevPVI = elevPVC + g1d * (L / 2);
  const elevPVT = elevPVI + g2d * (L / 2);

  // Elevation range for scaling
  const elevs = [elevPVC, elevPVI, elevPVT];
  const minElev = Math.min(...elevs);
  const maxElev = Math.max(...elevs);
  const elevRange = maxElev - minElev || 10;

  // ── Layout — profile view with vertical exaggeration ──
  const plotLeft = 55;
  const plotRight = W - 50;
  const plotTop = 50;
  const plotBot = H - 55;
  const plotW = plotRight - plotLeft;
  const plotH = plotBot - plotTop;

  // Horizontal scale: L maps to plotW
  const hScale = plotW / L;

  // Vertical scale: elevation range maps to plotH with padding
  const vPad = elevRange * 0.3;
  const vScale = plotH / (elevRange + 2 * vPad);

  // Convert engineering coords to SVG
  const toX = (station) => plotLeft + station * hScale;
  const toY = (elev) => plotBot - (elev - minElev + vPad) * vScale;

  // ── Key SVG positions ──
  const pvcX = toX(0);
  const pviX = toX(L / 2);
  const pvtX = toX(L);
  const pvcY = toY(elevPVC);
  const pviY = toY(elevPVI);
  const pvtY = toY(elevPVT);

  // Datum line Y
  const datumY = plotBot + 8;

  // Grade line extensions beyond PVC and PVT
  const extLen = 30;
  const backExtX = pvcX - extLen;
  const backExtY = pvcY + extLen * (g1d * hScale / (plotW / L)) * (vScale / hScale);
  // Simplified: just extend the tangent lines a bit
  const g1Slope = (pviY - pvcY) / (pviX - pvcX);
  const g2Slope = (pvtY - pviY) / (pvtX - pviX);

  const backExtYCalc = pvcY - g1Slope * extLen;
  const aheadExtX = pvtX + extLen;
  const aheadExtYCalc = pvtY + g2Slope * extLen;

  // Curve type label
  const isCrest = g1 > g2;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${isCrest ? 'Crest' : 'Sag'} vertical curve, g1=${g1}%, g2=${g2}%, L=${L} ft, PVC elevation ${elevPVC} ft`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Datum / ground reference line */}
      <line x1={plotLeft - 10} y1={datumY} x2={plotRight + 10} y2={datumY}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Station ticks on datum */}
      {[0, L / 2, L].map((sta, i) => {
        const x = toX(sta);
        const labels = ['PVC', 'PVI', 'PVT'];
        return (
          <g key={i}>
            <line x1={x} y1={datumY} x2={x} y2={datumY + 6}
              stroke="var(--gray-400)" strokeWidth={1} />
            <Label x={x} y={datumY + 16}
              fontSize={8} color="var(--gray-500)">
              {labels[i]}
            </Label>
          </g>
        );
      })}

      {/* 2. Grade (tangent) lines — dashed */}
      <DashedLine x1={backExtX} y1={backExtYCalc} x2={pviX} y2={pviY}
        color="var(--gray-400)" strokeWidth={1.5} />
      <DashedLine x1={pviX} y1={pviY} x2={aheadExtX} y2={aheadExtYCalc}
        color="var(--gray-400)" strokeWidth={1.5} />

      {/* 3. Vertical curve — quadratic Bezier (PVI is the control point) */}
      <path
        d={`M ${pvcX},${pvcY} Q ${pviX},${pviY} ${pvtX},${pvtY}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Road extensions beyond PVC and PVT (solid) */}
      <line x1={backExtX} y1={backExtYCalc} x2={pvcX} y2={pvcY}
        stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={pvtX} y1={pvtY} x2={aheadExtX} y2={aheadExtYCalc}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 4. Vertical dashed lines from points to datum */}
      <DashedLine x1={pvcX} y1={pvcY} x2={pvcX} y2={datumY}
        color="var(--gray-400)" strokeWidth={1} />
      <DashedLine x1={pviX} y1={pviY} x2={pviX} y2={datumY}
        color="var(--gray-400)" strokeWidth={1} />
      <DashedLine x1={pvtX} y1={pvtY} x2={pvtX} y2={datumY}
        color="var(--gray-400)" strokeWidth={1} />

      {/* 5. Point markers */}
      <circle cx={pvcX} cy={pvcY} r={3.5} fill="var(--charcoal)" />
      <circle cx={pviX} cy={pviY} r={3.5} fill="var(--charcoal)" />
      <circle cx={pvtX} cy={pvtY} r={3.5} fill="var(--charcoal)" />

      {/* 6. Point labels — above for crest, below for sag at PVI */}
      <Label x={pvcX - 4} y={pvcY - 14}
        fontSize={9} color="var(--charcoal)" bold anchor="end">
        PVC
      </Label>
      <Label x={pviX} y={pviY + (isCrest ? -14 : 16)}
        fontSize={9} color="var(--charcoal)" bold>
        PVI
      </Label>
      <Label x={pvtX + 4} y={pvtY - 14}
        fontSize={9} color="var(--charcoal)" bold anchor="start">
        PVT
      </Label>

      {/* 7. Grade annotations */}
      <Label x={(pvcX + pviX) / 2 + 10} y={(pvcY + pviY) / 2 + (isCrest ? 16 : -19)}
        fontSize={9} color="var(--gray-500)">
        g{'\u2081'} = {g1 > 0 ? '+' : ''}{g1}%
      </Label>
      <Label x={(pviX + pvtX) / 2 - 12} y={(pviY + pvtY) / 2 + (isCrest ? 16 : -14)}
        fontSize={9} color="var(--gray-500)">
        g{'\u2082'} = {g2 > 0 ? '+' : ''}{g2}%
      </Label>

      {/* 8. Elevation labels */}
      <Label x={pvcX - 8} y={pvcY + 2}
        fontSize={8} color="var(--gray-500)" anchor="end">
        {elevPVC.toFixed(0)} ft
      </Label>

      {/* 9. L dimension along top */}
      <line x1={pvcX} y1={plotTop - 8} x2={pvtX} y2={plotTop - 8}
        stroke="var(--gray-500)" strokeWidth={1}
        markerStart="url(#tickStart)" markerEnd="url(#tickEnd)" />
      <line x1={pvcX} y1={plotTop - 12} x2={pvcX} y2={plotTop - 4}
        stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={pvtX} y1={plotTop - 12} x2={pvtX} y2={plotTop - 4}
        stroke="var(--gray-500)" strokeWidth={1} />
      <Label x={(pvcX + pvtX) / 2} y={plotTop - 18}
        fontSize={9} color="var(--gray-500)">
        L = {L} ft
      </Label>
    </svg>
  );
}

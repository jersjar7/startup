import React from 'react';
import { PinSupport, RollerSupport, DimensionLine, Label } from './primitives';

/**
 * Influence line for a simply supported beam.
 *
 * Top section: beam elevation with pin (left) and roller (right).
 * Bottom section: IL graph — positive ordinates plotted ABOVE the zero baseline
 * (standard structural convention).
 *
 * type = 'reaction'  — IL for left reaction RA (linear 1→0)
 * type = 'shear'     — IL for shear at section a (jump at section)
 * type = 'moment'    — IL for bending moment at section a (triangle)
 *
 * Does NOT show: computed values (student solves using the IL).
 */
export function InfluenceLineSS({
  type = 'moment',
  L = 30,
  a = 15,
  unit = 'ft',
}) {
  const W = 420;
  const HH = 340;

  // Beam layout (top section)
  const beamY = 50;
  const beamLeft = 60;
  const beamRight = W - 60;
  const beamLen = beamRight - beamLeft;

  // IL graph — zero baseline near bottom, positive extends UPWARD
  const ilZeroY = 290;
  const ilTopY = type === 'shear' ? 150 : 140; // top extent of the IL graph
  const ilH = ilZeroY - ilTopY;

  // Section position in px
  const aFrac = a / L;
  const sectionX = beamLeft + aFrac * beamLen;

  // Scale IL ordinates to fit the graph area (positive = upward = smaller Y)
  const maxOrdinate = type === 'moment' ? (a * (L - a)) / L : 1.0;
  const ilScale = (type === 'shear' ? ilH * 0.45 : ilH * 0.85) / Math.max(maxOrdinate, 0.01);

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Influence line for ${type} at ${type === 'reaction' ? 'left support' : `section ${a} ${unit} from left`}, span ${L} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* ── Beam (top section) ── */}
      <line x1={beamLeft} y1={beamY} x2={beamRight} y2={beamY}
        stroke="var(--charcoal)" strokeWidth={3} />

      {/* Supports */}
      <PinSupport x={beamLeft} y={beamY} size={14} />
      <RollerSupport x={beamRight} y={beamY} size={14} />

      {/* Support labels */}
      <Label x={beamLeft} y={beamY + 34} fontSize={9} color="var(--charcoal)" bold>A</Label>
      <Label x={beamRight} y={beamY + 34} fontSize={9} color="var(--charcoal)" bold>B</Label>

      {/* Span dimension */}
      <DimensionLine x1={beamLeft} y1={beamY + 48} x2={beamRight} y2={beamY + 48}
        label={`L = ${L} ${unit}`} offset={12} fontSize={9} />

      {/* Section marker on beam (for shear and moment) */}
      {type !== 'reaction' && (
        <g>
          <line x1={sectionX} y1={beamY - 8} x2={sectionX} y2={beamY + 8}
            stroke="var(--ember)" strokeWidth={2} />
          <Label x={sectionX} y={beamY - 16} fontSize={8} color="var(--ember)">
            {a === L / 2 ? 'midspan' : `a = ${a}`}
          </Label>
        </g>
      )}

      {/* ── IL Graph (below beam, positive upward) ── */}

      {/* Zero baseline */}
      <line x1={beamLeft} y1={ilZeroY} x2={beamRight} y2={ilZeroY}
        stroke="var(--gray-400)" strokeWidth={1} />

      {/* Zero label */}
      <Label x={beamLeft - 8} y={ilZeroY} fontSize={8} color="var(--gray-400)" anchor="end">
        0
      </Label>

      {/* Dashed verticals connecting beam supports to IL baseline */}
      <line x1={beamLeft} y1={beamY + 48 + 16} x2={beamLeft} y2={ilZeroY}
        stroke="var(--gray-300)" strokeWidth={0.8} strokeDasharray="3,3" />
      <line x1={beamRight} y1={beamY + 48 + 16} x2={beamRight} y2={ilZeroY}
        stroke="var(--gray-300)" strokeWidth={0.8} strokeDasharray="3,3" />

      {type === 'reaction' && renderReactionIL(beamLeft, beamRight, ilZeroY, ilScale)}
      {type === 'shear' && renderShearIL(beamLeft, beamRight, sectionX, aFrac, ilZeroY, ilScale)}
      {type === 'moment' && renderMomentIL(beamLeft, beamRight, sectionX, a, L, ilZeroY, ilScale)}
    </svg>
  );
}

function renderReactionIL(left, right, zeroY, scale) {
  // IL for RA: 1.0 at A, 0 at B — positive UPWARD (smaller Y in SVG)
  const peakY = zeroY - scale * 1.0;

  return (
    <g>
      {/* Fill */}
      <path d={`M ${left},${zeroY} L ${left},${peakY} L ${right},${zeroY} Z`}
        fill="rgba(160,210,240,0.20)" />
      {/* IL line */}
      <line x1={left} y1={peakY} x2={right} y2={zeroY}
        stroke="var(--info)" strokeWidth={2} />
      {/* Peak ordinate */}
      <circle cx={left} cy={peakY} r={3} fill="var(--info)" />
      <Label x={left - 12} y={peakY} fontSize={8} color="var(--info)" anchor="end">
        1.0
      </Label>
      {/* Zero at right */}
      <circle cx={right} cy={zeroY} r={3} fill="var(--info)" />
    </g>
  );
}

function renderShearIL(left, right, sectionX, aFrac, zeroY, scale) {
  // Positive ordinate just right of section: 1 - a/L (drawn UPWARD)
  const posOrd = 1 - aFrac;
  // Negative ordinate just left of section: -a/L (drawn DOWNWARD)
  const negOrd = aFrac;

  const posY = zeroY - posOrd * scale; // above zero line (positive shear)
  const negY = zeroY + negOrd * scale; // below zero line (negative shear)

  return (
    <g>
      {/* Positive fill (right of section, above baseline) */}
      <path d={`M ${sectionX},${zeroY} L ${sectionX},${posY} L ${right},${zeroY} Z`}
        fill="rgba(160,210,240,0.20)" />
      {/* Negative fill (left of section, below baseline) */}
      <path d={`M ${left},${zeroY} L ${sectionX},${negY} L ${sectionX},${zeroY} Z`}
        fill="rgba(232,104,58,0.10)" />

      {/* IL lines */}
      <line x1={left} y1={zeroY} x2={sectionX} y2={negY}
        stroke="var(--info)" strokeWidth={2} />
      <line x1={sectionX} y1={posY} x2={right} y2={zeroY}
        stroke="var(--info)" strokeWidth={2} />

      {/* Discontinuity at section (vertical jump) */}
      <line x1={sectionX} y1={negY} x2={sectionX} y2={posY}
        stroke="var(--info)" strokeWidth={1.5} strokeDasharray="3,2" />

      {/* Peak ordinates */}
      <circle cx={sectionX} cy={posY} r={3} fill="var(--info)" />
      <Label x={sectionX + 10} y={posY - 2} fontSize={8} color="var(--info)" anchor="start">
        +{posOrd.toFixed(2)}
      </Label>

      <circle cx={sectionX} cy={negY} r={3} fill="var(--info)" />
      <Label x={sectionX + 10} y={negY + 10} fontSize={8} color="var(--info)" anchor="start">
        {'\u2013'}{negOrd.toFixed(2)}
      </Label>
    </g>
  );
}

function renderMomentIL(left, right, sectionX, a, L, zeroY, scale) {
  // Peak ordinate at the section: a(L-a)/L — plotted UPWARD (positive = up)
  const peak = (a * (L - a)) / L;
  const peakY = zeroY - peak * scale;

  return (
    <g>
      {/* Fill */}
      <path d={`M ${left},${zeroY} L ${sectionX},${peakY} L ${right},${zeroY} Z`}
        fill="rgba(160,210,240,0.20)" />
      {/* IL lines */}
      <line x1={left} y1={zeroY} x2={sectionX} y2={peakY}
        stroke="var(--info)" strokeWidth={2} />
      <line x1={sectionX} y1={peakY} x2={right} y2={zeroY}
        stroke="var(--info)" strokeWidth={2} />
      {/* Peak ordinate */}
      <circle cx={sectionX} cy={peakY} r={3} fill="var(--info)" />
      <Label x={sectionX + 10} y={peakY - 4} fontSize={8} color="var(--info)" anchor="start">
        {peak % 1 === 0 ? peak.toFixed(1) : peak.toFixed(2)}
      </Label>
      {/* Zero at supports */}
      <circle cx={left} cy={zeroY} r={3} fill="var(--info)" />
      <circle cx={right} cy={zeroY} r={3} fill="var(--info)" />
    </g>
  );
}

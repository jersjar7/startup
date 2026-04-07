import React from 'react';
import { deg } from './geo';
import { DashedLine, AngleArc, Label } from './primitives';

/**
 * Horizontal curve — plan view (bird's-eye).
 *
 * Two tangent road segments meeting at PI, connected by a circular arc.
 *
 * Shows: tangent lines, circular arc from PC to PT, intersection angle arc,
 *        point markers (PC, PT, PI), tangent distance dimension, radius line.
 * Does NOT show: computed values like L, E, M, station numbers.
 */
export function HorizontalCurve({
  R = 1000,
  I = 40,
  showR = true,
  showT = true,
}) {
  const W = 420;
  const H = 280;

  // Geometry — the back tangent enters from the upper-left, the curve bends right
  const halfI = I / 2;
  const halfIRad = deg(halfI);
  const iRad = deg(I);

  // Tangent distance (for layout, not labeled unless showT)
  const T = R * Math.tan(halfIRad);

  // Scale to fit viewBox — we need room for tangent extensions beyond PI
  const maxExtent = Math.max(T + 80, R);
  const scale = Math.min(200 / maxExtent, 0.22);

  // PI position — center-ish in the viewBox
  const piX = 200;
  const piY = 70;

  // Back tangent direction: entering from the left, going right
  // Ahead tangent direction: deflecting by angle I to the right (downward in plan view)
  const backDirX = -1;
  const backDirY = 0;

  // PC is at distance T along the back tangent from PI
  const pcX = piX + backDirX * T * scale;
  const pcY = piY + backDirY * T * scale;

  // Ahead tangent direction (rotated by I clockwise from back tangent)
  const aheadDirX = Math.cos(iRad);
  const aheadDirY = Math.sin(iRad);

  // PT is at distance T along the ahead tangent from PI
  const ptX = piX + aheadDirX * T * scale;
  const ptY = piY + aheadDirY * T * scale;

  // Arc center — perpendicular to the back tangent at PC, toward the inside of the curve
  // The curve bends to the right (downward), so the center is below the back tangent
  const arcCx = pcX;
  const arcCy = pcY + R * scale;

  // Arc radius in SVG pixels
  const rPx = R * scale;

  // Back tangent extension (before PC)
  const extLen = 50;
  const backExtX = pcX + backDirX * extLen;
  const backExtY = pcY;

  // Ahead tangent extension (after PT)
  const aheadExtX = ptX + aheadDirX * extLen;
  const aheadExtY = ptY + aheadDirY * extLen;

  // Arc sweep — large arc flag
  const largeArc = I > 180 ? 1 : 0;

  // Radius line from arc center to curve midpoint
  const midAngle = deg(90 - halfI);
  const midCurveX = arcCx + rPx * Math.cos(midAngle);
  const midCurveY = arcCy - rPx * Math.sin(midAngle);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Horizontal curve with radius ${R} ft, intersection angle ${I} degrees`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Tangent lines */}
      {/* Road approach before PC (solid) */}
      <line x1={backExtX} y1={backExtY} x2={pcX} y2={pcY}
        stroke="var(--charcoal)" strokeWidth={2.5} />
      {/* Back tangent PC → PI (dashed) */}
      <line x1={pcX} y1={pcY} x2={piX} y2={piY}
        stroke="var(--gray-400)" strokeWidth={1.5} strokeDasharray="6,4" />
      {/* Back tangent extension BEYOND PI (dashed) — forms one side of angle I */}
      <line x1={piX} y1={piY} x2={piX + extLen} y2={piY}
        stroke="var(--gray-400)" strokeWidth={1.5} strokeDasharray="6,4" />
      {/* Ahead tangent PI → PT (dashed) — forms other side of angle I */}
      <line x1={piX} y1={piY} x2={ptX} y2={ptY}
        stroke="var(--gray-400)" strokeWidth={1.5} strokeDasharray="6,4" />
      {/* Road departure after PT (solid) */}
      <line x1={ptX} y1={ptY} x2={aheadExtX} y2={aheadExtY}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 2. Circular arc (the curve itself) */}
      <path
        d={`M ${pcX},${pcY} A ${rPx},${rPx} 0 ${largeArc} 1 ${ptX},${ptY}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* 3. Intersection angle arc at PI — between extended back tangent (0°) and ahead tangent (-I°) */}
      <AngleArc cx={piX} cy={piY} radius={36}
        startAngle={-I} endAngle={0}
        color="var(--ember)" />
      {/* Angle label — offset further right so it doesn't overlap the arc */}
      {(() => {
        const midA = deg(-halfI);
        const lr = 56; // label radius — well beyond the arc
        return (
          <Label x={piX + lr * Math.cos(midA)} y={piY - lr * Math.sin(midA)}
            fontSize={10} color="var(--ember)" bold>
            I = {I}&deg;
          </Label>
        );
      })()}

      {/* 4. Radius line (dashed) */}
      {showR && (
        <>
          <DashedLine x1={arcCx} y1={arcCy} x2={midCurveX} y2={midCurveY}
            color="var(--gray-400)" strokeWidth={1} />
          <Label x={(arcCx + midCurveX) / 2 + 16} y={(arcCy + midCurveY) / 2}
            fontSize={9} color="var(--gray-500)">
            R
          </Label>
        </>
      )}

      {/* 5. Tangent distance dimension */}
      {showT && (
        <Label x={(pcX + piX) / 2} y={(pcY + piY) / 2 - 12}
          fontSize={9} color="var(--gray-500)">
          T
        </Label>
      )}

      {/* 6. Point markers */}
      <circle cx={pcX} cy={pcY} r={3.5} fill="var(--charcoal)" />
      <Label x={pcX} y={pcY - 14}
        fontSize={9} color="var(--charcoal)" bold>PC</Label>

      <circle cx={ptX} cy={ptY} r={3.5} fill="var(--charcoal)" />
      <Label x={ptX + 14} y={ptY - 6}
        fontSize={9} color="var(--charcoal)" bold>PT</Label>

      <circle cx={piX} cy={piY} r={3.5} fill="var(--charcoal)" />
      <Label x={piX + 4} y={piY - 14}
        fontSize={9} color="var(--charcoal)" bold>PI</Label>
    </svg>
  );
}

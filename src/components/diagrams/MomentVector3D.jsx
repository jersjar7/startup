import React from 'react';
import { ArrowMarkerDefs, ForceArrow, Label } from './primitives';

/**
 * Isometric 3D axes with position vector r and force vector F.
 * Shows: x, y, z axes, origin O, r vector to point P in xy-plane, F vector pointing down (-z) at P.
 * Does NOT show: the moment result.
 */
export function MomentVector3D({ rx = 3, ry = 4, fz = -50 }) {
  const W = 360;
  const H = 270;

  // Isometric origin — centered to accommodate P below-left and z-axis above
  const ox = 180;
  const oy = 120;

  // Isometric basis vectors (30-degree projection)
  const cos30 = Math.cos(Math.PI / 6);
  const sin30 = 0.5;
  const scale = 16;

  const xDir = { x: cos30 * scale, y: sin30 * scale };    // x: right-down
  const yDir = { x: -cos30 * scale, y: sin30 * scale };   // y: left-down
  const zDir = { x: 0, y: -scale };                         // z: up

  // Axis length (in units)
  const axLen = 5;

  // Axis endpoints
  const xEnd = { x: ox + xDir.x * axLen, y: oy + xDir.y * axLen };
  const yEnd = { x: ox + yDir.x * axLen, y: oy + yDir.y * axLen };
  const zEnd = { x: ox + zDir.x * axLen, y: oy + zDir.y * axLen };

  // Point P = rx along x + ry along y (isometric projection)
  const px = ox + xDir.x * rx + yDir.x * ry;
  const py = oy + xDir.y * rx + yDir.y * ry;

  // Force vector F at P: -z means down in SVG (+y)
  const fArrowLen = Math.min(56, Math.abs(fz) * 1.1);
  const fTipX = px;
  const fTipY = py + fArrowLen;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`3D moment diagram: r = (${rx}, ${ry}, 0), F = ${fz}k N`}
      style={{ width: '100%', height: 'auto' }}>

      <ArrowMarkerDefs id="arrowM3D" />
      <ArrowMarkerDefs id="arrowAxis3D" color="var(--gray-400)" />
      <ArrowMarkerDefs id="arrowForce3D" color="var(--ember)" />

      {/* Axes */}
      <ForceArrow x1={ox} y1={oy} x2={xEnd.x} y2={xEnd.y}
        color="var(--gray-400)" strokeWidth={1.5} markerId="arrowAxis3D" />
      <ForceArrow x1={ox} y1={oy} x2={yEnd.x} y2={yEnd.y}
        color="var(--gray-400)" strokeWidth={1.5} markerId="arrowAxis3D" />
      <ForceArrow x1={ox} y1={oy} x2={zEnd.x} y2={zEnd.y}
        color="var(--gray-400)" strokeWidth={1.5} markerId="arrowAxis3D" />

      {/* Axis labels */}
      <Label x={xEnd.x + 10} y={xEnd.y + 4} fontSize={12} color="var(--gray-500)" italic anchor="start">
        x
      </Label>
      <Label x={yEnd.x - 10} y={yEnd.y + 4} fontSize={12} color="var(--gray-500)" italic anchor="end">
        y
      </Label>
      <Label x={zEnd.x} y={zEnd.y - 10} fontSize={12} color="var(--gray-500)" italic>
        z
      </Label>

      {/* Origin label */}
      <Label x={ox - 14} y={oy + 6} fontSize={12} color="var(--charcoal)" bold anchor="end">
        O
      </Label>

      {/* Dashed projection lines in xy-plane (O → along x → P) */}
      <line x1={ox} y1={oy} x2={ox + xDir.x * rx} y2={oy + xDir.y * rx}
        stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />
      <line x1={ox + xDir.x * rx} y1={oy + xDir.y * rx} x2={px} y2={py}
        stroke="var(--gray-300)" strokeWidth={1} strokeDasharray="3,3" />

      {/* Position vector r (origin to P) */}
      <ForceArrow x1={ox} y1={oy} x2={px} y2={py}
        color="var(--charcoal)" strokeWidth={2.5} markerId="arrowM3D" />

      {/* r label */}
      <Label x={(ox + px) / 2 + 8} y={(oy + py) / 2 - 8} fontSize={12}
        color="var(--charcoal)" bold italic>
        r
      </Label>

      {/* Force vector F at P (pointing down = -z) */}
      <ForceArrow x1={px} y1={py} x2={fTipX} y2={fTipY}
        color="var(--ember)" strokeWidth={2.5} markerId="arrowForce3D" />

      {/* Force label */}
      <Label x={fTipX + 12} y={(py + fTipY) / 2} fontSize={11}
        color="var(--ember)" bold anchor="start">
        F = {fz}k N
      </Label>

      {/* Point P marker */}
      <circle cx={px} cy={py} r={3.5} fill="var(--charcoal)" />
      <Label x={px + 10} y={py - 10} fontSize={12} color="var(--charcoal)" bold anchor="start">
        P
      </Label>

      {/* Origin dot */}
      <circle cx={ox} cy={oy} r={3} fill="var(--charcoal)" />
    </svg>
  );
}

import React from 'react';
import { DimensionLine, DashedLine, Label } from './primitives';

/**
 * Steel tension member — plan view of flat plate with bolt holes.
 *
 * Shows: plate rectangle, bolt holes (open circles) at one cross-section,
 *        plate width, bolt diameter note, net section dashed line.
 *
 * Does NOT show: net area value, Pn, or which limit state controls (student solves).
 */
export function TensionPlateNet({
  width = 10,
  thickness = 0.5,
  numBolts = 2,
  boltDia = 0.875,
  unit = 'in.',
}) {
  const W = 400;

  // Bolt holes
  const holePx = 10;
  const edgePad = 20; // min edge distance from plate top/bottom to bolt center
  const minSpacing = holePx * 2 + 8; // min center-to-center between bolts

  // Plate geometry — height scales with bolt count to prevent overlap
  const plateW = 240;
  const plateH = Math.max(80, 2 * edgePad + (numBolts - 1) * minSpacing);
  const plateLeft = (W - plateW) / 2;
  const plateRight = plateLeft + plateW;
  const plateTop = 50;
  const plateBot = plateTop + plateH;
  const plateCY = plateTop + plateH / 2;
  const HH = plateBot + 70;

  // Bolt positions (distributed vertically across the plate width)
  const boltCX = plateLeft + plateW / 2; // all at same cross-section
  const boltPositions = [];
  if (numBolts === 1) {
    boltPositions.push({ x: boltCX, y: plateCY });
  } else {
    const topEdge = plateTop + edgePad;
    const spacing = (plateH - 2 * edgePad) / (numBolts - 1);
    for (let i = 0; i < numBolts; i++) {
      boltPositions.push({ x: boltCX, y: topEdge + i * spacing });
    }
  }

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Tension plate, ${width} ${unit} wide, ${thickness} ${unit} thick, ${numBolts} bolts at ${boltDia} ${unit} dia.`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Plate */}
      <rect x={plateLeft} y={plateTop} width={plateW} height={plateH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} rx={2} />

      {/* Bolt holes (open circles) */}
      {boltPositions.map((pos, i) => (
        <circle key={i} cx={pos.x} cy={pos.y} r={holePx}
          fill="white" stroke="var(--charcoal)" strokeWidth={1.5} />
      ))}

      {/* Net section line (dashed through bolt centers) */}
      <DashedLine x1={boltCX} y1={plateTop - 6} x2={boltCX} y2={plateBot + 6}
        color="var(--ember)" strokeWidth={1.5} dasharray="5,3" />

      {/* Net section label */}
      <Label x={boltCX} y={plateTop - 14} fontSize={8} color="var(--ember)">
        Net section
      </Label>

      {/* Width dimension (left side) */}
      <DimensionLine x1={plateLeft - 16} y1={plateBot} x2={plateLeft - 16} y2={plateTop}
        label={`${width} ${unit}`} offset={-28} fontSize={9} />

      {/* Thickness note */}
      <Label x={W / 2} y={plateBot + 28} fontSize={8} color="var(--gray-500)">
        t = {thickness} {unit}
      </Label>

      {/* Bolt diameter note */}
      <Label x={W / 2} y={plateBot + 44} fontSize={8} color="var(--gray-500)">
        {numBolts} bolts, d = {boltDia} {unit} dia.
      </Label>
    </svg>
  );
}

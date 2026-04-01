import React from 'react';
import { K } from './geo';
import {
  ArrowMarkerDefs, DashedLine, RightAngleMarker, Label,
} from './primitives';

export function CableGeometry({ horiz = 5, vert = 12, force = 1300 }) {
  const scale = 14;

  const wallX = 80;
  const wallY = 210;
  const anchorX = wallX + horiz * scale;
  const anchorY = wallY - vert * scale;

  return (
    <svg viewBox="0 0 360 260" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Cable: ${horiz} m horizontal, ${vert} m vertical, ${force} N`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowMain" />

      {/* Wall */}
      <line x1={wallX} y1={anchorY - 20} x2={wallX} y2={wallY + 20}
        stroke="var(--charcoal)" strokeWidth={3} />
      {Array.from({ length: 6 }, (_, i) => {
        const hy = anchorY - 10 + i * ((wallY - anchorY + 20) / 5);
        return (
          <line key={i}
            x1={wallX} y1={hy}
            x2={wallX - 10} y2={hy + 6}
            stroke="var(--charcoal)" strokeWidth={1.5} />
        );
      })}

      {/* Cable (wall attachment → anchor) */}
      <line x1={wallX} y1={wallY} x2={anchorX} y2={anchorY}
        stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Force label above anchor (top end of cable) */}
      <Label x={anchorX + 10} y={anchorY - 12} color="var(--charcoal)" bold fontSize={11} anchor="start">
        {force} N
      </Label>

      {/* Horizontal leg (dashed) */}
      <DashedLine x1={wallX} y1={wallY} x2={anchorX} y2={wallY} />
      <Label x={(wallX + anchorX) / 2} y={wallY + 18}>
        {horiz} m
      </Label>

      {/* Vertical leg (dashed) */}
      <DashedLine x1={anchorX} y1={wallY} x2={anchorX} y2={anchorY} />
      <Label x={anchorX + 18} y={(wallY + anchorY) / 2}>
        {vert} m
      </Label>

      {/* Right angle at corner */}
      <RightAngleMarker x={anchorX} y={wallY} size={K.MARKER_SIZE} rotation={-90} />

      {/* Joint dots */}
      <circle cx={wallX} cy={wallY} r={3} fill="var(--charcoal)" />
      <circle cx={anchorX} cy={anchorY} r={3} fill="var(--charcoal)" />
    </svg>
  );
}

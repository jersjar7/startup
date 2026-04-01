import React from 'react';
import { engY } from './geo';
import {
  DimensionLine, CentroidMarker, AxisLine, Label,
} from './primitives';

export function TSection({
  flangeW = 120, flangeH = 20,
  webW = 20, webH = 80,
  showCentroid = true, centroidY = 70,
  showAxis = false,
}) {
  const scale = 1.6;
  const ox = 80;   // left edge of flange
  const oy = 30;   // top of flange in SVG

  const fW = flangeW * scale;
  const fH = flangeH * scale;
  const wW = webW * scale;
  const wH = webH * scale;
  const totalH = fH + wH;   // total SVG height of the section

  const centerX = ox + fW / 2;
  const webLeft = centerX - wW / 2;

  // SVG bottom of the section
  const svgBottom = oy + totalH;

  // Centroid position (measured from bottom, converted to SVG y)
  const centSvgY = engY(oy, totalH, centroidY * scale);

  return (
    <svg viewBox="0 0 360 260" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`T-section: flange ${flangeW}x${flangeH}, web ${webW}x${webH}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Flange (top rectangle) */}
      <rect x={ox} y={oy} width={fW} height={fH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Web (bottom rectangle) */}
      <rect x={webLeft} y={oy + fH} width={wW} height={wH}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2.5} />

      {/* Dimensions — flange width (above) */}
      <DimensionLine x1={ox} y1={oy - 10} x2={ox + fW} y2={oy - 10}
        label={`${flangeW}`} offset={-10} />

      {/* Dimensions — flange height (right side) */}
      <DimensionLine x1={ox + fW + 14} y1={oy + fH} x2={ox + fW + 14} y2={oy}
        label={`${flangeH}`} offset={16} />

      {/* Dimensions — web width (below) */}
      <DimensionLine x1={webLeft} y1={svgBottom + 14} x2={webLeft + wW} y2={svgBottom + 14}
        label={`${webW}`} offset={12} />

      {/* Dimensions — web height (right side) */}
      <DimensionLine x1={ox + fW + 14} y1={svgBottom} x2={ox + fW + 14} y2={oy + fH}
        label={`${webH}`} offset={16} />

      {/* Centroid marker and label */}
      {showCentroid && (
        <>
          <CentroidMarker cx={centerX} cy={centSvgY} />
          <Label x={centerX + 16} y={centSvgY} color="var(--ember)" italic fontSize={11} anchor="start">
            ȳ = {centroidY} mm
          </Label>

          {/* Reference bracket from bottom to centroid */}
          <line x1={ox - 16} y1={svgBottom} x2={ox - 16} y2={centSvgY}
            stroke="var(--ember)" strokeWidth={1} strokeDasharray="3,3" />
          <line x1={ox - 20} y1={svgBottom} x2={ox - 12} y2={svgBottom}
            stroke="var(--ember)" strokeWidth={1} />
          <line x1={ox - 20} y1={centSvgY} x2={ox - 12} y2={centSvgY}
            stroke="var(--ember)" strokeWidth={1} />
        </>
      )}

      {/* Centroidal axis line */}
      {showAxis && (
        <AxisLine x1={ox - 20} y1={centSvgY} x2={ox + fW + 40} y2={centSvgY}
          label="x" />
      )}
    </svg>
  );
}

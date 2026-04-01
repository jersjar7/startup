import React from 'react';
import { ArrowMarkerDefs, ForceArrow, RectShape, DimensionLine, DashedLine, Label } from './primitives';

export function IBeamSection({ depth = 300, flangeW = 150, flangeT = 20, webT = 10 }) {
  /* Scale: 1 mm engineering = scale px SVG */
  const scale = depth > 250 ? 0.7 : 0.85;
  const sD = depth * scale;
  const sFW = flangeW * scale;
  const sFT = flangeT * scale;
  const sWT = webT * scale;

  /* Anchor: top-left of the bounding box */
  const ox = 90;
  const oy = 30;

  /* Key y-coordinates (SVG) */
  const topFlangeTop = oy;
  const topFlangeBot = oy + sFT;
  const botFlangeTop = oy + sD - sFT;
  const botFlangeBot = oy + sD;
  const naY = oy + sD / 2;

  /* Key x-coordinates */
  const cx = ox + sFW / 2;
  const webLeft = cx - sWT / 2;
  const webRight = cx + sWT / 2;

  /* Dimension line positions */
  const dimRight = ox + sFW + 44;
  const dimBottom = botFlangeBot + 20;

  /* Web thickness label: use a leader arrow since the web is too narrow for a DimensionLine */
  const webLabelX = webRight + 40;
  const webLabelY = naY + 20;

  return (
    <svg viewBox={`0 0 400 ${Math.round(sD + 100)}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`I-beam cross-section: ${depth} mm deep, ${flangeW} mm flange, ${flangeT} mm flange thickness, ${webT} mm web`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="arrowGray" color="var(--gray-500)" size={6} />

      {/* Top flange */}
      <RectShape x={ox} y={topFlangeTop} width={sFW} height={sFT}
        fill="var(--cream-dark)" />

      {/* Web */}
      <RectShape x={webLeft} y={topFlangeBot} width={sWT} height={sD - 2 * sFT}
        fill="var(--cream-dark)" />

      {/* Bottom flange */}
      <RectShape x={ox} y={botFlangeTop} width={sFW} height={sFT}
        fill="var(--cream-dark)" />

      {/* Neutral axis (dashed) — stop before depth dimension */}
      <DashedLine x1={ox - 15} y1={naY} x2={ox + sFW + 15} y2={naY}
        color="var(--gray-400)" dasharray="5,3" />
      <Label x={ox + sFW + 20} y={naY} anchor="start" fontSize={10} italic
        color="var(--gray-400)">
        NA
      </Label>

      {/* Junction marker — dashed horizontal at flange-web interface */}
      <DashedLine x1={webLeft - 8} y1={topFlangeBot} x2={webRight + 8} y2={topFlangeBot}
        color="var(--ember)" strokeWidth={1} dasharray="3,2" />
      <circle cx={cx} cy={topFlangeBot} r={2.5} fill="var(--ember)" />
      <Label x={webRight + 14} y={topFlangeBot + 10} anchor="start" fontSize={10} italic
        color="var(--ember)">
        junction
      </Label>

      {/* Flange width dimension (bottom) */}
      <DimensionLine x1={ox} y1={dimBottom} x2={ox + sFW} y2={dimBottom}
        label={`${flangeW}`} offset={12} />

      {/* Total depth dimension (right, bottom-to-top so label goes right) */}
      <DimensionLine x1={dimRight} y1={botFlangeBot} x2={dimRight} y2={topFlangeTop}
        label={`${depth}`} offset={18} />

      {/* Flange thickness dimension (left side, top flange) */}
      <DimensionLine x1={ox - 16} y1={topFlangeBot} x2={ox - 16} y2={topFlangeTop}
        label={`${flangeT}`} offset={-18} />

      {/* Web thickness — leader arrow pointing to web edge + label */}
      <ForceArrow x1={webLabelX} y1={webLabelY} x2={webRight + 2} y2={webLabelY}
        color="var(--gray-500)" strokeWidth={1} markerId="arrowGray" />
      <Label x={webLabelX + 4} y={webLabelY} anchor="start" fontSize={11}
        color="var(--gray-500)">
        {webT}
      </Label>

      {/* Units note */}
      <Label x={ox + sFW / 2} y={dimBottom + 28} fontSize={9} color="var(--gray-400)">
        (mm)
      </Label>
    </svg>
  );
}

import React from 'react';
import { ArrowMarkerDefs } from '../../primitives';
import { arcPath, polar } from '../../geo';
import { SubText, SurfaceHatch } from './ctGeoAParts';

/**
 * Cut slope with an assumed planar slip surface from the toe, drawn to scale:
 * slip length L at angle alpha, the sliding wedge and its weight W.
 * Shows givens only, never the factor of safety.
 */
export function CtGeotechnicalAPlanarSlope({
  L = 40, alpha = 35, face = 60, unit = 'ft', weight = 'W = 18,000 lb/ft', soil = ['c = 150 psf', 'φ = 26°'],
}) {
  const a = (alpha * Math.PI) / 180;
  const f = (face * Math.PI) / 180;
  const Hs = L * Math.sin(a);
  const runSlip = L * Math.cos(a);
  const runFace = Hs / Math.tan(f);
  const s = Math.min(9, 300 / (runSlip + 16));
  const toeX = 22 + 7 * s;
  const toeY = 24 + Hs * s;
  const P = (x, y) => ({ x: toeX + x * s, y: toeY - y * s });
  const crest = P(runFace, Hs);
  const exit = P(runSlip, Hs);
  const rightX = Math.min(P(runSlip + 12, 0).x, 430);
  const botY = toeY + 34;
  const W = rightX + 14;
  const H = botY + 8;
  const cg = { x: (toeX + crest.x + exit.x) / 3, y: (toeY + crest.y + exit.y) / 3 };
  // Slip length label just below the slip line, at 62% of its length
  const nx = Math.sin(a);
  const ny = Math.cos(a);
  const lp = { x: toeX + (exit.x - toeX) * 0.62 + nx * 16, y: toeY + (exit.y - toeY) * 0.62 + ny * 16 };
  // Weight label in the open air left of the slope face, level with the centroid,
  // so it never sits on the face or the slip line of a thin wedge.
  const wy = cg.y;
  const hy = (toeY - wy) / s; // height above toe, ft
  const faceX = toeX + (hy / Math.tan(f)) * s;
  const wx = faceX - 12;
  const arcPt = polar(toeX, toeY, 54, alpha / 2);

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Slope with planar slip surface ${L} ${unit} long at ${alpha} degrees`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctGeoASlopeArrow" color="var(--ember)" size={8} />
      {/* Soil body */}
      <polygon points={`12,${toeY} ${toeX},${toeY} ${crest.x},${crest.y} ${rightX},${crest.y} ${rightX},${botY} 12,${botY}`}
        fill="var(--gray-400)" fillOpacity={0.12} />
      {/* Sliding wedge */}
      <polygon points={`${toeX},${toeY} ${crest.x},${crest.y} ${exit.x},${exit.y}`}
        fill="var(--gray-400)" fillOpacity={0.22} />
      <polyline points={`12,${toeY} ${toeX},${toeY} ${crest.x},${crest.y} ${rightX},${crest.y}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <SurfaceHatch x1={12} x2={toeX - 2} y={toeY} step={14} len={6} />
      <SurfaceHatch x1={crest.x + 4} x2={rightX} y={crest.y} step={18} len={6} />

      {/* Slip surface */}
      <line x1={toeX} y1={toeY} x2={exit.x} y2={exit.y} stroke="var(--charcoal)" strokeWidth={2} strokeDasharray="9,5" />

      {/* Angle at the toe */}
      <line x1={toeX} y1={toeY} x2={toeX + 78} y2={toeY} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <path d={arcPath(toeX, toeY, 44, 0, alpha)} fill="none" stroke="var(--gray-500)" strokeWidth={1.3} />
      <SubText x={arcPt.x + 4} y={arcPt.y} color="var(--gray-500)">{`α = ${alpha}°`}</SubText>

      {/* Slip length */}
      <SubText x={lp.x} y={lp.y} color="var(--gray-500)">{`L = ${L} ${unit}`}</SubText>

      {/* Weight of the wedge */}
      <circle cx={cg.x} cy={cg.y} r={2.5} fill="var(--ember)" />
      <line x1={cg.x} y1={cg.y} x2={cg.x} y2={Math.min(cg.y + 42, toeY - (cg.x - toeX) * Math.tan(a) - 7)} stroke="var(--ember)" strokeWidth={2} markerEnd="url(#ctGeoASlopeArrow)" />
      <SubText x={wx} y={wy} anchor="end" color="var(--ember)" bold>{weight}</SubText>

      {/* Strength along the slip surface */}
      {soil.map((t, i) => (
        <SubText key={i} x={rightX - 10} y={botY - 14 - (soil.length - 1 - i) * 16} anchor="end">{t}</SubText>
      ))}
    </svg>
  );
}

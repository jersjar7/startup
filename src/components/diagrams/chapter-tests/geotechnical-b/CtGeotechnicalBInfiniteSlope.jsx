import React from 'react';
import { SubText, WaterMark } from './ctGeoBParts';

/**
 * Long (infinite) slope at angle beta with a slip plane parallel to the
 * surface at vertical depth H, the water table at the ground surface and
 * seepage parallel to the slope. Angle and depth to scale. Shows givens only,
 * never a factor of safety.
 */
export function CtGeotechnicalBInfiniteSlope({
  beta = 20,
  H = 8,
  unit = 'ft',
  soil = [],
}) {
  const W = 440;
  const t = Math.tan((beta * Math.PI) / 180);
  const sc = 7;
  const x0 = 16;
  const x1 = 424;
  const y0 = 40;
  const surf = (x) => y0 + (x - x0) * t;
  const dv = H * sc;
  const plane = (x) => surf(x) + dv;
  const bot = (x) => plane(x) + 34;
  const HH = bot(x1) + 8;
  const sx = 250; // slice
  const sw = 34;
  const cb = Math.cos((beta * Math.PI) / 180);
  const sb = Math.sin((beta * Math.PI) / 180);
  // seepage arrows, parallel to the slope, at mid-depth
  const arrows = [120, 330].map((x) => ({ x, y: surf(x) + dv * 0.55 }));
  const aL = 46;
  const ax = 70; // angle reference point on the surface
  const ay = surf(ax);

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Infinite slope at ${beta} degrees, slip plane parallel to the surface at a vertical depth of ${H} ${unit}, seepage parallel to the slope with the water table at the surface`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctGeoBSlopeArrow" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--info)" />
        </marker>
      </defs>
      {/* Sliding layer (saturated) and firm material below */}
      <polygon points={`${x0},${surf(x0)} ${x1},${surf(x1)} ${x1},${plane(x1)} ${x0},${plane(x0)}`}
        fill="var(--info)" fillOpacity={0.09} />
      <polygon points={`${x0},${plane(x0)} ${x1},${plane(x1)} ${x1},${bot(x1)} ${x0},${bot(x0)}`}
        fill="var(--gray-400)" fillOpacity={0.28} />

      {/* Ground surface = water table */}
      <line x1={x0} y1={surf(x0)} x2={x1} y2={surf(x1)} stroke="var(--charcoal)" strokeWidth={2} />
      <WaterMark x={380} y={surf(380) - 2} />
      <SubText x={392} y={surf(392) - 16} color="var(--info)">WT</SubText>

      {/* Slip plane */}
      <line x1={x0} y1={plane(x0)} x2={x1} y2={plane(x1)} stroke="var(--charcoal)" strokeWidth={1.6} strokeDasharray="8,4" />
      <g transform={`rotate(${beta} 320 ${plane(320) + 12})`}>
        <text x={320} y={plane(320) + 12} fill="var(--charcoal)" fontFamily="var(--font-body)" fontSize={11}
          textAnchor="middle" dominantBaseline="middle">Slip plane, parallel to surface</text>
      </g>

      {/* Seepage arrows */}
      {arrows.map((a, i) => (
        <line key={i} x1={a.x - (aL / 2) * cb} y1={a.y - (aL / 2) * sb} x2={a.x + (aL / 2) * cb} y2={a.y + (aL / 2) * sb}
          stroke="var(--info)" strokeWidth={1.6} markerEnd="url(#ctGeoBSlopeArrow)" />
      ))}
      <g transform={`rotate(${beta} 120 ${arrows[0].y - 12})`}>
        <text x={120} y={arrows[0].y - 12} fill="var(--info)" fontFamily="var(--font-body)" fontSize={11}
          textAnchor="middle" dominantBaseline="middle">Seepage</text>
      </g>

      {/* Slice with vertical depth H */}
      <line x1={sx} y1={surf(sx)} x2={sx} y2={plane(sx)} stroke="var(--charcoal)" strokeWidth={1.2} />
      <line x1={sx + sw} y1={surf(sx + sw)} x2={sx + sw} y2={plane(sx + sw)} stroke="var(--charcoal)" strokeWidth={1.2} />
      <line x1={sx - 14} y1={surf(sx)} x2={sx - 14} y2={plane(sx)} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={sx - 19} y1={surf(sx)} x2={sx - 9} y2={surf(sx)} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={sx - 19} y1={plane(sx)} x2={sx - 9} y2={plane(sx)} stroke="var(--gray-500)" strokeWidth={1} />
      <SubText x={sx - 22} y={(surf(sx) + plane(sx)) / 2 - 16} color="var(--gray-500)" anchor="end">{`H = ${H} ${unit}`}</SubText>

      {/* Slope angle */}
      <line x1={ax} y1={ay} x2={ax + 70} y2={ay} stroke="var(--gray-500)" strokeWidth={1} strokeDasharray="4,3" />
      <path d={`M ${ax + 52} ${ay} A 52 52 0 0 1 ${ax + 52 * cb} ${ay + 52 * sb}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.3} />
      <SubText x={ax + 76} y={ay - 9}>{`β = ${beta}°`}</SubText>

      {/* Soil properties, above the surface on the upslope side */}
      {soil.map((s, i) => (
        <SubText key={i} x={190} y={16 + i * 16}>{s}</SubText>
      ))}
    </svg>
  );
}

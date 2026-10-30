import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * A wedge driven to the right under a machine base. The base bears on a
 * smooth vertical guide at its right face and can only move up.
 * Shows: wedge angle, P, the base weight, friction coefficient, smooth guide.
 * Does NOT show: P's value or any reaction.
 */
export function CtStaticsBWedge({ angle = 10, weight = 20, mu = 0.25 }) {
  const fy = 200;
  const x0 = 60;
  const xt = 290;
  const t = Math.tan((angle * Math.PI) / 180);
  const H = (xt - x0) * t;
  const slopeY = (x) => fy - H * (xt - x) / (xt - x0);
  const bl = 176;
  const br = 252;
  const btop = 104;
  const gray = 'var(--gray-500)';
  const arcR = 66;
  const a1 = { x: x0 + arcR * Math.cos((angle * Math.PI) / 180), y: fy - H + arcR * Math.sin((angle * Math.PI) / 180) };

  return (
    <svg viewBox="0 0 352 212" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`A ${angle} degree wedge pushed by P under a ${weight} kN base held by a smooth guide, friction ${mu} on both wedge faces`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBWedgeArrow" color="var(--ember)" size={9} />
      <g transform="translate(0,-36)">

      {/* Floor */}
      <line x1={14} y1={fy} x2={338} y2={fy} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 21 }, (_, i) => (
        <line key={i} x1={20 + i * 15} y1={fy} x2={12 + i * 15} y2={fy + 8} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}

      {/* Smooth guide */}
      <line x1={br} y1={46} x2={br} y2={slopeY(br) - 20} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 9 }, (_, i) => (
        <line key={i} x1={br} y1={50 + i * 15} x2={br + 8} y2={42 + i * 15} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}
      <Label x={br + 16} y={64} color="var(--charcoal)" anchor="start">smooth</Label>
      <Label x={br + 16} y={79} color="var(--charcoal)" anchor="start">guide</Label>

      {/* Wedge */}
      <polygon points={`${x0},${fy} ${xt},${fy} ${x0},${fy - H}`} fill="var(--gray-200)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <Label x={x0 + 36} y={fy - 10} color="var(--charcoal)">wedge</Label>

      {/* Base */}
      <polygon points={`${bl},${btop} ${br},${btop} ${br},${slopeY(br)} ${bl},${slopeY(bl)}`} fill="var(--gray-100)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <Label x={(bl + br) / 2} y={(btop + slopeY(bl)) / 2 + 4} color="var(--charcoal)">base</Label>

      {/* Weight */}
      <line x1={(bl + br) / 2} y1={btop - 50} x2={(bl + br) / 2} y2={btop - 3} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBWedgeArrow)" />
      <Label x={(bl + br) / 2 - 8} y={btop - 40} color="var(--ember)" bold anchor="end">{`${weight} kN`}</Label>

      {/* P */}
      <line x1={10} y1={fy - H / 2} x2={x0 - 3} y2={fy - H / 2} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBWedgeArrow)" />
      <Label x={24} y={fy - H / 2 - 12} color="var(--ember)" bold italic>P</Label>

      {/* Wedge angle at the thick end */}
      <line x1={x0} y1={fy - H} x2={x0 + 92} y2={fy - H} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <path d={`M ${x0 + arcR},${fy - H} A ${arcR},${arcR} 0 0 1 ${a1.x},${a1.y}`} fill="none" stroke={gray} strokeWidth={1.2} />
      <Label x={x0 + arcR + 14} y={fy - H - 10} color="var(--charcoal)">{`${angle}°`}</Label>

      <Label x={14} y={fy + 26} anchor="start">{`μs = ${mu} on both wedge faces (top and floor)`}</Label>
      </g>
    </svg>
  );
}

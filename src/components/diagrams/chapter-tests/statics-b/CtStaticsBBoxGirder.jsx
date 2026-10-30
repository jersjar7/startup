import React from 'react';
import { Label } from '../../primitives';

/**
 * Hollow rectangular box girder section: outside b x h, flanges tf thick,
 * webs tw thick, horizontal centroidal axis drawn.
 * Shows: every dimension needed.
 * Does NOT show: I.
 */
export function CtStaticsBBoxGirder({ b = 400, h = 600, tf = 25, tw = 15, unit = 'mm' }) {
  const S = 0.36;
  const ox = 70;
  const oy = 40;
  const W = b * S;
  const H = h * S;
  const TF = tf * S;
  const TW = tw * S;
  const gray = 'var(--gray-500)';
  const cy = oy + H / 2;
  const d = `M ${ox},${oy} h ${W} v ${H} h ${-W} Z M ${ox + TW},${oy + TF} v ${H - 2 * TF} h ${W - 2 * TW} v ${-(H - 2 * TF)} Z`;
  const rx = ox + W;

  return (
    <svg viewBox={`0 0 ${rx + 150} ${oy + H + 16}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Box girder ${b} by ${h} ${unit}, flanges ${tf} ${unit}, webs ${tw} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>
      <path d={d} fill="var(--gray-200)" fillRule="evenodd" stroke="var(--charcoal)" strokeWidth={1.6} strokeLinejoin="round" />

      {/* Centroidal axis */}
      <line x1={ox - 16} y1={cy} x2={rx + 18} y2={cy} stroke="var(--ember)" strokeWidth={1.2} strokeDasharray="7,4" />
      <Label x={rx + 24} y={cy} color="var(--ember)" italic anchor="start">x (centroidal)</Label>

      {/* b dimension (top) */}
      <line x1={ox} y1={oy - 18} x2={rx} y2={oy - 18} stroke={gray} strokeWidth={1} />
      <line x1={ox} y1={oy - 23} x2={ox} y2={oy - 4} stroke={gray} strokeWidth={1} />
      <line x1={rx} y1={oy - 23} x2={rx} y2={oy - 4} stroke={gray} strokeWidth={1} />
      <Label x={ox + W / 2} y={oy - 28}>{`${b} ${unit}`}</Label>

      {/* h dimension (left) */}
      <line x1={ox - 26} y1={oy} x2={ox - 26} y2={oy + H} stroke={gray} strokeWidth={1} />
      <line x1={ox - 31} y1={oy} x2={ox - 5} y2={oy} stroke={gray} strokeWidth={1} />
      <line x1={ox - 31} y1={oy + H} x2={ox - 5} y2={oy + H} stroke={gray} strokeWidth={1} />
      <Label x={ox - 38} y={oy + H / 2} rotate={-90}>{`${h} ${unit}`}</Label>

      {/* Flange thickness: leader to the top flange */}
      <line x1={rx - 30} y1={oy + TF / 2} x2={rx + 22} y2={oy + 22} stroke={gray} strokeWidth={1} />
      <circle cx={rx - 30} cy={oy + TF / 2} r={1.8} fill={gray} />
      <Label x={rx + 26} y={oy + 22} anchor="start">{`flanges ${tf} ${unit}`}</Label>

      {/* Web thickness: leader to the right web */}
      <line x1={rx - TW / 2} y1={oy + H * 0.78} x2={rx + 22} y2={oy + H * 0.78} stroke={gray} strokeWidth={1} />
      <circle cx={rx - TW / 2} cy={oy + H * 0.78} r={1.8} fill={gray} />
      <Label x={rx + 26} y={oy + H * 0.78} anchor="start">{`webs ${tw} ${unit}`}</Label>

    </svg>
  );
}

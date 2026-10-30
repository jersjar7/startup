import React from 'react';
import { Label } from '../../primitives';
import { makeProjector } from './iso';

/**
 * Open-top tank with a square base, in oblique view.
 * Shows: the base sides x and x, the depth h, the open top.
 * Does NOT show: the optimum dimensions (drawn with generic proportions).
 */
export function CtMathematicsBTank({ volume = '500 m³' }) {
  // Generic proportions on purpose: the drawing must not hint at the optimum.
  const X = 7;
  const Hh = 5;
  const P = makeProjector(150, 196, 22, 0.6);
  // Corners: x toward the viewer, y to the right, z up.
  const b = [[0, 0, 0], [X, 0, 0], [X, X, 0], [0, X, 0]].map(P);
  const t = [[0, 0, Hh], [X, 0, Hh], [X, X, Hh], [0, X, Hh]].map(P);
  const pts = (arr) => arr.map((p) => `${p.x},${p.y}`).join(' ');
  const xs = [...b, ...t].map((p) => p.x);
  const ys = [...b, ...t].map((p) => p.y);
  const minX = Math.min(...xs);
  const maxX = Math.max(...xs);
  const minY = Math.min(...ys);
  const maxY = Math.max(...ys);
  const shiftX = 44 - minX;
  const shiftY = 40 - minY;
  const W = Math.round(maxX - minX + 44 + 50);
  const H = Math.round(maxY - minY + 40 + 34);
  const S = (p) => ({ x: p.x + shiftX, y: p.y + shiftY });
  const B = b.map(S);
  const T = t.map(S);
  // Where the front top edge T1-T2 crosses the back vertical corner B0-T0:
  // above it the inside corner is seen through the open top, below it is hidden.
  const u = (T[0].x - T[1].x) / (T[2].x - T[1].x);
  const C = { x: T[0].x, y: T[1].y + u * (T[2].y - T[1].y) };

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Open-top tank with a square base x by x and depth h, volume ${volume}`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Hidden back corner */}
      <line x1={B[0].x} y1={B[0].y} x2={B[1].x} y2={B[1].y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="4,3" />
      <line x1={B[0].x} y1={B[0].y} x2={B[3].x} y2={B[3].y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="4,3" />
      <line x1={B[0].x} y1={B[0].y} x2={C.x} y2={C.y} stroke="var(--gray-400)" strokeWidth={1.2} strokeDasharray="4,3" />

      {/* Inside of the two back walls, seen through the open top */}
      <polygon points={pts([T[0], T[1], C])} fill="var(--gray-400)" fillOpacity={0.1} />
      <polygon points={pts([T[0], C, T[2], T[3]])} fill="var(--gray-400)" fillOpacity={0.18} />
      <line x1={T[0].x} y1={T[0].y} x2={C.x} y2={C.y} stroke="var(--charcoal)" strokeWidth={1.6} />

      {/* Two front walls */}
      <polygon points={pts([B[1], B[2], T[2], T[1]])} fill="var(--gray-400)" fillOpacity={0.12} stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <polygon points={pts([B[2], B[3], T[3], T[2]])} fill="var(--gray-400)" fillOpacity={0.22} stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      {/* Open top rim */}
      <polygon points={pts(T)} fill="none" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <Label x={(T[0].x + T[2].x) / 2} y={(T[0].y + T[2].y) / 2} color="var(--gray-500)" fontSize={11} italic>open top</Label>

      {/* Dimensions as labels on the edges */}
      <Label x={(B[1].x + B[2].x) / 2} y={(B[1].y + B[2].y) / 2 + 14} color="var(--charcoal)" fontSize={13} italic bold>x</Label>
      <Label x={(B[2].x + B[3].x) / 2 + 12} y={(B[2].y + B[3].y) / 2 + 12} color="var(--charcoal)" fontSize={13} italic bold>x</Label>
      <Label x={B[3].x + 12} y={(T[3].y + B[3].y) / 2} anchor="start" color="var(--charcoal)" fontSize={13} italic bold>h</Label>
      <Label x={(T[0].x + T[3].x) / 2} y={Math.min(T[0].y, T[3].y) - 14} color="var(--ember)" fontSize={12} bold>{`V = ${volume}`}</Label>
    </svg>
  );
}

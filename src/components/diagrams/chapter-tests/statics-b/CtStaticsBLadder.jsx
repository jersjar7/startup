import React from 'react';
import { ArrowMarkerDefs, Label } from '../../primitives';

/**
 * Uniform ladder against a smooth wall, rough floor. Ladder weight at
 * mid-length, worker at an unknown distance s from the foot.
 * Shows: length, base distance, both weights, mu at the floor, s as a symbol.
 * Does NOT show: the slip distance.
 */
export function CtStaticsBLadder({ length = 20, base = 12, weight = 40, worker = 180, mu = 0.4 }) {
  const height = Math.sqrt(length * length - base * base);
  const S = 11;
  const fy = 236;
  const wx = 262;
  const A = { x: wx - base * S, y: fy };
  const B = { x: wx, y: fy - height * S };
  const Lp = length * S;
  const u = { x: (B.x - A.x) / Lp, y: (B.y - A.y) / Lp };
  const n = { x: u.y, y: -u.x }; // upper-left side normal
  const at = (f) => ({ x: A.x + u.x * Lp * f, y: A.y + u.y * Lp * f });
  const M = at(0.5);
  const K = at(0.28);
  const gray = 'var(--gray-500)';
  const off = (p, o) => ({ x: p.x + n.x * o, y: p.y + n.y * o });
  const lL = off(at(0.74), 16);
  const rails = [-3.5, 3.5];
  const sA = off(A, 16);
  const sK = off(K, 16);

  return (
    <svg viewBox="0 0 330 276" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Ladder ${length} ft long, foot ${base} ft from a smooth wall, weight ${weight} lb, worker ${worker} lb, floor friction ${mu}`}
      style={{ width: '100%', height: 'auto' }}>
      <ArrowMarkerDefs id="ctStBLadArrow" color="var(--ember)" size={9} />

      {/* Floor and wall */}
      <line x1={20} y1={fy} x2={wx + 14} y2={fy} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 17 }, (_, i) => (
        <line key={i} x1={26 + i * 15} y1={fy} x2={18 + i * 15} y2={fy + 8} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}
      <line x1={wx} y1={14} x2={wx} y2={fy} stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: 14 }, (_, i) => (
        <line key={i} x1={wx} y1={28 + i * 15} x2={wx + 8} y2={20 + i * 15} stroke="var(--charcoal)" strokeWidth={1.2} />
      ))}
      <Label x={wx + 14} y={24} color="var(--charcoal)" anchor="start">smooth</Label>
      <Label x={wx + 14} y={39} color="var(--charcoal)" anchor="start">wall</Label>

      {/* Ladder: two rails and rungs */}
      {rails.map((o) => {
        const p = off(A, o); const q = off(B, o);
        return <line key={o} x1={p.x} y1={p.y} x2={q.x} y2={q.y} stroke="var(--charcoal)" strokeWidth={2} />;
      })}
      {Array.from({ length: 13 }, (_, i) => {
        const c = at((i + 1) / 14);
        const p = off(c, -3.5); const q = off(c, 3.5);
        return <line key={i} x1={p.x} y1={p.y} x2={q.x} y2={q.y} stroke="var(--charcoal)" strokeWidth={1.2} />;
      })}

      {/* Weights */}
      <line x1={M.x} y1={M.y + 4} x2={M.x} y2={M.y + 38} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBLadArrow)" />
      <Label x={M.x + 8} y={M.y + 26} color="var(--ember)" bold anchor="start">{`${weight} lb`}</Label>
      <Label x={M.x + 8} y={M.y + 41} color="var(--charcoal)" anchor="start">ladder</Label>
      <line x1={K.x} y1={K.y + 4} x2={K.x} y2={K.y + 38} stroke="var(--ember)" strokeWidth={2.4} markerEnd="url(#ctStBLadArrow)" />
      <Label x={K.x + 8} y={K.y + 26} color="var(--ember)" bold anchor="start">{`${worker} lb`}</Label>
      <Label x={K.x + 8} y={K.y + 41} color="var(--charcoal)" anchor="start">worker</Label>

      {/* s along the ladder */}
      <line x1={sA.x} y1={sA.y} x2={sK.x} y2={sK.y} stroke={gray} strokeWidth={1} />
      {[sA, sK].map((p, i) => (
        <line key={i} x1={p.x + n.x * 5} y1={p.y + n.y * 5} x2={p.x - n.x * 5} y2={p.y - n.y * 5} stroke={gray} strokeWidth={1} />
      ))}
      <Label x={(sA.x + sK.x) / 2 + n.x * 12} y={(sA.y + sK.y) / 2 + n.y * 12} italic color="var(--charcoal)">s</Label>

      {/* Ladder length, written along the ladder near the top */}
      <Label x={lL.x} y={lL.y} rotate={(Math.atan2(u.y, u.x) * 180) / Math.PI} color="var(--charcoal)">{`ladder ${length} ft`}</Label>

      {/* Height dimension */}
      <line x1={wx + 30} y1={B.y} x2={wx + 30} y2={fy} stroke={gray} strokeWidth={1} />
      <line x1={wx + 4} y1={B.y} x2={wx + 35} y2={B.y} stroke={gray} strokeWidth={1} />
      <line x1={wx + 25} y1={fy} x2={wx + 35} y2={fy} stroke={gray} strokeWidth={1} />
      <Label x={wx + 39} y={(B.y + fy) / 2} anchor="start">{`${height} ft`}</Label>

      {/* Base dimension */}
      <line x1={A.x} y1={fy + 22} x2={wx} y2={fy + 22} stroke={gray} strokeWidth={1} />
      <line x1={A.x} y1={fy + 12} x2={A.x} y2={fy + 27} stroke={gray} strokeWidth={1} />
      <line x1={wx} y1={fy + 12} x2={wx} y2={fy + 27} stroke={gray} strokeWidth={1} />
      <Label x={(A.x + wx) / 2} y={fy + 33}>{`${base} ft`}</Label>
      <Label x={A.x - 14} y={fy + 22} color="var(--charcoal)" anchor="end">{`μs = ${mu.toFixed(2)}`}</Label>
    </svg>
  );
}

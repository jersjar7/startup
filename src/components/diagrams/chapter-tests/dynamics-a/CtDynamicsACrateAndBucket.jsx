import React from 'react';
import { Label } from '../../primitives';

/**
 * Crate on a rough level deck tied over an edge pulley to a hanging bucket.
 * Shows: both masses, the kinetic friction coefficient on the deck beside the crate.
 * Does NOT show: tension, acceleration or force arrows.
 */
export function CtDynamicsACrateAndBucket({ crateMass = 25, bucketMass = 15, mu = 0.2 }) {
  const deckY = 72;
  const deckX0 = 16;
  const edgeX = 282;
  const crate = { x: 70, w: 78, h: 54 };
  const pr = 13; // pulley radius
  const cordY = deckY - crate.h / 2; // cord leaves the crate at mid-height
  const pcx = edgeX + 22; // pulley centre
  const pcy = cordY + pr;
  const ropeX = pcx + pr;
  const bucketTop = pcy + 96;
  const bw = 44;
  const bh = 46;

  return (
    <svg viewBox={`0 0 ${ropeX + bw / 2 + 56} ${bucketTop + bh + 12}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${crateMass} kg crate on a level deck with kinetic friction ${mu}, tied over a pulley to a hanging ${bucketMass} kg bucket`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Deck with hatching below */}
      <line x1={deckX0} y1={deckY} x2={edgeX} y2={deckY} stroke="var(--charcoal)" strokeWidth={2.2} />
      <line x1={edgeX} y1={deckY} x2={edgeX} y2={deckY + 100} stroke="var(--charcoal)" strokeWidth={2.2} />
      {Array.from({ length: 16 }, (_, i) => (
        <line key={i} x1={deckX0 + 10 + i * 16} y1={deckY} x2={deckX0 + 2 + i * 16} y2={deckY + 9}
          stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Crate A */}
      <rect x={crate.x} y={deckY - crate.h} width={crate.w} height={crate.h} rx={3}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={crate.x + crate.w / 2} y={deckY - crate.h / 2 - 8} color="var(--charcoal)" fontSize={13} bold>A</Label>
      <Label x={crate.x + crate.w / 2} y={deckY - crate.h / 2 + 10} color="var(--charcoal)" fontSize={12}>{`${crateMass} kg`}</Label>
      <text x={crate.x + crate.w + 12} y={deckY - 8} fill="var(--gray-500)" fontFamily="var(--font-body)"
        fontSize={12} fontStyle="italic" textAnchor="start">
        {'μ'}<tspan fontSize={9} dy={3}>k</tspan><tspan dy={-3}>{` = ${mu.toFixed(2)}`}</tspan>
      </text>

      {/* Cord: crate to the top of the pulley, then down to the bucket */}
      <line x1={crate.x + crate.w} y1={cordY} x2={pcx} y2={cordY} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={ropeX} y1={pcy} x2={ropeX} y2={bucketTop - 3} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Pulley on a bracket fixed to the deck edge */}
      <polygon points={`${edgeX},${deckY - 1} ${edgeX},${deckY + 16} ${pcx},${pcy}`}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.8} strokeLinejoin="round" />
      <circle cx={pcx} cy={pcy} r={pr} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} />
      <circle cx={pcx} cy={pcy} r={2.5} fill="var(--charcoal)" />

      {/* Bucket B */}
      <path d={`M ${ropeX - bw / 2} ${bucketTop + 8} L ${ropeX + bw / 2} ${bucketTop + 8} L ${ropeX + bw / 2 - 6} ${bucketTop + bh} L ${ropeX - bw / 2 + 6} ${bucketTop + bh} Z`}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} strokeLinejoin="round" />
      <path d={`M ${ropeX - bw / 2} ${bucketTop + 8} Q ${ropeX} ${bucketTop - 14} ${ropeX + bw / 2} ${bucketTop + 8}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={1.5} />
      <Label x={ropeX + bw / 2 + 8} y={bucketTop + 20} color="var(--charcoal)" fontSize={13} bold anchor="start">B</Label>
      <Label x={ropeX + bw / 2 + 8} y={bucketTop + 36} color="var(--charcoal)" fontSize={12} anchor="start">{`${bucketMass} kg`}</Label>
    </svg>
  );
}

import React from 'react';
import { Label } from '../../primitives';

/**
 * Decision tree for a bid / no-bid decision.
 * Shows: the decision node (square), chance nodes (circles), outcome nodes
 * (triangles), the bid cost on the Bid branch, the probability of winning,
 * and the profit outcomes with their probabilities.
 * Does NOT show: the expected value (that is the answer).
 */
export function CtEconomicsABidDecisionTree({
  bidCost = 15000,
  pWin = 0.3,
  outcomes = [
    { p: 0.5, value: 200000 },
    { p: 0.3, value: 80000 },
    { p: 0.2, value: -60000 },
  ],
}) {
  const W = 470;
  const H = 228;
  const fmt = (v) => (v < 0 ? `−${Math.abs(v).toLocaleString('en-US')}` : v.toLocaleString('en-US'));
  const line = { stroke: 'var(--charcoal)', strokeWidth: 1.5, fill: 'none' };

  const D = { x: 24, y: 150 };
  const C1 = { x: 170, y: 104 };
  const C2 = { x: 300, y: 64 };
  const noBid = { x: 300, y: 206 };
  const lose = { x: 386, y: 146 };
  const ends = outcomes.map((_, k) => ({ x: 386, y: 22 + k * 42 }));

  const tri = (p) => `${p.x},${p.y} ${p.x + 10},${p.y - 6} ${p.x + 10},${p.y + 6}`;
  // Branch drawn as a short horizontal stub out of a node, then a straight run.
  const branch = (a, b) => `M ${a.x} ${a.y} L ${a.x + 14} ${b.y} L ${b.x} ${b.y}`;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label="Decision tree: bid or no bid, chance of winning, profit outcomes"
      style={{ width: '100%', height: 'auto' }}>

      {/* Decision node to its two branches */}
      <path d={branch({ x: D.x + 9, y: D.y }, { x: C1.x - 9, y: C1.y })} {...line} />
      <path d={branch({ x: D.x + 9, y: D.y }, noBid)} {...line} />
      <rect x={D.x - 9} y={D.y - 9} width={18} height={18} rx={2} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} />

      <Label x={(D.x + C1.x) / 2 + 12} y={C1.y - 12} fontSize={12} color="var(--charcoal)" bold>Bid</Label>
      <Label x={(D.x + C1.x) / 2 + 12} y={C1.y + 13} fontSize={11} color="var(--ember)">cost {fmt(bidCost)}</Label>
      <Label x={(D.x + noBid.x) / 2 + 12} y={noBid.y - 12} fontSize={12} color="var(--charcoal)" bold>No bid</Label>

      {/* Chance node 1: win or lose */}
      <path d={branch({ x: C1.x + 9, y: C1.y }, { x: C2.x - 9, y: C2.y })} {...line} />
      <path d={branch({ x: C1.x + 9, y: C1.y }, lose)} {...line} />
      <circle cx={C1.x} cy={C1.y} r={9} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={(C1.x + C2.x) / 2 + 8} y={C2.y - 12} fontSize={12} color="var(--charcoal)">Win ({pWin.toFixed(2)})</Label>
      <Label x={(C1.x + lose.x) / 2 + 8} y={lose.y - 12} fontSize={12} color="var(--charcoal)">Lose ({(1 - pWin).toFixed(2)})</Label>

      {/* Chance node 2: profit if won */}
      {ends.map((e, k) => (
        <g key={k}>
          <path d={branch({ x: C2.x + 9, y: C2.y }, e)} {...line} />
          <Label x={(C2.x + e.x) / 2 + 8} y={e.y - 10} fontSize={11} color="var(--gray-500)">{outcomes[k].p.toFixed(2)}</Label>
        </g>
      ))}
      <circle cx={C2.x} cy={C2.y} r={9} fill="#fff" stroke="var(--charcoal)" strokeWidth={2} />

      {/* Outcome nodes with their values */}
      {ends.map((e, k) => (
        <g key={k}>
          <polygon points={tri(e)} fill="var(--charcoal)" />
          <Label x={e.x + 16} y={e.y} fontSize={12} color="var(--charcoal)" anchor="start">{fmt(outcomes[k].value)}</Label>
        </g>
      ))}
      <polygon points={tri(lose)} fill="var(--charcoal)" />
      <Label x={lose.x + 16} y={lose.y} fontSize={12} color="var(--charcoal)" anchor="start">0</Label>
      <polygon points={tri(noBid)} fill="var(--charcoal)" />
      <Label x={noBid.x + 16} y={noBid.y} fontSize={12} color="var(--charcoal)" anchor="start">0</Label>

      <Label x={W - 6} y={H - 8} fontSize={11} color="var(--gray-500)" italic anchor="end">profit, dollars</Label>
    </svg>
  );
}

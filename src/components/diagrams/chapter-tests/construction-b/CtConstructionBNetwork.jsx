import React from 'react';

const NW = 58;
const NH = 46;

/**
 * Activity-on-node network, all links finish-to-start, durations in days.
 * Nodes are placed on a column/row grid from props.
 * Shows: activities and durations. Does NOT show: any early/late date or float.
 */
export function CtConstructionBNetwork({
  nodes = [
    { id: 'A', dur: 3, col: 0, row: 0 },
    { id: 'B', dur: 5, col: 0, row: 2 },
    { id: 'C', dur: 6, col: 1, row: 0 },
    { id: 'D', dur: 3, col: 1, row: 1 },
    { id: 'E', dur: 7, col: 1, row: 2 },
    { id: 'F', dur: 5, col: 2, row: 0.5 },
    { id: 'G', dur: 3, col: 2, row: 1.5 },
    { id: 'H', dur: 2, col: 3, row: 1 },
  ],
  links = [['A', 'C'], ['A', 'D'], ['B', 'D'], ['B', 'E'], ['C', 'F'], ['D', 'F'], ['D', 'G'], ['E', 'G'], ['F', 'H'], ['G', 'H']],
}) {
  const M = 14;
  const colX = (c) => M + NW / 2 + c * 108;
  const rowY = (r) => M + NH / 2 + r * 64;
  const pos = Object.fromEntries(nodes.map((n) => [n.id, { x: colX(n.col), y: rowY(n.row) }]));
  const maxCol = Math.max(...nodes.map((n) => n.col));
  const maxRow = Math.max(...nodes.map((n) => n.row));
  const W = colX(maxCol) + NW / 2 + M;
  const H = rowY(maxRow) + NH / 2 + M;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Activity-on-node network with activities and their durations in days"
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctConBNetArrow" markerWidth={8} markerHeight={8} refX={7.5} refY={4}
          orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--charcoal)" />
        </marker>
      </defs>
      {links.map(([f, t]) => {
        const a = pos[f]; const b = pos[t];
        const dy = Math.max(-11, Math.min(11, (a.y - b.y) * 0.3));
        const sy = Math.max(-11, Math.min(11, (b.y - a.y) * 0.3));
        return (
          <line key={f + t} x1={a.x + NW / 2} y1={a.y + sy} x2={b.x - NW / 2 - 1} y2={b.y + dy}
            stroke="var(--charcoal)" strokeWidth={1.4} markerEnd="url(#ctConBNetArrow)" />
        );
      })}
      {nodes.map((n) => {
        const { x, y } = pos[n.id];
        return (
          <g key={n.id}>
            <rect x={x - NW / 2} y={y - NH / 2} width={NW} height={NH} rx={6}
              fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
            <line x1={x - NW / 2 + 5} y1={y + 1} x2={x + NW / 2 - 5} y2={y + 1}
              stroke="var(--gray-300)" strokeWidth={1} />
            <text x={x} y={y - 10} fill="var(--charcoal)" fontFamily="var(--font-body)"
              fontWeight={700} fontSize={14} textAnchor="middle" dominantBaseline="middle">{n.id}</text>
            <text x={x} y={y + 13} fill="var(--charcoal)" fontFamily="var(--font-mono)"
              fontSize={12} textAnchor="middle" dominantBaseline="middle">{`${n.dur} d`}</text>
          </g>
        );
      })}
    </svg>
  );
}

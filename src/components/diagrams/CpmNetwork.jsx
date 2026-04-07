import React from 'react';
import { ArrowMarkerDefs } from './primitives';

/* ---------- Named Layouts ---------- */

const LAYOUTS = {
  /* A→B→D, A→C, B→E, C→E  (5 activities, 5 edges) */
  fiveActivity: {
    nodes: [
      { id: 'A', col: 0, row: 1 },
      { id: 'B', col: 1, row: 0 },
      { id: 'C', col: 1, row: 2 },
      { id: 'D', col: 2, row: 0 },
      { id: 'E', col: 2, row: 1 },
    ],
    edges: [['A','B'],['A','C'],['B','D'],['B','E'],['C','E']],
  },

  /* A→B→D, A→C→D  (4-activity diamond) */
  diamond4: {
    nodes: [
      { id: 'A', col: 0, row: 1 },
      { id: 'B', col: 1, row: 0 },
      { id: 'C', col: 1, row: 2 },
      { id: 'D', col: 2, row: 1 },
    ],
    edges: [['A','B'],['A','C'],['B','D'],['C','D']],
  },
};

/* ---------- Component ---------- */

export function CpmNetwork({ variant = 'fiveActivity', durations = {} }) {
  const layout = LAYOUTS[variant];
  if (!layout) return null;

  const colSpace = 120;
  const rowSpace = 72;
  const padX = 55;
  const padY = 42;
  const bw = 50;
  const bh = 44;
  const br = 6;

  const maxCol = Math.max(...layout.nodes.map(n => n.col));
  const maxRow = Math.max(...layout.nodes.map(n => n.row));
  const vbW = padX * 2 + maxCol * colSpace;
  const vbH = padY * 2 + maxRow * rowSpace;

  const nodeMap = Object.fromEntries(layout.nodes.map(n => [n.id, n]));
  const px = n => padX + n.col * colSpace;
  const py = n => padY + n.row * rowSpace;

  return (
    <svg
      viewBox={`0 0 ${vbW} ${vbH}`}
      style={{ width: '100%', height: 'auto' }}
      role="img"
      aria-label={`CPM network diagram with activities ${layout.nodes.map(n => n.id).join(', ')}`}
    >
      <ArrowMarkerDefs id="cpmArr" color="var(--charcoal)" size={6} />

      {/* Dependency arrows */}
      {layout.edges.map(([fId, tId], i) => {
        const f = nodeMap[fId];
        const t = nodeMap[tId];
        if (!f || !t) return null;
        return (
          <line
            key={`e${i}`}
            x1={px(f) + bw / 2}
            y1={py(f)}
            x2={px(t) - bw / 2}
            y2={py(t)}
            stroke="var(--charcoal)"
            strokeWidth={1.5}
            markerEnd="url(#cpmArr)"
          />
        );
      })}

      {/* Activity nodes */}
      {layout.nodes.map(n => {
        const x = px(n);
        const y = py(n);
        const dur = durations[n.id];
        return (
          <g key={n.id}>
            {/* Box */}
            <rect
              x={x - bw / 2}
              y={y - bh / 2}
              width={bw}
              height={bh}
              rx={br}
              ry={br}
              fill="white"
              stroke="var(--charcoal)"
              strokeWidth={1.5}
            />
            {/* Divider */}
            <line
              x1={x - bw / 2 + 4}
              y1={y + 1}
              x2={x + bw / 2 - 4}
              y2={y + 1}
              stroke="var(--gray-200)"
              strokeWidth={0.75}
            />
            {/* Activity name */}
            <text
              x={x}
              y={y - 8}
              fontSize={13}
              fontWeight={700}
              fontFamily="'DM Sans', sans-serif"
              fill="var(--charcoal)"
              textAnchor="middle"
              dominantBaseline="middle"
            >
              {n.id}
            </text>
            {/* Duration */}
            {dur != null && (
              <text
                x={x}
                y={y + 14}
                fontSize={10}
                fontFamily="'JetBrains Mono', monospace"
                fill="var(--gray-500)"
                textAnchor="middle"
                dominantBaseline="middle"
              >
                {dur}
              </text>
            )}
          </g>
        );
      })}
    </svg>
  );
}

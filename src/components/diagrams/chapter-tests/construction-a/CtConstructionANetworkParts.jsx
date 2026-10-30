import React from 'react';

/**
 * Shared drawing parts for the construction A activity-on-node figures.
 * Not registered itself: the registered figures use it.
 */
export const NODE_W = 56;
export const NODE_H = 46;

export function CtConstructionAArrowDefs({ id }) {
  return (
    <defs>
      <marker id={id} markerWidth={8} markerHeight={8} refX={7.5} refY={4}
        orient="auto" markerUnits="userSpaceOnUse">
        <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--charcoal)" />
      </marker>
    </defs>
  );
}

/** Activity box: letter on top, duration in days below. */
export function CtConstructionANode({ x, y, id, duration }) {
  return (
    <g>
      <rect x={x - NODE_W / 2} y={y - NODE_H / 2} width={NODE_W} height={NODE_H} rx={6}
        fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      <line x1={x - NODE_W / 2 + 5} y1={y + 1} x2={x + NODE_W / 2 - 5} y2={y + 1}
        stroke="var(--gray-300)" strokeWidth={1} />
      <text x={x} y={y - 10} fill="var(--charcoal)" fontFamily="var(--font-body)"
        fontWeight={700} fontSize={14} textAnchor="middle" dominantBaseline="middle">{id}</text>
      <text x={x} y={y + 13} fill="var(--charcoal)" fontFamily="var(--font-mono)"
        fontSize={12} textAnchor="middle" dominantBaseline="middle">{`${duration} d`}</text>
    </g>
  );
}

/** Finish-to-start link from the right edge of one box to the left edge of the next. */
export function CtConstructionALink({ from, to, markerId }) {
  return (
    <line x1={from.x + NODE_W / 2} y1={from.y} x2={to.x - NODE_W / 2 - 1}
      y2={to.y + Math.max(-11, Math.min(11, (from.y - to.y) * 0.3))}
      stroke="var(--charcoal)" strokeWidth={1.4} markerEnd={`url(#${markerId})`} />
  );
}

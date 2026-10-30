import React from 'react';

const NW = 112;
const NH = 48;

/**
 * Three activity-on-node boxes for a pipeline crew, linked by start-to-start
 * (left edge to left edge) and finish-to-finish (right edge to right edge)
 * relationships with lags, drawn the way the Handbook draws them.
 * Shows: durations, relationship types and lags. Does NOT show: any date.
 */
export function CtConstructionBLagNetwork({
  acts = [
    { id: 'A', name: 'Trench', dur: 10 },
    { id: 'B', name: 'Lay pipe', dur: 6 },
    { id: 'C', name: 'Backfill', dur: 5 },
  ],
  lags = [
    { ss: 2, ff: 1 },
    { ss: 1, ff: 2 },
  ],
}) {
  const left = 64; const top = 12; const dx = 78; const dy = 84; const out = 20;
  const pos = acts.map((_, i) => ({ x: left + NW / 2 + i * dx, y: top + NH / 2 + i * dy }));
  const W = pos[acts.length - 1].x + NW / 2 + out + 62;
  const H = pos[acts.length - 1].y + NH / 2 + 12;
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle' };
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Three activities linked by start-to-start and finish-to-finish relationships with lags in days"
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctConBLagArrow" markerWidth={8} markerHeight={8} refX={7.5} refY={4}
          orient="auto" markerUnits="userSpaceOnUse">
          <path d="M 0,0 L 8,4 L 0,8 Z" fill="var(--charcoal)" />
        </marker>
      </defs>
      {lags.map((l, i) => {
        const a = pos[i]; const b = pos[i + 1];
        const ya = a.y + 8; const yb = b.y - 8;
        const sx = a.x - NW / 2 - out; const fx = b.x + NW / 2 + out;
        return (
          <g key={i}>
            <path d={`M ${a.x - NW / 2} ${ya} H ${sx} V ${yb} H ${b.x - NW / 2 - 1}`}
              fill="none" stroke="var(--charcoal)" strokeWidth={1.4} markerEnd="url(#ctConBLagArrow)" />
            <text x={sx - 6} y={(ya + yb) / 2 + 8} fill="var(--ember)" fontSize={12} fontWeight={700}
              textAnchor="end" {...font} fontFamily="var(--font-mono)">{`SS ${l.ss}`}</text>
            <path d={`M ${a.x + NW / 2} ${ya} H ${fx} V ${yb} H ${b.x + NW / 2 + 1}`}
              fill="none" stroke="var(--charcoal)" strokeWidth={1.4} markerEnd="url(#ctConBLagArrow)" />
            <text x={fx + 6} y={(ya + yb) / 2 + 8} fill="var(--ember)" fontSize={12} fontWeight={700}
              textAnchor="start" {...font} fontFamily="var(--font-mono)">{`FF ${l.ff}`}</text>
          </g>
        );
      })}
      {acts.map((n, i) => {
        const { x, y } = pos[i];
        return (
          <g key={n.id}>
            <rect x={x - NW / 2} y={y - NH / 2} width={NW} height={NH} rx={6}
              fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
            <text x={x} y={y - 10} fill="var(--charcoal)" fontSize={13} fontWeight={700}
              textAnchor="middle" {...font}>{`${n.id}  ${n.name}`}</text>
            <text x={x} y={y + 12} fill="var(--charcoal)" fontSize={12}
              textAnchor="middle" {...font} fontFamily="var(--font-mono)">{`${n.dur} d`}</text>
          </g>
        );
      })}
    </svg>
  );
}

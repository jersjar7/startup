import React from 'react';
import { CtConstructionAArrowDefs, CtConstructionANode, CtConstructionALink, NODE_W, NODE_H } from './CtConstructionANetworkParts';

/**
 * Four-activity AON network (A then B or C, then D) with its crash table.
 * Shows: normal durations, crash limits, crash cost per day.
 * Does NOT show: which activities to crash or the total cost.
 */
export function CtConstructionACrashNetwork({
  rows = [
    { id: 'A', normal: 5, maxCrash: 2, cost: 900 },
    { id: 'B', normal: 7, maxCrash: 2, cost: 400 },
    { id: 'C', normal: 6, maxCrash: 1, cost: 300 },
    { id: 'D', normal: 4, maxCrash: 1, cost: 1000 },
  ],
}) {
  const d = Object.fromEntries(rows.map((r) => [r.id, r.normal]));
  const cols = [
    { w: 80, head: ['Activity'] },
    { w: 92, head: ['Normal', 'duration (d)'] },
    { w: 104, head: ['Most it can be', 'crashed (d)'] },
    { w: 116, head: ['Crash cost', '(dollars per day)'] },
  ];
  const TW = cols.reduce((s, c) => s + c.w, 0);
  const pad = 12;
  const W = TW + pad * 2;
  const cx = W / 2;
  const pos = {
    A: { x: cx - 120, y: pad + NODE_H / 2 + 34 },
    B: { x: cx, y: pad + NODE_H / 2 },
    C: { x: cx, y: pad + NODE_H / 2 + 68 },
    D: { x: cx + 120, y: pad + NODE_H / 2 + 34 },
  };
  const links = [['A', 'B'], ['A', 'C'], ['B', 'D'], ['C', 'D']];
  const tTop = pos.C.y + NODE_H / 2 + 22;
  const headH = 40;
  const rowH = 24;
  const H = tTop + headH + rows.length * rowH + pad;
  const xs = cols.reduce((a, c) => [...a, a[a.length - 1] + c.w], [pad]);
  const n = (v) => v.toLocaleString('en-US');

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Activity-on-node network A, B, C, D with a table of normal durations, crash limits and crash costs"
      style={{ width: '100%', height: 'auto' }}>
      <CtConstructionAArrowDefs id="ctConACrashArrow" />
      {links.map(([f, t]) => (
        <CtConstructionALink key={f + t} from={pos[f]} to={pos[t]} markerId="ctConACrashArrow" />
      ))}
      {Object.entries(pos).map(([id, p]) => (
        <CtConstructionANode key={id} x={p.x} y={p.y} id={id} duration={d[id]} />
      ))}

      <rect x={pad} y={tTop} width={TW} height={headH} rx={6} fill="var(--cream-dark)" />
      {cols.map((c, i) => c.head.map((line, k) => (
        <text key={`h${i}${k}`} x={xs[i] + c.w / 2} y={tTop + headH / 2 + (k - (c.head.length - 1) / 2) * 14}
          fill="var(--charcoal)" fontFamily="var(--font-body)" fontWeight={600} fontSize={11.5}
          textAnchor="middle" dominantBaseline="middle">{line}</text>
      )))}
      {rows.map((r, j) => {
        const y = tTop + headH + j * rowH;
        const cells = [r.id, r.normal, r.maxCrash, n(r.cost)];
        return (
          <g key={r.id}>
            <line x1={pad} y1={y} x2={pad + TW} y2={y} stroke={j === 0 ? 'var(--charcoal)' : 'var(--gray-300)'} strokeWidth={j === 0 ? 1.2 : 0.8} />
            {cells.map((c, i) => (
              <text key={i} x={xs[i] + cols[i].w / 2} y={y + rowH / 2} fill="var(--charcoal)"
                fontFamily={i === 0 ? 'var(--font-body)' : 'var(--font-mono)'} fontWeight={i === 0 ? 600 : 400}
                fontSize={12} textAnchor="middle" dominantBaseline="middle">{c}</text>
            ))}
          </g>
        );
      })}
      <line x1={pad} y1={tTop + headH + rows.length * rowH} x2={pad + TW} y2={tTop + headH + rows.length * rowH}
        stroke="var(--charcoal)" strokeWidth={1.2} />
    </svg>
  );
}

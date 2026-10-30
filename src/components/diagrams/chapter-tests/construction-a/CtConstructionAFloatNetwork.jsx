import React from 'react';
import { CtConstructionAArrowDefs, CtConstructionANode, CtConstructionALink, NODE_W, NODE_H } from './CtConstructionANetworkParts';

/**
 * Activity-on-node network, all links finish-to-start, durations in days.
 * Shows: activities and durations. Does NOT show: any early/late date or float.
 */
export function CtConstructionAFloatNetwork({
  durations = { A: 4, B: 5, C: 3, D: 8, E: 5, F: 4, G: 3 },
}) {
  const colX = (c) => 16 + NODE_W / 2 + c * 112;
  const rowY = (r) => 16 + NODE_H / 2 + r * 68;
  const pos = {
    A: { x: colX(0), y: rowY(1) },
    B: { x: colX(1), y: rowY(0) },
    C: { x: colX(1), y: rowY(1) },
    D: { x: colX(1), y: rowY(2) },
    E: { x: colX(2), y: rowY(0.5) },
    F: { x: colX(2), y: rowY(1.5) },
    G: { x: colX(3), y: rowY(1) },
  };
  const links = [['A', 'B'], ['A', 'C'], ['A', 'D'], ['B', 'E'], ['C', 'E'], ['C', 'F'], ['D', 'F'], ['E', 'G'], ['F', 'G']];
  const W = colX(3) + NODE_W / 2 + 16;
  const H = rowY(2) + NODE_H / 2 + 16;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Activity-on-node network with activities A to G and their durations in days"
      style={{ width: '100%', height: 'auto' }}>
      <CtConstructionAArrowDefs id="ctConAFloatArrow" />
      {links.map(([f, t]) => (
        <CtConstructionALink key={f + t} from={pos[f]} to={pos[t]} markerId="ctConAFloatArrow" />
      ))}
      {Object.entries(pos).map(([id, p]) => (
        <CtConstructionANode key={id} x={p.x} y={p.y} id={id} duration={durations[id]} />
      ))}
    </svg>
  );
}

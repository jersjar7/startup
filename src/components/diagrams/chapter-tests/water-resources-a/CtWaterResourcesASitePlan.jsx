import React from 'react';
import { Label } from '../../primitives';

/**
 * Plan of a small commercial site draining to one curb inlet.
 * Shows: two subareas (pavement, lawn) with their areas and runoff
 * coefficients, the overland flow path across the lawn and the gutter run
 * along the pavement edge to the inlet.
 * Does NOT show: the weighted C, the intensity or the peak flow.
 */
export function CtWaterResourcesASitePlan({ a1 = 2.4, c1 = 0.9, a2 = 1.6, c2 = 0.2 }) {
  const x0 = 14;
  const y0 = 14;
  const W = 380;
  const H = 180;
  const split = x0 + (W * a1) / (a1 + a2); // widths proportional to area
  const gutterY = y0 + H - 14;
  const inletX = x0 + 18;

  return (
    <svg viewBox={`0 0 ${x0 * 2 + W} ${y0 + H + 34}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Site plan: pavement ${a1} ac with C ${c1}, lawn ${a2} ac with C ${c2}, draining to one inlet`}
      style={{ width: '100%', height: 'auto' }}>
      <defs>
        <marker id="ctWraASiteArrow" markerWidth={8} markerHeight={8} refX={7} refY={4} orient="auto" markerUnits="userSpaceOnUse">
          <path d="M0,0 L8,4 L0,8 Z" fill="var(--info)" />
        </marker>
      </defs>

      {/* Lawn fill (stippled with short tufts) */}
      <rect x={split} y={y0} width={x0 + W - split} height={H} fill="var(--forest)" fillOpacity={0.08} />
      {Array.from({ length: 6 }, (_, r) => Array.from({ length: 5 }, (_, c) => {
        const tx = split + 16 + c * 28 + (r % 2) * 12;
        const ty = y0 + 14 + r * 28;
        if (ty > y0 + 22 && ty < y0 + 84 && tx > split + 20 && tx < x0 + W - 20) return null;
        if (ty > y0 + 92 && ty < y0 + 170 && Math.abs((ty - (y0 + 104)) - (tx - (x0 + W - 22)) * ((gutterY - 4 - y0 - 104) / (split + 16 - x0 - W + 22))) < 12) return null; // keep text clear
        const ox = (split + x0 + W) / 2 + 8; // 'overland' label box, ~50 x 12
        const oy = y0 + 146;
        if (tx > ox - 12 && tx < ox + 50 + 12 && ty > oy - 9 - 12 && ty < oy + 3 + 12) return null;
        return <path key={`${r}-${c}`} d={`M${tx - 3},${ty + 3} L${tx},${ty - 3} L${tx + 3},${ty + 3}`} fill="none" stroke="var(--forest)" strokeOpacity={0.45} strokeWidth={1} />;
      }))}

      {/* Pavement fill */}
      <rect x={x0} y={y0} width={split - x0} height={H} fill="var(--gray-400)" fillOpacity={0.14} />

      {/* Site boundary and subarea divide */}
      <rect x={x0} y={y0} width={W} height={H} fill="none" stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={split} y1={y0} x2={split} y2={y0 + H} stroke="var(--charcoal)" strokeWidth={1.2} strokeDasharray="6,4" />

      {/* Subarea data */}
      <Label x={(x0 + split) / 2} y={y0 + 54} color="var(--charcoal)" fontSize={13} bold>Pavement</Label>
      <Label x={(x0 + split) / 2} y={y0 + 74} color="var(--charcoal)" fontSize={12}>{`A = ${a1.toFixed(1)} ac`}</Label>
      <Label x={(x0 + split) / 2} y={y0 + 92} color="var(--charcoal)" fontSize={12}>{`C = ${c1.toFixed(2)}`}</Label>
      <Label x={(split + x0 + W) / 2} y={y0 + 34} color="var(--charcoal)" fontSize={13} bold>Lawn</Label>
      <Label x={(split + x0 + W) / 2} y={y0 + 54} color="var(--charcoal)" fontSize={12}>{`A = ${a2.toFixed(1)} ac`}</Label>
      <Label x={(split + x0 + W) / 2} y={y0 + 72} color="var(--charcoal)" fontSize={12}>{`C = ${c2.toFixed(2)}`}</Label>

      {/* Overland flow across the lawn to the pavement edge, then gutter flow to the inlet */}
      <path d={`M ${x0 + W - 22},${y0 + 104} L ${split + 16},${gutterY - 4}`} fill="none"
        stroke="var(--info)" strokeWidth={1.6} strokeDasharray="5,4" markerEnd="url(#ctWraASiteArrow)" />
      <line x1={split + 8} y1={gutterY} x2={inletX + 12} y2={gutterY}
        stroke="var(--info)" strokeWidth={1.8} markerEnd="url(#ctWraASiteArrow)" />
      <Label x={(split + x0 + W) / 2 + 8} y={y0 + 146} color="var(--info)" fontSize={11} anchor="start">overland</Label>
      <Label x={(x0 + split) / 2} y={gutterY - 12} color="var(--info)" fontSize={11}>gutter flow</Label>

      {/* Inlet grate on the site edge */}
      <rect x={inletX - 9} y={y0 + H - 7} width={18} height={14} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.6} />
      {[-4, 0, 4].map((d) => <line key={d} x1={inletX + d} y1={y0 + H - 5} x2={inletX + d} y2={y0 + H + 5} stroke="var(--charcoal)" strokeWidth={1} />)}
      <Label x={inletX + 16} y={y0 + H + 18} color="var(--charcoal)" fontSize={12} anchor="start">inlet</Label>
    </svg>
  );
}

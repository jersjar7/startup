import React from 'react';
import { DimensionLine, Label } from './primitives';

/**
 * Rectangular weir — side view showing water flowing over a crest.
 *
 * Shows: weir wall, upstream water, nappe (curved water sheet),
 *        crest label, head H dimension, crest length L note.
 *
 * Does NOT show: computed Q (student solves).
 */
export function RectangularWeir({
  L = 5,
  H: head = 1.5,
  unit = 'ft',
  contracted = false,
}) {
  const W = 380;
  const HH = 240;

  // Layout
  const botY = 200;
  const weirX = 200;                  // weir wall x-position
  const weirW = 12;                   // wall thickness
  const weirH = 80;                   // wall height in px
  const weirTop = botY - weirH;

  // Scale head proportionally to weir height
  const headPx = Math.min(head / (head + 1) * 60, 50);
  const upstreamY = weirTop - headPx; // upstream water level
  const crestY = weirTop;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`${contracted ? 'Contracted' : 'Suppressed'} rectangular weir, L = ${L} ${unit}, H = ${head} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* 1. Channel bottom */}
      <line x1={30} y1={botY} x2={W - 30} y2={botY}
        stroke="var(--charcoal)" strokeWidth={2} />

      {/* 2. Upstream water fill (extends over weir to cover gap above crest) */}
      <rect x={30} y={upstreamY} width={weirX + weirW - 30} height={botY - upstreamY}
        fill="rgba(160,210,240,0.25)" />

      {/* 3. Weir wall */}
      <rect x={weirX} y={weirTop} width={weirW} height={weirH}
        fill="var(--gray-200)" stroke="var(--charcoal)" strokeWidth={2} />

      {/* 4. Nappe (curved water sheet — top from water surface, bottom from crest) */}
      {(() => {
        const nX = weirX + weirW;
        const dropY = botY;
        // Top curve: starts at water surface level, arcs over and falls
        const top = `M ${nX},${upstreamY}
          Q ${nX + 18},${upstreamY} ${nX + 35},${upstreamY + 20}
          Q ${nX + 55},${upstreamY + 55} ${nX + 60},${dropY}`;
        // Bottom curve: starts at crest, falls more steeply (closer to wall)
        const bot = `M ${nX},${crestY}
          Q ${nX + 10},${crestY + 5} ${nX + 18},${crestY + 25}
          Q ${nX + 30},${crestY + 55} ${nX + 36},${dropY}`;
        // Fill between the two curves
        const fill = `M ${nX},${upstreamY}
          Q ${nX + 18},${upstreamY} ${nX + 35},${upstreamY + 20}
          Q ${nX + 55},${upstreamY + 55} ${nX + 60},${dropY}
          L ${nX + 36},${dropY}
          Q ${nX + 30},${crestY + 55} ${nX + 18},${crestY + 25}
          Q ${nX + 10},${crestY + 5} ${nX},${crestY}
          L ${nX},${upstreamY} Z`;
        return (
          <g>
            <path d={fill} fill="rgba(160,210,240,0.20)" />
            <path d={top} fill="none" stroke="var(--info)" strokeWidth={1.5} />
            <path d={bot} fill="none" stroke="var(--info)" strokeWidth={1.5} />
          </g>
        );
      })()}

      {/* 5. Upstream water surface */}
      <line x1={30} y1={upstreamY} x2={weirX + weirW} y2={upstreamY}
        stroke="var(--info)" strokeWidth={1.5} />
      {/* Wave ticks */}
      {[0.3, 0.5, 0.7].map((f, i) => {
        const sx = 30 + (weirX - 30) * f;
        return (
          <path key={i}
            d={`M ${sx - 3},${upstreamY} q 3,-2.5 6,0`}
            fill="none" stroke="var(--info)" strokeWidth={1} />
        );
      })}

      {/* 6. Crest label */}
      <Label x={weirX + weirW / 2} y={crestY - 6}
        fontSize={8} color="var(--gray-500)">
        Crest
      </Label>

      {/* 7. Head H dimension (left of weir) */}
      <DimensionLine x1={weirX - 16} y1={crestY} x2={weirX - 16} y2={upstreamY}
        label={`H = ${head} ${unit}`} offset={-30} fontSize={9} />

    </svg>
  );
}

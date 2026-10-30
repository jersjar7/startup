import React from 'react';
import { Label } from '../../primitives';

/**
 * Cross-section of a trapezoidal lined channel carrying uniform flow.
 * Shows: bottom width, side slope (z horizontal : 1 vertical), flow depth,
 * water surface symbol; drawn to scale.
 * Does NOT show: area, top width, velocity or Froude number.
 */
export function CtWaterResourcesATrapChannel({ b = 8, z = 2, y = 3, bank = 5 }) {
  const s = 13; // px per ft
  const ox = 22;
  const topY = 34; // top of bank
  const botY = topY + bank * s;
  const wsY = botY - y * s;
  const bl = ox + z * bank * s; // bottom-left corner x
  const br = bl + b * s;
  const tl = ox;
  const tr = br + z * bank * s;
  const wl = bl - z * y * s;
  const wr = br + z * y * s;
  const W = tr + 22;

  // Soil hatch under the lining, perpendicular-ish short strokes
  const hatch = [];
  const along = (x1, y1, x2, y2, k) => {
    const n = Math.floor(Math.hypot(x2 - x1, y2 - y1) / 14);
    for (let i = 1; i < n; i++) {
      const px = x1 + ((x2 - x1) * i) / n;
      const py = y1 + ((y2 - y1) * i) / n;
      hatch.push(<line key={`${k}${i}`} x1={px} y1={py + 2} x2={px - 7} y2={py + 9} stroke="var(--gray-400)" strokeWidth={1} />);
    }
  };
  along(tl, topY, bl, botY, 'l');
  along(bl, botY, br, botY, 'b');
  along(br, botY, tr, topY, 'r');

  // Slope triangle on the right bank, above the water (drawn on the air side)
  const rise = 16;
  const run = z * rise;
  const sx = br + z * (y + 0.3) * s; // point on the bank just above the water
  const sy = botY - (y + 0.3) * s;

  return (
    <svg viewBox={`0 0 ${W} ${botY + 44}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Trapezoidal channel, bottom width ${b} ft, side slopes ${z}H:1V, depth ${y} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {hatch}
      {/* Water */}
      <polygon points={`${wl},${wsY} ${wr},${wsY} ${br},${botY} ${bl},${botY}`} fill="var(--info)" fillOpacity={0.2} />
      <line x1={wl} y1={wsY} x2={wr} y2={wsY} stroke="var(--info)" strokeWidth={1.6} />
      {/* Water surface symbol */}
      <polygon points={`${wl + 40},${wsY - 3} ${wl + 50},${wsY - 3} ${wl + 45},${wsY - 11}`} fill="none" stroke="var(--info)" strokeWidth={1.4}
        transform={`rotate(180 ${wl + 45} ${wsY - 7})`} />
      <line x1={wl + 39} y1={wsY + 4} x2={wl + 51} y2={wsY + 4} stroke="var(--info)" strokeWidth={1} />
      <line x1={wl + 42} y1={wsY + 8} x2={wl + 48} y2={wsY + 8} stroke="var(--info)" strokeWidth={1} />

      {/* Channel lining */}
      <polyline points={`${tl},${topY} ${bl},${botY} ${br},${botY} ${tr},${topY}`} fill="none" stroke="var(--charcoal)" strokeWidth={2.4} strokeLinejoin="round" />
      <line x1={tl - 12} y1={topY} x2={tl} y2={topY} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={tr} y1={topY} x2={tr + 12} y2={topY} stroke="var(--charcoal)" strokeWidth={2} />

      {/* Side slope triangle: rise 1, run z, meeting the bank */}
      <polyline points={`${sx},${sy} ${sx},${sy - rise} ${sx + run},${sy - rise}`} fill="none" stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={sx - 8} y={sy - rise / 2} color="var(--charcoal)" fontSize={12} anchor="end">1</Label>
      <Label x={sx + run / 2} y={sy - rise - 10} color="var(--charcoal)" fontSize={12}>{z}</Label>

      {/* Depth y, inside the water near the left toe */}
      <line x1={bl + 18} y1={botY} x2={bl + 18} y2={wsY} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={bl + 14} y1={botY - 4} x2={bl + 22} y2={botY + 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={bl + 14} y1={wsY - 4} x2={bl + 22} y2={wsY + 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={bl + 26} y={(botY + wsY) / 2} color="var(--charcoal)" fontSize={12} anchor="start">{`y = ${y.toFixed(1)} ft`}</Label>

      {/* Bottom width */}
      <line x1={bl} y1={botY + 14} x2={bl} y2={botY + 26} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={br} y1={botY + 14} x2={br} y2={botY + 26} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={bl} y1={botY + 22} x2={br} y2={botY + 22} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={bl - 4} y1={botY + 26} x2={bl + 4} y2={botY + 18} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={br - 4} y1={botY + 26} x2={br + 4} y2={botY + 18} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={(bl + br) / 2} y={botY + 36} color="var(--charcoal)" fontSize={12}>{`b = ${b.toFixed(1)} ft`}</Label>
    </svg>
  );
}

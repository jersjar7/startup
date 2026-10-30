import React from 'react';
import { Label } from '../../primitives';

/**
 * Cross-section of a single-cell concrete box culvert flowing full.
 * Shows: inside width and height (to scale), concrete walls, the barrel
 * filled with water.
 * Does NOT show: hydraulic radius, velocity or discharge.
 */
export function CtWaterResourcesABoxCulvert({ width = 5, height = 4, wall = 0.67 }) {
  const s = 44; // px per ft
  const t = wall * s;
  const iw = width * s;
  const ih = height * s;
  const ox = 30;
  const oy = 14;
  const ix = ox + t;
  const iy = oy + t;
  const ow = iw + 2 * t;
  const oh = ih + 2 * t;
  const dimR = ox + ow + 22;
  const dimB = oy + oh + 22;

  // Concrete stipple: small dots in the walls
  const dots = [];
  for (let gx = ox + 4; gx < ox + ow - 2; gx += 9) {
    for (let gy = oy + 4; gy < oy + oh - 2; gy += 9) {
      const inside = gx > ix - 3 && gx < ix + iw + 3 && gy > iy - 3 && gy < iy + ih + 3;
      if (!inside) dots.push(<circle key={`${gx}-${gy}`} cx={gx + ((gy / 9) % 2) * 3} cy={gy} r={0.9} fill="var(--gray-500)" />);
    }
  }

  return (
    <svg viewBox={`0 0 ${dimR + 70} ${dimB + 30}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Box culvert ${width} ft wide by ${height} ft high inside, flowing full`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Concrete */}
      <rect x={ox} y={oy} width={ow} height={oh} fill="var(--gray-400)" fillOpacity={0.18} stroke="var(--charcoal)" strokeWidth={2} />
      {dots}
      {/* Barrel full of water */}
      <rect x={ix} y={iy} width={iw} height={ih} fill="var(--info)" fillOpacity={0.2} stroke="var(--charcoal)" strokeWidth={2} />
      <Label x={ix + iw / 2} y={iy + ih / 2} color="var(--info)" fontSize={13} bold>flowing full</Label>

      {/* Inside width */}
      <line x1={ix} y1={oy + oh + 4} x2={ix} y2={dimB + 5} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={ix + iw} y1={oy + oh + 4} x2={ix + iw} y2={dimB + 5} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={ix} y1={dimB} x2={ix + iw} y2={dimB} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={ix - 4} y1={dimB + 4} x2={ix + 4} y2={dimB - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={ix + iw - 4} y1={dimB + 4} x2={ix + iw + 4} y2={dimB - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={ix + iw / 2} y={dimB + 15} color="var(--charcoal)" fontSize={12}>{`${width.toFixed(1)} ft`}</Label>

      {/* Inside height */}
      <line x1={ox + ow + 4} y1={iy} x2={dimR + 5} y2={iy} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={ox + ow + 4} y1={iy + ih} x2={dimR + 5} y2={iy + ih} stroke="var(--gray-500)" strokeWidth={0.8} />
      <line x1={dimR} y1={iy} x2={dimR} y2={iy + ih} stroke="var(--gray-500)" strokeWidth={1} />
      <line x1={dimR - 4} y1={iy + 4} x2={dimR + 4} y2={iy - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <line x1={dimR - 4} y1={iy + ih + 4} x2={dimR + 4} y2={iy + ih - 4} stroke="var(--gray-500)" strokeWidth={1.2} />
      <Label x={dimR + 10} y={iy + ih / 2} color="var(--charcoal)" fontSize={12} anchor="start">{`${height.toFixed(1)} ft`}</Label>
    </svg>
  );
}

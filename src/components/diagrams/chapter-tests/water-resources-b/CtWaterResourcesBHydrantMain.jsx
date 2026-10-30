import React from 'react';
import { Label } from '../../primitives';

/**
 * Profile of an elevated tank feeding a fire hydrant through a buried main.
 * Not to scale.
 * Shows: tank water surface and floor elevations, hydrant ground elevation,
 * main length and diameter.
 * Does NOT show: the head loss or the hydrant pressure.
 */
export function CtWaterResourcesBHydrantMain({ elWs = 1240, elFloor = 1210, elHydrant = 1105, length = 3200, dia = 10 }) {
  const fmt = (v) => v.toLocaleString('en-US');
  const tL = 34;
  const tR = 104;
  const tTop = 22;
  const wsY = 36;
  const floorY = 72;
  const gX0 = 10;
  const gX1 = 410;
  const gY0 = 150;
  const gY1 = 196;
  const gy = (x) => gY0 + ((x - gX0) * (gY1 - gY0)) / (gX1 - gX0);
  const hX = 352;
  const pipeDepth = 14;
  const riserX = 69;

  return (
    <svg viewBox="0 0 420 246" xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Elevated tank, water surface El. ${elWs} ft, floor El. ${elFloor} ft, feeding a hydrant at ground El. ${elHydrant} ft through ${length} ft of ${dia}-in. main`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Ground */}
      <line x1={gX0} y1={gY0} x2={gX1} y2={gY1} stroke="var(--charcoal)" strokeWidth={1.6} />
      {Array.from({ length: 27 }, (_, i) => {
        const x = gX0 + 8 + i * 15;
        return <line key={i} x1={x} y1={gy(x) + 2} x2={x - 6} y2={gy(x) + 9} stroke="var(--gray-400)" strokeWidth={1} />;
      })}

      {/* Tower legs */}
      <line x1={tL + 6} y1={floorY} x2={tL - 2} y2={gy(tL - 2)} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={tR - 6} y1={floorY} x2={tR + 2} y2={gy(tR + 2)} stroke="var(--charcoal)" strokeWidth={2} />
      <line x1={tL + 4} y1={(floorY + gy(tL)) / 2} x2={tR - 4} y2={(floorY + gy(tR)) / 2} stroke="var(--charcoal)" strokeWidth={1} />

      {/* Tank */}
      <rect x={tL} y={wsY} width={tR - tL} height={floorY - wsY} fill="var(--info)" fillOpacity={0.2} />
      <rect x={tL} y={tTop} width={tR - tL} height={floorY - tTop} fill="none" stroke="var(--charcoal)" strokeWidth={2.2} />
      <line x1={tL} y1={wsY} x2={tR} y2={wsY} stroke="var(--info)" strokeWidth={1.6} />
      <polygon points={`${tL + 14},${wsY - 11} ${tL + 26},${wsY - 11} ${tL + 20},${wsY - 3}`} fill="none" stroke="var(--info)" strokeWidth={1.4} />
      <Label x={tR + 10} y={wsY} color="var(--charcoal)" fontSize={12} anchor="start">{`water surface El. ${fmt(elWs)} ft`}</Label>
      <Label x={tR + 10} y={floorY} color="var(--charcoal)" fontSize={12} anchor="start">{`tank floor El. ${fmt(elFloor)} ft`}</Label>

      {/* Riser and buried main */}
      <polyline
        points={`${riserX},${floorY} ${riserX},${gy(riserX) + pipeDepth} ${hX},${gy(hX) + pipeDepth} ${hX},${gy(hX)}`}
        fill="none" stroke="var(--charcoal)" strokeWidth={3} strokeLinejoin="round" />
      <Label x={210} y={gy(210) + pipeDepth + 22} color="var(--charcoal)" fontSize={12}>{`${fmt(length)} ft of ${dia}-in. ductile iron main`}</Label>

      {/* Hydrant */}
      <rect x={hX - 6} y={gy(hX) - 30} width={12} height={30} rx={2} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={2} />
      <path d={`M ${hX - 8},${gy(hX) - 30} Q ${hX},${gy(hX) - 42} ${hX + 8},${gy(hX) - 30} Z`} fill="var(--charcoal)" />
      <rect x={hX + 6} y={gy(hX) - 22} width={7} height={8} fill="var(--charcoal)" />
      <Label x={hX - 6} y={gy(hX) - 74} color="var(--charcoal)" fontSize={12} bold>hydrant</Label>
      <Label x={hX - 6} y={gy(hX) - 56} color="var(--charcoal)" fontSize={12}>{`ground El. ${fmt(elHydrant)} ft`}</Label>

      <Label x={14} y={234} color="var(--gray-500)" fontSize={11} anchor="start">NOT TO SCALE</Label>
    </svg>
  );
}

import React from 'react';
import { Label } from '../../primitives';

/**
 * Section through a steady pumping test in a confined aquifer. Distances are
 * to scale horizontally; drawdowns are exaggerated vertically.
 * Shows: pumping well and two observation wells with their distances, the
 * aquifer thickness, the original and pumping piezometric surfaces, the
 * drawdown in the near well (value) and in the far well (s2, no value).
 * Does NOT show: the value of s2 or the transmissivity.
 */
export function CtWaterResourcesBPumpingTest({ r1 = 50, r2 = 400, b = 100, s1 = 8.6, q = 500 }) {
  const wellX = 36;
  const px = 320 / r2; // px per ft horizontally
  const o1 = wellX + r1 * px;
  const o2 = wellX + r2 * px;
  const groundY = 22;
  const piezoY = 44;
  const aqTop = 120;
  const aqBot = 196;
  const baseBot = 208;
  const a = 12;
  const R = 1500;
  const sPx = (x) => a * Math.log(R / Math.max(x - wellX, 4));
  const curve = [];
  for (let x = wellX + 4; x <= 412; x += 4) curve.push(`${x},${piezoY + sPx(x)}`);
  const y1 = piezoY + sPx(o1);
  const y2 = piezoY + sPx(o2);
  const tick = (x, y) => <line x1={x - 4} y1={y + 4} x2={x + 4} y2={y - 4} stroke="var(--gray-500)" strokeWidth={1.2} />;
  const tri = (x, y) => `${x - 5},${y - 9} ${x + 5},${y - 9} ${x},${y - 2}`;
  const dimY1 = baseBot + 18;
  const dimY2 = baseBot + 38;
  const dots = [];
  for (let x = 20; x < 412; x += 13) for (let y = aqTop + 8; y < aqBot - 4; y += 12) {
    const dx = x + ((Math.round(y / 12)) % 2) * 6;
    const nearText = (Math.abs(y - 150) < 10 && dx > 140 && dx < 262) || (dx > 292 && dx < 352 && Math.abs(y - 160) < 10);
    const nearWell = Math.abs(dx - wellX) < 10 || Math.abs(dx - o1) < 6 || Math.abs(dx - o2) < 6;
    if (!nearText && !nearWell) dots.push(<circle key={`${x}-${y}`} cx={dx} cy={y} r={1} fill="var(--gray-500)" fillOpacity={0.6} />);
  }

  return (
    <svg viewBox={`0 0 420 ${dimY2 + 22}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Pumping well in a confined aquifer ${b} ft thick, observation wells at ${r1} ft and ${r2} ft, drawdown ${s1} ft at ${r1} ft`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Layers */}
      <rect x={8} y={groundY} width={404} height={aqTop - groundY} fill="var(--gray-400)" fillOpacity={0.12} />
      <rect x={8} y={aqTop} width={404} height={aqBot - aqTop} fill="var(--gray-400)" fillOpacity={0.04} />
      {dots}
      <rect x={8} y={aqBot} width={404} height={baseBot - aqBot} fill="var(--gray-400)" fillOpacity={0.3} />
      <line x1={8} y1={groundY} x2={412} y2={groundY} stroke="var(--charcoal)" strokeWidth={1.8} />
      <line x1={8} y1={aqTop} x2={412} y2={aqTop} stroke="var(--charcoal)" strokeWidth={1} />
      <line x1={8} y1={aqBot} x2={412} y2={aqBot} stroke="var(--charcoal)" strokeWidth={1} />
      <Label x={250} y={aqTop - 12} color="var(--gray-500)" fontSize={11}>confining clay</Label>
      <Label x={200} y={150} color="var(--charcoal)" fontSize={12}>confined aquifer</Label>

      {/* Piezometric surfaces */}
      <line x1={wellX} y1={piezoY} x2={412} y2={piezoY} stroke="var(--info)" strokeWidth={1.2} strokeDasharray="6,4" />
      <Label x={o2 - 40} y={piezoY - 10} color="var(--info)" fontSize={11} anchor="end">original piezometric surface</Label>
      <polyline points={curve.join(' ')} fill="none" stroke="var(--info)" strokeWidth={1.8} />

      {/* Pumping well */}
      <rect x={wellX - 5} y={groundY - 6} width={10} height={aqBot - groundY + 6} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1.6} />
      {Array.from({ length: 6 }, (_, i) => (
        <line key={i} x1={wellX - 5} y1={aqTop + 8 + i * 12} x2={wellX + 5} y2={aqTop + 8 + i * 12} stroke="var(--charcoal)" strokeWidth={1} />
      ))}
      <Label x={wellX - 4} y={9} color="var(--charcoal)" fontSize={12} anchor="start">{`Q = ${q} gpm`}</Label>

      {/* Observation wells */}
      {[[o1, y1], [o2, y2]].map(([x, y]) => (
        <g key={x}>
          <rect x={x - 2.5} y={groundY - 6} width={5} height={aqTop + 22 - groundY + 6} fill="var(--cream)" stroke="var(--charcoal)" strokeWidth={1.2} />
          <polygon points={tri(x, y)} fill="var(--info)" />
        </g>
      ))}

      {/* Drawdown in the near well */}
      <line x1={o1 + 12} y1={piezoY} x2={o1 + 12} y2={y1} stroke="var(--gray-500)" strokeWidth={1} />
      {tick(o1 + 12, piezoY)}
      {tick(o1 + 12, y1)}
      <Label x={o1 + 18} y={(piezoY + y1) / 2} color="var(--charcoal)" fontSize={12} anchor="start">{`s₁ = ${s1} ft`}</Label>

      {/* Drawdown in the far well (unknown) */}
      <line x1={o2 - 12} y1={piezoY} x2={o2 - 12} y2={y2} stroke="var(--gray-500)" strokeWidth={1} />
      {tick(o2 - 12, piezoY)}
      {tick(o2 - 12, y2)}
      <Label x={o2 - 18} y={(piezoY + y2) / 2} color="var(--ember)" fontSize={13} anchor="end" italic bold>s₂</Label>

      {/* Aquifer thickness */}
      <line x1={300} y1={aqTop} x2={300} y2={aqBot} stroke="var(--gray-500)" strokeWidth={1} />
      {tick(300, aqTop)}
      {tick(300, aqBot)}
      <Label x={306} y={160} color="var(--charcoal)" fontSize={12} anchor="start">{`b = ${b} ft`}</Label>

      {/* Distances */}
      {[wellX, o1, o2].map((x) => (
        <line key={x} x1={x} y1={baseBot + 4} x2={x} y2={(x === o2 ? dimY2 : x === o1 ? dimY1 : dimY2) + 4} stroke="var(--gray-500)" strokeWidth={0.8} />
      ))}
      <line x1={wellX} y1={dimY1} x2={o1} y2={dimY1} stroke="var(--gray-500)" strokeWidth={1} />
      {tick(wellX, dimY1)}
      {tick(o1, dimY1)}
      <Label x={o1 + 8} y={dimY1} color="var(--charcoal)" fontSize={12} anchor="start">{`${r1} ft`}</Label>
      <line x1={wellX} y1={dimY2} x2={o2} y2={dimY2} stroke="var(--gray-500)" strokeWidth={1} />
      {tick(wellX, dimY2)}
      {tick(o2, dimY2)}
      <Label x={(wellX + o2) / 2} y={dimY2 + 10} color="var(--charcoal)" fontSize={12}>{`${r2} ft`}</Label>
    </svg>
  );
}

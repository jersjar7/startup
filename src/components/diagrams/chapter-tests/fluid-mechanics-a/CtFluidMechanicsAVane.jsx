import React from 'react';
import { T, Arrow, Dim } from './CtFluidMechanicsAParts';

/**
 * Horizontal water jet turned by a fixed curved vane through the given angle
 * from its original direction (plan view, horizontal plane).
 * Does NOT show: any force on the vane.
 */
export function CtFluidMechanicsAVane({ d = 60, v = 22, angle = 120 }) {
  const W = 420;
  const H = 226;
  const jy = 176; // jet centerline
  const R = 62; // radius of the jet path on the vane
  const cx = 214;
  const cy = jy - R;
  const a = (angle * Math.PI) / 180;
  const ex = cx + R * Math.sin(a);
  const ey = cy + R * Math.cos(a);
  const dx = Math.cos(a);
  const dy = -Math.sin(a);
  const outLen = 66;
  const Rv = R + 7;
  const vane = (th) => [cx + Rv * Math.sin(th), cy + Rv * Math.cos(th)];
  const [v1x, v1y] = vane(-0.08);
  const [v2x, v2y] = vane(a + 0.06);
  const ar = 28;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Water jet ${d} mm at ${v} m/s turned ${angle} degrees by a fixed vane`}
      style={{ width: '100%', height: 'auto' }}>
      {/* nozzle */}
      <polygon points={`16,${jy - 16} 58,${jy - 6} 58,${jy + 6} 16,${jy + 16}`} fill="var(--gray-400)" fillOpacity={0.5} stroke="var(--charcoal)" strokeWidth={1.6} />
      {/* jet: straight, around the vane, out */}
      <path d={`M 58,${jy} L ${cx},${jy} A ${R},${R} 0 0 0 ${ex},${ey} L ${ex + dx * outLen},${ey + dy * outLen}`}
        fill="none" stroke="var(--info)" strokeWidth={9} strokeOpacity={0.55} />
      <Arrow x1={ex + dx * 20} y1={ey + dy * 20} x2={ex + dx * (outLen + 8)} y2={ey + dy * (outLen + 8)} color="var(--info)" width={1.6} size={8} />
      <Arrow x1={78} y1={jy} x2={128} y2={jy} color="var(--info)" width={1.6} size={8} />
      {/* vane */}
      <path d={`M ${v1x},${v1y} A ${Rv},${Rv} 0 0 0 ${v2x},${v2y}`} fill="none" stroke="var(--charcoal)" strokeWidth={4} strokeLinecap="round" />
      {/* vane support */}
      <line x1={cx + Rv} y1={cy} x2={cx + Rv + 34} y2={cy} stroke="var(--charcoal)" strokeWidth={3} />
      <line x1={cx + Rv + 34} y1={cy - 18} x2={cx + Rv + 34} y2={cy + 18} stroke="var(--charcoal)" strokeWidth={2} />
      {[-14, -6, 2, 10].map((o) => (
        <line key={o} x1={cx + Rv + 34} y1={cy + o} x2={cx + Rv + 42} y2={cy + o + 8} stroke="var(--gray-500)" strokeWidth={1} />
      ))}
      <T x={cx + Rv + 2} y={cy + 52} anchor="start" color="var(--gray-500)">fixed vane</T>

      {/* turning angle at the exit */}
      <line x1={ex} y1={ey} x2={ex + 52} y2={ey} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="5,3" />
      <path d={`M ${ex + ar},${ey} A ${ar},${ar} 0 0 0 ${ex + ar * Math.cos(a)},${ey - ar * Math.sin(a)}`} fill="none" stroke="var(--charcoal)" strokeWidth={1.2} />
      <T x={ex + 36} y={ey - 30} anchor="start">{`${angle}°`}</T>

      {/* jet data */}
      <T x={98} y={jy - 22}>{`v = ${v} m/s`}</T>
      <T x={98} y={jy + 26}>{`D = ${d} mm`}</T>

      {/* axes */}
      <Arrow x1={352} y1={196} x2={396} y2={196} color="var(--gray-500)" width={1.3} size={7} />
      <Arrow x1={352} y1={196} x2={352} y2={152} color="var(--gray-500)" width={1.3} size={7} />
      <T x={402} y={196} anchor="start" color="var(--gray-500)" italic>x</T>
      <T x={352} y={142} color="var(--gray-500)" italic>y</T>
    </svg>
  );
}

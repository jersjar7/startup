import React from 'react';

/**
 * Truck crane on outriggers lifting a precast panel at a working radius, with
 * the rated load chart for its boom. Drawn to scale (boom, radius, heights).
 * Shows: radius, boom length, the chart. Does NOT show: the allowed panel weight.
 */
export function CtConstructionACraneChart({
  radius = 38,
  boom = 90,
  chart = [[30, 32000], [35, 26500], [40, 22000], [45, 18600], [50, 15800]],
}) {
  const s = 2.9; // px per ft
  const ground = 300;
  const x0 = 108; // center of rotation
  const pinOff = 3; // boom foot pin ahead of the rotation center, ft
  const pinH = 9; // boom foot pin height, ft
  const pin = { x: x0 + pinOff * s, y: ground - pinH * s };
  const run = radius - pinOff;
  const rise = Math.sqrt(boom * boom - run * run);
  const tip = { x: x0 + radius * s, y: pin.y - rise * s };
  const hookY = ground - 20 * s;
  const panelW = 9 * s;
  const panelH = 12 * s;

  // Chart table
  const tx = 292;
  const tw = 150;
  const ty = 96;
  const headH = 40;
  const rowH = 24;
  const n = (v) => v.toLocaleString('en-US');
  const W = tx + tw + 12;
  const H = ground + 50;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label={`Truck crane with a ${boom} ft boom lifting a panel at a ${radius} ft radius, and its rated load chart`}
      style={{ width: '100%', height: 'auto' }}>
      {/* Ground */}
      <line x1={8} y1={ground} x2={tx - 20} y2={ground} stroke="var(--charcoal)" strokeWidth={1.6} />
      {Array.from({ length: 18 }, (_, i) => (
        <line key={i} x1={14 + i * 12} y1={ground} x2={6 + i * 12} y2={ground + 8}
          stroke="var(--gray-400)" strokeWidth={1} />
      ))}

      {/* Carrier, outriggers, upper works */}
      <rect x={x0 - 22 * s} y={ground - 7 * s} width={30 * s} height={3.6 * s} rx={3}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.6} />
      {[x0 - 20 * s, x0 + 6 * s].map((ox, i) => (
        <g key={i}>
          <line x1={ox} y1={ground - 3.4 * s} x2={ox} y2={ground - 1.2} stroke="var(--charcoal)" strokeWidth={2.4} />
          <rect x={ox - 6} y={ground - 3} width={12} height={3} fill="var(--charcoal)" />
        </g>
      ))}
      <rect x={x0 - 16 * s} y={ground - 12.5 * s} width={19 * s} height={5.5 * s} rx={3}
        fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={1.6} />

      {/* Boom (two chords) */}
      <line x1={pin.x - 2} y1={pin.y} x2={tip.x - 1} y2={tip.y} stroke="var(--charcoal)" strokeWidth={4} strokeLinecap="round" />
      <circle cx={pin.x} cy={pin.y} r={3.5} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      <circle cx={tip.x} cy={tip.y} r={4} fill="#fff" stroke="var(--charcoal)" strokeWidth={1.6} />
      <text x={(pin.x + tip.x) / 2 - 12} y={(pin.y + tip.y) / 2} fill="var(--charcoal)" fontFamily="var(--font-body)"
        fontSize={12} textAnchor="end" dominantBaseline="middle">{`${boom} ft boom`}</text>

      {/* Hook line, hook block, panel */}
      <line x1={tip.x} y1={tip.y + 4} x2={tip.x} y2={hookY - 14} stroke="var(--charcoal)" strokeWidth={1.2} />
      <rect x={tip.x - 5} y={hookY - 14} width={10} height={12} rx={2} fill="var(--charcoal)" />
      <line x1={tip.x} y1={hookY - 2} x2={tip.x - panelW / 2 + 3} y2={hookY + 16} stroke="var(--charcoal)" strokeWidth={1} />
      <line x1={tip.x} y1={hookY - 2} x2={tip.x + panelW / 2 - 3} y2={hookY + 16} stroke="var(--charcoal)" strokeWidth={1} />
      <rect x={tip.x - panelW / 2} y={hookY + 16} width={panelW} height={panelH} rx={2}
        fill="var(--ember-bg)" stroke="var(--ember)" strokeWidth={1.8} />
      <text x={tip.x + panelW / 2 + 8} y={hookY + 16 + panelH / 2} fill="var(--ember)" fontFamily="var(--font-body)"
        fontWeight={600} fontSize={12} textAnchor="start" dominantBaseline="middle">panel</text>

      {/* Centerline of rotation and hook line extended to the radius dimension */}
      <line x1={x0} y1={ground - 27 * s} x2={x0} y2={ground + 34} stroke="var(--gray-500)" strokeWidth={1}
        strokeDasharray="10,3,2,3" />
      <line x1={tip.x} y1={hookY + 16 + panelH + 3} x2={tip.x} y2={ground + 34} stroke="var(--gray-500)" strokeWidth={1}
        strokeDasharray="4,3" />
      <line x1={x0} y1={ground + 28} x2={tip.x} y2={ground + 28} stroke="var(--gray-500)" strokeWidth={1} />
      {[x0, tip.x].map((x, i) => (
        <line key={i} x1={x - 4} y1={ground + 32} x2={x + 4} y2={ground + 24} stroke="var(--gray-500)" strokeWidth={1.2} />
      ))}
      <text x={(x0 + tip.x) / 2} y={ground + 42} fill="var(--charcoal)" fontFamily="var(--font-body)"
        fontSize={12} fontWeight={600} textAnchor="middle" dominantBaseline="middle">{`radius = ${radius} ft`}</text>
      <text x={x0 - 6} y={ground - 24 * s} fill="var(--gray-500)" fontFamily="var(--font-body)"
        fontSize={11} textAnchor="end" dominantBaseline="middle">center of</text>
      <text x={x0 - 6} y={ground - 24 * s + 13} fill="var(--gray-500)" fontFamily="var(--font-body)"
        fontSize={11} textAnchor="end" dominantBaseline="middle">rotation</text>

      {/* Load chart */}
      <text x={tx + tw / 2} y={ty - 24} fill="var(--charcoal)" fontFamily="var(--font-body)" fontWeight={600}
        fontSize={12} textAnchor="middle" dominantBaseline="middle">Rated load chart</text>
      <text x={tx + tw / 2} y={ty - 9} fill="var(--gray-500)" fontFamily="var(--font-body)"
        fontSize={11} textAnchor="middle" dominantBaseline="middle">{`${boom} ft boom, on outriggers`}</text>
      <rect x={tx} y={ty} width={tw} height={headH} rx={6} fill="var(--cream-dark)" />
      {[['Radius', '(ft)'], ['Rated load', '(lb)']].map((h, i) => h.map((line, k) => (
        <text key={`${i}${k}`} x={tx + (i === 0 ? 34 : 105)} y={ty + 13 + k * 14} fill="var(--charcoal)"
          fontFamily="var(--font-body)" fontWeight={600} fontSize={11.5} textAnchor="middle" dominantBaseline="middle">{line}</text>
      )))}
      {chart.map(([r, w], j) => {
        const y = ty + headH + j * rowH;
        return (
          <g key={r}>
            <line x1={tx} y1={y} x2={tx + tw} y2={y} stroke={j === 0 ? 'var(--charcoal)' : 'var(--gray-300)'} strokeWidth={j === 0 ? 1.2 : 0.8} />
            <text x={tx + 34} y={y + rowH / 2} fill="var(--charcoal)" fontFamily="var(--font-mono)" fontSize={12}
              textAnchor="middle" dominantBaseline="middle">{r}</text>
            <text x={tx + 105} y={y + rowH / 2} fill="var(--charcoal)" fontFamily="var(--font-mono)" fontSize={12}
              textAnchor="middle" dominantBaseline="middle">{n(w)}</text>
          </g>
        );
      })}
      <line x1={tx} y1={ty + headH + chart.length * rowH} x2={tx + tw} y2={ty + headH + chart.length * rowH}
        stroke="var(--charcoal)" strokeWidth={1.2} />
      <line x1={tx + 68} y1={ty + headH} x2={tx + 68} y2={ty + headH + chart.length * rowH} stroke="var(--gray-300)" strokeWidth={0.8} />
    </svg>
  );
}

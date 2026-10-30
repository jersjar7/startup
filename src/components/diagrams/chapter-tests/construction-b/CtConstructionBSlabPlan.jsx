import React from 'react';

/**
 * Plan of a rectangular slab on grade, drawn to scale, with a typical patch of
 * the bottom mat in one corner (as plans show it) and the reinforcing callout.
 * Shows: slab size, bar size and spacing, edge cover. Does NOT show: bar counts or weight.
 */
export function CtConstructionBSlabPlan({
  lengthFtIn = [30, 6], widthFtIn = [20, 6], bar = '#4', spacingIn = 12, coverIn = 3,
}) {
  const s = 9; // px per ft
  const Lft = lengthFtIn[0] + lengthFtIn[1] / 12;
  const Wft = widthFtIn[0] + widthFtIn[1] / 12;
  const x0 = 16; const y0 = 40;
  const w = Lft * s; const h = Wft * s;
  const c = Math.max((coverIn / 12) * s, 4); // at least 4 px so the end gap reads
  const sp = (spacingIn / 12) * s;
  const dimC = 'var(--gray-500)';
  const font = { fontFamily: 'var(--font-body)', dominantBaseline: 'middle', fontSize: 12 };
  const tick = (x, y) => <line x1={x - 4} y1={y + 4} x2={x + 4} y2={y - 4} stroke={dimC} strokeWidth={1.2} />;
  const fmt = ([f, i]) => (i ? `${f} ft ${i} in.` : `${f} ft`);
  const nPatch = 7;
  // Typical patch: lower-left corner, bars stop at the cover line
  const px0 = x0 + c; const py1 = y0 + h - c;
  const patchW = (nPatch - 1) * sp; const patchH = (nPatch - 1) * sp;
  const rx = x0 + w + 22;
  const W = rx + 76;
  const H = y0 + h + 14;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg" role="img"
      aria-label="Plan of a slab on grade with its dimensions and a typical patch of reinforcing bars"
      style={{ width: '100%', height: 'auto' }}>
      <rect x={x0} y={y0} width={w} height={h} rx={2} fill="var(--cream-dark)" stroke="var(--charcoal)" strokeWidth={2} />
      {Array.from({ length: nPatch }, (_, i) => (
        <g key={i}>
          <line x1={px0} y1={py1 - i * sp} x2={px0 + patchW + sp * 0.6} y2={py1 - i * sp} stroke="var(--ember)" strokeWidth={1.3} />
          <line x1={px0 + i * sp} y1={py1} x2={px0 + i * sp} y2={py1 - patchH - sp * 0.6} stroke="var(--ember)" strokeWidth={1.3} />
        </g>
      ))}
      {/* Callout */}
      <line x1={px0 + patchW * 0.55} y1={py1 - patchH * 0.55} x2={x0 + w * 0.52} y2={y0 + h * 0.36} stroke="var(--charcoal)" strokeWidth={1} />
      <circle cx={px0 + patchW * 0.55} cy={py1 - patchH * 0.55} r={2.5} fill="var(--charcoal)" />
      <text x={x0 + w * 0.52 + 4} y={y0 + h * 0.36 - 9} {...font} fill="var(--charcoal)" textAnchor="start">{`${bar} @ ${spacingIn} in. o.c.`}</text>
      <text x={x0 + w * 0.52 + 4} y={y0 + h * 0.36 + 8} {...font} fill="var(--charcoal)" textAnchor="start">each way, bottom</text>
      <text x={x0 + w * 0.52 + 4} y={y0 + h * 0.36 + 32} {...font} fill="var(--gray-500)" textAnchor="start">{`bars end ${coverIn} in.`}</text>
      <text x={x0 + w * 0.52 + 4} y={y0 + h * 0.36 + 48} {...font} fill="var(--gray-500)" textAnchor="start">from every edge</text>

      {/* Length (top) */}
      <line x1={x0} y1={y0 - 6} x2={x0} y2={y0 - 30} stroke={dimC} strokeWidth={0.8} />
      <line x1={x0 + w} y1={y0 - 6} x2={x0 + w} y2={y0 - 30} stroke={dimC} strokeWidth={0.8} />
      <line x1={x0} y1={y0 - 22} x2={x0 + w} y2={y0 - 22} stroke={dimC} strokeWidth={1} />
      {tick(x0, y0 - 22)}{tick(x0 + w, y0 - 22)}
      <rect x={x0 + w / 2 - 38} y={y0 - 30} width={76} height={16} fill="#fff" />
      <text x={x0 + w / 2} y={y0 - 22} {...font} fill="var(--charcoal)" textAnchor="middle">{fmt(lengthFtIn)}</text>

      {/* Width (right) */}
      <line x1={x0 + w + 6} y1={y0} x2={rx + 8} y2={y0} stroke={dimC} strokeWidth={0.8} />
      <line x1={x0 + w + 6} y1={y0 + h} x2={rx + 8} y2={y0 + h} stroke={dimC} strokeWidth={0.8} />
      <line x1={rx} y1={y0} x2={rx} y2={y0 + h} stroke={dimC} strokeWidth={1} />
      {tick(rx, y0)}{tick(rx, y0 + h)}
      <text x={rx + 8} y={y0 + h / 2} {...font} fill="var(--charcoal)" textAnchor="start">{fmt(widthFtIn)}</text>
    </svg>
  );
}

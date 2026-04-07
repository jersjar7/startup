import React from 'react';
import { DashedLine, Label } from './primitives';

/**
 * Lateral-torsional buckling (LTB) strength curve.
 *
 * Shows: Mn vs Lb graph with three zones (plastic, inelastic, elastic),
 *        boundary lines at Lp and Lr, horizontal references at Mp and Mr,
 *        marker(s) at the given Lb (and optional Lb2).
 *
 * Does NOT show: computed Mn value (student solves).
 */

/* Subscript helper — renders "base" then a shifted-down subscript */
const S = ({ children, size = 6, dy = 3 }) => (
  <tspan dy={dy} fontSize={size}>{children}</tspan>
);
/* Reset baseline after a subscript */
const R = ({ children, dy = -3 }) => (
  <tspan dy={dy}>{children}</tspan>
);

export function LTBCurve({
  Mp = 500,
  Mr = 300,
  Lp = 8,
  Lr = 25,
  Lb = 15,
  Lb2 = null,
  unit = 'ft',
}) {
  const W = 420;
  const HH = 290;

  // Graph area
  const gLeft = 60;
  const gRight = W - 40;
  const gTop = 30;
  const gBot = 220;
  const gW = gRight - gLeft;
  const gH = gBot - gTop;

  // X scale: Lb axis (0 to ~1.4 * Lr)
  const maxLb = Lr * 1.4;
  const xScale = gW / maxLb;
  const toX = (lb) => gLeft + lb * xScale;

  // Y scale: Mn axis (0 to ~1.15 * Mp)
  const maxMn = Mp * 1.15;
  const yScale = gH / maxMn;
  const toY = (mn) => gBot - mn * yScale;

  // Key points
  const xLp = toX(Lp);
  const xLr = toX(Lr);
  const yMp = toY(Mp);
  const yMr = toY(Mr);

  // Elastic curve beyond Lr
  const elasticPts = [];
  const nPts = 20;
  for (let i = 0; i <= nPts; i++) {
    const lb = Lr + (maxLb - Lr) * (i / nPts);
    const mn = Math.max(Mr * (Lr / lb) * (Lr / lb), Mp * 0.08);
    elasticPts.push(`${toX(lb).toFixed(1)},${toY(mn).toFixed(1)}`);
  }

  // Compute Mn at a given Lb value
  const mnAt = (lb) => {
    if (lb <= Lp) return Mp;
    if (lb <= Lr) return Mp - (Mp - Mr) * ((lb - Lp) / (Lr - Lp));
    return Mr * (Lr / lb) * (Lr / lb);
  };

  // Lb marker
  const xLb = toX(Lb);
  const yLb = toY(mnAt(Lb));

  // Optional second Lb marker
  let xLb2, yLb2;
  if (Lb2 !== null) {
    xLb2 = toX(Lb2);
    yLb2 = toY(mnAt(Lb2));
  }

  // Collision detection: suppress boundary label when Lb marker overlaps it
  const OVERLAP_PX = 20;
  const lbNearLp = Math.abs(xLb - xLp) < OVERLAP_PX;
  const lbNearLr = Math.abs(xLb - xLr) < OVERLAP_PX;
  const lb2NearLp = Lb2 !== null && Math.abs(xLb2 - xLp) < OVERLAP_PX;
  const lb2NearLr = Lb2 !== null && Math.abs(xLb2 - xLr) < OVERLAP_PX;
  const suppressLp = lbNearLp || lb2NearLp;
  const suppressLr = lbNearLr || lb2NearLr;

  // Single label row close to axis
  const labelY = gBot + 14;

  return (
    <svg viewBox={`0 0 ${W} ${HH}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`LTB curve: Mp=${Mp}, Lp=${Lp} ${unit}, Lr=${Lr} ${unit}, Lb=${Lb} ${unit}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* ── Axes ── */}
      <line x1={gLeft} y1={gTop - 10} x2={gLeft} y2={gBot}
        stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={gLeft} y1={gBot} x2={gRight + 10} y2={gBot}
        stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Axis labels */}
      <Label x={gLeft - 4} y={gTop - 18} fontSize={9} color="var(--charcoal)" bold anchor="middle">
        M<S size={7}>n</S>
      </Label>
      <Label x={gRight + 10} y={gBot + 16} fontSize={9} color="var(--charcoal)" bold anchor="end">
        L<S size={7}>b</S>
      </Label>

      {/* ── Zone fills ── */}
      <rect x={gLeft} y={yMp} width={xLp - gLeft} height={gBot - yMp}
        fill="rgba(45,122,95,0.06)" />
      <polygon points={`${xLp},${yMp} ${xLr},${yMr} ${xLr},${gBot} ${xLp},${gBot}`}
        fill="rgba(59,130,184,0.06)" />

      {/* ── Strength curve ── */}
      <line x1={gLeft} y1={yMp} x2={xLp} y2={yMp}
        stroke="var(--info)" strokeWidth={2.5} />
      <line x1={xLp} y1={yMp} x2={xLr} y2={yMr}
        stroke="var(--info)" strokeWidth={2.5} />
      <polyline points={`${xLr},${yMr} ${elasticPts.join(' ')}`}
        fill="none" stroke="var(--info)" strokeWidth={2.5} />

      {/* ── Y-axis references ── */}
      <DashedLine x1={gLeft} y1={yMp} x2={gLeft - 4} y2={yMp}
        color="var(--gray-400)" strokeWidth={1} dasharray="3,2" />
      <Label x={gLeft - 8} y={yMp} fontSize={8} color="var(--gray-500)" anchor="end">
        M<S>p</S>
      </Label>

      <DashedLine x1={gLeft} y1={yMr} x2={xLr} y2={yMr}
        color="var(--gray-400)" strokeWidth={1} dasharray="3,2" />
      <Label x={gLeft - 8} y={yMr} fontSize={8} color="var(--gray-500)" anchor="end">
        0.7F<S>y</S><R>S</R><S>x</S>
      </Label>

      {/* ── Boundary verticals ── */}
      <DashedLine x1={xLp} y1={yMp} x2={xLp} y2={gBot}
        color="var(--gray-400)" strokeWidth={1} dasharray="4,3" />
      {!suppressLp && (
        <Label x={xLp} y={labelY} fontSize={8} color="var(--gray-500)">
          L<S>p</S>
        </Label>
      )}

      <DashedLine x1={xLr} y1={yMr} x2={xLr} y2={gBot}
        color="var(--gray-400)" strokeWidth={1} dasharray="4,3" />
      {!suppressLr && (
        <Label x={xLr} y={labelY} fontSize={8} color="var(--gray-500)">
          L<S>r</S>
        </Label>
      )}

      {/* ── Zone labels (inside graph area) ── */}
      <Label x={(gLeft + xLp) / 2} y={gBot - 24} fontSize={7} color="var(--gray-400)">
        Plastic
      </Label>
      <Label x={(xLp + xLr) / 2} y={gBot - 24} fontSize={7} color="var(--gray-400)">
        Inelastic
      </Label>
      <Label x={(xLr + gRight) / 2} y={gBot - 24} fontSize={7} color="var(--gray-400)">
        Elastic
      </Label>

      {/* ── Lb marker ── */}
      <DashedLine x1={xLb} y1={yLb} x2={xLb} y2={gBot}
        color="var(--ember)" strokeWidth={1.5} dasharray="4,3" />
      <circle cx={xLb} cy={yLb} r={4} fill="var(--ember)" />
      <Label x={xLb} y={labelY} fontSize={8} color="var(--ember)" bold>
        {lbNearLp
          ? <>L<S>p</S><R>{` = L`}</R><S>{`b${Lb2 !== null ? '\u2081' : ''}`}</S></>
          : lbNearLr
            ? <>L<S>r</S><R>{` = L`}</R><S>{`b${Lb2 !== null ? '\u2081' : ''}`}</S></>
            : <>L<S>{`b${Lb2 !== null ? '\u2081' : ''}`}</S></>}
      </Label>

      {/* Optional second Lb marker */}
      {Lb2 !== null && (
        <g>
          <DashedLine x1={xLb2} y1={yLb2} x2={xLb2} y2={gBot}
            color="var(--ember)" strokeWidth={1.5} dasharray="4,3" />
          <circle cx={xLb2} cy={yLb2} r={4} fill="var(--ember)" />
          <Label x={xLb2} y={labelY} fontSize={8} color="var(--ember)" bold>
            {lb2NearLp
              ? <>L<S>p</S><R>{' = L'}</R><S>b{'\u2082'}</S></>
              : lb2NearLr
                ? <>L<S>r</S><R>{' = L'}</R><S>b{'\u2082'}</S></>
                : <>L<S>b{'\u2082'}</S></>}
          </Label>
        </g>
      )}
    </svg>
  );
}

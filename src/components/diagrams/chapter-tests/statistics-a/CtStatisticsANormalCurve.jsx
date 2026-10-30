import React from 'react';

/**
 * Normal distribution with one or two specification limits and the tail
 * area(s) beyond them shaded. Drawn in standard units so the limits sit at
 * their true distance from the mean.
 * Shows: the bell curve, the mean, the limit(s) the question gives, the
 *        spread, and any tail area the question gives.
 * Does NOT show: the area or value the question asks for.
 *
 * props:
 *   lower       { z, label, area }   lower limit (area: optional tail text)
 *   upper       { z, label, area }   upper limit, or null
 *   meanLabel   text under the mean
 *   sdLabel     text for the standard deviation
 *   axisLabel   variable name under the axis
 */
export function CtStatisticsANormalCurve({
  lower = { z: -2, label: '4.9%' },
  upper = { z: 1.6, label: '5.8%' },
  meanLabel = 'μ = 5.4%',
  sdLabel = 'σ = 0.25%',
  axisLabel = 'Asphalt content',
}) {
  const W = 420;
  const zMin = -3.3;
  const zMax = 3.3;
  const left = 14;
  const right = W - 14;
  const top = 34;
  const baseY = 170;
  const peakH = baseY - top - 6;
  const X = (z) => left + ((z - zMin) / (zMax - zMin)) * (right - left);
  const Y = (z) => baseY - Math.exp(-0.5 * z * z) * peakH;

  const curve = [];
  for (let i = 0; i <= 160; i++) {
    const z = zMin + (i / 160) * (zMax - zMin);
    curve.push(`${X(z).toFixed(1)},${Y(z).toFixed(1)}`);
  }
  const tail = (a, b) => {
    const pts = [`${X(a).toFixed(1)},${baseY}`];
    for (let i = 0; i <= 60; i++) {
      const z = a + (i / 60) * (b - a);
      pts.push(`${X(z).toFixed(1)},${Y(z).toFixed(1)}`);
    }
    pts.push(`${X(b).toFixed(1)},${baseY}`);
    return pts.join(' ');
  };

  const limits = [lower, upper].filter(Boolean);
  const H = axisLabel ? 222 : 200;

  return (
    <svg viewBox={`0 0 ${W} ${H}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Normal curve, ${meanLabel}, ${sdLabel}, limits ${limits.map((l) => l.label).join(' and ')}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Shaded tails beyond the limits */}
      {lower && <polygon points={tail(zMin, lower.z)} fill="var(--ember)" fillOpacity={0.18} stroke="none" />}
      {upper && <polygon points={tail(upper.z, zMax)} fill="var(--ember)" fillOpacity={0.18} stroke="none" />}

      {/* Curve and axis */}
      <polyline points={curve.join(' ')} fill="none" stroke="var(--charcoal)" strokeWidth={2.5} />
      <line x1={left} y1={baseY} x2={right} y2={baseY} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Mean */}
      <line x1={X(0)} y1={baseY} x2={X(0)} y2={top - 4} stroke="var(--gray-400)" strokeWidth={1} strokeDasharray="4,3" />
      <text x={X(0)} y={baseY + 18} fill="var(--gray-500)" fontFamily="var(--font-body)" fontSize={12}
        textAnchor="middle" dominantBaseline="middle">{meanLabel}</text>

      {/* Spread, top right, clear of the curve */}
      <text x={right} y={top} fill="var(--gray-500)" fontFamily="var(--font-body)" fontSize={12}
        textAnchor="end" dominantBaseline="middle">{sdLabel}</text>

      {/* Limits */}
      {limits.map((l, i) => (
        <g key={i}>
          <line x1={X(l.z)} y1={baseY + 5} x2={X(l.z)} y2={Y(l.z) - 14}
            stroke="var(--ember)" strokeWidth={1.5} strokeDasharray="4,3" />
          <text x={X(l.z)} y={baseY + 18} fill="var(--ember)" fontFamily="var(--font-body)" fontWeight={600}
            fontSize={12} textAnchor="middle" dominantBaseline="middle">{l.label}</text>
        </g>
      ))}

      {/* Given tail areas, with a short leader into the shaded tail */}
      {lower && lower.area && (() => {
        const zt = (zMin + lower.z) / 2 + 0.25;
        const tx = X(zt);
        const ty = baseY - 6;
        const lx = X(lower.z) - 64;
        const ly = Y(lower.z) - 30;
        return (
          <g>
            <line x1={tx} y1={ty} x2={lx + 6} y2={ly + 8} stroke="var(--ember)" strokeWidth={1} />
            <text x={lx} y={ly} fill="var(--ember)" fontFamily="var(--font-body)" fontWeight={600} fontSize={12}
              textAnchor="middle" dominantBaseline="middle">{lower.area}</text>
          </g>
        );
      })()}

      {axisLabel && (
        <text x={(left + right) / 2} y={baseY + 42} fill="var(--gray-500)" fontFamily="var(--font-body)" fontSize={12}
          fontStyle="italic" textAnchor="middle" dominantBaseline="middle">{axisLabel}</text>
      )}
    </svg>
  );
}

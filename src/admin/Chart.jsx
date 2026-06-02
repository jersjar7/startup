import React from 'react';

/* Measure a container's pixel width so the SVG renders crisp (unscaled) text
   and hover math is direct. */
function useMeasure() {
  const ref = React.useRef(null);
  const [width, setWidth] = React.useState(0);
  React.useLayoutEffect(() => {
    const el = ref.current;
    if (!el) return undefined;
    const ro = new ResizeObserver((entries) => setWidth(entries[0].contentRect.width));
    ro.observe(el);
    return () => ro.disconnect();
  }, []);
  return [ref, width];
}

// Round a max value up to a clean axis bound (1, 2, 2.5, 5, 10 × 10ⁿ).
function niceMax(max) {
  if (max <= 0) return 1;
  const pow = 10 ** Math.floor(Math.log10(max));
  const n = max / pow;
  const step = n <= 1 ? 1 : n <= 2 ? 2 : n <= 2.5 ? 2.5 : n <= 5 ? 5 : 10;
  return step * pow;
}

const mdLabel = (ymd) => {
  const [, m, d] = ymd.split('-');
  return `${Number(m)}/${Number(d)}`;
};

const COLORS = {
  ember: '#E8683A',
  forest: '#2D7A5F',
  sunbeam: '#F5B731',
  info: '#3B82B8',
};

/* A single time-series chart — bars (per-day counts) or an area line
   (cumulative / level metrics). Self-contained SVG, on-brand, with a hover
   tooltip and a light grid. */
export function Chart({ axis, data, type = 'bar', color = 'ember', label, fmt = (v) => v }) {
  const [ref, width] = useMeasure();
  const [hover, setHover] = React.useState(null);
  const stroke = COLORS[color] || COLORS.ember;
  const H = 220;
  const pad = { top: 16, right: 14, bottom: 26, left: 44 };

  const plotW = Math.max(0, width - pad.left - pad.right);
  const plotH = H - pad.top - pad.bottom;
  const n = axis.length;
  const max = niceMax(Math.max(1, ...data));
  const x = (i) => pad.left + (n <= 1 ? plotW / 2 : (i / (n - 1)) * plotW);
  const y = (v) => pad.top + plotH - (v / max) * plotH;

  const gridLines = [0, 0.25, 0.5, 0.75, 1].map((t) => ({
    v: max * t,
    yy: pad.top + plotH - t * plotH,
  }));

  // X ticks: ~6 evenly spaced labels.
  const tickEvery = Math.max(1, Math.round(n / 6));
  const xticks = axis.map((d, i) => ({ i, d })).filter(({ i }) => i % tickEvery === 0 || i === n - 1);

  // Area/line geometry.
  const linePath = data.map((v, i) => `${i === 0 ? 'M' : 'L'} ${x(i)} ${y(v)}`).join(' ');
  const areaPath = `${linePath} L ${x(n - 1)} ${pad.top + plotH} L ${x(0)} ${pad.top + plotH} Z`;

  // Bar geometry.
  const slot = n > 0 ? plotW / n : plotW;
  const barW = Math.max(1, Math.min(slot * 0.62, 26));

  const onMove = (e) => {
    if (!width) return;
    const rect = e.currentTarget.getBoundingClientRect();
    const px = e.clientX - rect.left;
    const i = Math.max(0, Math.min(n - 1, Math.round(((px - pad.left) / plotW) * (n - 1))));
    setHover(i);
  };

  const gid = `grad-${color}`;

  return (
    <div className="chart" ref={ref}>
      {width > 0 && (
        <div className="chart-inner" style={{ position: 'relative' }}>
          <svg width={width} height={H} role="img" aria-label={label}>
            <defs>
              <linearGradient id={gid} x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor={stroke} stopOpacity="0.22" />
                <stop offset="100%" stopColor={stroke} stopOpacity="0" />
              </linearGradient>
            </defs>

            {/* grid + y labels */}
            {gridLines.map((g, idx) => (
              <g key={idx}>
                <line x1={pad.left} x2={width - pad.right} y1={g.yy} y2={g.yy}
                  stroke="#EBE4D6" strokeWidth="1" />
                <text x={pad.left - 8} y={g.yy + 4} textAnchor="end" className="chart-axis-label">
                  {fmt(Math.round(g.v * 100) / 100)}
                </text>
              </g>
            ))}

            {/* series */}
            {type === 'area' ? (
              <>
                <path d={areaPath} fill={`url(#${gid})`} />
                <path d={linePath} fill="none" stroke={stroke} strokeWidth="2.5"
                  strokeLinejoin="round" strokeLinecap="round" />
              </>
            ) : (
              data.map((v, i) => (
                <rect key={i} x={x(i) - barW / 2} y={y(v)} width={barW}
                  height={Math.max(0, pad.top + plotH - y(v))} rx="2"
                  fill={stroke} opacity={hover === null || hover === i ? 0.92 : 0.55} />
              ))
            )}

            {/* x ticks */}
            {xticks.map(({ i, d }) => (
              <text key={i} x={x(i)} y={H - 8} textAnchor="middle" className="chart-axis-label">
                {mdLabel(d)}
              </text>
            ))}

            {/* hover guide */}
            {hover !== null && (
              <>
                <line x1={x(hover)} x2={x(hover)} y1={pad.top} y2={pad.top + plotH}
                  stroke={stroke} strokeWidth="1" strokeDasharray="3 3" opacity="0.5" />
                <circle cx={x(hover)} cy={y(data[hover])} r="3.5" fill={stroke} />
              </>
            )}

            {/* hover capture */}
            <rect x={pad.left} y={pad.top} width={plotW} height={plotH} fill="transparent"
              onMouseMove={onMove} onMouseLeave={() => setHover(null)} />
          </svg>

          {hover !== null && (
            <div className="chart-tip" style={{
              left: x(hover), top: y(data[hover]),
            }}>
              <span className="chart-tip-val">{fmt(data[hover])}</span>
              <span className="chart-tip-day">{mdLabel(axis[hover])}</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

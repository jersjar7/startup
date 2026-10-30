import React from 'react';

/**
 * Shared drawing for the data tables in the statistics B figures.
 * Not registered itself: the registered figures wrap it.
 *
 * Two layouts:
 *  - 'rows': each data series is a row; the first column holds the series
 *    name (one or two lines), the other columns hold values.
 *  - 'grid': a header row plus body rows (a two-way table).
 *
 * header: array of header cells (strings, or arrays of lines) for 'grid'.
 * rows:   [{ label: ['line 1', 'line 2'], cells: [...] }]
 */
export function CtStatisticsBTableBase({ labelW = 150, cellW = 44, rows, header = null, label, rowH = 34, fontSize = 12 }) {
  const pad = 8;
  const nCells = rows[0].cells.length;
  const W = labelW + nCells * cellW;
  const headLines = header ? Math.max(...header.map((h) => (Array.isArray(h) ? h.length : 1))) : 0;
  const headH = header ? 12 + headLines * 15 : 0;
  const H = headH + rows.length * rowH;
  const cellX = (i) => pad + labelW + i * cellW + cellW / 2;
  const lines = (v) => (Array.isArray(v) ? v : [v]);

  return (
    <svg viewBox={`0 0 ${W + pad * 2} ${H + pad * 2}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={label} style={{ width: '100%', height: 'auto' }}>
      {header && (
        <>
          {header.map((h, i) => {
            const ls = lines(h);
            const x = i === 0 ? pad + 10 : cellX(i - 1);
            const top = pad + headH / 2 - ((ls.length - 1) * 15) / 2;
            return ls.map((t, k) => (
              <text key={`h${i}-${k}`} x={x} y={top + k * 15} fill="var(--charcoal)"
                fontFamily="var(--font-body)" fontWeight={600} fontSize={fontSize - 0.5}
                textAnchor={i === 0 ? 'start' : 'middle'} dominantBaseline="middle">{t}</text>
            ));
          })}
        </>
      )}

      {rows.map((r, j) => {
        const y = pad + headH + j * rowH;
        const ls = lines(r.label);
        const top = y + rowH / 2 - ((ls.length - 1) * 14) / 2;
        return (
          <g key={`r${j}`}>
            {j > 0 || header ? (
              <line x1={pad} y1={y} x2={pad + W} y2={y}
                stroke={j === 0 ? 'var(--charcoal)' : 'var(--gray-400)'} strokeWidth={j === 0 ? 1.2 : 0.7} />
            ) : null}
            {ls.map((t, k) => (
              <text key={`l${k}`} x={pad + 10} y={top + k * 14} fill="var(--charcoal)"
                fontFamily="var(--font-body)" fontWeight={600} fontSize={fontSize - 0.5}
                dominantBaseline="middle">{t}</text>
            ))}
            {r.cells.map((c, i) => (
              <text key={`c${i}`} x={cellX(i)} y={y + rowH / 2} fill="var(--charcoal)"
                fontFamily="var(--font-mono)" fontSize={fontSize} textAnchor="middle"
                dominantBaseline="middle">{c}</text>
            ))}
          </g>
        );
      })}
      <line x1={pad} y1={pad} x2={pad + W} y2={pad} stroke="var(--charcoal)" strokeWidth={1.2} />
      <line x1={pad} y1={pad + H} x2={pad + W} y2={pad + H} stroke="var(--charcoal)" strokeWidth={1.2} />
      <line x1={pad + labelW} y1={pad} x2={pad + labelW} y2={pad + H} stroke="var(--gray-400)" strokeWidth={0.7} />
    </svg>
  );
}

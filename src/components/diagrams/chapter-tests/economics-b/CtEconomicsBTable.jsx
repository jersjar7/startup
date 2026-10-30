import React from 'react';

/**
 * Shared drawing for the data tables in the economics B figures.
 * Not registered itself: the registered figures wrap it.
 *
 * cols: [{ w, header: ['line 1', 'line 2'], align: 'start' | 'middle' }]
 * rows: [['cell', 'cell', ...]]
 */
export function CtEconomicsBTable({ cols, rows, label, rowH = 26, fontSize = 12 }) {
  const pad = 8;
  const headLines = Math.max(...cols.map((c) => c.header.length));
  const headH = 12 + headLines * 15;
  const W = cols.reduce((s, c) => s + c.w, 0);
  const H = headH + rows.length * rowH;
  const xs = cols.reduce((a, c) => [...a, a[a.length - 1] + c.w], [0]);
  const textX = (i) => (cols[i].align === 'start' ? pad + xs[i] + 10 : pad + xs[i] + cols[i].w / 2);
  const anchor = (i) => (cols[i].align === 'start' ? 'start' : 'middle');

  return (
    <svg viewBox={`0 0 ${W + pad * 2} ${H + pad * 2}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={label} style={{ width: '100%', height: 'auto' }}>
      <rect x={pad} y={pad} width={W} height={headH} rx={6} fill="var(--cream-dark)" />
      <rect x={pad} y={pad + headH - 6} width={W} height={6} fill="var(--cream-dark)" />
      {cols.map((c, i) => {
        const top = pad + headH / 2 - ((c.header.length - 1) * 15) / 2;
        return c.header.map((line, k) => (
          <text key={`h${i}-${k}`} x={textX(i)} y={top + k * 15}
            fill="var(--charcoal)" fontFamily="var(--font-body)" fontWeight={600}
            fontSize={fontSize - 0.5} textAnchor={anchor(i)} dominantBaseline="middle">{line}</text>
        ));
      })}
      {rows.map((cells, j) => {
        const y = pad + headH + j * rowH;
        return (
          <g key={`r${j}`}>
            <line x1={pad} y1={y} x2={pad + W} y2={y}
              stroke={j === 0 ? 'var(--charcoal)' : 'var(--gray-400)'} strokeWidth={j === 0 ? 1.2 : 0.7} />
            {cells.map((cell, i) => (
              <text key={`c${j}-${i}`} x={textX(i)} y={y + rowH / 2}
                fill="var(--charcoal)" fontFamily={i === 0 ? 'var(--font-body)' : 'var(--font-mono)'}
                fontSize={fontSize} textAnchor={anchor(i)} dominantBaseline="middle">{cell}</text>
            ))}
          </g>
        );
      })}
      <line x1={pad} y1={pad + H} x2={pad + W} y2={pad + H} stroke="var(--charcoal)" strokeWidth={1.2} />
    </svg>
  );
}

import React from 'react';

/**
 * Shared drawing for the data tables in the materials A figures.
 * Not registered itself: the registered figures wrap it.
 *
 * cols: [{ w, header: ['line 1', 'line 2'], align: 'start' | 'middle' }]
 * rows: [['cell', 'cell', ...]]; a row object { cells, bold } is also accepted.
 */
export function CtMaterialsATable({ cols, rows, label, rowH = 26, fontSize = 12 }) {
  const pad = 8;
  const headLines = Math.max(...cols.map((c) => c.header.length));
  const headH = 12 + headLines * 15;
  const W = cols.reduce((s, c) => s + c.w, 0);
  const H = headH + rows.length * rowH;
  const xs = cols.reduce((a, c) => [...a, a[a.length - 1] + c.w], [0]);

  const textX = (i) => {
    const c = cols[i];
    if (c.align === 'start') return pad + xs[i] + 10;
    return pad + xs[i] + c.w / 2;
  };

  return (
    <svg viewBox={`0 0 ${W + pad * 2} ${H + pad * 2}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={label} style={{ width: '100%', height: 'auto' }}>
      {/* Header band */}
      <rect x={pad} y={pad} width={W} height={headH} rx={6}
        fill="var(--cream-dark)" />
      <rect x={pad} y={pad + headH - 6} width={W} height={6} fill="var(--cream-dark)" />

      {cols.map((c, i) => {
        const n = c.header.length;
        const top = pad + headH / 2 - ((n - 1) * 15) / 2;
        return c.header.map((line, k) => (
          <text key={`h${i}-${k}`} x={textX(i)} y={top + k * 15}
            fill="var(--charcoal)" fontFamily="var(--font-body)" fontWeight={600}
            fontSize={fontSize - 0.5} textAnchor={c.align === 'start' ? 'start' : 'middle'}
            dominantBaseline="middle">{line}</text>
        ));
      })}

      {/* Body rows */}
      {rows.map((r, j) => {
        const cells = Array.isArray(r) ? r : r.cells;
        const bold = !Array.isArray(r) && r.bold;
        const y = pad + headH + j * rowH;
        return (
          <g key={`r${j}`}>
            <line x1={pad} y1={y} x2={pad + W} y2={y}
              stroke={j === 0 || bold ? 'var(--charcoal)' : 'var(--gray-400)'}
              strokeWidth={j === 0 || bold ? 1.2 : 0.7} />
            {cells.map((cell, i) => (
              <text key={`c${j}-${i}`} x={textX(i)} y={y + rowH / 2}
                fill="var(--charcoal)"
                fontFamily={i === 0 ? 'var(--font-body)' : 'var(--font-mono)'}
                fontWeight={bold ? 600 : 400}
                fontSize={fontSize} textAnchor={cols[i].align === 'start' ? 'start' : 'middle'}
                dominantBaseline="middle">{cell}</text>
            ))}
          </g>
        );
      })}
      <line x1={pad} y1={pad + H} x2={pad + W} y2={pad + H} stroke="var(--charcoal)" strokeWidth={1.2} />
    </svg>
  );
}

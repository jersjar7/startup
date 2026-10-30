import React from 'react';

/**
 * A small data table, drawn the way an exam shows lab or field results.
 * Shows: column headings (with units) and the rows the question gives.
 * Does NOT show: any computed statistic (that is the answer).
 *
 * props:
 *   headers  [string, ...]            column headings, units included
 *   rows     [[string, ...], ...]     cell text, one array per row
 *   widths   [number, ...]            column widths in viewBox units
 */
export function CtStatisticsADataTable({
  headers = ['Source', 'Volume (yd³)', 'Moisture content (%)'],
  rows = [['A', '1,500', '12'], ['B', '2,500', '17'], ['C', '1,000', '27']],
  widths = [90, 130, 170],
}) {
  const m = 8;
  const headH = 32;
  const rowH = 28;
  const W = widths.reduce((a, b) => a + b, 0);
  const H = headH + rows.length * rowH;
  const xs = widths.reduce((acc, w, i) => [...acc, acc[i] + w], [m]);

  return (
    <svg viewBox={`0 0 ${W + 2 * m} ${H + 2 * m}`} xmlns="http://www.w3.org/2000/svg"
      role="img" aria-label={`Table: ${headers.join(', ')}`}
      style={{ width: '100%', height: 'auto' }}>

      {/* Top and bottom rules, heavier under the heading */}
      <line x1={m} y1={m} x2={m + W} y2={m} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={m} y1={m + headH} x2={m + W} y2={m + headH} stroke="var(--charcoal)" strokeWidth={1.5} />
      <line x1={m} y1={m + H} x2={m + W} y2={m + H} stroke="var(--charcoal)" strokeWidth={1.5} />

      {/* Light rules between rows */}
      {rows.slice(0, -1).map((_, i) => (
        <line key={`r${i}`} x1={m} y1={m + headH + (i + 1) * rowH} x2={m + W} y2={m + headH + (i + 1) * rowH}
          stroke="var(--gray-400)" strokeWidth={0.75} />
      ))}

      {/* Headings */}
      {headers.map((h, j) => (
        <text key={`h${j}`} x={(xs[j] + xs[j + 1]) / 2} y={m + headH / 2}
          fill="var(--charcoal)" fontFamily="var(--font-body)" fontWeight={600} fontSize={12}
          textAnchor="middle" dominantBaseline="middle">
          {h}
        </text>
      ))}

      {/* Cells */}
      {rows.map((r, i) => r.map((c, j) => (
        <text key={`c${i}-${j}`} x={(xs[j] + xs[j + 1]) / 2} y={m + headH + i * rowH + rowH / 2}
          fill="var(--charcoal)" fontFamily={j === 0 ? 'var(--font-body)' : 'var(--font-mono)'} fontSize={12}
          textAnchor="middle" dominantBaseline="middle">
          {c}
        </text>
      )))}
    </svg>
  );
}

import React from 'react';
import { CtStatisticsBTableBase } from './CtStatisticsBTableBase';

/**
 * Two-way (contingency) table of counts. No totals are drawn, so the
 * student has to form the row and column sums.
 */
export function CtStatisticsBTwoWayTable({ corner, colHeads, rowHeads, counts, labelW = 150, cellW = 110 }) {
  return (
    <CtStatisticsBTableBase
      label="Two-way table of counts"
      labelW={labelW}
      cellW={cellW}
      header={[corner, ...colHeads]}
      rows={rowHeads.map((h, i) => ({ label: h, cells: counts[i] }))}
    />
  );
}

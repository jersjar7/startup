import React from 'react';
import { CtStatisticsBTableBase } from './CtStatisticsBTableBase';

/**
 * Two data series laid out as rows (x values on top, y values below).
 * Used for a frequency table and for paired regression data.
 * Shows only the data the question gives.
 */
export function CtStatisticsBSeriesTable({ xLabel, xValues, yLabel, yValues, labelW = 150, cellW = 44 }) {
  return (
    <CtStatisticsBTableBase
      label={`${xLabel.join(' ')} and ${yLabel.join(' ')}`}
      labelW={labelW}
      cellW={cellW}
      rows={[
        { label: xLabel, cells: xValues },
        { label: yLabel, cells: yValues },
      ]}
    />
  );
}

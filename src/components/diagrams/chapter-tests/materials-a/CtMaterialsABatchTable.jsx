import React from 'react';
import { CtMaterialsATable } from './CtMaterialsATable';

/**
 * Concrete batch weights on an SSD basis with the aggregate absorption and
 * stockpile moisture. Shows the givens only; never the corrected water.
 */
export function CtMaterialsABatchTable({
  cement = 600, water = 285,
  coarse = { ssd: 1780, absorption: 0.8, moisture: 2.4 },
  fine = { ssd: 1240, absorption: 1.5, moisture: 0.5 },
}) {
  const n = (v) => v.toLocaleString('en-US');
  const p = (v) => v.toFixed(1);
  return (
    <CtMaterialsATable
      label="Batch weights per cubic yard with aggregate absorption and stockpile moisture"
      cols={[
        { w: 140, header: ['Material'], align: 'start' },
        { w: 108, header: ['SSD batch', 'weight (lb/yd³)'] },
        { w: 92, header: ['Absorption', '(%)'] },
        { w: 108, header: ['Stockpile', 'moisture (%)'] },
      ]}
      rows={[
        ['Cement', n(cement), '–', '–'],
        ['Mixing water', n(water), '–', '–'],
        ['Coarse aggregate', n(coarse.ssd), p(coarse.absorption), p(coarse.moisture)],
        ['Fine aggregate', n(fine.ssd), p(fine.absorption), p(fine.moisture)],
      ]}
    />
  );
}

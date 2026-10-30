import React from 'react';
import { CtMaterialsATable } from './CtMaterialsATable';

/**
 * Sieve analysis of a sand: mass retained on each sieve (individual, not
 * cumulative). Shows the givens only; never cumulative percentages or FM.
 */
export function CtMaterialsASieveTable({
  sieves = [
    ['3/8 in.', 0], ['No. 4', 15], ['No. 8', 60], ['No. 16', 85],
    ['No. 30', 110], ['No. 50', 120], ['No. 100', 80], ['Pan', 30],
  ],
}) {
  const total = sieves.reduce((s, [, m]) => s + m, 0);
  return (
    <CtMaterialsATable
      label="Sieve analysis: mass retained on each sieve"
      rowH={24}
      cols={[
        { w: 170, header: ['Sieve'], align: 'start' },
        { w: 174, header: ['Mass retained', 'on sieve (g)'] },
      ]}
      rows={[
        ...sieves.map(([s, m]) => [s, String(m)]),
        { cells: ['Total', String(total)], bold: true },
      ]}
    />
  );
}

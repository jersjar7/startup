import React from 'react';
import { CtEconomicsBTable } from './CtEconomicsBTable';

/**
 * Flood wall alternatives: first cost, annual O&M and the expected annual
 * flood damage left with each in place. Givens only; no B/C ratios.
 */
export function CtEconomicsBFloodWalls({ walls = [
  { name: 'Low wall', first: 2000000, om: 20000, damage: 180000 },
  { name: 'Medium wall', first: 3200000, om: 30000, damage: 80000 },
  { name: 'High wall', first: 4600000, om: 40000, damage: 40000 },
], noneDamage = 400000 }) {
  const n = (v) => v.toLocaleString('en-US');
  return (
    <CtEconomicsBTable
      label="Flood wall alternatives with first cost, annual operation and maintenance, and expected annual damage"
      cols={[
        { w: 112, header: ['Alternative'], align: 'start' },
        { w: 104, header: ['First cost', '(dollars)'] },
        { w: 104, header: ['Annual O&M', '(dollars/yr)'] },
        { w: 124, header: ['Expected damage', '(dollars/yr)'] },
      ]}
      rows={[
        ['No wall', '0', '0', n(noneDamage)],
        ...walls.map((w) => [w.name, n(w.first), n(w.om), n(w.damage)]),
      ]}
    />
  );
}

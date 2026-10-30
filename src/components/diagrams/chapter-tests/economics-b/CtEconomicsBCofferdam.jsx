import React from 'react';
import { CtEconomicsBTable } from './CtEconomicsBTable';

/**
 * Flood outcomes for one construction season: the probability of each river
 * level and the loss if each cofferdam is overtopped. Givens only.
 */
export function CtEconomicsBCofferdam({ lowFt = 8, highFt = 12, outcomes = [
  { p: 0.80, low: 0, high: 0 },
  { p: 0.15, low: 200000, high: 0 },
  { p: 0.05, low: 200000, high: 250000 },
] }) {
  const n = (v) => v.toLocaleString('en-US');
  const levels = [`Below ${lowFt} ft`, `${lowFt} to ${highFt} ft`, `Above ${highFt} ft`];
  return (
    <CtEconomicsBTable
      label="Flood level probabilities and overtopping losses for a low and a high cofferdam"
      cols={[
        { w: 116, header: ['Peak river', 'stage'], align: 'start' },
        { w: 92, header: ['Probability'] },
        { w: 118, header: ['Loss with', `${lowFt} ft cofferdam`, '(dollars)'] },
        { w: 122, header: ['Loss with', `${highFt} ft cofferdam`, '(dollars)'] },
      ]}
      rows={outcomes.map((o, k) => [levels[k], o.p.toFixed(2), n(o.low), n(o.high)])}
    />
  );
}

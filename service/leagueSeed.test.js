import { describe, it, expect } from 'vitest';
const { seedTiers } = require('./leagues/seed.js');

// Starting tiers for the first league week (ADR 0037, decision 5).

describe('seeding starting tiers', () => {
  it('splits students into five equal bands by their recent XP', () => {
    const entries = Array.from({ length: 10 }, (_, i) => ({ email: `s${i}`, xp: (i + 1) * 100 }));
    const { tiers, cutoffs } = seedTiers(entries);
    expect(tiers.get('s0')).toBe('copper');
    expect(tiers.get('s1')).toBe('copper');
    expect(tiers.get('s4')).toBe('silver');
    expect(tiers.get('s9')).toBe('platinum');
    expect(cutoffs).toEqual({ copper: 100, bronze: 300, silver: 500, gold: 700, platinum: 900 });
  });

  it('leaves students with no recent XP unseeded', () => {
    const { tiers } = seedTiers([{ email: 'idle', xp: 0 }, { email: 'busy', xp: 40 }]);
    expect(tiers.has('idle')).toBe(false);
  });

  it('one student goes to the bottom band, not the top', () => {
    expect(seedTiers([{ email: 'solo', xp: 9000 }]).tiers.get('solo')).toBe('copper');
  });
});

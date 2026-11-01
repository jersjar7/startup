import { describe, it, expect } from 'vitest';
const { seedTiers } = require('./leagues/seed.js');

// Starting tiers for the first league week (ADR 0037, decision 5).

describe('seeding starting tiers', () => {
  it('splits students into five equal bands by their recent XP', () => {
    const entries = Array.from({ length: 10 }, (_, i) => ({ email: `s${i}`, xp: (i + 1) * 100 }));
    const { tiers, cutoffs } = seedTiers(entries);
    expect(tiers.get('s0')).toBe('timber');
    expect(tiers.get('s1')).toBe('timber');
    expect(tiers.get('s4')).toBe('concrete');
    expect(tiers.get('s9')).toBe('titanium');
    expect(cutoffs).toEqual({ timber: 100, masonry: 300, concrete: 500, steel: 700, titanium: 900 });
  });

  it('leaves students with no recent XP unseeded', () => {
    const { tiers } = seedTiers([{ email: 'idle', xp: 0 }, { email: 'busy', xp: 40 }]);
    expect(tiers.has('idle')).toBe(false);
  });

  it('one student goes to the bottom band, not the top', () => {
    expect(seedTiers([{ email: 'solo', xp: 9000 }]).tiers.get('solo')).toBe('timber');
  });
});

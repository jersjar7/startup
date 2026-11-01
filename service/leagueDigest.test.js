import { describe, it, expect } from 'vitest';
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const { leagueLine } = require('./email.js');
const { lastWeekLeagueResult } = require('./mailer-jobs.js');
const { leagueStandingCollection } = require('./db/connection.js');

// The weekly digest's league sentence (ADR 0037).

describe('the league line', () => {
  const base = { place: 2, size: 15, tierName: 'Bronze', newTierName: 'Silver' };

  it('says when they moved up', () => {
    expect(leagueLine({ ...base, moved: 'up' })).toBe('You finished 2nd of 15 in your Bronze league and moved up to Silver.');
  });

  it('says where they are after moving down, without scolding', () => {
    expect(leagueLine({ ...base, place: 13, moved: 'down', tierName: 'Silver', newTierName: 'Bronze' }))
      .toBe('You finished 13th of 15 in your Silver league. This week you are in Bronze.');
  });

  it('says they stay', () => {
    expect(leagueLine({ ...base, place: 11, moved: 'stayed' })).toBe('You finished 11th of 15 in your Bronze league and stay in Bronze this week.');
  });

  it('is left out when they were not in a league', () => {
    expect(leagueLine(null)).toBeNull();
  });

  it('writes ordinals the way people say them', () => {
    expect(leagueLine({ ...base, place: 1, moved: 'up' })).toContain('1st');
    expect(leagueLine({ ...base, place: 3, moved: 'up' })).toContain('3rd');
    expect(leagueLine({ ...base, place: 12, moved: 'stayed' })).toContain('12th');
  });
});

describe('last week\'s result for the digest', () => {
  it('finds the week that just ended', async () => {
    leagueStandingCollection.findOne = async () => ({
      history: [
        { weekId: '2026-W44', tier: 'copper', newTier: 'bronze', place: 3, size: 15, moved: 'up' },
        { weekId: '2026-W45', tier: 'bronze', newTier: 'bronze', place: 7, size: 15, moved: 'stayed' },
      ],
    });
    const r = await lastWeekLeagueResult('a@x.com', new Date('2026-11-09T15:00:00Z')); // Monday of W46
    expect(r).toMatchObject({ weekId: '2026-W45', place: 7, tierName: 'Bronze', newTierName: 'Bronze' });
  });

  it('is null when they sat last week out', async () => {
    leagueStandingCollection.findOne = async () => ({ history: [{ weekId: '2026-W40', tier: 'copper', newTier: 'copper' }] });
    expect(await lastWeekLeagueResult('a@x.com', new Date('2026-11-09T15:00:00Z'))).toBeNull();
  });
});

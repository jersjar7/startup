import { describe, it, expect } from 'vitest';
const { userCollection, userStatsCollection } = require('./db/connection.js');
const { getLeagueMemberInfo } = require('./db/leagues.js');

// A league row's name fields, this week's XP, and the days studied this week
// (ADR 0038). Days from an earlier week, and XP cached for an earlier week,
// count for nothing.

const rows = (list) => ({ toArray: async () => list });

describe('a group\'s member info', () => {
  it('counts only this week\'s study days and XP', async () => {
    userCollection.find = () => rows([{ email: 'a@x.com', firstName: 'Ana' }]);
    userStatsCollection.find = () => rows([
      { email: 'a@x.com', weekId: '2026-W45', weeklyXp: 400, studyDays: ['2026-10-31', '2026-11-01', '2026-11-03', '2026-11-04'] },
      { email: 'b@x.com', weekId: '2026-W44', weeklyXp: 900, studyDays: ['2026-10-30'] },
    ]);
    const info = await getLeagueMemberInfo(['a@x.com', 'b@x.com', 'c@x.com'], '2026-W45');
    expect(info).toEqual([
      { email: 'a@x.com', firstName: 'Ana', weeklyXp: 400, days: 3 },
      { email: 'b@x.com', weeklyXp: 0, days: 0 },
      { email: 'c@x.com', weeklyXp: 0, days: 0 },
    ]);
  });
});

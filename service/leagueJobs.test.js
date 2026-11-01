import { describe, it, expect, afterEach } from 'vitest';
const DB = require('./database.js');
const { tick, mayClose } = require('./leagueJobs.js');

// When the league week closes (ADR 0037): 3 am Eastern on Sunday, so a
// west-coast Saturday evening still counts.

afterEach(() => { delete process.env.LEAGUES_DISABLED; });

describe('when the week may close', () => {
  it('not at 2:30 am Eastern on Sunday', () => {
    expect(mayClose(new Date('2026-11-08T07:30:00Z'))).toBe(false);
  });
  it('from 3 am Eastern on Sunday', () => {
    expect(mayClose(new Date('2026-11-08T08:05:00Z'))).toBe(true);
  });
  it('any later day, to catch up after downtime', () => {
    expect(mayClose(new Date('2026-11-10T15:00:00Z'))).toBe(true);
  });
});

describe('the job', () => {
  it('does nothing while leagues are switched off', async () => {
    process.env.LEAGUES_DISABLED = '1';
    let asked = false;
    DB.listOpenLeagueGroupsBefore = async () => { asked = true; return []; };
    expect(await tick(new Date('2026-11-08T09:00:00Z'))).toBeNull();
    expect(asked).toBe(false);
  });

  it('closes what ended when it runs', async () => {
    DB.listOpenLeagueGroupsBefore = async (weekId) => { expect(weekId).toBe('2026-W46'); return []; };
    expect(await tick(new Date('2026-11-08T09:00:00Z'))).toMatchObject({ groups: 0 });
  });
});

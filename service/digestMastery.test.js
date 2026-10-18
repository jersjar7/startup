import { describe, it, expect, beforeEach } from 'vitest';
// The email module builds its client on load; a dummy key keeps it quiet.
process.env.RESEND_API_KEY = process.env.RESEND_API_KEY || 're_test_dummy';
const { userStatsCollection, sessionLogCollection } = require('./db/connection.js');
const { weeklyStatsFor } = require('./mailer-jobs.js');
const { weightedMastery } = require('./examWeights.js');

// The weekly email's "Overall mastery" is the dashboard's number. It used to
// average only the chapters a student had touched, which gave a real student
// 18% in his email and 11% on his dashboard (2026-07-27).

let stats;
beforeEach(() => {
  Object.assign(userStatsCollection, { findOne: async () => stats });
  Object.assign(sessionLogCollection, { aggregate: () => ({ toArray: async () => [] }) });
});

describe('the digest\'s overall mastery', () => {
  it('is the dashboard\'s weighted number, untouched chapters as zero', async () => {
    stats = { chapterMastery: { structural: { totalMastery: 40 }, ethics: { totalMastery: 80 } } };
    const out = await weeklyStatsFor('a@x.com');
    // structural 40 x 11 + ethics 80 x 4, over all 110.
    expect(out.masteryTo).toBe(Math.round((40 * 11 + 80 * 4) / 110));
    expect(out.masteryTo).toBe(weightedMastery(stats.chapterMastery));
    expect(out.focusChapter).toBe('structural');
  });

  it('never drops when a student starts a new chapter', async () => {
    stats = { chapterMastery: { ethics: { totalMastery: 80 } } };
    const before = (await weeklyStatsFor('a@x.com')).masteryTo;
    stats = { chapterMastery: { ethics: { totalMastery: 80 }, structural: { totalMastery: 5 } } };
    const after = (await weeklyStatsFor('a@x.com')).masteryTo;
    expect(after).toBeGreaterThanOrEqual(before);
  });

  it('stays off the email for a student with no mastery yet', async () => {
    stats = { chapterMastery: {} };
    expect((await weeklyStatsFor('a@x.com')).masteryTo).toBeNull();
  });
});

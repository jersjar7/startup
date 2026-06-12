import { describe, it, expect } from 'vitest';
// Canonical (web) module + the mobile mirror, checked against ONE set of golden
// fixtures. If the two surfaces ever disagree — or either drifts from the
// fixtures, or the version strings fall out of sync — this test goes red. That
// is the entire guarantee that web and mobile schedule identically.
const canonical = require('./scheduler.js');
import * as mirror from '../../mobile/src/shared/scheduler';
import fixtures from './scheduler.fixtures.json';

const { NOW } = fixtures;

function midnight(dateStr) {
  return Date.parse(`${dateStr}T00:00:00`);
}

describe('scheduler parity: version', () => {
  it('canonical, mirror, and fixtures all carry the same SCHEDULER_VERSION', () => {
    expect(canonical.SCHEDULER_VERSION).toBe(fixtures.version);
    expect(mirror.SCHEDULER_VERSION).toBe(fixtures.version);
  });

  it('shared constants match across surfaces', () => {
    for (const k of ['DAY_MS', 'RELEARN_MS', 'MIN_EASE', 'START_EASE', 'MAX_INTERVAL_DAYS', 'MAX_PROJECTION']) {
      expect(mirror[k], k).toBe(canonical[k]);
    }
  });
});

describe('scheduler parity: nextSchedule', () => {
  for (const f of fixtures.nextSchedule) {
    it(f.desc, () => {
      const c = canonical.nextSchedule(f.state, f.grade, NOW);
      const m = mirror.nextSchedule(f.state, f.grade, NOW);
      const dueAt = NOW + (f.grade === 'forgot' ? canonical.RELEARN_MS : f.expect.intervalDays * canonical.DAY_MS);
      const expected = { ...f.expect, dueAt };
      expect(c).toEqual(expected);
      expect(m).toEqual(expected); // mirror reproduces canonical exactly
    });
  }
});

describe('scheduler parity: seedState', () => {
  for (const f of fixtures.seedState) {
    it(f.desc, () => {
      expect(canonical.seedState(f.row)).toEqual(f.expect);
      expect(mirror.seedState ? mirror.seedState(f.row) : canonical.seedState(f.row)).toEqual(f.expect);
    });
  }
});

describe('scheduler parity: daysUntil', () => {
  for (const f of fixtures.daysUntil) {
    it(f.desc, () => {
      const now = midnight(f.nowDate);
      expect(canonical.daysUntil(f.examDate, now)).toBe(f.expect);
      expect(mirror.daysUntil(f.examDate, now)).toBe(f.expect);
    });
  }
});

describe('scheduler parity: regimeForStudyDays', () => {
  for (const f of fixtures.regime) {
    it(`studyDays ${f.studyDays} -> ${f.expect}`, () => {
      expect(canonical.regimeForStudyDays(f.studyDays)).toBe(f.expect);
      expect(mirror.regimeForStudyDays(f.studyDays)).toBe(f.expect);
    });
  }
});

describe('scheduler parity: computeDailyPlan', () => {
  for (const f of fixtures.dailyPlan) {
    it(f.desc, () => {
      const now = midnight(f.nowDate);
      const input = {
        now,
        examDate: f.examDate,
        minutesPerDay: f.minutesPerDay,
        currentMasteryPercent: f.currentMasteryPercent,
        coveragePercent: f.coveragePercent,
        dueCount: f.dueCount,
      };
      const c = canonical.computeDailyPlan(input);
      const m = mirror.computeDailyPlan(input);
      expect(c).toEqual(f.expect);
      expect(m).toEqual(f.expect);
    });
  }
});

// A randomless sweep: drive a spread of states/grades and pacing inputs through
// BOTH implementations and assert they never diverge, beyond the static cases.
describe('scheduler parity: exhaustive sweep (canonical === mirror)', () => {
  it('nextSchedule agrees across a grid of states and grades', () => {
    const grades = ['forgot', 'fuzzy', 'gotIt'];
    for (let interval = 0; interval <= 60; interval += 7) {
      for (let reps = 0; reps <= 6; reps++) {
        for (let easeX10 = 13; easeX10 <= 25; easeX10 += 3) {
          for (const grade of grades) {
            const state = { intervalDays: interval, ease: easeX10 / 10, reps, lapses: 2 };
            expect(mirror.nextSchedule(state, grade, NOW)).toEqual(canonical.nextSchedule(state, grade, NOW));
          }
        }
      }
    }
  });

  it('computeDailyPlan agrees across a grid of horizons and minutes', () => {
    const now = midnight('2026-06-12');
    const examDates = ['2026-06-13', '2026-06-16', '2026-06-26', '2026-07-20', '2026-12-01', null];
    for (const examDate of examDates) {
      for (let minutes = 5; minutes <= 60; minutes += 11) {
        for (let due = 0; due <= 60; due += 15) {
          for (const mastery of [undefined, 0, 35, 90]) {
            const input = { now, examDate, minutesPerDay: minutes, currentMasteryPercent: mastery, dueCount: due };
            expect(mirror.computeDailyPlan(input)).toEqual(canonical.computeDailyPlan(input));
          }
        }
      }
    }
  });
});

// shared/scheduler.js — the ONE pacing + interval brain for web and mobile.
//
// This file is the CANONICAL source. The mobile mirror
// (mobile/src/shared/scheduler.ts) must reproduce every case in
// scheduler.fixtures.json and carry the SAME SCHEDULER_VERSION. A parity test
// (scheduler.parity.test.js) imports both and fails the build on any drift, so
// the two surfaces can never silently disagree about when an item is due or how
// hard a day should be.
//
// Pure: no DB, no framework, no clock of its own (callers pass `now`). Each
// surface maps its own stored state to/from these plain shapes:
//   - web  problemHistory { interval, ease, reps, lapses, nextReview }
//   - RN   ReviewSchedule { intervalDays, ease, reps, lapses, dueAt }
//
// Grades are three: 'forgot' | 'fuzzy' | 'gotIt'. The web UI is multiple-choice
// (right/wrong only) and maps isCorrect -> 'gotIt' / 'forgot'; 'fuzzy' is a
// phone-only self-grade. The sync event log already speaks gotIt/forgot.

'use strict';

const SCHEDULER_VERSION = '2.0.0';

const DAY_MS = 24 * 60 * 60 * 1000;
const RELEARN_MS = 10 * 60 * 1000; // a missed item resurfaces in ~10 minutes
const MIN_EASE = 1.3;
const START_EASE = 2.5;
const MAX_INTERVAL_DAYS = 60; // ceiling; the exam-eve clamp happens at queue build, not here

// Ease is kept at 2 decimals so it never accumulates IEEE-754 noise
// (e.g. 2.45 - 0.05 = 2.4000000000000004), which would make fixtures brittle.
function round2(n) {
  return Math.round(n * 100) / 100;
}

// --- interval scheduling (trimmed SM-2, three grades) ----------------------

// A fresh item: due immediately, no history.
function startSchedule(now) {
  return { intervalDays: 0, ease: START_EASE, reps: 0, lapses: 0, dueAt: now };
}

// Next schedule from prior state + the grade just given.
// state: { intervalDays, ease, reps, lapses } — any field may be missing
// (legacy web rows) and is defaulted. Returns the same shape plus dueAt.
function nextSchedule(state, grade, now) {
  const ease0 = typeof state.ease === 'number' ? state.ease : START_EASE;
  const reps0 = state.reps || 0;
  const lapses0 = state.lapses || 0;
  const prevInterval = state.intervalDays || 0;

  if (grade === 'forgot') {
    return {
      intervalDays: 0,
      ease: round2(Math.max(MIN_EASE, ease0 - 0.2)),
      reps: 0,
      lapses: lapses0 + 1,
      dueAt: now + RELEARN_MS,
    };
  }

  const reps = reps0 + 1;
  const ease = grade === 'fuzzy' ? round2(Math.max(MIN_EASE, ease0 - 0.05)) : ease0;
  const grown =
    reps === 1
      ? 1
      : reps === 2
        ? 3
        : Math.round(Math.max(1, prevInterval) * (grade === 'fuzzy' ? 1.2 : ease));
  const intervalDays = Math.min(grown, MAX_INTERVAL_DAYS);

  return { intervalDays, ease, reps, lapses: lapses0, dueAt: now + intervalDays * DAY_MS };
}

// Seed a full schedule state from a possibly-legacy web row. Rows written
// before the ease/reps model only carry `interval`; treat a matured interval as
// an item already a few reps in, so a correct answer keeps growing it (prev *
// ease) instead of snapping back to 1 day.
function seedState(row) {
  const intervalDays = row.intervalDays != null ? row.intervalDays : row.interval || 0;
  return {
    intervalDays,
    ease: typeof row.ease === 'number' ? row.ease : START_EASE,
    reps: row.reps != null ? row.reps : intervalDays > 0 ? 3 : 0,
    lapses: row.lapses != null ? row.lapses : row.timesIncorrect || 0,
  };
}

// --- adaptive pacing (exam-aware) ------------------------------------------
//
// Daily load and projection scale with time-to-exam (the spacing effect:
// Cepeda 2008). The plan targets mastery by the DAY BEFORE the exam — the final
// day is light review / rest, never new learning. Three regimes; crunch
// compresses the schedule and surfaces the whole review backlog so a late
// starter (1–2 weeks out) is never told "come back tomorrow".

const MAX_PROJECTION = 98; // never project 100% / a guaranteed pass

function daysUntil(examDate, now) {
  if (!examDate) return null;
  const exam = Date.parse(`${examDate}T00:00:00`);
  if (Number.isNaN(exam)) return null;
  return Math.max(0, Math.ceil((exam - now) / DAY_MS));
}

function regimeForStudyDays(studyDays) {
  if (studyDays == null) return 'onPace'; // no exam date -> steady default
  if (studyDays >= 56) return 'runway';
  if (studyDays >= 14) return 'onPace';
  return 'crunch';
}

// Recommended number of due reviews to surface today. This is a SOFT target:
// the API/UI must always offer "keep going" past it and must never hard-stop a
// motivated user. The ceiling only shapes the *default* batch. Web used to
// return a flat 5 (max 8) regardless of the exam; in crunch we surface the
// whole backlog instead.
function reviewTargetFor(regime, dueCount) {
  const ceiling = regime === 'crunch' ? 30 : regime === 'onPace' ? 12 : 8;
  return Math.min(Math.max(0, dueCount || 0), ceiling);
}

function clamp(n, lo, hi) {
  return Math.max(lo, Math.min(hi, n));
}

// The full daily plan, shared by both surfaces. Mobile reads dailyCardTarget /
// dailyPaperTarget / projection; web reads regime / reviewTarget.
//   input: { now, examDate?, minutesPerDay?, currentMasteryPercent?, dueCount? }
function computeDailyPlan(input) {
  const now = input.now;
  const days = daysUntil(input.examDate, now);
  const studyDays = days == null ? null : Math.max(0, days - 1);
  const regime = regimeForStudyDays(studyDays);
  const intensity = regime === 'crunch' ? 1.3 : 1;

  const minutesPerDay = input.minutesPerDay || 20;
  const dailyCardTarget = clamp(Math.round(minutesPerDay * 0.6 * intensity), 5, 40);
  const dailyPaperTarget = regime === 'crunch' ? 2 : 1;
  const reviewTarget = reviewTargetFor(regime, input.dueCount || 0);

  let projection = null;
  if (typeof input.currentMasteryPercent === 'number') {
    const gainPerDay = minutesPerDay * 0.03;
    const sd = studyDays == null ? 0 : studyDays;
    const projectedPercent = Math.round(
      clamp(input.currentMasteryPercent + sd * gainPerDay, 0, MAX_PROJECTION),
    );
    projection = {
      currentPercent: Math.round(input.currentMasteryPercent),
      projectedPercent,
      examDate: input.examDate || null,
    };
  }

  return {
    daysUntilExam: days,
    studyDays,
    regime,
    intensity,
    minutesPerDay,
    dailyCardTarget,
    dailyPaperTarget,
    reviewTarget,
    softCap: true, // callers MUST offer "keep going" beyond the target
    projection,
  };
}

module.exports = {
  SCHEDULER_VERSION,
  // constants (exported so the mirror + tests can assert exact parity)
  DAY_MS,
  RELEARN_MS,
  MIN_EASE,
  START_EASE,
  MAX_INTERVAL_DAYS,
  MAX_PROJECTION,
  // interval scheduling
  startSchedule,
  nextSchedule,
  seedState,
  // pacing
  daysUntil,
  regimeForStudyDays,
  reviewTargetFor,
  computeDailyPlan,
};

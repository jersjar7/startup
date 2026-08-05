// Who is shown the exam-simulation pitch.
//
// Extracted and tested because this one predicate decides the reach of the only
// paid product. The previous gate (exam date AND 2-30 days out) reached 15 of
// 270 users, discarding 96% before the banner was even considered, while
// converting 60% of the few who saw it. That is a distribution problem, not a
// persuasion problem.
//
// Two independent routes in:
//   1. Any FUTURE exam date, with no upper bound. The old 30-day ceiling
//      excluded 35 users purely for planning ahead.
//   2. Enough problems answered, for studiers who never set a date and are
//      otherwise invisible to a date-gated pitch.
//
// The lower bound stays: selling a 5h20m simulation to somebody sitting the
// exam tomorrow is not a real offer.

export const MIN_DAYS = 2;

// Evidence-based but deliberately loose. Of the first 8 buyers, 7 had answered
// 45+ problems before purchasing, but tuning to 45 would be overfitting 8 data
// points. Only 1 of 8 was below 25, so 25 costs almost nothing in precision and
// roughly doubles reach (34 users vs 18 at the time of writing).
export const PROBLEMS_THRESHOLD = 25;

// Whole days until the exam, or null when there is no usable date.
export function daysUntil(examDate, now = Date.now()) {
  if (!examDate) return null;
  const t = new Date(`${examDate}T00:00:00`).getTime();
  if (Number.isNaN(t)) return null;
  return Math.ceil((t - now) / 86400000);
}

export function shouldShowSimPitch({ daysLeft, problemsAnswered = 0 } = {}) {
  const dated = daysLeft != null && daysLeft >= MIN_DAYS;
  const earned = problemsAnswered >= PROBLEMS_THRESHOLD;
  return dated || earned;
}

// Which copy to use. A user with no date, or a stale one, has no countdown to
// lean on, so they must NOT get the time-based copy — that path renders the
// literal string "Just null days to go."
export function usesCountdownCopy(daysLeft) {
  return daysLeft != null && daysLeft >= MIN_DAYS;
}

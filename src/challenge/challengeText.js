// The words the challenge card and page use, kept apart from the markup so
// they are tested on their own (ADR 0027).

const DAY_MS = 86400000;

/** Whole days from a local day to the challenge's last day, counting today. */
export function daysLeft(today, end) {
  const a = Date.parse(`${today}T00:00:00Z`);
  const b = Date.parse(`${end}T00:00:00Z`);
  if (Number.isNaN(a) || Number.isNaN(b)) return 0;
  return Math.max(0, Math.round((b - a) / DAY_MS) + 1);
}

/** "3 of 7 lessons, 2 at the desk" */
export function progressLine(progress) {
  if (!progress) return '';
  const desk = progress.lessons.filter((l) => l.cleared === 'desk').length;
  const base = `${progress.cleared} of ${progress.total} lessons`;
  return desk > 0 && desk < progress.cleared ? `${base}, ${desk} at the desk` : base;
}

/** "12 days left", "Last day", "" once over. */
export function daysLine(n) {
  if (n <= 0) return '';
  if (n === 1) return 'Last day';
  return `${n} days left`;
}

/** "Nobody has finished yet" / "1 student finished" / "14 students finished" */
export function finishedLine(finished) {
  const n = finished?.finished || 0;
  if (n === 0) return 'Nobody has finished yet';
  return `${n} ${n === 1 ? 'student' : 'students'} finished`;
}

/** The first lesson not yet cleared, else the first not cleared at the desk. */
export function nextLesson(progress) {
  if (!progress) return null;
  return progress.lessons.find((l) => !l.cleared) || progress.lessons.find((l) => l.cleared !== 'desk') || null;
}

/** What the card says about the finish, if anything. */
export function finishLine(progress) {
  if (!progress?.finished) return '';
  if (progress.finishedAtDesk) return 'Finished at the desk.';
  return 'Finished. Clear the rest at the desk for the gold rim.';
}

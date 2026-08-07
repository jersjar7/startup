// Render a duration in seconds as "4h 38m" / "47m".
//
// Extracted from ExamResults so it can be tested directly. The results screen
// reports pacing (time used against the limit), and a wrong or crashing format
// here is the difference between a customer learning they ran out of time and
// seeing "NaNh 0m" on the report they paid for.
//
// Returns null rather than a string for anything non-numeric: attempts recorded
// before time was tracked have no timeUsedSeconds, and the caller hides the
// whole stat instead of rendering a placeholder.
export function formatDuration(seconds) {
  if (!Number.isFinite(seconds) || seconds < 0) return null;
  const totalMinutes = Math.round(seconds / 60);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
}

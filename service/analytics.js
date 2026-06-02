// Pure helpers for shaping daily analytics into continuous, zero-filled time
// series. Kept DB-free so the bucketing math is unit-testable on its own.

// Build an array of YYYY-MM-DD strings for the last `days` days ending at (and
// including) `endYmd`, in chronological order. Uses UTC calendar arithmetic on
// date-only values so daylight-saving shifts never drop or duplicate a day.
function dateAxis(endYmd, days) {
  const [y, m, d] = endYmd.split('-').map(Number);
  const end = Date.UTC(y, m - 1, d);
  const axis = [];
  for (let i = days - 1; i >= 0; i--) {
    const dt = new Date(end - i * 86400000);
    const ys = dt.getUTCFullYear();
    const ms = String(dt.getUTCMonth() + 1).padStart(2, '0');
    const ds = String(dt.getUTCDate()).padStart(2, '0');
    axis.push(`${ys}-${ms}-${ds}`);
  }
  return axis;
}

// Given rows like [{ day: 'YYYY-MM-DD', count: 3, ... }] and a date axis,
// return one numeric value per axis day for `key`, zero-filling missing days.
function seriesFor(rows, axis, key) {
  const byDay = new Map(rows.map((r) => [r.day, r]));
  return axis.map((day) => Number(byDay.get(day)?.[key] || 0));
}

// Running cumulative total of a per-day series, offset by a baseline (the total
// that accrued before the window started) so the final value is the true total.
function cumulative(series, baseline = 0) {
  let acc = baseline;
  return series.map((v) => (acc += v));
}

module.exports = { dateAxis, seriesFor, cumulative };

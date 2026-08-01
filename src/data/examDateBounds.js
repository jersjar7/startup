// Accepted range for an FE exam date, mirroring examDateBounds() in
// service/profile.js.
//
// The FE runs in continuous NCEES windows, so a real exam date is always within
// about a year. Two users had entered 2028 dates, which produced a 739-day
// outlier and made purchase-timing data unusable.
//
// A rolling window rather than fixed years, so it keeps working without anyone
// remembering to bump a constant. Kept in sync with the server by hand, the same
// way src/data/exam-bank mirrors service/examWeights.js — the server is
// authoritative and rejects anything outside this range regardless.
export function examDateBounds(now = new Date()) {
  const min = new Date(now.getTime());
  min.setUTCFullYear(min.getUTCFullYear() - 1);
  const max = new Date(now.getTime());
  max.setUTCFullYear(max.getUTCFullYear() + 1);
  return { min: min.toISOString().slice(0, 10), max: max.toISOString().slice(0, 10) };
}

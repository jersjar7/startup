// The student's own calendar day, YYYY-MM-DD, sent with every progress write
// so a study day is counted by the student's clock on every surface (the
// phone sends the same). The server falls back to its UTC day without it.
export function localDate(d = new Date()) {
  return d.toLocaleDateString('en-CA');
}

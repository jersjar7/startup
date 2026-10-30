// Whether an autosave the server answered (rather than one that never got
// through) should be sent again on the next tick. A 5xx is the server failing
// to store it ("Failed to save progress"), and a 408 or 429 is a passing
// condition, so all of those retry. A 4xx otherwise means the request itself
// can never succeed (no attempt, no access), and sending it every tick would
// change nothing.
export function shouldRetrySave(status) {
  return status >= 500 || status === 408 || status === 429;
}

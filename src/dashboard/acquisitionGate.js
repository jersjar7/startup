// Decides whether the dashboard may ask "how did you find us?".
//
// The rule is one sentence: ask until resolved, never after.
//
// Registration (src/login/login.jsx) is the primary ask, since it is the one
// point every new user passes through. The dashboard is the safety net for
// anyone who slipped past it — someone who closed the tab mid-signup, or who
// registered before the question existed at all.
//
// "Resolved" is server-side (service/acquisition.js): the user answered, or
// explicitly dismissed. It is NOT a localStorage flag, so it holds across
// devices, browser profiles, and cleared site data. That is what stops the
// same person being asked twice.
//
// `acquisitionResolved` must be an explicit `false` to trigger the ask. While
// /me is still loading it is undefined, and the component defaults it to true,
// so a slow or failed request shows nothing rather than risking a duplicate.
export function shouldAskSource({ acquisitionResolved } = {}) {
  return acquisitionResolved === false;
}

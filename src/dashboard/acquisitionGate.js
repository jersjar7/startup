// Decides whether the dashboard may ask "how did you find us?".
//
// The question is asked at REGISTRATION for everyone from 2026-07-30 onward
// (src/login/login.jsx). The dashboard ask is a one-time backfill for accounts
// created before that, which never got the chance.
//
// Two independent conditions, both required, so no user can be asked twice:
//   1. Not already resolved (answered or dismissed) — server-side truth, so it
//      holds across devices, browser profiles and cleared site data.
//   2. Created before the cutoff — anyone newer was already asked at sign-up.
//
// `acquisitionResolved` is treated as resolved when missing or not-yet-loaded,
// so a slow or failed /me shows nothing rather than risking a duplicate ask.
export const ACQ_BACKFILL_CUTOFF = Date.parse('2026-07-30T00:00:00Z');

export function shouldAskSource({ acquisitionResolved, createdAt } = {}, cutoff = ACQ_BACKFILL_CUTOFF) {
  if (acquisitionResolved !== false) return false;
  if (!createdAt) return false;
  const created = Date.parse(createdAt);
  if (Number.isNaN(created)) return false;
  return created < cutoff;
}

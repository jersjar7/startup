// Single source of truth for "is this user done with the attribution question?"
//
// Used by GET /api/user/me (to tell the client whether to ask) and by
// POST /api/user/acquisition (to make answering and dismissing idempotent).
// Kept in one place so the two can never disagree and ask somebody twice.
//
// Resolved means EITHER:
//   - they answered (acquisition.source is set), or
//   - they explicitly dismissed the prompt (acquisition.dismissedAt is set)
//
// Deliberately server-side: a localStorage flag is per-device, so the same
// person would be asked again on their phone, in another browser profile, or
// after clearing site data.
function isAcquisitionResolved(user) {
  const acq = user && user.acquisition;
  if (!acq) return false;
  return Boolean(acq.source || acq.dismissedAt);
}

module.exports = { isAcquisitionResolved };

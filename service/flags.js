// Feature flags for the staged study-load rollout (see
// docs/mobile/study-load-implementation-plan.md).
//
// Default OFF everywhere: Stage 1 computes the new plan and LOGS it alongside
// the old one ("compute-dark") while still serving today's behavior. Stage 2
// flips these on — and will grow per-user ramp logic here so existing users are
// grandfathered over 5–7 days rather than jumped overnight.

function envOn(name, def = false) {
  const v = process.env[name];
  if (v == null) return def;
  return v === '1' || v.toLowerCase() === 'true';
}

module.exports = {
  // Serve the shared 3-grade SM-2 intervals on web (vs the legacy binary model).
  schedulerV2: () => envOn('SCHEDULER_V2'),
  // Serve the exam-aware review target (vs the flat 5/8).
  studyLoadV2: () => envOn('STUDY_LOAD_V2'),
  // Emit [sched-dark] / [load-dark] comparison logs while computing dark.
  darkLog: () => envOn('SCHEDULER_DARK_LOG', true),
};

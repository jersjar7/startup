// How long the exam outcome ask jumps the queue.
//
// The first batch after switching the ask on sent four of a 65-person backlog,
// because it sits last in the morning order and countdowns and win-backs had
// already spent the day's headroom on the free Resend tier. Sixteen days to
// drain is too slow for a question whose entire value is catching somebody
// before they stop opening anything from us, and the first ask is the one most
// likely to be answered.
//
// So for two weeks it goes ahead of countdowns, digests and win-backs. Those
// are worth less than asking somebody who has just sat the exam.
//
// Temporary by construction. A flag someone has to remember to turn off is a
// flag that stays on for a year, so this expires on a date instead.

/// When the usual order comes back. Set when the change was made, not computed
/// at boot: a restart must not extend it.
const OUTCOME_PRIORITY_UNTIL = '2026-10-21';

/// Whether the ask is still jumping the queue.
function outcomePriorityActive(now = new Date(), until = OUTCOME_PRIORITY_UNTIL) {
  const day = now.toISOString().slice(0, 10);
  return day < until;
}

module.exports = { OUTCOME_PRIORITY_UNTIL, outcomePriorityActive };

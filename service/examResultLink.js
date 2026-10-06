// What a tap from the outcome email means.
//
// Pulled out of the route so it can be tested without a database, the same way
// school.js and analyticsWindow.js are. The route is glue: read the token, call
// these, render a page.
//
// Why a tokenised GET at all. Requiring a sign in would lose most of the
// replies, and non-response here is not random: somebody who failed is less
// likely to come back and log in to say so, which is precisely the bias the
// whole question exists to measure. One tap, no account, no friction.
//
// The token is a capability: unguessable, per user, and deliberately separate
// from the unsubscribe token so an unsubscribe link that leaks cannot also
// write an exam result.

const { isAnswered } = require('./examOutcome.js');

/// The three answers the email offers. A no-show is recorded as having no
/// result rather than as a failure: storing passed:false against somebody who
/// never sat the exam would make every pass rate computed from this wrong.
const ANSWERS = {
  passed: { sat: true, passed: true },
  failed: { sat: true, passed: false },
  missed: { sat: false, passed: null },
};

function parseAnswer(a) {
  return ANSWERS[String(a || '').toLowerCase()] || null;
}

/// The update to apply, or null when there is nothing valid to write.
///
/// Returns the same shape the in-app answer writes, so a result recorded from
/// an email and one recorded from the phone are indistinguishable afterwards
/// apart from `via`.
function outcomeUpdate(a, { examDate = null, now = new Date() } = {}) {
  const choice = parseAnswer(a);
  if (!choice) return null;
  return {
    'examOutcome.sat': choice.sat,
    'examOutcome.passed': choice.passed,
    // Always cleared: the attempt number is a separate, optional second tap,
    // and a re-answer must not inherit a number from a previous one.
    'examOutcome.attemptNumber': null,
    'examOutcome.examDateAtAnswer': examDate,
    'examOutcome.answeredAt': now,
    'examOutcome.via': 'email',
  };
}

/// Whether this tap should write anything.
///
/// Mail clients follow links to build previews, and people tap twice. Neither
/// may overwrite a real answer.
function shouldRecord(user, a) {
  if (!user) return false;
  if (!parseAnswer(a)) return false;
  return !isAnswered(user);
}

/// The optional follow-up. Never required, and it can never change the result.
function validAttempt(n) {
  const v = Number(n);
  if (!Number.isInteger(v) || v < 1 || v > 20) return null;
  return v;
}

/// What the thank-you page should say. Pure so the wording is testable, and
/// because getting it wrong matters: somebody who failed is reading this.
function resultCopy(a, { already = false } = {}) {
  const choice = parseAnswer(a);
  if (!choice) return null;
  if (already) {
    return {
      heading: 'Already noted',
      msg: 'We had your answer already. Nothing more to do.',
      offerAttempt: false,
    };
  }
  if (!choice.sat) {
    return {
      heading: 'Thank you for telling us',
      msg: 'That is recorded. Your account is here whenever you want it.',
      offerAttempt: false,
    };
  }
  return {
    heading: choice.passed ? 'Congratulations' : 'Thank you for telling us',
    msg: 'That is recorded. It genuinely helps the people sitting it after you.',
    offerAttempt: true,
  };
}

module.exports = {
  ANSWERS,
  parseAnswer,
  outcomeUpdate,
  shouldRecord,
  validAttempt,
  resultCopy,
};

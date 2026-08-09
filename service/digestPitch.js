// Who gets the exam-simulation footer in the weekly digest.
//
// Two rules, both of which exist to keep the pitch honest rather than to be
// cautious:
//
// 1. NEVER to somebody who already owns it. Selling a customer the thing they
//    already paid for reads as a company that does not know who they are, and
//    it inflates the denominator of the one rate worth watching.
//
// 2. Only in the ACTIVE digest. The digest has two branches: a week-in-review
//    for people who studied, and a restart nudge for people who logged nothing.
//    The growth plan's stated reason for this placement is "free placement in
//    front of your most engaged segment", and the inactive branch is by
//    definition the opposite of that. Its job is to get somebody back to five
//    minutes of study; appending a $49 offer to it works against that and reads
//    badly to a person who just had a bad week.
//
// This is deliberately NOT the dashboard banner's gate (ADR-0004). That gate
// weighs exam proximity and problems answered to decide whether an interruption
// is earned. A footer under an email the user already opted into is a much
// smaller ask, so requiring an exam date here would suppress it for the ~73% of
// users who have none, for no gain.
function shouldPitchSimInDigest({ active = false, hasPurchased = false } = {}) {
  if (hasPurchased) return false;
  return active === true;
}

module.exports = { shouldPitchSimInDigest };

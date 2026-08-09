// Authoritative pricing for the exam-simulation full-access pass.
// Student (.edu / academic email) vs. standard. Amounts in cents so they can
// be passed straight to Stripe as inline price_data (no pre-created Price IDs).
// Keep dollar amounts in sync with src/data/pricing.js (display).

const STUDENT_CENTS = Number(process.env.PRICE_STUDENT_CENTS) || 3500; // $35
const STANDARD_CENTS = Number(process.env.PRICE_STANDARD_CENTS) || 4900; // $49

// Amounts we have actually charged in the past, so historical purchases keep
// reporting the tier they were sold at. Without this, raising the student price
// silently reclassified every $29 sale as 'unknown' and the admin tier
// breakdown — the input to average order value — lost half its rows.
// Never remove an entry: it is a record of what a real customer paid.
const LEGACY_TIER_CENTS = {
  2900: 'student',   // student price until 2026-08-10
  4900: 'standard',
};

// Matches .edu, .edu.xx, .ac.xx (covers US + common international academic domains).
const ACADEMIC_RE = /\.(edu|edu\.[a-z]{2}|ac\.[a-z]{2})$/i;

function isStudentEmail(email) {
  return !!email && ACADEMIC_RE.test(String(email).trim());
}

function priceCentsForEmail(email) {
  return isStudentEmail(email) ? STUDENT_CENTS : STANDARD_CENTS;
}

// Anti-fraud gate for the student price. A raw .edu STRING never qualifies on
// its own — anyone could type one. The student price applies only when the user
// has proven control of an academic inbox:
//   1. studentVerified === true  (verified a .edu via an emailed code), or
//   2. their ACCOUNT email is academic AND that email is verified.
function qualifiesForStudent(user) {
  if (!user) return false;
  if (user.studentVerified === true) return true;
  if (isStudentEmail(user.email) && user.emailVerified === true) return true;
  return false;
}

function priceCentsForUser(user) {
  return qualifiesForStudent(user) ? STUDENT_CENTS : STANDARD_CENTS;
}

// Map a paid amount (cents) back to its tier. Fallback for purchases whose
// Stripe session metadata didn't carry an explicit tier.
function tierForCents(cents) {
  if (cents === STUDENT_CENTS) return 'student';
  if (cents === STANDARD_CENTS) return 'standard';
  return LEGACY_TIER_CENTS[cents] || 'unknown';
}

module.exports = {
  isStudentEmail,
  priceCentsForEmail,
  qualifiesForStudent,
  priceCentsForUser,
  tierForCents,
  STUDENT_CENTS,
  STANDARD_CENTS,
};

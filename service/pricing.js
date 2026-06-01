// Authoritative pricing for the exam-simulation full-access pass.
// Student (.edu / academic email) vs. standard. Amounts in cents so they can
// be passed straight to Stripe as inline price_data (no pre-created Price IDs).
// Keep dollar amounts in sync with src/data/pricing.js (display).

const STUDENT_CENTS = Number(process.env.PRICE_STUDENT_CENTS) || 2900; // $29
const STANDARD_CENTS = Number(process.env.PRICE_STANDARD_CENTS) || 4900; // $49

// Matches .edu, .edu.xx, .ac.xx (covers US + common international academic domains).
const ACADEMIC_RE = /\.(edu|edu\.[a-z]{2}|ac\.[a-z]{2})$/i;

function isStudentEmail(email) {
  return !!email && ACADEMIC_RE.test(String(email).trim());
}

function priceCentsForEmail(email) {
  return isStudentEmail(email) ? STUDENT_CENTS : STANDARD_CENTS;
}

module.exports = { isStudentEmail, priceCentsForEmail, STUDENT_CENTS, STANDARD_CENTS };

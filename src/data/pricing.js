// Pricing — single source of truth for DISPLAY.
// The server (service/pricing.js + service/routes/checkout.js) is authoritative
// for the actual charge; keep these dollar amounts in sync with the cents there.

export const STUDENT_PRICE = 35;
export const STANDARD_PRICE = 49;

// Students verify with a .edu (or common academic) email. They lose it after
// graduating, so it's a natural, low-friction proof of "currently a student".
const ACADEMIC_RE = /\.(edu|edu\.[a-z]{2}|ac\.[a-z]{2})$/i;

export function isStudentEmail(email) {
  return !!email && ACADEMIC_RE.test(String(email).trim());
}

export function priceForEmail(email) {
  return isStudentEmail(email) ? STUDENT_PRICE : STANDARD_PRICE;
}
